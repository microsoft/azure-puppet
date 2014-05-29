#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/core/utility'
require 'puppet/application_config'
include Puppet::ApplicationConfig

module Puppet::SqlDatabase
  class << self
    def initialize_env_variable(options)
      sql_db_endpoint = 'https://management.database.windows.net:8443/'
      options[:management_endpoint] ||= sql_db_endpoint
      ENV['azure_management_certificate'.upcase] = options[:management_certificate]
      ENV['azure_subscription_id'.upcase] = options[:azure_subscription_id]
      ENV['azure_management_endpoint'.upcase] = options[:management_endpoint]
      require 'azure'
    end

    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_sqldb/views', name)
    end

    def add_create_options(action)
      add_default_options(action)
      add_login_option(action)
      add_password_option(action)
      add_location_option(action)
    end

    def add_delete_options(action)
      add_default_options(action)
      add_server_name_option(action)
    end

    def add_reset_password_options(action)
      add_default_options(action)
      add_server_name_option(action)
      add_password_option(action)
    end

    def add_create_firewall_options(action)
      add_default_options(action)
      add_server_name_option(action)
      add_rule_name_option(action)
      add_start_ip_address_option(action)
      add_end_ip_address_option(action)
    end

    def add_delete_firewall_options(action)
      add_default_options(action)
      add_server_name_option(action)
      add_rule_name_option(action)
    end

    def add_login_option(action)
      action.option '--login=' do
        summary 'The login username for the Microsoft Azure sql database server.'
        description 'The login username of Microsoft Azure sql database server.'
        required
        before_action do |act, args, options|
          if options[:login].empty?
            fail ArgumentError, 'Login is required.'
          end
        end
      end
    end

    def add_password_option(action)
      action.option '--password=' do
        summary 'The pasword for the Microsoft Azure sql database server.'
        description 'The password for the Microsoft Azure sql database server.'
        required
        before_action do |act, args, options|
          if options[:password].empty?
            fail ArgumentError, 'Password is required.'
          end
        end
      end
    end

    def add_server_name_option(action)
      action.option '--server-name=' do
        summary 'The server name for the Microsoft Azure sql database server.'
        description 'The server name for the Microsoft Azure sql database server.'
        required
        before_action do |act, args, options|
          if options[:server_name].empty?
            fail ArgumentError, 'Server name is required.'
          end
        end
      end
    end

    def add_rule_name_option(action)
      action.option '--rule-name=' do
        summary 'The rule name for the sql database server firewall.'
        description 'The rule name for the sql database server firewall.'
        required
        before_action do |act, args, options|
          if options[:rule_name].empty?
            fail ArgumentError, 'Firewall rule name is required.'
          end
        end
      end
    end

    def  add_start_ip_address_option(action)
      action.option '--start-ip-address=' do
        summary 'The start ip address for the sql database server firewall.'
        description 'The start ip address of sql database server firewall.'
      end
    end

    def  add_end_ip_address_option(action)
      action.option '--end-ip-address=' do
        summary 'The end ip address for the sql database server firewall.'
        description 'The end ip address for the sql database server firewall.'
      end
    end
  end
end
