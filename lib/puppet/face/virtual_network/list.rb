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
  action :list do

    summary 'List virtual networks.'
    arguments 'list'
    description <<-'EOT'
      The list action obtains a list of virtual networks and
      displays them on the console output.
    EOT

    Puppet::VirtualNetwork.add_default_options(self)

    when_invoked do |options|
      Puppet::VirtualNetwork.initialize_env_variable(options)
      virtual_network_service = Azure::VirtualNetworkManagementService.new

      virtual_networks = virtual_network_service.list_virtual_networks
      puts Tilt.new(Puppet::VirtualNetwork.views('virtual_networks.erb'), 1, :trim => '%').render(nil, :vnets => virtual_networks)
    end

    returns 'Array of virtual network objets.'

    examples <<-'EOT'
      $ puppet virtual_network list --management-certificate ~/exp/azuremanagement.pem\
        --azure-subscription-id=368a3-dcd0-4cd3 --management-endpoint=https://management.core.windows.net                                 Listing virtual networks

      Virtual Network: 1
        Server Name         : vnet-AG
        Address Space       : 172.16.0.0/12, 10.0.0.0/8, 192.168.0.0/24

        Subnets:             Name              Address Prefix
                             Subnet-1          172.16.0.0/12
                             Subnet-2          10.0.0.0/8
                             Subnet-4          192.168.0.0/26

        Dns Servers:         Name              Ip Address
                             google            8.8.8.8
                             google-2          8.8.4.4

        EOT
  end
end
