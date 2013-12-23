
Puppet::Face.define :azure_sqldb, '1.0.0' do
  action :delete_firewall do

    summary 'Delete Windows Azure sql database firewall rule on server'

    description <<-'EOT'
      The delete action delete windows azure sql database firewall on server.
    EOT

    Puppet::SqlDatabase.add_delete_firewall_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db = Azure::SqlDatabaseManagementService.new
      db.delete_sql_server_firewall_rule(options[:server_name], options[:rule_name])
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_sqldb delete_firewall --management-certificate path-to-azure-certificate \
         --azure-subscription-id=YOUR-SUBSCRIPTION-ID --management-endpoint=https://management.database.windows.net:8443/\
         --server-name=xlykw0su08 --rule-name rule1

    EOT
  end
end
