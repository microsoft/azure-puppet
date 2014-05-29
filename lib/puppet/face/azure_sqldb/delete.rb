#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_sqldb, '1.0.0' do
  action :delete do

    summary 'Delete Microsoft Azure sql database server'

    description <<-'EOT'
      The delete action delete windows azure sql server.
    EOT

    Puppet::SqlDatabase.add_delete_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db = Azure::SqlDatabaseManagementService.new
      db.delete_server(options[:server_name])
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $  puppet azure_sqldb delete --server-name=ezprthvj9w \
         --management-certificate path-to-azure-certificate  \
         --azure-subscription-id OUR-SUBSCRIPTION-ID \
         --management-endpoint=https://management.database.windows.net:8443/
    EOT
  end
end
