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
require 'puppet/core/utility'
require 'rubygems'
require 'tilt'

module Puppet::DatabasePack

  class << self
    def initialize_env_variable(options)
      ENV['azure_management_certificate'.upcase] = options[:management_certificate]
      ENV['azure_subscription_id'.upcase] = options[:azure_subscription_id]
      ENV['azure_management_endpoint'.upcase] = options[:management_endpoint]
      require 'azure'
    end

    def views(name)
      File.join(File.dirname(__FILE__), 'face/database_server/views', name)
    end

    def merge_default_options(options)
      default_options = { "management-certificate" => true, "subscription-id" => true, "management-endpoint" => true }
      default_options.merge(options)
    end

    def add_default_options(action)
      add_management_certificate_option(action)
      add_subscription_id_option(action)
      add_management_endpoint_option(action)
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
        summary 'The login username for the Windows Azure sql database server.'
        description <<-EOT
          The login usernam for the Windows Azure sql database server.
        EOT
        required
        before_action do |action, args, options|
          if options[:login].empty?
            raise ArgumentError, "Login is required."
          end
        end
      end
    end

    def add_password_option(action)
      action.option '--password=' do
        summary 'The pasword for the Windows Azure sql database server.'
        description <<-EOT
          The password for the Windows Azure sql database server.
        EOT
        required
        before_action do |action, args, options|
          if options[:password].empty?
            raise ArgumentError, "Password is required."
          end
        end
      end
    end

    def add_location_option(action)
      action.option '--location=' do
        summary 'The location of Windows Azure sql database server.'
        description <<-EOT
          The location of the Windows Azure sql database server.
        EOT
        required
        before_action do |action, args, options|
          if options[:location].empty?
            raise ArgumentError, "Location is required."
          end
        end
      end
    end

    def add_server_name_option(action)
      action.option '--server-name=' do
        summary 'The server name for the Windows Azure sql database server.'
        description <<-EOT
          The server name for the Windows Azure sql database server.
        EOT
        required
        before_action do |action, args, options|
          if options[:server_name].empty?
            raise ArgumentError, "Server name is required."
          end
        end
      end
    end

    def add_management_endpoint_option(action)
      action.option '--management-endpoint=' do
        summary 'The management endpoint for the Windows Azure portal.'
        description <<-EOT
          The management endpoint for the Windows Azure portal.
        EOT
        required
        before_action do |action, args, options|
          if options[:management_endpoint].empty?
            raise ArgumentError, "Management endpoint is required."
          end
        end
      end
    end

    def add_subscription_id_option(action)
      action.option '--azure-subscription-id=' do
        summary 'The subscription identifier for the Windows Azure portal.'
        description <<-EOT
          The subscription identifier for the Windows Azure portal.
        EOT
        required
        before_action do |action, args, options|
          if options[:azure_subscription_id].empty?
            raise ArgumentError, "Subscription id is required."
          end
        end
      end
    end

    def add_management_certificate_option(action)
      action.option '--management-certificate=' do
        summary 'The subscription identifier for the Windows Azure portal.'
        description <<-EOT
          The subscription identifier for the Windows Azure portal.
        EOT
        required
        before_action do |action, args, options|
          if options[:management_certificate].empty?
            raise ArgumentError, "Publish Settings File Id is required"
          end
          unless test 'f', options[:management_certificate]
            raise ArgumentError, "Could not find file '#{options[:management-certificate]}'"
          end
          unless test 'r', options[:management_certificate]
            raise ArgumentError, "Could not read from file '#{options[:management-certificate]}'"
          end
          unless(options[:management_certificate] =~ /(pem|pfx)$/)
            raise RuntimeError, "Management certificate expects a .pem or .pfx file."
          end
        end
      end
    end

    def add_rule_name_option(action)
      action.option '--rule-name=' do
        summary 'The rule name for the sql database server firewall.'
        description <<-EOT
          The rule name for the sql database server firewall.
        EOT
        required
        before_action do |action, args, options|
          if options[:rule_name].empty?
            raise ArgumentError, "Firewall rule name is required."
          end
        end
      end
    end

    def  add_start_ip_address_option(action)
      action.option '--start-ip-address=' do
        summary 'The start ip address for the sql database server firewall.'
        description <<-EOT
          The start ip address for the sql database server firewall.
        EOT
      end
    end

    def  add_end_ip_address_option(action)
      action.option '--end-ip-address=' do
        summary 'The end ip address for the sql database server firewall.'
        description <<-EOT
          The end ip address for the sql database server firewall.
        EOT
      end
    end

  end
end
