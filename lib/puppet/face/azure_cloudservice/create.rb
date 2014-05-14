#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_cloudservice, '1.0.0' do
  action :create do

    summary 'Create cloud service.'

    description 'The create action create a cloud service.'

    Puppet::CloudService.add_create_options(self)

    when_invoked do |options|
      Puppet::CloudService.initialize_env_variable(options)
      cloud_service = Azure::CloudServiceManagementService.new
      others = {
        description:  options[:description],
        label: options[:label],
        affinity_group_name: options[:affinity_group_name],
        location: options[:location],
        extended_properties: options[:extended_properties]
      }

      cloud_service.create_cloud_service(
        options[:cloud_service_name],
        others
      )
      nil
    end

    examples <<-'EOT'
      $ puppet azure_cloudservice create  --label aglabel \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --location 'West Us' \
        --affinity-group-name agname --description 'Some Description' \
        --management-certificate path-to-azure-certificate \
        --cloud-service-name cloudservice1
    EOT
  end
end
