require 'puppet/application_config'
include Puppet::ApplicationConfig

module Puppet::VirtualMachine

  class << self
    
    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_vm/views', name)
    end

    def add_shutdown_options(action)
      add_deployment_options(action)
      add_vm_name_option(action,false)
    end

    def add_delete_options(action)
      add_default_options(action)
      add_vm_name_option(action,false)
      add_cloud_service_name_option(action,false)
    end

    def add_deployment_options(action)
      add_default_options(action)
      add_cloud_service_name_option(action,false)
    end

    def add_bootstrap_options(action)
      add_default_options(action)
      add_node_ipaddress_options(action)
      add_password_option(action)
      add_ssh_user_option(action)
      add_ssh_port_option(action)
      add_winrm_user_option(action)
      add_winrm_port_option(action)
      add_puppet_master_ip_option(action, false)
      add_certificate_file_option(action)
      add_private_key_file_option(action)
      add_bootstrap_winrm_transport_option(action)
    end

    def add_create_options(action)
      add_default_options(action)
      add_image_option(action)
      add_vm_name_option(action, false)
      add_storage_account_option(action)
      add_cloud_service_name_option(action)
      add_deployment_name_option(action)
      add_vm_user_option(action)
      add_password_option(action)
      add_puppet_master_ip_option(action)
      add_end_points_option(action)
      add_location_option(action)
      add_vm_size_option(action)
      add_ssh_port_option(action)
      add_certificate_file_option(action)
      add_private_key_file_option(action)
      add_winrm_transport_option(action)
      add_virtual_network_option(action)
      add_subnet_option(action)
      add_affinity_group_option(action)
    end

    def add_vm_name_option(action, optional=true)
      action.option '--vm-name=' do
        summary 'The name of the virtual machine.'
        description <<-EOT
          The name of the virtual machine.
        EOT
        required unless optional
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
          if options[:vm_name].empty?
            raise ArgumentError, "VM Name is required."
          end
        end
      end
    end

    def add_image_option(action)
      action.option '--image=' do
        summary 'The name of the disk image that will be used to create the virtual machine'
        description <<-EOT
          The name of the disk image that will be used to create the virtual machine
        EOT
        required
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
          if options[:image].empty?
            raise ArgumentError, "Source image name is required"
          else
            Puppet::VirtualMachine.initialize_env_variable(options)
            image_service = Azure::VirtualMachineImageManagementService.new
            os_image = image_service.list_virtual_machine_images.select{|x| x.name == options[:image]}.first
            raise ArgumentError, "Source image name is invalid" unless os_image
            @os_type = os_image.os_type
          end
        end
      end
    end

    def add_storage_account_option(action)
      action.option '--storage-account-name=' do
        summary 'The name of the storage account used with the cloud service.'
        description <<-EOT
          The name of the storage account used with the cloud service
        EOT
      end
    end

    def add_cloud_service_name_option(action, optional=true)
      action.option '--cloud-service-name=' do
        summary 'The name of the cloud service.'
        description <<-EOT
          The name of the cloud service.
        EOT
        required unless optional
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
          if options[:cloud_service_name].empty?
            raise ArgumentError, "Cloud service name is required."
          end
        end
      end
    end

    def add_vm_user_option(action, optional=true)
      action.option '--vm-user=' do
        summary 'The VM user name.'
        description <<-EOT
          The VM user name. It mandatory incase of liunx VM installation.
        EOT
        required unless optional
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
          if options[:vm_user].empty?
            raise ArgumentError, "The VM user name is required."
          end
        end
      end
    end

    def add_puppet_master_ip_option(action, optional=true)
      action.option '--puppet-master-ip=' do
        summary 'The puppet master ip address.'
        description <<-EOT
          The puppet master ip address. It mandatory incase of puppet node installation.
        EOT
        required if !optional
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
          if options[:puppet_master_ip].empty?
            raise ArgumentError, "The pupet master ip address is required."
          end
        end
      end
    end

    def add_deployment_name_option(action, optional=true)
      action.option '--deployment-name=' do
        summary 'The vm instance deployment name.'
        description <<-EOT
          The vm instance deployment name.
        EOT
        required unless optional
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
          if options[:deployment_name].empty?
            raise ArgumentError, "Deployment name is required."
          end
        end
      end
    end

    def add_password_option(action)
      action.option '--password=' do
        summary 'Authentication password for vm.'
        description <<-EOT
          Authentication password for vm.
        EOT
        required if @os_type == 'Windows'
        before_action do |action, args, options|
          if options[:password].empty?
            raise ArgumentError, "The password is required."
          end
        end
      end
    end

    def add_end_points_option(action)
      action.option '--tcp-endpoints=' do
        summary 'Tcp End Points. '
        description <<-EOT
          Add Tcp end points. example --tcp-endpoints="80,3889:3889"
        EOT

      end
    end

    def add_node_ipaddress_options(action)
      action.option '--node-ipaddress=' do
        summary 'Node Ip address. '
        description <<-EOT
          The ip address where puppet need to install."
        EOT
        required
        before_action do |action, args, options|
          if options[:ssh_user].nil? && options[:winrm_user].nil?
            raise ArgumentError, "winrm_user or ssh_user is required."
          elsif options[:ssh_user].nil?
            @os_type = 'Windows'
          elsif options[:winrm_user].nil?
            @os_type = 'Linux'
          end
          if options[:node_ipaddress].empty?
            raise ArgumentError, "The Node ip address is require."
          end
        end
      end
    end

    def add_certificate_file_option(action)
      action.option '--certificate-file=' do
        summary "Authentication using certificate instead of password."
        description <<-EOT
          Authentication using certificate instead of password.
        EOT
        before_action do |action, args, options|
          unless test 'f', options[:certificate_file]
            raise ArgumentError, "Could not find file '#{options[:certificate_file]}'"
          end
          unless test 'r', options[:certificate_file]
            raise ArgumentError, "Could not read from file '#{options[:certificate_file]}'"
          end
        end
      end
    end

    def add_private_key_file_option(action)
      action.option '--private-key-file=' do
        summary "Authentication using certificate instead of password."
        description <<-EOT
          Authentication using certificate instead of password..
        EOT
        before_action do |action, args, options|
          unless test 'f', options[:private_key_file]
            raise ArgumentError, "Could not find file '#{options[:private_key_file]}'"
          end
          unless test 'r', options[:private_key_file]
            raise ArgumentError, "Could not read from file '#{options[:private_key_file]}'"
          end
        end
      end
    end

    def add_winrm_transport_option(action)
      action.option '--winrm-transport=' do
        summary "Winrm authentication protocol. Valid choices are http or https or http,https"
        description <<-EOT
          Winrm authentication protocol. Valid choices are http or https or http,https.
        EOT
        before_action do |action, args, options|
          winrm_transport = options[:winrm_transport].split(",")
          unless (!winrm_transport.nil? && (winrm_transport.select{|x| x.downcase == 'http' or x.downcase == 'https'}.size > 0))
            raise ArgumentError, "The winrm transport is not valid. Valid choices are http or https or http,https"
          end
          options[:winrm_transport] = winrm_transport
        end
      end
    end

    def add_ssh_port_option(action)
      action.option '--ssh-port=' do
        summary 'Port for ssh server.'
        description <<-EOT
          Port for ssh server.
        EOT
      end
    end

    def add_vm_size_option(action)
      action.option '--vm-size=' do
        summary 'The instance size. valid choice are ExtraSmall, Small, Medium, Large, ExtraLarge'
        description <<-EOT
          The instance size. valid choice are ExtraSmall, Small, Medium, Large, ExtraLarge
        EOT
        before_action do |action, args, options|
          valid_role_sizes = ['ExtraSmall', 'Small', 'Medium', 'Large', 'ExtraLarge', 'A6', 'A7']
          if options[:vm_size] && !valid_role_sizes.include?(options[:vm_size])
            raise ArgumentError, "The vm-size is not valid. Valid choices are valid choice are ExtraSmall, Small, Medium, Large, ExtraLarge"
          end
        end
      end
    end

    def add_virtual_network_option(action)
      action.option '--virtual-network-name=' do
        summary 'The virtual network name.'
        description <<-EOT
          The name of virtual network.
        EOT

      end
    end

    def add_subnet_option(action)
      action.option '--virtual-network-subnet=' do
        summary 'The virtual network subnet.'
        description <<-EOT
          The subnet of virtual network.
        EOT

      end
    end

    def add_affinity_group_option(action)
      action.option '--affinity-group-name=' do
        summary 'The affinity group name.'
        description <<-EOT
          The name of affinity group.
        EOT

      end
    end

    def add_ssh_user_option(action)
      action.option '--ssh-user=' do
        summary 'The VM user name.'
        description <<-EOT
          The ssh user name. It mandatory incase of liunx VM installation.
        EOT
        required if @os_type == 'Linux'
        before_action do |action, args, options|
          if options[:ssh_user].empty?
            raise ArgumentError, "The ssh username is required."
          end
        end
      end
    end

    def add_winrm_user_option(action)
      action.option '--winrm-user=' do
        summary 'The winrm user name.'
        description <<-EOT
          The winrm user name. It mandatory incase of Windows puppet agent installation.
        EOT
        required if @os_type == 'Windows'
        before_action do |action, args, options|
          if options[:winrm_user].empty?
            raise ArgumentError, "The winrm username is required."
          end
        end
      end
    end

    def add_winrm_port_option(action)
      action.option '--winrm-port=' do
        summary 'Port for winrm.'
        description <<-EOT
          Port for winrm.
        EOT
      end
    end

    def add_bootstrap_winrm_transport_option(action)
      action.option '--winrm-transport=' do
        summary "Winrm authentication protocol. Valid choices are http or https"
        description <<-EOT
          Winrm authentication protocol. Valid choices are http or https.
        EOT
        before_action do |action, args, options|
          winrm_transport = options[:winrm_transport]
          unless (['http', 'https', nil].include?(winrm_transport))
            raise ArgumentError, "The winrm transport is not valid. Valid choices are http or https"
          end

        end
      end
    end
  end
end
