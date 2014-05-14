#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_affinitygroup, '1.0.0' do
  action :create do

    summary 'Create affinity group.'

    description 'The create action create a affinity group.'

    Puppet::AffinityGroup.add_create_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new
      others = { description:  options[:description] }
      begin
        affinity_group_service.create_affinity_group(
          options[:affinity_group_name],
          options[:location],
          options[:label],
          others
        )
      rescue => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinitygroup create  --label aglabel \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --location 'West Us' \
        --affinity-group-name agname --description 'Some Description' \
        --management-certificate path-to-azure-certificate
    EOT
  end
end
