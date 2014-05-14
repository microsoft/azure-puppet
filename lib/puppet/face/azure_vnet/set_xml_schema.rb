#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

Puppet::Face.define :azure_vnet, '1.0.0' do
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
      $ puppet azure_vnet set --management-certificate path-to-azure-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID --management-endpoint=https://management.database.windows.net:8443/

    EOT
  end
end
