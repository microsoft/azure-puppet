#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'puppet/azurepack/bootstrap'

Puppet::Face.define :azure_vm, '1.0.0' do
  action :bootstrap do

    summary 'Install puppet node on  Microsoft Azure VM'
    description 'Install puppet node on Microsoft Azure Virtual Machine.'

    Puppet::VirtualMachine.add_bootstrap_options(self)

    when_invoked do |options|
      Puppet::AzurePack::BootStrap.start(options)
      nil
    end

    examples <<-'EOT'
      $ puppet azure_vm bootstrap --node-ip-address=domain.cloudapp.net \
       --vm-user username --puppet-master-ip 152.56.161.48 --password Abcd123 \
       --agent-environment development
    EOT
  end
end
