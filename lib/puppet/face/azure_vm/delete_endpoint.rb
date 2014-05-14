#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :delete_endpoint do

    summary 'Delete endpoint of virtual machine.'

    description <<-'EOT'
      Delete endpoint of windows azure node instances.
    EOT

    Puppet::VirtualMachine.delete_endpoint_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new

      virtual_machine_service.delete_endpoint(
        options[:vm_name],
        options[:cloud_service_name],
        options[:endpoint_name]
      )
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm delete_endpoint --endpoint-name endpointname \
      --management-certificate path-to-azure-certificate --vm-name vmname \
      --cloud-service-name cloudname
    EOT
  end
end
