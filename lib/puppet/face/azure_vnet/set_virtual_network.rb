
Puppet::Face.define :azure_vnet, '1.0.0' do
  action :set do

    summary 'Set Network configures the virtual network'
    description <<-'EOT'
      The Set Network Configuration operation asynchronously configures the virtual network.
    EOT

    Puppet::VirtualNetwork.add_set_virtual_network_options(self)

    when_invoked do |options|
      Puppet::VirtualNetwork.initialize_env_variable(options)
      virtual_network_service = Azure::VirtualNetworkManagementService.new
      address_space = options[:address_space].split(",")
      optional = {}
      if options[:subnets]
        subnets = []
        options[:subnets].split(",").each do |subnet|
          values = subnet.split(":")
          raise "Missing argument name or ip_address or cidr in subnet" if values.size !=3
          subnets << {:name =>values[0], :ip_address=>values[1], :cidr=>values[2] }
        end
        optional[:subnet] = subnets
      end
      if options[:dns_servers]
        dns = []
        options[:dns_servers].split(",").each do |ds|
          values = ds.split(":")
          raise "Missing argument name or ip_address in dns" if values.size !=2
          dns << {:name =>values[0], :ip_address=>values[1]}
        end
        optional[:dns] = dns
      end
      virtual_network_service.set_network_configuration(options[:virtual_network_name], options[:affinity_group_name], address_space, optional)
      nil
    end

    returns 'None '

    examples <<-'EOT'
      $ puppet azure_vnet set --management-certificate path-to-azure-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID --management-endpoint=https://management.database.windows.net:8443/

    EOT
  end
end
