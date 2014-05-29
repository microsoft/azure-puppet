#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/storage_account'

Puppet::Face.define(:azure_storage, '1.0.0') do

  summary 'View and manage Window Azure storage account.'
  description <<-'EOT'
  This subcommand provides a command line interface to work with Microsoft Azure
  storage account. The goal of these actions are to easily manage storage account.
  EOT

end
