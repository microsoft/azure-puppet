require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:base_service) { Azure::BaseManagementService }
  let(:location) do
    Location.new do |loc|
      loc.name = 'West US'
      loc.available_services = 'Compute, Storage, PersistentVMRole, HighMemory'
    end
  end
  
  before :each do
    @options = {
      management_certificate: File.expand_path('spec/fixtures/management_certificate.pem'),
      azure_subscription_id: 'Subscription-id'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      base_service.any_instance.stubs(:list_locations).returns([location])
    end
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.locations(@options) }.to_not raise_error
      end
    end

    describe '(azure_subscription_id)' do
      it 'should require a azure_subscription_id' do
        @options.delete(:azure_subscription_id)
        expect { subject.locations(@options) }.to raise_error ArgumentError, /required: azure_subscription_id/
      end
    end

    describe '(management_certificate)' do
      it 'should require a management_certificate' do
        @options.delete(:management_certificate)
        expect { subject.locations(@options) }.to raise_error ArgumentError, /required: management_certificate/
      end

      it 'management_certificate doesn\'t  exist' do
        @options[:management_certificate] = 'FileNotExist'
        expect { subject.locations(@options) }.to raise_error ArgumentError, /Could not find file 'FileNotExist'/
      end

      it 'management_certificate extension is not valid' do
        @options[:management_certificate] = File.expand_path('spec/fixtures/invalid_file.txt')
        expect { subject.locations(@options) }.to raise_error RuntimeError, /Management certificate expects a .pem or .pfx file/
      end
    end
  end
end
