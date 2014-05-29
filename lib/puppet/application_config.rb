#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/core/utility'
include Puppet::Core::Utility

module Puppet
  module ApplicationConfig
    def initialize_env_variable(options)
      ENV['azure_management_certificate'.upcase] = options[:management_certificate]
      ENV['azure_subscription_id'.upcase] = options[:azure_subscription_id]
      ENV['azure_management_endpoint'.upcase] = options[:management_endpoint]
      gem "azure", '=0.6.4'
      require 'azure'
    end

    def add_default_options(action)
      add_management_certificate_option(action)
      add_subscription_id_option(action)
      add_management_endpoint_option(action)
    end

    def add_management_certificate_option(action)
      action.option '--management-certificate=' do
        summary 'The subscription identifier for the Microsoft Azure portal.'
        description 'The subscription identifier for the Microsoft Azure portal.'
        required
        before_action do |act, args, options|
          file = options[:management_certificate]
          validate_file(file, 'Management certificate', %w(pem pfx))
        end
      end
    end

    def add_subscription_id_option(action)
      action.option '--azure-subscription-id=' do
        summary 'The subscription identifier for the Microsoft Azure portal.'
        description 'The subscription identifier for the Microsoft Azure portal.'
        required
        before_action do |act, args, options|
          if options[:azure_subscription_id].empty?
            fail ArgumentError, 'Subscription id is required.'
          end
        end
      end
    end

    def add_management_endpoint_option(action)
      action.option '--management-endpoint=' do
        summary 'The management endpoint for the Microsoft Azure portal.'
        description 'The management endpoint for the Microsoft Azure portal.'

      end
    end

    def add_location_option(action, optional = false)
      action.option '--location=' do
        summary 'The location identifier for the Microsoft Azure portal.'
        description <<-EOT
          The location identifier for the Microsoft Azure portal.
          valid choices are ('West US', 'East US', 'Southeast Asia',
          'North Europe', 'West Europe', 'East Asia' ...).
        EOT
        required unless optional
        before_action do |act, args, options|
          if options[:location].empty?
            fail ArgumentError, 'Location is required'
          end
        end
      end
    end

    def add_affinity_group_name_option(action, optional = false)
      action.option '--affinity-group-name=' do
        summary 'The affinity group name.'
        description 'The affinity group name.'
        required unless optional
        before_action do |act, args, options|
          if options[:affinity_group_name].empty?
            fail ArgumentError, 'Affinity group name is required'
          end
        end
      end
    end
  end
end
