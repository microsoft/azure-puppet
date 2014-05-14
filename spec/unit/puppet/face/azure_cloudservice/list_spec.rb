#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_cloudservice, :current] do
  let(:cloud_service) { Azure::CloudServiceManagementService }
  let(:cloud_service_obj) do
    Azure::CloudServiceManagement::CloudService.new do |cs|
      cs.name = 'cs-1'
      cs.location = 'West US'
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

    before :each do
      cloud_service.any_instance.stubs(
        :list_cloud_services
      ).returns([cloud_service_obj])
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.list(@options) }.to_not raise_error
      end

      it 'should print affinity groups details' do
        cs_services = subject.list(@options)
        name = "#{'Name'.fix(20)}: #{cloud_service_obj.name}"
        location = "#{'Locaton'.fix(20)}: #{cloud_service_obj.location}"
        expect(cs_services).to match(/#{name}/)
        expect(cs_services).to match(/#{location}/)
      end
    end

    it_behaves_like 'validate authentication credential', :list

  end
end
