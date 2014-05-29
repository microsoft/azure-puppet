<h1>Microsoft Azure Cloud Provisioner</h1>
              
<p>Microsoft Open Technologies and Puppet Enterprise provide support for working with virtual machine instances using Microsoft Azure. Using actions of the <code>puppet azure_vm</code> sub-command, you can launch and manage Microsoft Microsoft Azure services like virtual machines, virtual networks and SQL database services.</p>

<h2>Required gems</h2>

<p>The required gems and version are listed here.</p>

<p><li>azure (>= 0.6.4)</li>
<li>net-ssh (>= 2.1.4)</li>
<li>net-scp (>= 1.0.4)</li>
</p>

<h2>The provisioner tools</h2>

<p>The main actions used for Azure cloud provisioning include:</p>

<ul>
  <li><code>puppet azure_vm list</code> for viewing existing instances</li>
  <li><code>puppet azure_vm create</code> for creating new instances</li>
  <li><code>puppet azure_vm terminate</code> for destroying no longer needed instances</li>
</ul>

<p>If you are new to Microsoft Azure, we recommend reading the <a href="http://www.windowsazure.com">Getting Started documentation</a>.</p>

<p>Here is a quick look at some of the basic operations. For comprehensive information, see <a href="#getting-more-help">Getting More Help</a> below.</p>

<h2 id="viewing-existing-instances">Viewing existing virtual machines</h2>

<p><a href="http://www.windowsazure.com/en-us/services/virtual-machines/" target="_blank">Virtual Machines</a> are on-demand, scalable compute platforms that allow your business to meet its growing needs. Simply choose your compute configuration and system image and give your systems full obility by transferring your virtual hard disks between on-premises and the cloud.</p>

<p>Let's start by finding out about the currently running virtual machine instances.  You do this by running the <code>puppet azure_vm list</code> command.</p>

<pre><code>$ puppet azure_vm list
</code></pre>

<p>This shows all the running vm instances. For each instance, the following characteristics are shown:</p>

<ul>
  <li>The instance name</li>
  <li>The date the instance was created</li>
  <li>The DNS host name of the instance</li>
  <li>The ID of the instance</li>
  <li>The state of the instance, for example, running or terminated</li>
</ul>

<p><strong>If you have no instances running, nothing will be returned.</strong></p>

<h2 id="creating-a-new-vm-instance">Creating a new virtual machine instance</h2>

<p>New instances are created using the <code>azure_vm create</code> action. The <code>create</code> action simply builds a new virtual machine instance. The bootstrap “wrapper” action creates, classifies, and then initializes the node all in one command.</p>

<h3 id="using-create">Using <code>create</code></h3>

<p>The <code>azure_vm create</code> subcommand is used to build a new virtual machine instance based on a selected AMI image.</p>

<p>The subcommand has some required options:</p>

<ul>
  <li>The management certificate (pem or pfx file) we'd like to use. (<code>--management-certificate</code>)</li>
  <li>The Azure Subscription we'd like to use. (<code>--azure-subscription-id</code>)</li>
  <li>The AMI image we'd like to use. (<code>--image</code>)</li>
  <li>The location we'd like our new vm to run in. (<code>--location</code>)</li>
  <li>The name for our vm. (<code>--vm-name</code>)</li>
  <li>The username and password we'd like to use. (<code>--vm-user --password</code>)</li>
  <li>The puppet master IP address. (<code>--puppet-master-ip</code>)</li>
</ul>

<p>Provide this information and run the command:</p>

<pre><code>$ puppet azure_vm create --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id \
--image b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-13_04-amd64-server-20130501-en-us-30GB --location 'west us' 
--vm-name vmname --vm-user username --password ComplexPassword  --puppet-master-ip 198.62.195.5
</code></pre>

<p>Once launched, you should be able to SSH to the new system using the username and password.</p>

<p>You can also specify a variety of other options, including delete, images, servers and start. You can see a full list of these options
by running <code>puppet help azure_vm create</code>.</p>

<h3 id="using-bootstrap">Using <code>bootstrap</code></h3>

<p>The <code>bootstrap</code> action is a wrapper that combines several actions, allowing you to create, classify, install Puppet on, and sign the certificate of your Azure virtual machine instances. Classification is done via the Console.</p>

<p>The example below will bootstrap a node using a Linux image, located in the US West region.</p>

<pre><code>$ puppet azure_vm create --bootstrap --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id \
--image b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-13_04-amd64-server-20130501-en-us-30GB --location 'west us' 
--vm-name vmname --vm-user username --password ComplexPassword  --puppet-master-ip 198.62.195.5
</code></pre>

<h2 id="virtual-network">Creating and managing a virtual network</h2>

