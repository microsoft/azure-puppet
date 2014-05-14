#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_storage, '1.0.0' do
  action :delete do

    summary 'Delete storage account.'

    description 'The delete action delete a storage account.'

    Puppet::StorageAccount.add_delete_options(self)

    when_invoked do |options|
      Puppet::StorageAccount.initialize_env_variable(options)
      storage_service = Azure::StorageManagementService.new
      begin
        storage_service.delete_storage_account(options[:storage_account_name])
      rescue
      end
      nil
    end

    examples <<-'EOT'
      $ puppet azure_storage delete --storage-account-name storagename \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID \
        --management-certificate path-to-azure-certificate
    EOT
  end
end
