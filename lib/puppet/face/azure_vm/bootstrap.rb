require 'puppet/cloudpack/bootstrap'

Puppet::Face.define :azure_vm, '0.0.1' do
  action :bootstrap do

    summary 'Install puppet node on  Windows Azure VM'
    
    description <<-'EOT'
      Install puppet node on Windows Azure Virtual Machine.
    EOT

    Puppet::VirtualMachine.add_bootstrap_options(self)

    when_invoked do |options|
      Puppet::CloudPack::BootStrap.start(options)
      nil
    end

    examples <<-'EOT'
      $ puppet azure_vm bootstrap --publish-settings-file=azuremanagement_pfx.publishsettings \
       --vm-user=username --puppet-master-ip=152.56.161.48 --password=Abcd123 \
       --node-ip-address=domain.cloudapp.net
    EOT
  end
end
