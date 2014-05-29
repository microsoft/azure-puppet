#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/sql_database'

Puppet::Face.define(:azure_sqldb, '1.0.0') do

  summary 'View and manage Window Azure database servers.'
  description <<-'EOT'
    This subcommand provides a command line interface to work with Microsoft Azure
    machine instances. The goal of these actions are to easily create new
    database servers.
  EOT

end
