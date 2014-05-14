#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_sqldb, :current] do
  let(:sql_service) { Azure::SqlDatabaseManagementService }
  let(:firewalls) do
    [
      {
        rule: 'Rule 1',
        start_ip_address: '192.168.1.1',
        end_ip_address: '192.168.1.255'
      }
    ]
  end

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id',
      server_name: 'db-server'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      sql_service.any_instance.stubs(
        :list_sql_server_firewall_rules
      ).returns(firewalls)
    end
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.list_firewall(@options) }.to_not raise_error
      end

      it 'should print affinity groups details' do
        server_firewalls = subject.list_firewall(@options)
        firewall = firewalls.first
        start_ip = firewall[:start_ip_address]
        end_ip = firewall[:end_ip_address]
        rule = "#{'Rule Name'.fix(20)}: #{firewall[:rule]}"
        expect(server_firewalls).to match(/#{rule}/)
        start_ip_text = "#{'Start IP Address'.fix(20)}: #{start_ip}"
        expect(server_firewalls).to match(/#{start_ip_text}/)
        end_ip_text = "#{'End IP Address'.fix(20)}: #{end_ip}"
        expect(server_firewalls).to match(/#{end_ip_text}/)
      end
    end

    it_behaves_like 'validate authentication credential', :list_firewall

  end
end
