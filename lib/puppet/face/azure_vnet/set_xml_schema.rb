
Puppet::Face.define :azure_vnet, '0.0.1' do
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
      $ puppet azure_vnet set --management-certificate ~/exp/azuremanagement.pem\
        --azure-subscription-id=368a3-dcd0-4cd3 --management-endpoint=https://management.database.windows.net:8443/

    EOT
  end
end
