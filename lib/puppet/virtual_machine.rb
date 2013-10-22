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
require 'puppet/application_config'
include Puppet::ApplicationConfig

module Puppet::VirtualMachine

  class << self
    
    def views(name)
      File.join(File.dirname(__FILE__), 'face/node_azure/views', name)
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
      add_vm_user_option(action,false)
      add_node_ipaddress_options(action,false)
      add_password_option(action)
      add_puppet_master_ip_option(action,false)
      add_ssh_port_option(action)
      add_certificate_file_option(action)
      add_private_key_file_option(action)
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
    end

    def add_location_option(action)
      action.option '--location=' do
        summary "The location identifier for the Windows Azure portal.valid choices are ('West US', 'East US', 'East Asia', 'Southeast Asia','North Europe', 'West Europe')."
        description <<-EOT
          The location identifier for the Windows Azure portal.
          valid choices are ('West US', 'East US', 'East Asia', 'Southeast Asia',
          'North Europe', 'West Europe').
        EOT
        required
        before_action do |action, args, options|
          valid_locations = ['west us', 'east us', 'east asia', 'southeast asia', 'north europe', 'west europe']
          if options[:location].empty?
            raise ArgumentError, "Location is required"
          elsif options[:location] && !valid_locations.include?(options[:location].downcase)
            raise ArgumentError, "The location is not valid. .valid choices are ('West US', 'East US', 'East Asia', 'Southeast Asia','North Europe', 'West Europe')."
          end
        end
      end
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
        required unless optional
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

    def add_node_ipaddress_options(action, optional=true)
      action.option '--node-ipaddress=' do
        summary 'Node Ip address. '
        description <<-EOT
          The ip address where puppet need to install."
        EOT
        required unless optional
        before_action do |action, args, options|
          options = Puppet::VirtualMachine.merge_default_options(options)
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

  end
end