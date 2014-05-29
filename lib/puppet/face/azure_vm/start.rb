#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :start do

    summary 'starts Microsoft Azure node instances'

    description <<-'EOT'
      The start action starts windows azure node instances.
    EOT

    Puppet::VirtualMachine.add_shutdown_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      virtual_machine_service.start_virtual_machine(
        options[:vm_name],
        options[:cloud_service_name]
      )
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm start --cloud-service-name service_name \
        --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --vm-name name

    EOT
  end
end
