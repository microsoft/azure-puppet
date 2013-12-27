# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_affinitygroup, :current] do
  let(:base_service) { Azure::BaseManagementService }
  let(:affinity_group) do
    Azure::BaseManagement::AffinityGroup.new do |ag|
      ag.name = 'AG1'
      ag.label = 'Label'
      ag.description = 'Description'
      ag.capability = %w(PersistentVMRole HighMemory)
    end
  end

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id',
      affinity_group_name: 'ag-name'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      base_service.any_instance.stubs(:delete_affinity_group)
    end
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.delete(@options) }.to_not raise_error
      end
    end

    describe '(affinity_group_name)' do
      it 'should validate the affinity group name' do
        @options.delete(:affinity_group_name)
        expect { subject.delete(@options) }.to raise_error(
          ArgumentError,
          /required: affinity_group_name/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :delete
  end
end
