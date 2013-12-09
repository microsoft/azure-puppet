require 'puppet/virtual_machine'

Puppet::Face.define(:azure_vm, '0.0.1') do
  copyright "Windows Azure", 2013
  license   "Microsoft Open Technologies, Inc; see COPYING"

  summary "View and manage Window Azure nodes."
  description <<-'EOT'
    This subcommand provides a command line interface to work with Windows Azure
    machine instances.  The goal of these actions are to easily create new
    machines, install Puppet onto them, and tear them down when they're no longer
    required.
  EOT
  
end
