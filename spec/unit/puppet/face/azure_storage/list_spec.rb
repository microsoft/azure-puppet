#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_storage, :current] do
  let(:storage_service) { Azure::StorageManagementService }
  let(:storage_account_obj) do
    Azure::StorageManagement::StorageAccount.new do |sa|
      sa.name = 'cs-1'
      sa.location = 'West US'
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
      storage_service.any_instance.stubs(
        :list_storage_accounts
      ).returns([storage_account_obj])
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.list(@options) }.to_not raise_error
      end

      it 'should print storage account details' do
        cs_services = subject.list(@options)
        name = "#{'Name'.fix(20)}: #{storage_account_obj.name}"
        location = "#{'Locaton'.fix(20)}: #{storage_account_obj.location}"
        expect(cs_services).to match(/#{name}/)
        expect(cs_services).to match(/#{location}/)
      end
    end

    it_behaves_like 'validate authentication credential', :list

  end
end
