#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :create do

    summary 'Create Microsoft Azure VM'

    description <<-'EOT'
      The create action create a storage account, cloud service and virtula machine.
    EOT

    Puppet::VirtualMachine.add_create_options(self)

    when_invoked do |options|
      options = ask_for_password(options, @os_type)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      params = {
        vm_name:  options[:vm_name],
        vm_user:  options[:vm_user],
        image:  options[:image],
        password:  options[:password],
        location:  options[:location]
      }
      others = {
        storage_account_name:  options[:storage_account_name],
        cloud_service_name:  options[:cloud_service_name],
        deployment_name:  options[:deployment_name],
        tcp_endpoints:  options[:tcp_endpoints],
        private_key_file:  options[:private_key_file] ,
        certificate_file:  options[:certificate_file],
        ssh_port:  options[:ssh_port],
        vm_size:  options[:vm_size],
        virtual_network_name:  options[:virtual_network_name],
        subnet_name:  options[:virtual_network_subnet],
        affinity_group_name:  options[:affinity_group_name],
        availability_set_name: options[:availability_set_name],
        winrm_http_port:  options[:winrm_http_port],
        winrm_https_port:  options[:winrm_https_port],
      }
      others.merge!(winrm_transport:  options[:winrm_transport]) unless options[:winrm_transport].nil?
      server = virtual_machine_service.create_virtual_machine(params, others)
      unless server.class == String
        if options[:puppet_master_ip] && server
          if  server.os_type == 'Linux'
            options[:node_ipaddress] = server.ipaddress
            options[:ssh_user] = params[:vm_user]
            Puppet::AzurePack::BootStrap.start(options)
          else
            puts
            msg = <<-'EOT'
              To Bootstrap windows node log into the VM and run these commands:
              winrm set winrm/config/service @{AllowUnencrypted="true"}
              winrm set winrm/config/service/auth @{Basic="true"}
              And then run puppet bootstrap command on master.
            EOT
            puts msg
          end
        end
      end
    end

    examples <<-'EOT'
      $ puppet azure_vm create --vm-name vmname --location "Southeast Asia" \
        --management-certificate path-to-azure-certificate --vm-user ranjan \
        --password Password!@12 --storage-account-name storageaccount1'\
        --image  b446e5424aa335e__SUSE-Linux-Enterprise-Server-11-SP2-Agent13 \
        --cloud-service-name cloudname --subscription-id YOUR-SUBSCRIPTION-ID \
        --tcp-endpoints "80,3889:3889"
    EOT
  end
end
