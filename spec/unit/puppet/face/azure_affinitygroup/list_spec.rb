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
      azure_subscription_id: 'Subscription-id'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      base_service.any_instance.stubs(
        :list_affinity_groups
      ).returns([affinity_group])
    end
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.list(@options) }.to_not raise_error
      end

      it 'should print affinity groups details' do
        affinity_groups = subject.list(@options)
        name = "#{'Name'.fix(20)}: #{affinity_group.name}"
        expect(affinity_groups).to match(/#{name}/)
        label = "#{'Label'.fix(20)}: #{affinity_group.label}"
        expect(affinity_groups).to match(/#{label}/)
        capability = "#{'Capability'.fix(20)}: #{affinity_group.capability}"
        expect(affinity_groups).to match(/#{capability}/)
      end
    end

    it_behaves_like 'validate authentication credential', :list

  end
end
