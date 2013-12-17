
class windowsazure::all (
  # For windows azure authentication
  $azure_management_certificate,
  $azure_subscription_id,
  # For provision virtual machine
  $vm_name                      = undef,
  $vm_user                      = undef,
  $image                        = undef,
  $location                     = undef,
  $homedir                      = undef,
  $puppet_master_ip             = undef,
  $private_key_file             = undef,
  $certificate_file             = undef,
  $storage_account_name         = undef,
  $cloud_service_name           = undef,
  $password                     = undef,
  $virtual_network_name         = undef,
  $vm_size                      = 'Small',
  $affinity_group_name          = undef,
  # To create sqldb
  $db_login                     = undef,
  $db_password                  = undef,
  $db_location                  = undef,
  # To create virtual network
  $vnet_virtual_network_name    = undef,
  $vnet_affinity_group_name     = undef,
  $address_space                = undef,
  $dns_servers                  = undef,
  $subnets                      = undef
) {

  if $db_login == undef or $db_password == undef or $db_location == undef
  {
    notify {"Some parameter is missing. SQL database is not created.":}
  }else{
    windowsazure::db { 'bt-0':
      azure_management_certificate => $azure_management_certificate,
      azure_subscription_id        => $azure_subscription_id,
      login                        => $db_login,
      password                     => $db_password,
      location                     => $db_location
    }
  }

  if $virtual_network_name == undef or $affinity_group_name == undef or $address_space == undef
  {
    notify {"Some parameter is missing. Virtual network is not created.":}
  }else{
    windowsazure::vnet { 'vnet-0':
      azure_management_certificate => $azure_management_certificate,
      azure_subscription_id        => $azure_subscription_id,
      virtual_network_name         => $vnet_virtual_network_name,
      affinity_group_name          => $vnet_affinity_group_name,
      address_space                => $address_space,
      subnets                      => $subnets,
      dns_servers                  => $dns_servers
    }
  }

  windowsazure::vm { 'vm-0':
    azure_management_certificate => $azure_management_certificate,
    azure_subscription_id        => $azure_subscription_id,
    vm_name                      => $vm_name,
    vm_user                      => $vm_user,
    image                        => $image,
    location                     => $location,
    homedir                      => $homedir,
    vm_size                      => $vm_size,
    puppet_master_ip             => $puppet_master_ip,
    private_key_file             => $private_key_file,
    certificate_file             => $certificate_file,
    storage_account_name         => $storage_account_name,
    cloud_service_name           => $cloud_service_name,
    password                     => $password
  }

}
