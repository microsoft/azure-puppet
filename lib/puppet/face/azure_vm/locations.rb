#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :locations do

    summary 'List Microsoft Azure locations'

    description <<-'EOT'
      The locations action obtains a list of locatons from the cloud provider
      and displays them on the console output.
    EOT

    Puppet::VirtualMachine.add_default_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      base_management = Azure::BaseManagementService.new
      locations = base_management.list_locations
      template = Tilt.new(Puppet::VirtualMachine.views('locations.erb'))
      template.render(nil, locations:  locations)
    end

    returns <<-'EOT'
      Array of attribute hashes containing information about
      Microsoft Azure locations.'
    EOT

    examples <<-'EOT'
      $ puppet azure_vm locations --azure-subscription-id YOUR-SUBSCRIPTION-ID\
        --management-certificate path-to-azure-certificate
      Location Name         Available Service

      West US :  Compute, Storage, PersistentVMRole
      East US :  Compute, Storage, PersistentVMRole
      East Asia :  Compute, Storage, PersistentVMRole
      Southeast Asia :  Compute, Storage, PersistentVMRole
      North Europe :  Compute, Storage, PersistentVMRole
      West Europe :  Compute, Storage, PersistentVMRole
    EOT
  end
end
