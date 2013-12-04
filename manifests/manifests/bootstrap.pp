define windowsazure::bootstrap (
  $homedir = undef,
  $azure_management_certificate,
  $azure_subscription_id,
  $puppet_master_ip,
  $node_ipaddress,
  $ssh_user = undef,
  $winrm_user = undef,
  $private_key_file = undef,
  $winrm_port = undef,
  $password = undef,
  $ssh_port = 22,
  $winrm_transport = 'http'
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    $cmd = "puppet node_azure bootstrap --node-ipaddress $node_ipaddress \
            --management-certificate $azure_management_certificate \
            --azure-subscription-id $azure_subscription_id \
            --puppet-master-ip $puppet_master_ip"

    if ($ssh_user == undef) and ($winrm_user == undef) {
      fail('Please specify SSH User or Winrm User.')
    }

    if ($ssh_user != undef) and ($winrm_user != undef) {
      fail('Please specify either SSH User or Winrm User.')
    }

    if ($homedir == undef) and ($ssh_user != undef) {
      fail('home directory path is required for Linux VM bootstrap.')
    }

    if $azure_management_certificate == undef {
      fail('Specify azure management certificate path.')
    }

    if $azure_subscription_id == undef {
      fail('Specify subscription id.')
    }

    if $winrm_user != undef {
      $winrmu = "--winrm-user $winrm_user"
    }

    if $ssh_user != undef {
      $sshu = "--ssh-user $ssh_user"
    }

    if $puppet_master_ip != undef {
      $pmi = "--puppet-master-ip $puppet_master_ip"
    }

    if $password != undef {
      $passwd = "--password $password"
    }

    if $private_key_file != undef {
      $pkf = "--private-key-file $private_key_file"
    }

    if $winrm_port != undef {
      $wp = "--winrm-port $winrm_port"
    }

    if $ssh_port != undef {
      $ssp = "--ssh-port $ssh_port"
    }

    if $winrm_transport != undef {
      $wrmtp = "--winrm-transport $winrm_transport"
    }


    $command = "${cmd} ${passwd} ${pmi} ${pkf} ${wp} ${ssp} ${wrmtp} ${winrmu} ${sshu}"

    if !defined( Package['azure'] ) {
      package { 'azure':
        ensure   => 'installed',
        provider => 'gem',
      }
    }

    exec {"Provisioning VM ${title}":
      command    => "/bin/bash -c \"export HOME=$homedir; $command\"",
      logoutput  => true
    }

}
