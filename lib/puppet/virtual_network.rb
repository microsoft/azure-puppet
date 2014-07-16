#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/application_config'
require 'puppet/core/utility'
include Puppet::ApplicationConfig

module Puppet::VirtualNetwork
  class << self
    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_vnet/views', name)
    end

    def add_set_virtual_network_options(action)
      add_default_options(action)
      add_virtual_network_name_option(action)
      add_location_option(action)
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
        summary 'Xml schema file path'
        description 'Xml schema file path of virtual network.'
        required
        before_action do |act, args, options|
          filepath = options[:xml_schema_file]
          validate_file(filepath, 'Network schema', ['xml'])
        end
      end
    end

    def add_virtual_network_name_option(action)
      action.option '--virtual-network-name=' do
        summary 'The virtual network name.'
        description 'Name of virtual network.'
        required
        before_action do |act, args, options|
          if options[:virtual_network_name].empty?
            fail ArgumentError, 'Virtual network name is required'
          end
        end
      end
    end

    def add_address_space_option(action)
      action.option '--address-space=' do
        summary 'The address space for virtual network.'
        description 'Address space for virtual network.'
        required
        before_action do |act, args, options|
          if options[:address_space].empty?
            fail ArgumentError, 'Virtual network address space is required'
          end
        end
      end
    end

    def add_subnet_option(action)
      action.option '--subnets=' do
        summary 'Subnet of virtual network.'
        description <<-EOT
          Contains the specification for the subnets that you want to create
          within the address space of your virtual network sites.
        EOT
      end
    end

    def add_dns_server_option(action)
      action.option '--dns-servers=' do
        summary 'Dns server for virtual network.'
        description 'Contains the collection of DNS servers.'
      end
    end
  end
end
