#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

class microsoftazure::db (
  $azure_management_certificate,
  $azure_subscription_id,
  $login,
  $password,
  $location
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    $puppet_command = "puppet azure_sqldb create --login ${login} --management-certificate ${azure_management_certificate} --azure-subscription-id ${azure_subscription_id} --password ${password} --location '${location}'"

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
        ensure   => '0.6.4',
        provider => 'gem',
      }
    }

    exec {"SQL database":
      command    => $puppet_command,
      logoutput  => true
    }

    Package['azure'] -> Exec['SQL database']
}
