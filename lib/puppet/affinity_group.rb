#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'puppet/application_config'
include Puppet::ApplicationConfig

module Puppet::AffinityGroup
  class << self
    def views(name)
      File.join(File.dirname(__FILE__), 'face/azure_affinitygroup/views', name)
    end

    def add_create_options(action)
      add_default_options(action)
      add_affinity_group_name_option(action)
      add_location_option(action)
      add_description_option(action)
      add_label_option(action)
    end

    def add_delete_options(action)
      add_default_options(action)
      add_affinity_group_name_option(action)
    end

    def add_update_options(action)
      add_default_options(action)
      add_affinity_group_name_option(action)
      add_label_option(action)
      add_description_option(action)
    end

    def add_description_option(action)
      action.option '--description=' do
        summary 'Description of affinity group'
        description 'Description of affinity group.'
      end
    end

    def add_label_option(action)
      action.option '--label=' do
        summary 'Label of affinity group'
        description 'Label of affinity group.'
        required
        before_action do |act, args, options|
          fail ArgumentError, 'Label is required' if options[:label].empty?
        end
      end
    end
  end
end
