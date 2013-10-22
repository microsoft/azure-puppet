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

Puppet::Face.define :node_azure, '0.0.1' do
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
      $ puppet node_azure delete --publish-settings-file azuremanagement.publishsettings \
       --cloud-service-name service_name --vm-name name

    EOT
  end
end
