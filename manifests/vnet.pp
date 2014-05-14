#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

class microsoftazure::vnet (
  $azure_management_certificate,
  $azure_subscription_id,
  $virtual_network_name,
  $affinity_group_name,
  $address_space,
  $subnets = undef,
  $dns_servers = undef
) {

    Exec { path => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'] }

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => '0.6.4',
        provider => 'gem',
      }
    }

    if $virtual_network_name == undef {
      fail('No virtual network name specified for virtual network.')
    }

    if $affinity_group_name == undef {
      fail('No affinity group name specified for virtual network.')
    }

    if $address_space == undef {
      fail('No address space specified for virtual network.')
    }else {
      $addr_spc_val = inline_template("<%=(@address_space).join(',')%>")
    }

    if $subnets != undef {
      $subnet_values = inline_template("<% values=[] %><% @subnets.each do |x| %><% values << x.values.join(':') %><% end %><%= values.join(',') %>")
      $snet = "--subnets '${subnet_values}'"
    }

    if $dns_servers != undef {
      $dns_values = inline_template("<% values=[] %><% @dns_servers.each do |x| %><% values << x.values.join(':') %><% end %><%= values.join(',') %>")
      $dns = "--dns-servers '${dns_values}'"
    }

    $cmd = "puppet azure_vnet set --virtual-network-name ${virtual_network_name} --management-certificate ${azure_management_certificate} --azure-subscription-id ${azure_subscription_id} --affinity-group-name ${affinity_group_name} --address-space '${addr_spc_val}' "

    $puppet_command = "${cmd} ${dns} ${snet}"

    exec {"Creating virtual network":
      command    => $puppet_command,
      logoutput  => true
    }

    Package['azure'] -> Exec['Creating virtual network']
}