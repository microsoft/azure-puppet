#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'tilt'

Puppet::Face.define :azure_cloudservice, '1.0.0' do
  action :list do

    summary 'List cloud services.'

    description <<-'EOT'
      The list action obtains a list of cloud services and
      displays them on the console output.
    EOT

    Puppet::CloudService.add_default_options(self)

    when_invoked do |options|
      Puppet::CloudService.initialize_env_variable(options)
      cloud_service = Azure::CloudServiceManagementService.new

      cloud_services = cloud_service.list_cloud_services
      template = Tilt.new(Puppet::CloudService.views('cloud_services.erb'))
      template.render(nil, cloud_services:  cloud_services)
    end

    returns 'Array of cloud service objets.'

    examples <<-'EOT'
      $ puppet azure_cloudservice list \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID

      Listing cloud services
        Cloud Service: 1
          Name                : azure-puppet
          Locaton             : West US
          Status              : Created
          Winrm Thumbprint    :
        Cloud Service: 2
          Name                : puppet-dashboard-service-oiurf
          Locaton             : West US
          Status              : Created
          Winrm Thumbprint    :
        Cloud Service: 3
          Name                : puppet-master
          Locaton             : West US
          Status              : Created
          Winrm Thumbprint    :
        EOT
  end
end
