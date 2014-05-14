#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_cloudservice, :current] do
  let(:cloud_service) { Azure::CloudServiceManagementService }

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      cloud_service_name: 'cloud-name'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    cloud_service.any_instance.stubs(:delete_cloud_service).with(anything)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.delete(@options) }.to_not raise_error
      end
    end

    describe '(cloud_service_name)' do
      it 'should validate cloud service name' do
        @options.delete(:cloud_service_name)
        expect { subject.delete(@options) }.to raise_error(
          ArgumentError,
          /required: cloud_service_name/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :delete

  end
end
