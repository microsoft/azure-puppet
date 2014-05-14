#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_affinitygroup, '1.0.0' do
  action :update do

    summary 'Update affinity group.'

    description <<-'EOT'
      The update action updates a affinity group.
    EOT

    Puppet::AffinityGroup.add_update_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new
      others = { description:  options[:description] }
      begin
        affinity_group_service.update_affinity_group(
          options[:affinity_group_name],
          options[:label],
          others
        )
      rescue => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinitygroup update --description 'Some Description'
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --label aglabel \
        --affinity-group-name agname
    EOT
  end
end
