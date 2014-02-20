class windowsazure::cloudservice (
  $azure_management_certificate,
  $azure_subscription_id,
  $cloud_service_name,
  $description = undef,
  $label = undef,
  $location = undef,
  $affinity_group_name = undef
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    $cmd = "puppet azure_cloudservice create --cloud-service-name ${cloud_service_name} --management-certificate ${azure_management_certificate} --azure-subscription-id ${azure_subscription_id}"

    if $azure_management_certificate == undef {
      fail('Specify azure management certificate path.')
    }

    if $azure_subscription_id == undef {
      fail('Specify subscription id.')
    }

    if $cloud_service_name == undef {
      fail('Cloud service name is not specified for creating cloud service.')
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

    if $cloud_service_name != undef {
      $csn = "--cloud-service-name ${cloud_service_name}"
    }

    if $location != undef {
      $loc = "--location '${location}'"
    }

    $puppet_command = "${cmd} ${lbl} ${desc} ${csn} ${agn} ${loc}"

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => '0.6.1',
        provider => 'gem',
      }
    }

    exec {"Cloud service":
      command    => $puppet_command,
      logoutput  => true,
    }

    Package['azure'] -> Exec['Cloud service']

}
