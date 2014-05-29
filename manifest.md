<h1>Microsoft Open Technologies manifest files for Puppet</h1>
              
<p>Microsoft Open Technologies is providing a Microsoft Azure Cloud Provisioner Module for Puppet that streamlines provisioning Microsoft Azure services like, virtual machines, virtual networks and SQL database services.
</p>

<h2>Requirements</h2>

<p>To enable bootstrapping Puppet agent, the following Windows Remote Management (WinRM) settings need to be updated.</p>

<p>To update these settings run these commands.</p>

<pre><code>$ winrm set winrm/config/service @{AllowUnencrypted="true"}

$ winrm set winrm/config/service/auth @{Basic="true"}
</code></pre>

<p>The following gems are also required.</p>

<p><li>azure (>= 0.6.4)</li>
<li>net-ssh (>= 2.1.4)</li>
<li>net-scp (>= 1.0.4)</li>
</p>

<h2>Microsoft Azure</h2>

To provision a puppet agent on the Microsoft Azure platform, run the following command.

<pre><code>puppet module install msopentech/microsoftazure --version 1.2.1</code></pre>

For more information on Microsoft Azure, <a href="http://www.windowsazure.com/en-us/solutions/infrastructure/" tartget="_blank">visit the Microsoft Azure website</a>.

<h2>Manifest files</h2>

<p>Manifest files are collections of definitions, references (Including other manifest files.) and commands that enable you to quickly and repeatably deploy a configured virtual machine, virtual network or SQL database. 
There are provided manifest files which are listed below, the parameters they use and their defaults. Parameters with the value "undef" require you to supply the appropriate value.</p>

<p><strong>Enabling the puppet agent</strong><br />
Bootstrap.pp allows you to create a new instance with Puppet already installed and configured. When using the class, the reference will be,

<pre><code>microsoftazure::bootstrap</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$homedir = undef,
$puppet_master_ip,
$node_ipaddress,
$ssh_user = undef,
$winrm_user = undef,
$private_key_file = undef,
$winrm_port = undef,
$password = undef,
$ssh_port = 22,
$winrm_transport = 'http'</code></pre>

<p><strong>Creating a database</strong><br />
db.pp allows you to create a new instance of SQL server. When using the class, the reference will be,

<pre><code>microsoftazure::db</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$azure_management_certificate,
$azure_subscription_id,
$login,
$password,
$location</code></pre>

<p><strong>Creating a vm</strong><br />
vm.pp allows you to create a new virtual machine instance. When using the class, the reference will be,

<pre><code>microsoftazure::VM</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$vm_name,
$vm_user,
$image,
$location,
$homedir = undef,
$azure_management_certificate,
$azure_subscription_id,
$vm_size = 'Small',
$puppet_master_ip = undef,
$private_key_file = undef,
$certificate_file = undef ,
$storage_account_name = undef,
$cloud_service_name = undef,
$password = undef</code></pre>

<p><strong>Creating a virtual network</strong><br />
vnet.pp allows you to create a new virtual network instance. When using the class, the reference will be,

<pre><code>microsoftazure::vnet</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$azure_management_certificate,
$azure_subscription_id,
$virtual_network_name,
$affinity_group_name,
$address_space,
$subnets = undef,
$dns_servers = undef</code></pre>

<p><strong>Creating a virtual network, sql db and virtual machine</strong><br />
provisioner.pp allows you to create a new virtual network instance, sql db and virtual network. When using the class, the reference will be,

<pre><code>microsoftazure::provisioner</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$azure_management_certificate,
$azure_subscription_id,
$create_vnet, #true or false
$virtual_network_name,
$affinity_group_name,
$address_space,
$subnets,
$dns_servers,
$create_vm,  #true or false
$vm_name,
$vm_user,
$image,
$location,
$homedir,
$azure_management_certificate,
$azure_subscription_id,
$vm_size = 'Small',
$puppet_master_ip,
$private_key_file,
$certificate_file,
$storage_account_name,
$cloud_service_name,
$password,
$create_sqldb,   #true or false
$login,
$password,
$location</code></pre>

<p><strong>Creating a cloud service</strong><br />
cloudservice.pp allows you to create a new cloud service. When using the class, the reference will be,

<pre><code>microsoftazure::cloudservice</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$azure_management_certificate,
$azure_subscription_id,
$cloud_service_name,
$affinity_group_name,
$location,
$label = undef,
$description = undef
</code></pre>

<p><strong>Creating a storage account</strong><br />
storage.pp allows you to create a new storage account. When using the class, the reference will be,

<pre><code>microsoftazure::storage</code></pre>

This manifest takes the following parameters.</p>

<pre><code>
$azure_management_certificate,
$azure_subscription_id,
$storage_account_name,
$affinity_group_name,
$location,
$label = undef,
$description = undef
</code></pre>

