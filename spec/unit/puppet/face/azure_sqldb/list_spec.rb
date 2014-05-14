#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_sqldb, :current] do
  let(:sql_service) { Azure::SqlDatabaseManagementService }
  let(:sql_server) do
    Azure::SqlDatabaseManagement::SqlDatabase.new do |db|
      db.name = 'db-1'
      db.administrator_login = 'login-name'
      db.location = 'West US'
    end
  end

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      sql_service.any_instance.stubs(
        :list_servers
      ).returns([sql_server])
    end
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.list(@options) }.to_not raise_error
      end

      it 'should print affinity groups details' do
        db_servers = subject.list(@options)
        expect(db_servers).to match(/Server Name         : #{sql_server.name}/)
        login = "Administrator login : #{sql_server.administrator_login}"
        expect(db_servers).to match(/#{login}/)
        location = "#{'Location'.fix(20)}: #{sql_server.location}"
        expect(db_servers).to match(/#{location}/)
      end
    end

    it_behaves_like 'validate authentication credential', :list

  end
end
