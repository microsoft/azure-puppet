# encoding: UTF-8
require 'tilt'

Puppet::Face.define :azure_servicebus, '1.0.0' do
  action :create_queue do

    summary 'List SQL database servers.'
    arguments 'list'
    description <<-'EOT'
      The list action obtains a list of sql database servers and
      displays them on the console output.
    EOT

    Puppet::ServiceBus.add_create_queue_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_service_bus = Azure::ServiceBusService.new
      azure_service_bus.create_queue(options[:queue_name])
    end

    returns 'Array of database server objets.'

    examples <<-'EOT'
      $ puppet azure_sqldb list --azure-subscription-id=YOUR-SUBSCRIPTION-ID \
        --management-certificate azure-certificate-path \
        --management-endpoint=https://management.database.windows.net:8443/

    Listing Servers

      Server: 1
        Server Name         : esinlp9bav
        Administrator login : puppet3
        Location            : West US

      Server: 2
        Server Name         : estkonosnv
        Administrator login : puppet
        Location            : West US

      Server: 3
        Server Name         : ezprthvj9w
        Administrator login : puppet
        Location            : West US

    EOT
  end
end
