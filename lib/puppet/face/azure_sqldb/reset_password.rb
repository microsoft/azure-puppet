#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_sqldb, '1.0.0' do
  action :reset_password do

    summary 'Reset password of sql database server.'

    description <<-'EOT'
      The reset_passowrd action reset password of sql database server.
    EOT

    Puppet::SqlDatabase.add_reset_password_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db = Azure::SqlDatabaseManagementService.new
      db.reset_password(options[:server_name], options[:password])
      nil
    end

    examples <<-'EOT'
      $ puppet azure_sqldb reset_password  --password ComplexPassword$# \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID --server-name hc786mm0l8 \
        --management-endpoint=https://management.database.windows.net:8443/\

    EOT
  end
end
