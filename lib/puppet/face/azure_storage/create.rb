#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
Puppet::Face.define :azure_storage, '1.0.0' do
  action :create do

    summary 'Create storage service.'

    description 'The create action create a storage account.'

    Puppet::StorageAccount.add_create_options(self)

    when_invoked do |options|
      Puppet::StorageAccount.initialize_env_variable(options)
      storage_account = Azure::StorageManagementService.new
      others = {
        description:  options[:description],
        label: options[:label],
        affinity_group_name: options[:affinity_group_name],
        location: options[:location],
        extended_properties: options[:extended_properties]
      }
      storage_account.create_storage_account(
        options[:storage_account_name],
        others
      )
      nil
    end

    examples <<-'EOT'
      $ puppet azure_storage create  --label aglabel \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --location 'West Us' \
        --affinity-group-name agname --description 'Some Description' \
        --management-certificate path-to-azure-certificate
    EOT
  end
end
