#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/cloud_service'

Puppet::Face.define(:azure_cloudservice, '1.0.0') do

  summary 'View and manage Window Azure cloud service.'
  description <<-'EOT'
  This subcommand provides a command line interface to work with Microsoft Azure
  cloud services. The goal of these actions are to easily manage cloud service.
  EOT

end
