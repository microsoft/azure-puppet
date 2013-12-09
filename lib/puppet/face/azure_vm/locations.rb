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
require 'tilt'

Puppet::Face.define :azure_vm, '0.0.1' do
  action :locations do

    summary 'List Windows Azure locations'
    #arguments 'NONE'
    description <<-'EOT'
      The locations action obtains a list of locatons from the cloud provider and
      displays them on the console output.
    EOT

    Puppet::VirtualMachine.add_default_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      base_management = Azure::BaseManagementService.new
      locations = base_management.list_locations
      puts Tilt.new(Puppet::VirtualMachine.views('locations.erb'), 1, :trim => '%').render(nil, :locations => locations)
    end

    returns 'Array of attribute hashes containing information about each Azure locations.'

    examples <<-'EOT'
      $ puppet azure_vm locations --publish-settings-file azuremanagement.publishsettings
      Location Name         Available Service

      West US :  Compute, Storage, PersistentVMRole
      East US :  Compute, Storage, PersistentVMRole
      East Asia :  Compute, Storage, PersistentVMRole
      Southeast Asia :  Compute, Storage, PersistentVMRole
      North Europe :  Compute, Storage, PersistentVMRole
      West Europe :  Compute, Storage, PersistentVMRole
    EOT
  end
end
