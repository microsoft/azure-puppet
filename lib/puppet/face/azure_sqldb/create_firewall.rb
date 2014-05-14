#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_sqldb, '1.0.0' do
  action :create_firewall do

    summary 'Create SQL database firewall rule on a server.'

    description <<-'EOT'
      The create action create a SQL database firewall rule on a server.
    EOT

    Puppet::SqlDatabase.add_create_firewall_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db_server = Azure::SqlDatabaseManagementService.new
      ip_range = {
        start_ip_address:  options[:start_ip_address],
        end_ip_address:  options[:end_ip_address]
      }
      db_server.set_sql_server_firewall_rule(
        options[:server_name],
        options[:rule_name],
        ip_range
      )
    end

    examples <<-'EOT'
      $ puppet azure_sqldb create_firewall  --end-ip-address 10.10.0.255 \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --rule-name ranjan \
        --management-endpoint=https://management.database.windows.net:8443/\
        --server-name=g2jxhsbk0w --start-ip-address 10.10.0.0

      $ puppet azure_sqldb create_firewall --server-name=g2jxhsbk0w\
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --rule-name ranjan
    EOT
  end
end
