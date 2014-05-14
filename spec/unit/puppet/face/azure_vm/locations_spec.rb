#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:base_service) { Azure::BaseManagementService }
  let(:location_name) { 'West US' }
  let(:loc_services) { 'Compute, Storage, PersistentVMRole, HighMemory' }
  let(:location) do
    Location.new do |loc|
      loc.name = location_name
      loc.available_services = loc_services
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
      base_service.any_instance.stubs(:list_locations).returns([location])
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.locations(@options) }.to_not raise_error
      end

      it 'should print locations details' do
        locations = subject.locations(@options)
        expect(locations).to match(/#{location_name.fix}      #{loc_services}/)
      end
    end

    it_behaves_like 'validate authentication credential', :locations
  end
end
