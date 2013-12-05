# Windows Azure Puppet module

## Overview

The Windows Azure Puppet module provides fundamental building blocks to help you construct your application in the cloud with ease. This module allows you to provision resources on Windows Azure, such as 
	Virtual Machines
	Virtual Networks
	SQL Databases

## Usage

### class azure::vm

Creates a Virtual Machine(VM) on Windows Azure and boostraps the Puppet agent on to the newly created node to enable configuration management from the Puppet Master.

Parameters:
* vm_size    (default: Small) - Specifies the size of the virtual machine instance.
* image    - Name of the disk image to use to create the virtual machine.
* vm_user  - User name for the virtual machine instance.
* password - Specify SSH password
* location - The location where the virtual machine will be created.
* vm_name  - Name of virtual machine.
* storage_account_name  - (Optional) Name of storage account.
* cloud_service_name    - (Optional) Name of cloud service.
* tcp_endpoints+        - (Optional) Specifies the internal port and external/public port separated by a colon.
                           You can map multiple internal and external ports by separating them with a comma.
* winrm_transport       - (Optional) Specifies WINRM transport protocol.
* ssh_private_key_file  - (Optional) Path of private key file.
* ssh_certificate_file  - (Optional) Path of certificate file.

Examples:
 
    azure::vm { 'vm-1':
      azure_subscription_id => 'your-subscription-id',
      azure_management_certificate => '<path to management certificate>',
      vm_name =>  'demo-vm-1',
      vm_user =>  'user1',
      image =>    '5112500ae3b842c8b9c604889f8753c3__OpenLogic-CentOS-63APR20130415',
      password => 'ComplexPassword',
      location => 'west US',
      homedir => '/home/ranjan'   #For puppet bootstrap
    }

### class azure::db

Create Sql Database Server on Windows Azure and bootstraps the Puppet Agent on the newly created node. 

Parameters:
* login    - The administrator login name.
* password - The administrator login password.
* location - The location where the database server will be created.

Examples:

    azure::db { 'db-1':
      azure_subscription_id => 'your-subscription-id',
      azure_management_certificate => '<path to management certificate>',
      login =>  'user1',
      password =>  'ComplexPassword',
      location =>  'East Us'
    }

### class azure::vnet

Creates a Virtual Network on Windows Azure

Parameters:
* vnet_name    - The name of the virtual network.
* affinity_group_name - The name of the affinity group.
* address_space - Contains a collection of Classless Inter-Domain Routing (CIDR) identifiers that specify the address
                  space that you will use for your local network site
* subnets - (Optional) A hash of the name/value pairs. Contains the name, IPv4 address and Cidr of the DNS server.
* dns_servers - (Optional) A hash of the name/value pairs. Contains the name and IPv4 address of the DNS server.

Examples:

    windowsazure::vnet { 'vnet-1':
      azure_subscription_id => 'your-subscription-id',
      azure_management_certificate => '<path to management certificate>',
      virtual_network_name => 'vnet-name',
      affinity_group_name => 'AG1',
      address_space => ['172.16.0.0/12', '10.0.0.0/8', '192.168.0.0/24'],
      subnets => [
                  {'name' => 'Subnet-2', 'ip_address' => '10.0.0.0', 'cidr' => 8},
                  {'name' => 'Subnet-4', 'ip_address' => '192.168.0.0', 'cidr' => 26}
                 ],
      dns_servers =>[
                     {'name' => 'dns-1', 'ip_address' => '192.8.8.8'},
                     {'name' => 'dns-2', 'ip_address' => '8.8.4.2'}
                    ]
    }

## Supported Platforms

* Windows
* Debian
* Ubuntu
* RHEL
