#-------------------------------------------------------------------------
# Copyright 2013 Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require 'puppet/cloudpack/bootstrap'

Puppet::Face.define :node_azure, '0.0.1' do
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
      $ puppet node_azure bootstrap --publish-settings-file=azuremanagement_pfx.publishsettings \
       --vm-user=username --puppet-master-ip=152.56.161.48 --password=Abcd123 \
       --node-ip-address=domain.cloudapp.net
    EOT
  end
end
