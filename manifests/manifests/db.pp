define windowsazure::db (
  $azure_management_certificate,
  $azure_subscription_id,
  $login,
  $password,
  $location
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    $cmd = "puppet database_server create --login $login \
        --management-certificate $azure_management_certificate \
        --azure-subscription-id $azure_subscription_id \
        --password $password --location '$location'"

    if $azure_management_certificate == undef {
      fail('Specify azure management certificate path.')
    }

    if $azure_subscription_id == undef {
      fail('Specify subscription id.')
    }

    if $login == undef {
      fail('No login specified for provisioning VM.')
    }

    if $password == undef {
      fail('No password specified for provisioning VM.')
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

    exec {"SQL database ${title}":
      command    => "$cmd",
      logoutput  => true
    }

}