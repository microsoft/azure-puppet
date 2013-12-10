require 'tilt'

Puppet::Face.define :azure_vm, '1.0.0' do
  action :servers do

    summary 'List Windows Azure node instances'
    arguments 'list'
    description <<-'EOT'
      The list action obtains a list of instances from the cloud provider and
      displays them on the console output.  For Azure instances, only the instances in
      a specific region are provided.
    EOT

    Puppet::VirtualMachine.add_default_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      servers = virtual_machine_service.list_virtual_machines
      puts Tilt.new(Puppet::VirtualMachine.views('servers.erb'), 1, :trim => '%').render(nil, :roles => servers)
    end

    returns 'Array of attribute hashes containing information about each Azure instance.'

    examples <<-'EOT'
      $ puppet azure_vm servers --publish-settings-file azuremanagement.publishsettings --azure-subscription-id ID
      Server: 1
        Service: cloudserver1
        Deployment:  deployment1
        Role:  windows
        Host:  akwindows
        Deployment Status: Running
        Role Status:  ReadyRole
        IP Address:  168.61.8.83
    EOT
  end
end
