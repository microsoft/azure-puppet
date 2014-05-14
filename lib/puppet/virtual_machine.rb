#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/application_config'
require 'puppet/option_validation'
include Puppet::ApplicationConfig
include Puppet::OptionValidation
module Puppet
  module VirtualMachine
    class << self
      def views(name)
        File.join(File.dirname(__FILE__), 'face/azure_vm/views', name)
      end

      def add_list_images_options(action)
        add_default_options(action)
        add_location_option(action, true)
      end

      def add_data_disk_options(action)
        add_default_options(action)
        add_cloud_service_name_option(action, false)
        add_vm_name_option(action, false)
        add_disk_import_option(action)
        add_disk_name_option(action)
        add_disk_size_option(action)
        add_disk_label_option(action)
      end

      def update_endpoint_options(action)
        add_default_options(action)
        add_cloud_service_name_option(action, false)
        add_vm_name_option(action, false)
        add_endpoint_name_option(action)
        add_public_port_option(action)
        add_local_port_option(action)
        add_protocol_option(action)
        add_load_balancer_name_option(action)
        add_direct_server_return_option(action)
        add_load_balancer_port_option(action)
        add_load_balancer_protocol_option(action)
        add_load_balancer_path_option(action)
      end

      def delete_endpoint_options(action)
        add_default_options(action)
        add_cloud_service_name_option(action, false)
        add_vm_name_option(action, false)
        add_endpoint_name_option(action)
      end

      def add_shutdown_options(action)
        add_default_options(action)
        add_cloud_service_name_option(action, false)
        add_vm_name_option(action, false)
      end

      def add_delete_options(action)
        add_default_options(action)
        add_vm_name_option(action, false)
        add_cloud_service_name_option(action, false)
      end

      def add_bootstrap_options(action)
        add_node_ipaddress_options(action)
        add_password_option(action)
        add_ssh_user_option(action)
        add_ssh_port_option(action)
        add_winrm_user_option(action)
        add_winrm_port_option(action)
        add_puppet_master_ip_option(action, false)
        add_private_key_file_option(action)
        add_bootstrap_winrm_transport_option(action)
        add_agent_environment_options(action)
      end

      def add_create_options(action, add_role = false)
        add_default_options(action)
        if add_role
          add_cloud_service_name_option(action, false)
        else
          add_cloud_service_name_option(action)
          add_deployment_name_option(action)
          add_location_option(action)
        end
        add_image_option(action)
        add_vm_name_option(action, false)
        add_storage_account_option(action)
        add_vm_user_option(action, false)
        add_password_option(action)
        add_puppet_master_ip_option(action)
        add_end_points_option(action)
        add_vm_size_option(action)
        add_ssh_port_option(action)
        add_winrm_http_port_option(action)
        add_winrm_https_port_option(action)
        add_certificate_file_option(action)
        add_private_key_file_option(action)
        add_winrm_transport_option(action)
        add_virtual_network_option(action)
        add_subnet_option(action)
        add_affinity_group_option(action)
        add_availability_set_options(action)
      end

      def add_vm_name_option(action, optional = true)
        action.option '--vm-name=' do
          summary 'The name of the virtual machine.'
          description 'The name of the virtual machine.'
          required unless optional
          before_action do |act, args, options|
            if options[:vm_name].empty?
              fail ArgumentError, 'VM Name is required.'
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
          before_action do |act, args, options|
            if options[:image].empty?
              fail ArgumentError, 'Source image name is required'
            else
              Puppet::VirtualMachine.initialize_env_variable(options)
              image_service = Azure::VirtualMachineImageManagementService.new
              images = image_service.list_virtual_machine_images
              os_image = images.select { |x| x.name == options[:image] }.first
              fail ArgumentError, 'Source image name is invalid' unless os_image
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

      def add_cloud_service_name_option(action, optional = true)
        action.option '--cloud-service-name=' do
          summary 'The name of the cloud service.'
          description 'The name of the cloud service.'
          required unless optional
          before_action do |act, args, options|
            if options[:cloud_service_name].empty?
              fail ArgumentError, 'Cloud service name is required.'
            end
          end
        end
      end

      def add_vm_user_option(action, optional = true)
        action.option '--vm-user=' do
          summary 'The VM user name.'
          description <<-EOT
          The VM user name. It mandatory incase of liunx VM installation.
          EOT
          required unless optional
          before_action do |act, args, options|
            if options[:vm_user].empty?
              fail ArgumentError, 'The VM user name is required.'
            end
          end
        end
      end

      def add_puppet_master_ip_option(action, optional = true)
        action.option '--puppet-master-ip=' do
          summary 'The puppet master ip address.'
          description <<-EOT
          The puppet master ip address.
          It mandatory incase of puppet node installation.
          EOT
          required unless optional
          before_action do |act, args, options|
            if options[:puppet_master_ip].empty?
              fail ArgumentError, 'The pupet master ip address is required.'
            end
          end
        end
      end

      def add_deployment_name_option(action, optional = true)
        action.option '--deployment-name=' do
          summary 'The vm instance deployment name.'
          description 'The vm instance deployment name.'
          required unless optional
          before_action do |act, args, options|
            if options[:deployment_name].empty?
              fail ArgumentError, 'Deployment name is required.'
            end
          end
        end
      end

      def add_password_option(action)
        action.option '--password=' do
          summary 'Authentication password for vm.'
          description 'Authentication password for vm.'
          required if @os_type == 'Windows'
          before_action do |act, args, options|
            if options[:password].empty?
              fail ArgumentError, 'The password is required.'
            end
          end
        end
      end

      def add_end_points_option(action)
        action.option '--tcp-endpoints=' do
          summary 'Tcp end points. '
          description 'Add Tcp end points. example --tcp-endpoints="80,3889:3889"'
        end
      end

      def add_node_ipaddress_options(action)
        action.option '--node-ipaddress=' do
          summary 'Node Ip address. '
          description 'The ip address where puppet need to install.'
          required
          before_action do |act, args, options|
            validate_bootstrap_options(options)
            if options[:node_ipaddress].empty?
              fail ArgumentError, 'The Node ip address is require.'
            end
          end
        end
      end

      def add_certificate_file_option(action)
        action.option '--certificate-file=' do
          summary 'Authentication using certificate instead of password.'
          description 'Authentication using certificate instead of password.'
          before_action do |act, args, options|
            file_path = options[:certificate_file]
            unless test 'f', file_path
              fail ArgumentError, "Could not find file '#{file_path}'"
            end
            unless test 'r', file_path
              fail ArgumentError, "Could not read from file '#{file_path}'"
            end
          end
        end
      end

      def add_private_key_file_option(action)
        action.option '--private-key-file=' do
          summary 'Authentication using certificate instead of password.'
          description 'Authentication using certificate instead of password.'
          before_action do |act, args, options|
            file_path = options[:private_key_file]
            unless test 'f', file_path
              fail ArgumentError, "Could not find file '#{file_path}'"
            end
            unless test 'r', file_path
              fail ArgumentError, "Could not read from file '#{file_path}'"
            end
          end
        end
      end

      def add_winrm_transport_option(action)
        action.option '--winrm-transport=' do
          summary 'Winrm authentication protocol default is http.'
          description <<-EOT
          Winrm authentication protocol.
          Valid choices are http or https or http,https.
          EOT
          before_action do |act, args, options|
            winrm_transport = options[:winrm_transport].split(',')
            winrm_transport_size = winrm_transport.select do
              |x| x.downcase == 'http' || x.downcase == 'https'
            end.size
            unless !winrm_transport.nil? && (winrm_transport_size > 0)
              fail ArgumentError, 'The winrm transport is not valid. Valid choices are http or https or http,https'
            end
            options[:winrm_transport] = winrm_transport
          end
        end
      end

      def add_ssh_port_option(action)
        action.option '--ssh-port=' do
          summary 'Port for ssh server.'
          description 'Port for ssh server.'
        end
      end

      def add_vm_size_option(action)
        action.option '--vm-size=' do
          role_sizes = %w(ExtraSmall Small Medium Large ExtraLarge A5 A6 A7 Basic_A0 Basic_A1 Basic_A2 Basic_A3 Basic_A4)
          summary "The instance size. valid choice are #{role_sizes.join(', ')}"
          description <<-EOT
          The instance size. valid choice are #{role_sizes.join(', ')}
          EOT
          before_action do |act, args, options|
            if options[:vm_size] && !role_sizes.include?(options[:vm_size])
              fail ArgumentError, "The vm-size is not valid. Valid choice are #{role_sizes.join(', ')}"
            end
          end
        end
      end

      def add_virtual_network_option(action)
        action.option '--virtual-network-name=' do
          summary 'The virtual network name.'
          description 'The name of virtual network.'
        end
      end

      def add_subnet_option(action)
        action.option '--virtual-network-subnet=' do
          summary 'The virtual network subnet.'
          description 'The subnet of virtual network.'
        end
      end

      def add_affinity_group_option(action)
        action.option '--affinity-group-name=' do
          summary 'The affinity group name.'
          description 'The name of affinity group.'
        end
      end

      def add_ssh_user_option(action)
        action.option '--ssh-user=' do
          summary 'The VM user name.'
          description <<-EOT
          The ssh user name. It mandatory incase of liunx VM installation.
          EOT
          required if @os_type == 'Linux'
          before_action do |act, args, options|
            if options[:ssh_user].empty?
              fail ArgumentError, 'The ssh username is required.'
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
          before_action do |act, args, options|
            if options[:winrm_user].empty?
              fail ArgumentError, 'The winrm username is required.'
            end
          end
        end
      end

      def add_winrm_port_option(action)
        action.option '--winrm-port=' do
          summary 'Port for winrm.'
          description 'Port for winrm.'
        end
      end

      def add_bootstrap_winrm_transport_option(action)
        action.option '--winrm-transport=' do
          summary 'Winrm authentication protocol. Valid choices are http or https'
          description <<-EOT
          Winrm authentication protocol. Valid choices are http or https.
          EOT
          before_action do |act, args, options|
            winrm_transport = options[:winrm_transport]
            unless ['http', 'https', nil].include?(winrm_transport)
              fail ArgumentError, 'The winrm transport is not valid. Valid choices are http or https'
            end
          end
        end
      end

      def add_agent_environment_options(action)
        action.option '--agent-environment=' do
          summary 'Pupppet agent environment. default is production'
          description 'Pupppet agent environment. default is production'
        end
      end

      def add_availability_set_options(action)
        action.option '--availability-set-name=' do
          summary 'Availability set name of virtual machine'
          description 'Availability set name of virtual machine'
        end
      end

      def add_disk_name_option(action)
        action.option '--disk-name=' do
          summary 'Specifies the name of the disk'
          description <<-EOT
            Specifies the name of the disk. Reqruied if import is set to true.
          EOT
        end
      end

      def add_disk_import_option(action)
        action.option '--import=' do
          summary 'if true, then allows to use an existing disk by disk name. if false, then create and attach new data disk.'
          description <<-EOT
            if true, then allows to use an existing disk by disk name.
            if false, then create and attach new data disk.
          EOT
          before_action do |act, args, options|
            options[:import] ||=  'false'
            unless ['true', 'false', nil].include?(options[:import])
              fail ArgumentError, 'Disk import option is not valid. Valid choices are true or false'
            end
            if options[:disk_name].nil? && options[:import] == 'true'
              fail ArgumentError, 'Disk name is required when import is true.'
            end
          end
        end
      end

      def add_disk_size_option(action)
        action.option '--disk-size=' do
          summary 'Specifies the size of disk in GB'
          description <<-EOT
            Specifies the size of disk in GB
          EOT
        end
      end

      def add_disk_label_option(action)
        action.option '--disk-label=' do
          summary 'Specifies the label of the data disk.'
          description <<-EOT
            Specifies the description of the data disk.
          EOT
        end
      end

      def add_endpoint_name_option(action)
        action.option '--endpoint-name=' do
          summary 'Name of endpoint.'
          description 'Name of endpoint'
          required
          before_action do |act, args, options|
            if options[:endpoint_name].empty?
              fail ArgumentError, 'Endpoint name is required.'
            end
          end
        end
      end

      def add_public_port_option(action)
        action.option '--public-port=' do
          summary 'Specifies the external port to use for the endpoint.'
          description 'Specifies the external port to use for the endpoint.'
          required
          before_action do |act, args, options|
            if options[:public_port].empty?
              fail ArgumentError, 'Public port is required.'
            end
          end
        end
      end

      def add_local_port_option(action)
        action.option '--local-port=' do
          summary 'Specifies the internal port on which the Virtual Machine is listening.'
          description 'Specifies the internal port on which the Virtual Machine is listening.'
          required
          before_action do |act, args, options|
            if options[:local_port].empty?
              fail ArgumentError, 'Local port is required.'
            end
          end
        end
      end

      def add_protocol_option(action)
        action.option '--protocol=' do
          summary 'pecifies the transport protocol for the endpoint.'
          description <<-EOT
            Specifies the transport protocol for the endpoint.
            Possible values are: TCP, UDP. Default is TCP
          EOT
          before_action do |act, args, options|
            unless %w(tcp udp).include?(options[:protocol].downcase)
              fail 'Protocol is invalid. Allowed values are tcp,udp'
            end
          end
        end
      end

      def add_load_balancer_name_option(action)
        action.option '--load-balancer-name=' do
          summary 'Specifies a name for a load-balanced endpoint.'
          description 'Specifies a name for a load-balanced endpoint.'
        end
      end

      def add_direct_server_return_option(action)
        action.option '--direct-server-return=' do
          summary 'Specifies whether the endpoint uses Direct Server Return'
          description <<-EOT
          Specifies whether the endpoint uses Direct Server Return.
          Possible values are: true, false. Default is false.
          EOT
          before_action do |act, args, options|
            unless %w(true false).include?(options[:direct_server_return].downcase)
              fail 'direct_server_return is invalid. Allowed values are true,false'
            end
          end
        end
      end

      def add_load_balancer_port_option(action)
        action.option '--load-balancer-port=' do
          summary 'Specifies the internal port on which the Virtual Machine is listening.'
          description <<-EOT
          Specifies the internal port on which the Virtual Machine is listening.
          EOT
        end
      end

      def add_load_balancer_protocol_option(action)
        action.option '--load-balancer-protocol=' do
          summary 'Possible values are: HTTP TCP. Default is TCP.'
          description <<-EOT
          Specifies the protocol to use to inspect the availability status of the Virtual Machine.
          Possible values are: HTTP TCP. Default is TCP.
          EOT
          before_action do |act, args, options|
            lbp = options[:load_balancer_protocol].downcase
            unless %w(http tcp).include?(lbp)
              fail 'Load balancer protocol is invalid. Allowed values are http,tcp'
            end
            if lbp == 'http' && options[:load_balancer_path].nil?
              fail 'Load balancer path is required if load balancer protocol is http.'
            end
          end
        end
      end

      def add_load_balancer_path_option(action)
        action.option '--load-balancer-path=' do
          summary 'Specifies the relative path to determine the availability status'
          description <<-EOT
          Specifies the relative path to inspect to determine the availability status of the Virtual Machine.
          If Protocol is set to TCP, this value must be NULL.
          EOT
        end
      end

      def add_winrm_http_port_option(action)
        action.option '--winrm-http-port=' do
          summary 'Specifies the WinRM HTTP port number.'
          description 'Specifies the WinRM HTTP port number.'
        end
      end

      def add_winrm_https_port_option(action)
        action.option '--winrm-https-port=' do
          summary 'Specifies the WinRM HTTPS port number.'
          description 'Specifies the WinRM HTTPS port number.'
        end
      end
    end
  end
end
