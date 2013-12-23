require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:image_name) { 'azure-linux-image' }
  let(:os_type) { 'Windows' }
  let(:image_service) { Azure::VirtualMachineImageManagementService }
  let(:vm_service) { Azure::VirtualMachineManagementService }
  let(:vm) { Azure::VirtualMachineManagement::VirtualMachine }
  let(:virtual_machine_obj) do
    vm.new do |virtual_machine|
      virtual_machine.vm_name = 'windows-instance'
      virtual_machine.ipaddress = '192.168.1.1'
      virtual_machine.os_type = os_type
    end
  end
  let(:image) do
    VirtualMachineImage.new do |image|
      image.os_type = os_type
      image.name = image_name
    end
  end

  before :each do
    $stdout.stubs(:write)
    @options = {
      management_certificate: File.expand_path('spec/fixtures/management_certificate.pem'),
      azure_subscription_id: 'Subscription-id',
      vm_name: 'test-vm',
      vm_user: 'vm_user',
      image: image_name,
      password: 'ComplexPassword123',
      location: 'West us',
      ssh_port: 22,
      affinity_group_name: 'ag',
      certificate_file: File.expand_path('spec/fixtures/certificate.pem'),
      private_key_file: File.expand_path('spec/fixtures/private_key.key'),
      cloud_service_name: 'cloud-name',
      deployment_name: 'deployment-name',
      management_endpoint: 'management.core.windows.net',
      puppet_master_ip: '127.0.0.1',
      storage_account_name: 'storage_account',
      tcp_endpoints: '80:80',
      virtual_network_name: 'vnet',
      virtual_network_subnet: 'Subnet-1',
      winrm_transport: 'http',
      vm_size: 'Small'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vm_service.any_instance.stubs(:create_virtual_machine).with(anything, anything).returns(virtual_machine_obj)
    image_service.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
  end

  describe 'option validation' do

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(image)' do
      it 'should require a image' do
        @options.delete(:image)
        expect { subject.create(@options) }.to raise_error Exception, /required: image/
      end

      it 'should validate the image' do
        @options[:image] = 'WrongImageName'
        expect { subject.create(@options) }.to raise_error ArgumentError, /Source image name is invalid/
      end
    end

    describe '(vm_name)' do
      it 'should validate the vm name' do
        @options.delete(:vm_name)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required: vm_name/
      end
    end

    describe '(location)' do
      it 'should require a location' do
        @options.delete(:location)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required: location/
      end
    end

    describe '(azure_subscription_id)' do
      it 'should require a azure_subscription_id' do
        @options.delete(:azure_subscription_id)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required: azure_subscription_id/
      end
    end

    describe '(management_certificate)' do
      it 'should require a management_certificate' do
        @options.delete(:management_certificate)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required: management_certificate/
      end

      it 'management_certificate doesn\'t  exist' do
        @options[:management_certificate] = 'FileNotExist'
        expect { subject.create(@options) }.to raise_error ArgumentError, /Could not find file 'FileNotExist'/
      end

      it 'management_certificate extension is not valid' do
        @options[:management_certificate] = File.expand_path('spec/fixtures/invalid_file.txt')
        expect { subject.create(@options) }.to raise_error RuntimeError, /Management certificate expects a .pem or .pfx file/
      end
    end

    describe '(vm_user)' do
      it 'should require a vm user' do
        @options.delete(:vm_user)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required: vm_user/
      end
    end
  end

  describe 'optional parameter validation' do

    describe '(vm_size)' do
      it 'vm_size should be optional' do
        @options.delete(:vm_size)
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'should validate the vm_size' do
        @options[:vm_size] = 'InvalidSize'
        expect { subject.create(@options) }.to raise_error ArgumentError, /The vm-size is not valid/
      end
    end

    describe '(winrm_transport)' do
      it 'winrm_transport should be optional' do
        @options.delete(:winrm_transport)
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'should validate the winrm_transport' do
        @options[:winrm_transport] = 'ftp'
        expect { subject.create(@options) }.to raise_error ArgumentError, /The winrm transport is not valid/
      end

      it 'should validate the winrm_transport' do
        @options[:winrm_transport] = 'http'
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'should validate the winrm_transport' do
        @options[:winrm_transport] = 'https,http'
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(virtual_network_subnet)' do
      it 'virtual_network_subnet should be optional' do
        @options.delete(:virtual_network_subnet)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(virtual_network_name)' do
      it 'virtual_network_name should be optional' do
        @options.delete(:virtual_network_name)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(tcp_endpoints)' do
      it 'tcp_endpoints should be optional' do
        @options.delete(:tcp_endpoints)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(ssh_port)' do
      it 'ssh_port should be optional' do
        @options.delete(:ssh_port)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(affinity_group_name)' do
      it 'affinity_group_name should be optional' do
        @options.delete(:affinity_group_name)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(certificate_file)' do
      it 'certificate_file should be optional' do
        @options.delete(:certificate_file)
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'certificate_file should exist' do
        @options[:certificate_file] = 'FileNotExist'
        expect { subject.create(@options) }.to raise_error ArgumentError, /Could not find file 'FileNotExist'/
      end
    end

    describe '(private_key_file)' do
      it 'private_key_file should be optional' do
        @options.delete(:private_key_file)
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'private_key_file should exist' do
        @options[:private_key_file] = 'FileNotExist'
        expect { subject.create(@options) }.to raise_error ArgumentError, /Could not find file 'FileNotExist'/
      end
    end

    describe '(cloud_service_name)' do
      it 'cloud_service_name should be optional' do
        @options.delete(:cloud_service_name)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(deployment_name)' do
      it 'deployment_name should be optional' do
        @options.delete(:deployment_name)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '( management_endpoint)' do
      it ' management_endpoint should be optional' do
        @options.delete(:management_endpoint)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(puppet_master_ip)' do
      it 'puppet_master_ip should be optional' do
        @options.delete(:puppet_master_ip)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(storage_account_name)' do
      it 'storage_account_name should be optional' do
        @options.delete(:storage_account_name)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

  end

  describe '(Password)' do

    describe '(password prompt for windows)' do
      before :each do
        image.os_type = 'Windows'
        image_service.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
        @count = 0
        @prompt_msg = nil
        HighLine.any_instance.stubs(:ask).with(anything) do |msg|
          @prompt_msg = msg
          @count += 1
        end
      end

      it 'should ask for password if password options is empty' do
        @options.delete(:password)
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(1)
        expect(@prompt_msg).to match(/PASSWORD?/)
      end

      it 'should prompt for password if password is weak.' do
        @options[:password] = 'weakpassword'
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(1)
        expect(@prompt_msg).to match(/PASSWORD?/)
      end

      it 'should not prompt for password if password is complex.' do
        @options[:password] = 'ComplexPassword$123'
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(0)
      end
    end

    describe 'password prompt for linux' do
      before :each do
        image.os_type = 'Linux'
        image_service.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
        @options.delete(:puppet_master_ip)
        @count = 0
        @prompt_msg = nil
        HighLine.any_instance.stubs(:ask).with(anything) do |msg|
          @prompt_msg = msg
          @count += 1
          @count == 1 ? 'y' : 'ComplexPassword123'   # TODO: Fix Input to IOStream
        end
      end

      it 'should prompt enable password message if options password is empty and ssh certificate is provided.' do
        @options.delete(:password)
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(1)
        expect(@prompt_msg).to match(/Do you want to enable password authentication/)
      end

      it 'should ask for password if password and ssh certificate options is empty' do
        @options.delete(:password)
        @options.delete(:certificate_file)
        @options.delete(:private_key_file)
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(1)
        expect(@prompt_msg).to match(/PASSWORD?/)
      end

      it 'should prompt for password if password is weak and ssh certificate is given.' do
        @options.delete(:certificate_file)
        @options.delete(:private_key_file)
        @options[:password] = 'weakpassword'
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(1)
        expect(@prompt_msg).to match(/PASSWORD?/)
      end

      it 'should not prompt for password if password is complex.' do
        @options[:password] = 'ComplexPassword$123'
        @options.delete(:certificate_file)
        @options.delete(:private_key_file)
        expect { subject.create(@options) }.to_not raise_error
        expect(@count).to eq(0)
      end
    end
  end

end