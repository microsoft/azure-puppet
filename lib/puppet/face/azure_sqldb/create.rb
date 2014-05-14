#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_sqldb, '1.0.0' do
  action :create do

    summary 'Create SQL database server.'
    description 'The create action create a SQL database server.'

    Puppet::SqlDatabase.add_create_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db = Azure::SqlDatabaseManagementService.new
      sql_server = db.create_server(
        options[:login],
        options[:password],
        options[:location]
      )
      template = Tilt.new(Puppet::SqlDatabase.views('servers.erb'))
      template.render(nil, db_servers:  sql_server) if sql_server
    end

    examples <<-'EOT'
      $ puppet azure_sqldb create --login puppet --location 'West Us' \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID --password Ranjan@123 \
        --management-endpoint=https://management.database.windows.net:8443/ \
        --management-certificate path-to-azure-certificate
    EOT
  end
end
