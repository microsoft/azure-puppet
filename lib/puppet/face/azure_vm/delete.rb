
Puppet::Face.define :azure_vm, '0.0.1' do
  action :delete do

    summary 'Delete Windows Azure node instances'

    description <<-'EOT'
      The delete action delete windows azure node instances.
    EOT

    Puppet::VirtualMachine.add_delete_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      virtual_machine_service.delete_virtual_machine(options[:vm_name], options[:cloud_service_name])
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm delete --publish-settings-file azuremanagement.publishsettings \
       --cloud-service-name service_name --vm-name name

    EOT
  end
end
