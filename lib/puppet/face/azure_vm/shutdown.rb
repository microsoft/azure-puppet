
Puppet::Face.define :azure_vm, '1.0.0' do
  action :shutdown do

    summary 'Shutdown Windows Azure node instances'

    description <<-'EOT'
      The shutdown action stops windows azure node instances.
    EOT

    Puppet::VirtualMachine.add_shutdown_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      virtual_machine_service.shutdown_virtual_machine(options[:vm_name], options[:cloud_service_name])
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm shutdown --publish-settings-file azuremanagement.publishsettings \
       --cloud-service-name service_name --vm-name name

    EOT
  end
end
