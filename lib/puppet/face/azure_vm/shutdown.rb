#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :shutdown do

    summary 'Shutdown Microsoft Azure node instances'
    description 'The shutdown action stops windows azure node instances.'

    Puppet::VirtualMachine.add_shutdown_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      virtual_machine_service.shutdown_virtual_machine(
        options[:vm_name],
        options[:cloud_service_name]
      )
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm shutdown --cloud-service-name service_name \
       --publish-settings-file azure-certificate-path --vm-name name \
       --management-certificate path-to-azure-certificate

    EOT
  end
end
