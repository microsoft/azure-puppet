require 'puppet/sql_database'

Puppet::Face.define(:azure_sqldb, '0.0.1') do
  copyright "Windows Azure", 2013
  license   "Microsoft Open Technologies, Inc; see COPYING"

  summary "View and manage Window Azure database servers."
  description <<-'EOT'
    This subcommand provides a command line interface to work with Windows Azure
    machine instances.  The goal of these actions are to easily create new
    database servers.
  EOT

end
