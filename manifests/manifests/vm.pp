define windowsazure::vm (
  $vm_name,
  $vm_user,
  $image,
  $password,
  $location,
  $vm_size = 'Small'
) {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    if $vm_name == undef {
      fail("No vm_name specified for provisioning VM.")
    }

    if $vm_user == undef {
      fail("No vm_user specified for provisioning VM.")
    }

    if $image == undef {
      fail("No image specified for provisioning VM.")
    }

    if $password == undef {
      fail("No SSH password specified for provisioning VM.")
    }

    if $location == undef {
      fail("No location specified for provisioning VM.")
    }

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => 'installed',
        provider => 'gem',
      }
    }

    file {"azure_vm_provisioner-${title}.rb":
      path => "/tmp/azure_vm_provisioner-${title}.rb",
      ensure  => file,
      content => template('windowsazure/azure_vm_provisioner.rb.erb'),
      owner   => root,
      group   => root,
      mode    => 644
    }~>

    exec {"Provisioning VM ${title}":
      command => "ruby /tmp/azure_vm_provisioner-${title}.rb",
      require => File["azure_vm_provisioner-${title}.rb"],
      subscribe   => File["azure_vm_provisioner-${title}.rb"],
      refreshonly => true,
      logoutput => true
    }
}