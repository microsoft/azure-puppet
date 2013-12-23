
Puppet::Face.define :azure_sqldb, '1.0.0' do
  action :create do

    summary 'Create SQL database server.'

    description <<-'EOT'
      The create action create a SQL database server.
    EOT

    Puppet::SqlDatabase.add_create_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db = Azure::SqlDatabaseManagementService.new
      servers = db.create_server(options[:login], options[:password], options[:location])
      template = Tilt.new(Puppet::SqlDatabase.views('servers.erb'))
      template.render(nil, db_servers:  servers) if servers
    end

    examples <<-'EOT'
      $ puppet azure_sqldb create --management-certificate path-to-azure-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID --login puppet --location 'West Us'\
        --management-endpoint=https://management.database.windows.net:8443/ --password Ranjan@123
    EOT
  end
end
