#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'tilt'

Puppet::Face.define :azure_affinitygroup, '1.0.0' do
  action :list do

    summary 'List affinity groups.'
    arguments 'list'
    description <<-'EOT'
      The list action obtains a list of affinity groups and
      displays them on the console output.
    EOT

    Puppet::AffinityGroup.add_default_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new
      affinity_groups = affinity_group_service.list_affinity_groups
      template = Tilt.new(Puppet::AffinityGroup.views('affinity_groups.erb'))
      template.render(nil, affinity_groups:  affinity_groups)
    end

    returns 'Array of affinity group objets.'

    examples <<-'EOT'
      $ puppet affinity_group list \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID \
        --management-endpoint=https://management.core.windows.net

      Listing affinity groups

        Affinity Group: 1
          Name                : integration-test-affinity-group
          Label               : Label
          Locaton             : East Asia
          Description         : Description
          Capability          : PersistentVMRole, HighMemory

        Affinity Group: 2
          Name                : Test
          Label               : this is update operation
          Locaton             : West US
          Description         : My Description
          Capability          : PersistentVMRole, HighMemory

    EOT
  end
end
