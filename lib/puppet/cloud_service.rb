#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/core/utility'
require 'puppet/application_config'
include Puppet::ApplicationConfig

module Puppet::CloudService
  class << self
    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_cloudservice/views', name)
    end

    def add_create_options(action)
      add_default_options(action)
      add_affinity_group_name_option(action, true)
      add_location_option(action, true)
      add_cloud_service_name_option(action)
      add_description_option(action)
      add_label_option(action)
    end

    def add_delete_options(action)
      add_default_options(action)
      add_cloud_service_name_option(action)
    end

    def add_certificate_options(action)
      add_default_options(action)
      add_cloud_service_name_option(action)
      add_certificate_file_option(action)
      add_private_key_file_option(action)
    end

    def add_delete_deployment_options(action)
      add_default_options(action)
      add_cloud_service_name_option(action)
    end

    def add_description_option(action)
      action.option '--description=' do
        summary 'Description of cloud service'
        description 'Description of cloud service.'
      end
    end

    def add_label_option(action)
      action.option '--label=' do
        summary 'Label of cloud service'
        description 'Label of cloud service.'
      end
    end

    def add_cloud_service_name_option(action)
      action.option '--cloud-service-name=' do
        summary 'The name of the cloud service.'
        description 'The name of the cloud service.'
        required
        before_action do |act, args, options|
          if act.name == :create && options[:location].nil? && options[:affinity_group_name].nil?
            fail ArgumentError, 'affinity group name or location is required.'
          end
          if options[:cloud_service_name].empty?
            fail ArgumentError, 'Cloud service name is required.'
          end
        end
      end
    end

    def add_certificate_file_option(action)
      action.option '--certificate-file=' do
        summary 'Specify certificate file.'
        description 'Path of certificate file.'
        required
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
        summary 'Specify private key file.'
        description 'Path of private key file.'
        required
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
  end
end
