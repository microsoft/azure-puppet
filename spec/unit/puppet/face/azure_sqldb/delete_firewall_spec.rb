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
      rule_name: 'rule 1'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      sql_service.any_instance.stubs(:delete_sql_server_firewall_rule).with(
        any_parameters)
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.delete_firewall(@options) }.to_not raise_error
      end
    end

    describe '(server_name)' do
      it 'should validate the sql server_name' do
        @options.delete(:server_name)
        expect { subject.delete_firewall(@options) }.to raise_error(
          ArgumentError,
          /required: server_name/
        )
      end

      describe '(rule_name)' do
        it 'should validate the sql server_name' do
          @options.delete(:rule_name)
          expect { subject.delete_firewall(@options) }.to raise_error(
            ArgumentError,
            /required: rule_name/
          )
        end
      end
    end

    it_behaves_like 'validate authentication credential', :delete_firewall
  end
end
