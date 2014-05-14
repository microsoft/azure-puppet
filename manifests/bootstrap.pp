#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

class microsoftazure::bootstrap (
  $puppet_master_ip,
  $node_ipaddress,
  $homedir = undef,
  $ssh_user = undef,
  $winrm_user = undef,
  $private_key_file = undef,
  $winrm_port = undef,
  $password = undef,
  $ssh_port = 22,
  $winrm_transport = 'http'
) {

    Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

    $cmd = "puppet azure_vm bootstrap --node-ipaddress ${node_ipaddress} --puppet-master-ip ${puppet_master_ip}"

    if ($ssh_user == undef) and ($winrm_user == undef) {
      fail('Please specify SSH User or Winrm User.')
    }

    if ($ssh_user != undef) and ($winrm_user != undef) {
      fail('Please specify either SSH User or Winrm User.')
    }

    if ($homedir == undef) and ($ssh_user != undef) {
      fail('home directory path is required for Linux VM bootstrap.')
    }elsif ($homedir != undef){
      $export_home_dir = "export HOME=${homedir};"
    }

    if ($node_ipaddress == undef) {
      fail('Please specify IP address of VM to be provisioned.')
    }

    if $winrm_user != undef {
      $winrmu = "--winrm-user ${winrm_user}"
    }

    if $ssh_user != undef {
      $sshu = "--ssh-user ${ssh_user}"
    }

    if $password != undef {
      $passwd = "--password ${password}"
    }

    if $private_key_file != undef {
      $pkf = "--private-key-file ${private_key_file}"
    }

    if $winrm_port != undef {
      $wp = "--winrm-port ${winrm_port}"
    }

    if $ssh_port != undef {
      $ssp = "--ssh-port ${ssh_port}"
    }

    if $winrm_transport != undef {
      $wrmtp = "--winrm-transport ${winrm_transport}"
    }

    $puppet_command = "${export_home_dir} ${cmd} ${passwd} ${pkf} ${wp} ${ssp} ${wrmtp} ${winrmu} ${sshu}"

    exec {"Provisioning VM ${title}":
      command    => "/bin/bash -c \"${puppet_command}\"",
      logoutput  => true,
      timeout    => 900
    }

}
