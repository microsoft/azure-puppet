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

module Puppet
  module ApplicationConfig

    def initialize_env_variable(options)
      ENV['azure_management_certificate'.upcase] = options[:management_certificate]
      ENV['azure_subscription_id'.upcase] = options[:azure_subscription_id]
      ENV['azure_management_endpoint'.upcase] = options[:management_endpoint]
      require 'azure'
    end

    def add_default_options(action)
      add_management_certificate_option(action)
      add_subscription_id_option(action)
      add_management_endpoint_option(action)
    end
      
    def merge_default_options(options)
      default_options = { "management-certificate" => true, "subscription-id" => true, "management-endpoint" => true }
      default_options.merge(options)
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
            raise ArgumentError, "Management certificate file is required"
          end
          unless test 'f', options[:management_certificate]
            raise ArgumentError, "Could not find file '#{options[:management_certificate]}'"
          end
          unless test 'r', options[:management_certificate]
            raise ArgumentError, "Could not read from file '#{options[:management_certificate]}'"
          end
          unless(options[:management_certificate] =~ /(pem|pfx)$/)
            raise RuntimeError, "Management certificate expects a .pem or .pfx file."
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

    def add_management_endpoint_option(action)
      action.option '--management-endpoint=' do
        summary 'The management endpoint for the Windows Azure portal.'
        description <<-EOT
          The management endpoint for the Windows Azure portal.
        EOT
        
      end
    end
    
  end
end
