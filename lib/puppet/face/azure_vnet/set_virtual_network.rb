#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
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
      address_space = options[:address_space].split(',')
      optional = {}
      if options[:subnets]
        subnets = []
        options[:subnets].split(',').each do |subnet|
          values = subnet.split(':')
          fail 'Missing argument subnet name or ip_address or cidr in subnet' if values.size != 3
          subnets << { name:  values[0], ip_address:  values[1], cidr:  values[2] }
        end
        optional[:subnet] = subnets
      end
      if options[:dns_servers]
        dns = []
        options[:dns_servers].split(',').each do |ds|
          values = ds.split(':')
          fail 'Missing argument dns name or ip_address in dns' if values.size != 2
          dns << { name:  values[0], ip_address:  values[1] }
        end
        optional[:dns] = dns
      end
      virtual_network_service.set_network_configuration(
        options[:virtual_network_name],
        options[:location],
        address_space,
        optional
      )
      nil
    end

    returns 'None '

    examples <<-'EOT'
      $ puppet azure_vnet set --management-certificate path-to-certificate \
        --azure-subscription-id=YOUR-SUBSCRIPTION-ID \
        --dns-servers 'google-1:8.8.8.8,google-2:8.8.4.4' \
        --subnets 'subnet-1:172.16.0.0:12,subnet-2:192.168.0.0:29' \
        --virtual-network-name v-net --location 'West US' \
        --address-space '172.16.0.0/12,192.168.0.0/16'

    EOT
  end
end
