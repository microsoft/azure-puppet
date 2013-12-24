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
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do

    describe 'valid options' do
      before :each do
        base_service.any_instance.stubs(:list_locations).returns([location])
      end

      it 'should not raise any exception' do
        expect { subject.locations(@options) }.to_not raise_error
      end
    end

    it_behaves_like 'validate authentication credential', :locations
  end
end
