#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

class microsoftazure::provisioner (
  # For windows azure authentication
  $azure_management_certificate,
  $azure_subscription_id,
  # Require for virtual machine  provision
  $create_vm                    = true,
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
  $add_role                     = 'false',
  # Require for SQL database create
  $create_sqldb                 = true,
  $db_login                     = undef,
  $db_password                  = undef,
  $db_location                  = undef,
  # Require for virtual network create
  $create_vnet                  = true,
  $vnet_virtual_network_name    = undef,
  $vnet_affinity_group_name     = undef,
  $address_space                = undef,
  $dns_servers                  = undef,
  $subnets                      = undef
) {

  stage { 'prereqs':
    before => Stage['main'],
  }

  stage { 'final':
    require => Stage['main'],
  }

  stage { 'middle':
    before => Stage['final'],
  }

  if ($create_vm){
    class { 'microsoftazure::vm':
      stage                        => final,
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
      password                     => $password,
      add_role                     => $add_role
    }
  }

  if ($create_vnet){
    class { 'microsoftazure::vnet':
      stage                        => prereqs,
      azure_management_certificate => $azure_management_certificate,
      azure_subscription_id        => $azure_subscription_id,
      virtual_network_name         => $vnet_virtual_network_name,
      affinity_group_name          => $vnet_affinity_group_name,
      address_space                => $address_space,
      subnets                      => $subnets,
      dns_servers                  => $dns_servers
    }
  }

  if ($create_sqldb){
   class { 'microsoftazure::db':
      stage                        => middle,
      azure_management_certificate => $azure_management_certificate,
      azure_subscription_id        => $azure_subscription_id,
      login                        => $db_login,
      password                     => $db_password,
      location                     => $db_location
    }
  }
}
