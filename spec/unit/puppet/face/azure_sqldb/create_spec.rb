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
      azure_subscription_id: 'Subscription-id',
      management_endpoint: 'management.core.windows.net',
      login: 'login-name',
      location: 'West US',
      password: 'ComplexPassword$'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    sql_service.any_instance.stubs(
      :create_server).with(
      any_parameters).returns(sql_server)
  end

  describe 'option validation' do

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'should print sql server details' do
        server = subject.create(@options)
        expect(server).to match(/Server Name         : #{sql_server.name}/)
        login = "Administrator login : #{sql_server.administrator_login}"
        expect(server).to match(/#{login}/)
        expect(server).to match(/Location            : #{sql_server.location}/)
      end
    end

    describe '(login)' do
      it 'should validate the sql db login' do
        @options.delete(:login)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: login/
        )
      end
    end

    describe '(location)' do
      it 'should validate the sql db location' do
        @options.delete(:location)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: location/
        )
      end
    end

    describe '(password)' do
      it 'should validate sql db password' do
        @options.delete(:password)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: password/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :create
  end
end
