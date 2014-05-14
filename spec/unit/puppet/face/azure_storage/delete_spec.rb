#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_storage, :current] do
  let(:storage_service) { Azure::StorageManagementService }

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      storage_account_name: 'storage-account',
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    storage_service.any_instance.stubs(:delete_storage_account).with(anything)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.delete(@options) }.to_not raise_error
      end
    end

    describe '(storage_account_name)' do
      it 'should validate storage account name' do
        @options.delete(:storage_account_name)
        expect { subject.delete(@options) }.to raise_error(
          ArgumentError,
          /required: storage_account_name/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :delete

  end
end
