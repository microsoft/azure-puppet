Windows Azure Cloud Provisioner
========================

Puppet Module to launch and manage Microsoft Windows Azure Services like Virtual Machines, Virtual Network and SQL Database services.

This module requires Puppet 2.7.2 or later.

# Library Features
* Virtual Machine Management
    * Images
	* list images	
    * Virtual Machines
        * create linux based VMs and ssh with cert and key option enabled for ssh and WINRM (both http & https)enabled for windows based VMs
	* list, shut down, delete, find virtual machine deployments. While shutting down your VMs the provisioning state would be deallocated and this VM will not be included in the billing cycle.
        * Create VM for a specific virtual network

* Virtual Network Management
    * List VNet
    * Create VNet
    	* via parameters
    	* via xml file
    	
* SQL Database Server Management
	* list, create, list sqldb servers & password reset for a sqldb server
	* list, set, delete firewall rules for a sqldb server


Getting Started
===============

Required Gems
=============

 * azure (>= 0.6.0)
 * net-ssh (>= 2.1.4)
 * net-scp (>= 1.0.4)
 * winrm (>= 1.1.3)

Manage Virtual machine
========================

You may launch a new instance and install puppet agent with this module installed using the following single command:

    $puppet azure_vm create --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id \
    --image b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-13_04-amd64-server-20130501-en-us-30GB --location 'west us' 
    --vm-name vmname --vm-user username --password ComplexPassword  --puppet-master-ip 198.62.195.5

Once launched, you should be able to SSH to the new system using the username and password.

Other avaliable actions are

  
    bootstrap    Install puppet node on  Windows Azure VM
    create       Create Windows Azure VM
    delete       Delete Windows Azure node instances
    images       List Windows Azure images
    locations    List Windows Azure locations
    servers      List Windows Azure node instances
    shutdown     Shutdown Windows Azure node instances
    start        starts Windows Azure node instances

To list all options for any action

    $puppet help azure_vm ACTION-NAME

Manage Virtual Network
========================

Creating virtual network

    $puppet azure_vnet set --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id
    --virtual-network-name vnetname --affinity-group-name ag-name --address-space '172.16.0.0/12,192.168.0.0/16'
    --dns-servers 'dns1-1:10.10.8.8,dns2:172.8.4.4' --subnets 'subnet-1:172.16.0.0:12,subnet-2:192.168.0.0:29'

Other avaliable actions are

    list              List virtual networks.
    set               Set Network configures the virtual network
    set_xml_schema    set_xml_schema Network configures the virtual network using xml schema

Manage SQL database server
========================

Creating SQL database server

    $puppet azure_sqldb create --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id \
    --management-endpoint=https://management.database.windows.net:8443/ --login loginname --password ComplexPassword --location 'West Us'

Other avaliable actions are

    create             Create SQL database server.
    create_firewall    Create SQL database firewall rule on a server.
    delete             Delete Windows Azure sql database server
    delete_firewall    Delete Windows Azure sql database firewall rule on a server.
    list               List SQL database servers.
    list_firewall      List firewall of SQL database servers.
    reset_password     Reset password of sql database server.


# Certificate Management

* Currently the sdk supports *.pem or *.pfx (passwordless pfx) for service management operations. Following are the steps discussed on various cert operations.

	* To create pfx, simply download the publishsettings file for your subscription, copy the contents of Management Certificate from the publishsettings and save it in a file and name the file
	  as your cert.pfx. This pfx will be a passwordless pfx which can be supplied as a cert parameter for Service Management Commands

	* Using the following openssl commands to extract the pem file and pass the pem file as management cert parameter.

		* To get only private key from pfx use Openssl.exe pkcs12 -in cert.pfx -nocerts -out cert.pem

		* To remove passphrase from the above private key use Openssl.exe rsa -in cert.pem -out certprivnopassword.pem

		* To extract both public & private keys from pfx use Openssl.exe pkcs12 -in cert.pfx -out certprivpub.pem

		* To extract only public key from pem use Openssl x509 -inform pem -in certprivpub.pem -pubkey -out certpub.pem -outform pem

		* Finally copy the public key & private key to a file *.pem and pass that pem file to management cert parameter.

	* To extract pem from custom certificate, export the pfx, follow the above steps to convert to pem and pass that pem file to management cert parameter.
	

Puppet Installation
===================

http://docs.puppetlabs.com/guides/installation.html#installing-puppet-1


