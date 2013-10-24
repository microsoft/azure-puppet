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

Puppet::Face.define :virtual_network, '0.0.1' do
  action :set_xml_schema do

    summary 'set_xml_schema Network configures the virtual network using xml schema'
    description <<-'EOT'
      The set_xml_schema Network Configuration operation asynchronously configures the virtual network.
    EOT

    Puppet::VirtualNetwork.add_set_xml_schema_options(self)

    when_invoked do |options|
      Puppet::VirtualNetwork.initialize_env_variable(options)
      virtual_network_service = Azure::VirtualNetworkManagementService.new
      virtual_network_service.set_network_configuration(options[:xml_schema_file])
      nil
    end

    returns 'None '

    examples <<-'EOT'
      $ puppet virtual_network set --management-certificate ~/exp/azuremanagement.pem\
        --azure-subscription-id=368a3-dcd0-4cd3 --management-endpoint=https://management.database.windows.net:8443/

    EOT
  end
end
