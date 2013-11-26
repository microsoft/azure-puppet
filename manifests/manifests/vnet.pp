define windowsazure::vnet (
  $virtual_network_name,
  $affinity_group_name,
  $address_space,
  $subnets = [],
  $dns_servers = []
) {
    Exec { path => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'] }

    if $virtual_network_name == undef {
      fail('No virtual network name specified for virtual network.')
    }

    if $affinity_group_name == undef {
      fail('No affinity group name specified for virtual network.')
    }

    if $address_space == undef {
      fail('No address space specified for virtual network.')
    }

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => 'installed',
        provider => 'gem',
      }
    }

    file {"azure_vnet-${title}.rb":
      ensure  =>  file,
      path    => "/tmp/azure_vnet-${title}.rb",
      content => template('windowsazure/azure_vnet.rb.erb'),
      owner   => root,
      group   => root,
      mode    => '0644'
    }~>

    exec {"Creating virtual network ${title}":
      command     => "ruby /tmp/azure_vnet-${title}.rb",
      require     => File["azure_vnet-${title}.rb"],
      subscribe   => File["azure_vnet-${title}.rb"],
      refreshonly => true,
      logoutput   => true
    }
}
