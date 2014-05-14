#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/core/utility'
require 'puppet/application_config'
include Puppet::ApplicationConfig

module Puppet::StorageAccount
  class << self
    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_storage/views', name)
    end

    def add_create_options(action)
      add_default_options(action)
      add_affinity_group_name_option(action, true)
      add_location_option(action, true)
      add_storage_account_name_option(action)
      add_description_option(action)
      add_label_option(action)
      add_extended_properties_option(action)
    end

    def add_delete_options(action)
      add_default_options(action)
      add_storage_account_name_option(action)
    end

    def add_description_option(action)
      action.option '--description=' do
        summary 'Description of storage account'
        description 'Description of storage account'
      end
    end

    def add_label_option(action)
      action.option '--label=' do
        summary 'Label of storage account'
        description 'Label of storage account'
      end
    end

    def add_storage_account_name_option(action)
      action.option '--storage-account-name=' do
        summary 'The name of the storae account.'
        description 'The name of the storage account.'
        required
        before_action do |act, args, options|
          if act.name == :create && options[:location].nil? && options[:affinity_group_name].nil?
            fail ArgumentError, 'affinity group name or location is required.'
          end
          if options[:storage_account_name].empty?
            fail ArgumentError, 'Storage Account name is required.'
          end
        end
      end
    end

    def add_extended_properties_option(action)
      action.option '--extended-properties=' do
        summary 'Extended properties of storage account'
        description 'Extended properties of storage account'
        properties = {}
        before_action do |act, args, options|
          options[:extended_properties].split(',').each do |prop|
            values = prop.split(':')
            properties[values[0].to_sym] = values[1] if values.size == 2
          end
          options[:extended_properties] = properties
        end
      end
    end

  end
end
