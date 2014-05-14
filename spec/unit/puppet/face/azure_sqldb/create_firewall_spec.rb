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
      azure_subscription_id: 'Subscription-id',
      management_endpoint: 'management.core.windows.net',
      start_ip_address: '192.168.1.1',
      end_ip_address: '192.168.1.5',
      server_name: 'sql-db',
      rule_name: 'rule 1'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    sql_service.any_instance.stubs(
      :set_sql_server_firewall_rule).with(
      any_parameters
    )
  end

  describe 'option validation' do

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create_firewall(@options) }.to_not raise_error
      end
    end

    describe '(server_name)' do
      it 'should validate the sql server name' do
        @options.delete(:server_name)
        expect { subject.create_firewall(@options) }.to raise_error(
          ArgumentError,
          /required: server_name/
        )
      end
    end

    describe '(rule_name)' do
      it 'should validate the sql db location' do
        @options.delete(:rule_name)
        expect { subject.create_firewall(@options) }.to raise_error(
          ArgumentError,
          /required: rule_name/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :create_firewall
  end

  describe 'optional parameter validation' do
    describe '(start_ip_address)' do
      it 'start_ip_address should be optional' do
        @options.delete(:start_ip_address)
        expect { subject.create_firewall(@options) }.to_not raise_error
      end

      it 'end_ip_address should be optional' do
        @options.delete(:end_ip_address)
        expect { subject.create_firewall(@options) }.to_not raise_error
      end
    end
  end
end
