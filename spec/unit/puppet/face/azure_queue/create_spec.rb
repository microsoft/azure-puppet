#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'spec_helper'
describe Puppet::Face[:azure_queue, :current] do
  let(:queue_service) { Azure::QueueService }

  before :each do

    @options = {
      storage_account_name:  'storage-account',
      storage_access_key: 'nD/E49P4SJG8UVEpABOeZRc=',
      queue_name: 'queue'
    }

    Azure.configure do |config|
      config.storage_account_name  = @options[:storage_account_name]
      config.storage_access_key = @options[:storage_access_key]
    end

    queue_service.any_instance.stubs(:create_queue).with(any_parameters)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(queue_name)' do
      it 'should validate queue name' do
        @options.delete(:queue_name)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: queue_name/
        )
      end
    end

    describe '(storage_access_key)' do
      it 'should validate service bus access key' do
        @options.delete(:storage_access_key)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: storage_access_key/
        )
      end
    end

    describe '(storage_account_name)' do
      it 'should validate storage account name' do
        @options.delete(:storage_account_name)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: storage_account_name/
        )
      end
    end

  end
end
