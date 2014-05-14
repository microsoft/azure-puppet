#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

class microsoftazure::storage (
  $azure_management_certificate,
  $azure_subscription_id,
  $storage_account_name,
  $description = undef,
  $label = undef,
  $location = undef,
  $affinity_group_name = undef
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    $cmd = "puppet azure_storage create --storage-account-name ${storage_account_name} --management-certificate ${azure_management_certificate} --azure-subscription-id ${azure_subscription_id}"

    if $azure_management_certificate == undef {
      fail('Specify azure management certificate path.')
    }

    if $azure_subscription_id == undef {
      fail('Specify subscription id.')
    }

    if $storage_account_name == undef {
      fail('Storage account name is not specified for storage account.')
    }

    if $label != undef {
      $lbl = "--label ${label}"
    }

    if $description != undef {
      $desc = "--description ${description}"
    }

    if $affinity_group_name != undef {
      $agn = "--affinity-group-name ${affinity_group_name}"
    }

    if $storage_account_name != undef {
      $sac = "--storage-account-name ${storage_account_name}"
    }

    if $location != undef {
      $loc = "--location '${location}'"
    }

    $puppet_command = "${cmd} ${lbl} ${desc} ${sac} ${agn} ${loc}"

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => '0.6.4',
        provider => 'gem',
      }
    }

    exec {"Storage Account":
      command    => $puppet_command,
      logoutput  => true,
    }

    Package['azure'] -> Exec['Storage Account']

}
