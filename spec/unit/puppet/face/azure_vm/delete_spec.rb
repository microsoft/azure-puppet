require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:vm_service) { Azure::VirtualMachineManagementService }

  before :each do
    @options = {
      management_certificate: File.expand_path('spec/fixtures/management_certificate.pem'),
      azure_subscription_id: 'Subscription-id',
      vm_name: 'test-vm',
      cloud_service_name: 'cloud-name'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vm_service.any_instance.stubs(:delete_virtual_machine).with(anything, anything)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.delete(@options) }.to_not raise_error
      end
    end

    describe '(vm_name)' do
      it 'should validate the vm name' do
        @options.delete(:vm_name)
        expect { subject.delete(@options) }.to raise_error ArgumentError, /required: vm_name/
      end
    end

    describe '(cloud_service_name)' do
      it 'cloud_service_name should be optional' do
        @options.delete(:cloud_service_name)
        expect { subject.delete(@options) }.to raise_error ArgumentError, /required: cloud_service_name/
      end
    end

    describe '(azure_subscription_id)' do
      it 'should require a azure_subscription_id' do
        @options.delete(:azure_subscription_id)
        expect { subject.delete(@options) }.to raise_error ArgumentError, /required: azure_subscription_id/
      end
    end

    describe '(management_certificate)' do
      it 'should require a management_certificate' do
        @options.delete(:management_certificate)
        expect { subject.delete(@options) }.to raise_error ArgumentError, /required: management_certificate/
      end

      it 'management_certificate doesn\'t  exist' do
        @options[:management_certificate] = 'FileNotExist'
        expect { subject.delete(@options) }.to raise_error ArgumentError, /Could not find file 'FileNotExist'/
      end

      it 'management_certificate extension is not valid' do
        @options[:management_certificate] = File.expand_path('spec/fixtures/invalid_file.txt')
        expect { subject.delete(@options) }.to raise_error RuntimeError, /Management certificate expects a .pem or .pfx file/
      end
    end
  end
end
