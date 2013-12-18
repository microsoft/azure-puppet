require 'spec_helper'
require 'puppet/virtual_machine'

describe Puppet::Face[:azure_vm, :current] do
  before :all do
    #$stdout.stubs(:write)
  end
  let(:image_name) {'azure-linux-image'}
  let(:os_type) {'Windows'}
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
    image = VirtualMachineImage.new
    image.os_type = os_type
    image.name = image_name
    image
  }

  describe 'option validation' do

    describe 'valid options' do
      $stdout.stubs(:write)
      before :each do
        Azure::VirtualMachineImageManagementService.any_instance.expects(:list_virtual_machine_images).returns([image]).at_least(0)
        virtual_machine_obj = Azure::VirtualMachineManagement::VirtualMachine.new do |virtual_machine|
          virtual_machine.vm_name = 'windows-instance'
          virtual_machine.ipaddress = '192.168.1.1'
          virtual_machine.os_type = os_type
        end        
        Azure::VirtualMachineManagementService.any_instance.stubs(:create_virtual_machine).with(anything, anything).returns(virtual_machine_obj)
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
      it 'should validate the azure_subscription_id' do
        @options.delete(:azure_subscription_id)
        expect { subject.create(@options) }.to raise_error ArgumentError, /required/
      end
    end

  end

end