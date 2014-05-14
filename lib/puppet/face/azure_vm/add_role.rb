#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :add_role do

    summary 'Create multiple roles under the same cloud service'

    description <<-'EOT'
      The add_role action create multiple roles under the same cloud service.
      Atleast a single deployment should be created under a hosted service.
    EOT

    Puppet::VirtualMachine.add_create_options(self, true)

    when_invoked do |options|
      options = ask_for_password(options, @os_type)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      params = {
        vm_name:  options[:vm_name],
        vm_user:  options[:vm_user],
        image:  options[:image],
        password:  options[:password],
        cloud_service_name:  options[:cloud_service_name],
      }

      others = {
        storage_account_name:  options[:storage_account_name],
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
      winrm_tp = options[:winrm_transport]
      others.merge!(winrm_transport:  winrm_tp) unless winrm_tp.nil?
      server = virtual_machine_service.add_role(params, others)
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
      $ puppet azure_vm add_role --vm-name vmname --location "Southeast Asia" \
        --management-certificate path-to-azure-certificate --vm-user ranjan \
        --password Password!@12 --storage-account-name storageaccount1'\
        --image  b446e5424aa335e__SUSE-Linux-Enterprise-Server-11-SP2-Agent13 \
        --cloud-service-name cloudname --subscription-id YOUR-SUBSCRIPTION-ID \
        --tcp-endpoints "80,3889:3889"
    EOT
  end
end