<p><a href="http://www.windowsazure.com/en-us/services/virtual-network/" target="_blank">Virtual Networks</a> are logicaly isolated sections in the cloud that you can then securly connect to your on-premises data center. Virtual networks make it easy to extend your data center and manage it like your on-premises infrastructure.</p>

<p>You can create and manage a virtual network from the command line. Using the virtual_network set action as in this example.</p>

<pre><code>$ puppet azure_vnet set --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id
--virtual-network-name vnetname --affinity-group-name ag-name --address-space '172.16.0.0/12,192.168.0.0/16'
--dns-servers 'dns1-1:10.10.8.8,dns2:172.8.4.4' --subnets 'subnet-1:172.16.0.0:12,subnet-2:192.168.0.0:29'
</code></pre>

<p>Other available actions are list and set_xml_schema which configures the virtual network using a provided xml schema as hown in this example</p>

<pre><code>puppet azure_vnet set_xml_schema --management-certificate ~/exp/azuremanagement.pem --azure-subscription-id=268a3762-fce0-4cd3-a4ea-80e84bddff87
  --xml-schema-file /home/ranjan/network.xml
</code></pre>

<h2 id="sql-database">Creating and managing a SQL database server</h2>

<p><a href="http://www.windowsazure.com/en-us/services/sql-database/" target="_blank">Microsoft Azure SQL Database</a> is a fully managed relational database service that delivers flexible manageability, includes built-in high availability, offers predictable performance, and supports massive scale-out.</p>

<p>You can create and manage a SQL server as in the following example.</p>

<pre><code>$ puppet azure_sqldb create --management-certificate pem-or-pfx-file-path --azure-subscription-id=your-subscription-id \
--management-endpoint=https://management.database.windows.net:8443/ --login loginname --password ComplexPassword --location 'West Us'
</code></pre>

<p>Other available actions are list and set_xml_schema which configures the virtual network using a provided xml schema</p>

<h2 id="cert-management">Certificate Management</h2>

<p>A <a href="http://msdn.microsoft.com/en-us/library/windowsazure/gg981929.aspx" target="_blank">management certificate</a> is needed when you want to use the Service Management API to interact with the Microsoft Azure image platform. Stored at the subscription level, these certificates are independent of any hosted service or deployment.

<p>Currently the sdk supports *.pem or *.pfx (passwordless pfx) for service management operations. 
The following are the steps to obtain and extract you management certificates.</p>

<p>To create a pfx, simply download the publishsettings file for your subscription, copy the contents of Management Certificate from the publishsettings and save it in a file and name the file as your cert.pfx. This pfx will be a passwordless pfx which can be supplied as a cert parameter for Service Management Commands</p>

<p>To extract pem from a custom certificate, export the pfx, use the following openssl commands to extract the pem file and pass the pem file as management cert parameter.</p>

<li>To get only private key from pfx use Openssl.exe pkcs12 -in cert.pfx -nocerts -out cert.pem</li>
<li>To remove passphrase from the above private key use Openssl.exe rsa -in cert.pem -out certprivnopassword.pem</li>
<li>To extract both public & private keys from pfx use Openssl.exe pkcs12 -in cert.pfx -out certprivpub.pem</li>
<li>To extract only public key from pem use Openssl x509 -inform pem -in certprivpub.pem -pubkey -out certpub.pem -outform pem</li>
<li>Finally copy the public key & private key to a file *.pem and pass that pem file to management cert parameter.</li>

<h2 id="getting-more-help">Getting more help</h2>

<p>The <code>puppet azure_vm</code> command has extensive in-line help documentation.</p>

<p>To see the available actions and command line options, run:</p>

<pre><code>$ puppet help azure_vm &lt;action&gt;

This subcommand provides a command line interface to work with Microsoft Azure virtual
machine instances. The goal of these actions are to easily create new
machines, install Puppet onto them, and tear them down when they're no longer
required.

OPTIONS:
  --mode MODE                    - The run mode to use (user, agent, or master).
  --render-as FORMAT             - The rendering format to use.
  --verbose                      - Whether to log verbosely.
  --debug                        - Whether to log debug information.

ACTIONS:
  bootstrap        Install puppet node on a Microsoft Azure VM
  create           Create a Microsoft Azure VM
  delete           Delete a Microsoft Azure node instance
  servers          List Microsoft Azure node instances
  shutdown         Shutdown Microsoft Azure node instance
  start            Starts Microsoft Azure node instance

See 'puppet help azure_vm' or 'help puppet-azure_vm' for full help.
</code></pre>

<p>For more detailed help you can also view the help page .</p>

<pre><code>$ puppet help azure_vm
</code></pre>

<p>You can get help on individual actions by running:</p>

<pre><code>$ puppet help azure_vm &lt;ACTION&gt;
</code></pre>

<p>For example,</p>

<pre><code>$ puppet help azure_vm list
</code></pre>
