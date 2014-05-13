require 'puppet/service_bus'

Puppet::Face.define(:azure_servicebus, '1.0.0') do

  summary 'View and manage Window Azure database servers.'
  description <<-'EOT'
    This subcommand provides a command line interface to work with Windows Azure
    machine instances. The goal of these actions are to easily create new
    database servers.
  EOT

end
