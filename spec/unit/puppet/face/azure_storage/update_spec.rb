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
      location: 'west us',
      description: 'Some description',
      label: 'label',
      affinity_group_name: 'ag-1',
      extended_properties: 'key-1:value1,key-2:value2'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    storage_service.any_instance.stubs(
      :update_storage_account
    ).with(anything, anything)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.update(@options) }.to_not raise_error
      end
    end

    describe '(storage_account_name)' do
      it 'should validate storage account name' do
        @options.delete(:storage_account_name)
        expect { subject.update(@options) }.to raise_error(
          ArgumentError,
          /required: storage_account_name/
        )
      end
    end

    describe '(location)' do
      it 'should not raise any exception when only location is given' do
        @options.delete(:affinity_group_name)
        expect { subject.update(@options) }.to_not raise_error
      end

      it 'should not raise any exception when only affinity group is given' do
        @options.delete(:location)
        expect { subject.update(@options) }.to_not raise_error
      end
    end

    describe '(description)' do
      it 'should validate the cloud service description' do
        @options.delete(:description)
        expect { subject.update(@options) }.to_not raise_error
      end
    end

    describe '(label)' do
      it 'should validate the cloud service label' do
        @options.delete(:label)
        expect { subject.update(@options) }.to_not raise_error
      end
    end

    describe '(extended_properties)' do
      it 'should validate the cloud service extended_properties' do
        @options.delete(:extended_properties)
        expect { subject.update(@options) }.to_not raise_error
      end
    end

    it_behaves_like 'validate authentication credential', :update

  end
end
