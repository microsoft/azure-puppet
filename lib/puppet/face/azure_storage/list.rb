#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'tilt'

Puppet::Face.define :azure_storage, '1.0.0' do
  action :list do

    summary 'List storage accounts.'

    description <<-'EOT'
      The list action obtains a list of storage accounts and
      displays them on the console output.
    EOT

    Puppet::StorageAccount.add_default_options(self)

    when_invoked do |options|
      Puppet::StorageAccount.initialize_env_variable(options)
      strage_service = Azure::StorageManagementService.new

      storage_accounts = strage_service.list_storage_accounts
      template = Tilt.new(Puppet::StorageAccount.views('storage_accounts.erb'))
      template.render(nil, storage_accounts:  storage_accounts)
    end

    returns 'Array of storage account objets.'

    examples <<-'EOT'
      $ puppet azure_storage list \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID

      Listing storage accounts
        Storage Account: 1
          Name                : azure-puppet
          Locaton             : West US
          Status              : Created
          Winrm Thumbprint    :
        Storage Account: 2
          Name                : puppet-dashboard-service-oiurf
          Locaton             : West US
          Status              : Created
          Winrm Thumbprint    :
        Storage Account: 3
          Name                : puppet-master
          Locaton             : West US
          Status              : Created
          Winrm Thumbprint    :
        EOT
  end
end
