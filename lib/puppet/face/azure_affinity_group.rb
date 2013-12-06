require 'puppet/affinity_group'

Puppet::Face.define(:azure_affinity_group, '0.0.1') do
  copyright "Windows Azure", 2013
  license   "Microsoft Open Technologies, Inc; see COPYING"

  summary "View and manage Window Azure affinity groups."
  description <<-'EOT'
    This subcommand provides a command line interface to work with Windows Azure
    affinity groups.  The goal of these actions are to easily create new or update
    affinity group.
  EOT

end
