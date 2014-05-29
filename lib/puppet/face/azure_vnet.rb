#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/virtual_network'

Puppet::Face.define(:azure_vnet, '1.0.0') do

  summary 'View and manage Window Azure virtual networks.'
  description <<-'EOT'
    This subcommand provides a command line interface to work with Microsoft Azure
    virtual networks. The goal of these actions are to easily create new or update
    virtual network.
  EOT

end
