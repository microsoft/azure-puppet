require 'spec_helper'
require 'puppet/virtual_machine'

describe Puppet::Face[:azure_vm, :current] do
  before :all do
    #$stdout.stubs(:write)
  end
  let(:image_name) { 'azure-linux-image' }
  let(:os_type) { 'Windows' }
  let(:image_service) { Azure::VirtualMachineImageManagementService }
  let(:vm_service) { Azure::VirtualMachineManagementService }
  before :each do
    @options = {
      :management_certificate => File.expand_path("spec/fixtures/management_certificate.pem"),
      :azure_subscription_id => 'Subscription-id',
      :vm_name=> 'test-vm',
      :vm_user=> 'vm_user',
      :image => image_name,
      :password => 'ComplexPassword123',
      :location => 'West us',
      :ssh_port => 22,      
      :affinity_group_name => 'ag',
      :certificate_file => File.expand_path("spec/fixtures/certificate.pem"),
      :private_key_file => File.expand_path("spec/fixtures/private_key.key"),
      :cloud_service_name => 'cloud-name',
      :deployment_name => 'deployment-name',      
      :management_endpoint => 'management.core.windows.net',      
      :puppet_master_ip => '127.0.0.1',
      :storage_account_name => 'storage_account',
      :tcp_endpoints => '80:80',
      :virtual_network_name => 'vnet',
      :virtual_network_subnet => 'Subnet-1',
      :winrm_transport => 'http',
      :vm_size => 'Small'
    }
  end 
  let(:image){
    image = VirtualMachineImage.new do |image|
      image.os_type = os_type
      image.name = image_name
    end
  }

  describe 'option validation' do

    describe 'valid options' do
      $stdout.stubs(:write)
      before :each do
        image_service.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
        virtual_machine_obj = Azure::VirtualMachineManagement::VirtualMachine.new do |virtual_machine|
          virtual_machine.vm_name = 'windows-instance'
          virtual_machine.ipaddress = '192.168.1.1'
          virtual_machine.os_type = os_type
        end        
        vm_service.any_instance.stubs(:create_virtual_machine).with(anything, anything).returns(virtual_machine_obj)
      end

      it 'should not raise any exception' do
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(image)' do
      it 'should require a image' do
        @options.delete(:image)
        expect { subject.create(@options) }.to raise_error Exception, /required/
      end
    end

    describe '(vm_name)' do
      it 'should validate the vm name' do
        @options.delete(:vm_name)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required/
      end
    end

    describe '(location)' do
      it 'should require a location' do
        @options.delete(:location)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required/
      end
    end

    describe '(azure_subscription_id)' do
      it 'should require a azure_subscription_id' do
        @options.delete(:azure_subscription_id)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required/
      end
    end

    describe '(management_certificate)' do
      it 'should require a management_certificate' do
        @options.delete(:management_certificate)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required/
      end
    end

    describe '(vm_user)' do
      before :each do
        image_service.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
      end

      it 'should require a management_certificate' do
        @options.delete(:vm_user)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required/
      end
    end
  end
  
  describe 'optional parameter validation' do
    before :each do
      $stdout.stubs(:write)
      image_service.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
      virtual_machine_obj = Azure::VirtualMachineManagement::VirtualMachine.new do |virtual_machine|
        virtual_machine.vm_name = 'windows-instance'
        virtual_machine.ipaddress = '192.168.1.1'
        virtual_machine.os_type = os_type
      end
      vm_service.any_instance.stubs(:create_virtual_machine).with(anything, anything).returns(virtual_machine_obj)
    end

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
  end

end
