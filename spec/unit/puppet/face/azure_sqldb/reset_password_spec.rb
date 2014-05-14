#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_sqldb, :current] do
  let(:sql_service) { Azure::SqlDatabaseManagementService }
  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id',
      server_name: 'sql-db',
      password: 'ComplexPassword$!'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      sql_service.any_instance.stubs(:reset_password).with(anything, anything)
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.reset_password(@options) }.to_not raise_error
      end
    end

    describe '(server_name)' do
      it 'should validate the sql server_name' do
        @options.delete(:server_name)
        expect { subject.reset_password(@options) }.to raise_error(
          ArgumentError,
          /required: server_name/
        )
      end
    end

    describe '(password)' do
      it 'should validate the sql server password' do
        @options.delete(:password)
        expect { subject.reset_password(@options) }.to raise_error(
          ArgumentError,
          /required: password/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :reset_password
  end
end
