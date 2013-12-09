require 'puppet/virtual_network'

Puppet::Face.define(:azure_vnet, '0.0.1') do
  copyright "Windows Azure", 2013
  license   "Microsoft Open Technologies, Inc; see COPYING"

  summary "View and manage Window Azure virtual networks."
  description <<-'EOT'
    This subcommand provides a command line interface to work with Windows Azure
    virtual networks.  The goal of these actions are to easily create new or update
    virtual network.
  EOT

end
