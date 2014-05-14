#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_affinitygroup, '1.0.0' do
  action :delete   do

    summary 'Delete affinity group.'

    description <<-'EOT'
      The delete action delete a affinity group.
    EOT

    Puppet::AffinityGroup.add_delete_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new
      begin
        affinity_group_service.delete_affinity_group(
          options[:affinity_group_name]
        )
      rescue => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinitygroup delete --affinity-group-name ag-name \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID
    EOT
  end
end
