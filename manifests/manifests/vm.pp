define windowsazure::vm (
  $vm_name,
  $vm_user,
  $image,
  $password,
  $location,
  $vm_size = 'Small'
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    if $vm_name == undef {
      fail('No vm_name specified for provisioning VM.')
    }

    if $vm_user == undef {
      fail('No vm_user specified for provisioning VM.')
    }

    if $image == undef {
      fail('No image specified for provisioning VM.')
    }

    if $password == undef {
      fail('No SSH password specified for provisioning VM.')
    }

    if $location == undef {
      fail('No location specified for provisioning VM.')
    }

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => 'installed',
        provider => 'gem',
      }
    }

    file { ['/tmp/windowsazure/','/tmp/windowsazure/vm/']:
      ensure => "directory",
    }~>

    file {"azure_vm_provisioner-${title}.rb":
      ensure  => file,
      path    => "/tmp/windowsazure/vm/azure_vm_provisioner-${title}.rb",
      content => template('windowsazure/azure_vm_provisioner.rb.erb'),
      owner   => root,
      group   => root,
      mode    => '0644'
    }~>

    file {"azure_vm_bootstrap.rb":
      ensure  => file,
      path    => "/tmp/windowsazure/vm/azure_vm_bootstrap.rb",
      content => template('windowsazure/azure_vm_bootstrap.rb.erb'),
      owner   => root,
      group   => root,
      mode    => '0644'
    }~>

    file {"puppet-community.sh.erb":
      ensure  => file,
      path    => "/tmp/windowsazure/vm/puppet-community.sh",
      content => template('windowsazure/puppet-community.sh.erb'),
      owner   => root,
      group   => root,
      mode    => '0644'
    }~>

    exec {"Provisioning VM ${title}":
      command     => "ruby /tmp/windowsazure/vm/azure_vm_provisioner-${title}.rb",
      require     => File["azure_vm_provisioner-${title}.rb"],
      subscribe   => File["azure_vm_provisioner-${title}.rb"],
      refreshonly => true,
      logoutput   => true
    }
}
