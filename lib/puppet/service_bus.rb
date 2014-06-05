#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module Puppet::ServiceBus

  class << self
    def initialize_env_variable(options)
      ENV['AZURE_SERVICEBUS_NAMESPACE']  = options[:sb_namespace]
      ENV['AZURE_SERVICEBUS_ACCESS_KEY'] = options[:sb_access_key]
      ENV["AZURE_STORAGE_ACCOUNT"] = options[:storage_account_name]
      ENV["AZURE_STORAGE_ACCESS_KEY"] = options[:storage_access_key]
      gem "azure", '=0.6.4'
      require 'azure'
    end

    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_servicebus/views', name)
    end

    def add_default_options(action)
      add_sb_namespace_option(action)
      add_sb_access_key_option(action)
    end

    def add_queue_default_options(action)
      add_storage_account_name_option(action)
      add_storage_access_key_option(action)
    end

    def add_servicebus_queue_options(action)
      add_default_options(action)
      add_queue_name_option(action)
    end

    def add_servicebus_topic_options(action)
      add_default_options(action)
      add_topic_name_option(action)
    end

    def add_create_queue_options(action)
      add_queue_default_options(action)
      add_queue_name_option(action)
    end

    def add_create_message_options(action)
      add_queue_default_options(action)
      add_queue_name_option(action)
      add_queue_message_option(action)
    end

    def add_sb_namespace_option(action)
      action.option '--sb-namespace=' do
        summary 'The azure service bus namespace.'
        description 'azure service bus namespace.'
        required        
      end
    end

    def add_sb_access_key_option(action)
      action.option '--sb-access-key=' do
        summary 'The azure service bus access key.'
        description 'The azure service bus access key.'
        required       
      end
    end

    def add_queue_name_option(action)
      action.option '--queue-name=' do
        summary 'Name of azure queue.'
        description 'Name of azure queue.'
        required
      end
    end

    def add_topic_name_option(action)
      action.option '--topic-name=' do
        summary 'Name of azure topic.'
        description 'Name of azure topic.'
        required
      end
    end

    def add_queue_message_option(action)
      action.option '--queue-message=' do
        summary 'Queue message'
        required
      end
    end

    def add_storage_account_name_option(action)
      action.option '--storage-account-name=' do
        summary 'The storage account name of Windows Azure portal.'
        description 'The storage account name of Windows Azure portal.'
        required
      end
    end

    def add_storage_access_key_option(action)
      action.option '--storage-access-key=' do
        summary 'The access key of storage account.'
        description 'The access key of storage account.'
        required       
      end
    end

  end
end
