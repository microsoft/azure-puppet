#-------------------------------------------------------------------------
# Copyright 2013 Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

Puppet::Face.define :node_azure, '0.0.1' do
  action :create do

    summary 'Create Windows Azure VM'

    description <<-'EOT'
      The create action create a storage account, cloud service and vm.
    EOT

    Puppet::VirtualMachine.add_create_options(self)

    when_invoked do |options|
      options = ask_for_password(options, @os_type)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      params = {
        :vm_name=> options[:vm_name],
        :vm_user=> options[:vm_user],
        :image=> options[:image],
        :password => options[:password],
        :location => options[:location]
      }
      others = {
        :storage_account_name=> options[:storage_account_name],
        :cloud_service_name=> options[:cloud_service_name],
        :deployment_name => options[:deployment_name],
        :tcp_endpoints => options[:tcp_endpoints],
        :private_key_file => options[:private_key_file] ,
        :certificate_file => options[:certificate_file],
        :ssh_port => options[:ssh_port],
        :vm_size => options[:vm_size],
        :vitual_network_name => options[:virtual_network_name],
        :subnet_name => options[:virtual_network_subnet],
        :affinity_group_name => options[:affinity_group_name]
      }
      others.merge!(:winrm_transport => options[:winrm_transport]) unless options[:winrm_transport].nil?
      server = virtual_machine_service.create_virtual_machine(params, others)
      unless server.class == String
        options[:node_ipaddress] = server.ipaddress
        if options[:puppet_master_ip] && server
          test_tcp_connection(server)
          if  server.os_type == 'Linux'
            Puppet::CloudPack::BootStrap.start(options)
          else
            puts '\npuppet installation on windows is not yet implemented.'
          end
        end
      end
    end

    examples <<-'EOT'
      $ puppet node_azure create --publish-settings-file azuremanagement.publishsettings --vm-name vmname\
           --vm-user ranjan  --password Password!@12  --storage-account-name storageaccount1'\
           --image  b4590d9e3ed742e4a1d46e5424aa335e__SUSE-Linux-Enterprise-Server-11-SP2-Agent13\
           --cloud-service-name cloudname --subscription-id 2346a-fce0-4cd3-a4ea-80e84bddff87\
           --service-location "Southeast Asia" --tcp-endpoints "80,3889:3889"
    EOT
  end
end