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
require 'tilt'
require 'puppet/application_config'
require 'puppet/core/utility'
include Puppet::ApplicationConfig

module Puppet::VirtualNetwork

  class << self
    
    def views(name)
      File.join(File.dirname(__FILE__), 'face/virtual_network/views', name)
    end

    def add_set_virtual_network_options(action)
      add_default_options(action)
      add_virtual_network_name_option(action)
      add_affinity_group_name_option(action)
      add_address_space_option(action)
      add_subnet_option(action)
      add_dns_server_option(action)
    end

    def add_set_xml_schema_options(action)
      add_default_options(action)
      add_xml_schema_file_option(action)
    end

    def add_xml_schema_file_option(action)
      action.option '--xml-schema-file=' do
        summary "Xml schema file path"
        description <<-EOT
          Xml schema file path of virtual network.
        EOT
        required
        before_action do |action, args, options|
          unless test 'f', options[:xml_schema_file]
            raise ArgumentError, "Could not find file '#{options[:xml_schema_file]}'"
          end
          unless test 'r', options[:xml_schema_file]
            raise ArgumentError, "Could not read from file '#{options[:xml_schema_file]}'"
          end
          if options[:xml_schema_file] !~ /(xml)$/
            raise ArgumentError, "File extension of '#{options[:xml_schema_file]}' must be xml"
          end
        end
      end
    end
    
    def add_virtual_network_name_option(action)
      action.option '--virtual-network-name=' do
        summary "The virtual network name."
        description <<-EOT
          Name of virtual network.
        EOT
        required
        before_action do |action, args, options|
          if options[:virtual_network_name].empty?
            raise ArgumentError, "Virtual network name is required"
          end
        end
      end
    end

    def add_affinity_group_name_option(action)
      action.option '--affinity-group-name=' do
        summary "The affinity group name."
        description <<-EOT
          The affinity group name.
        EOT
        required
        before_action do |action, args, options|
          if options[:affinity_group_name].empty?
            raise ArgumentError, "Affinity group name is required"
          end
        end
      end
    end

    def add_address_space_option(action)
      action.option '--address-space=' do
        summary "The address space for virtual network."
        description <<-EOT
          Address space for virtual network.
        EOT
        required
        before_action do |action, args, options|
          if options[:address_space].empty?
            raise ArgumentError, "Virtual network address space is required"
          end
        end
      end
    end

    def add_subnet_option(action)
      action.option '--subnets=' do
        summary "Subnet of virtual network."
        description <<-EOT
          Contains the specification for the subnets that you want to create
          within the address space of your virtual network sites.
        EOT
      end
    end

    def add_dns_server_option(action)
      action.option '--dns-servers=' do
        summary "Dns server for virtual network."
        description <<-EOT
          Contains the collection of DNS servers.
        EOT
      end
    end

  end
  
end
