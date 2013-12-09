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
        summary "Description of affinity group"
        description <<-EOT
          Description of affinity group.
        EOT
      end
    end

    def add_label_option(action)
      action.option '--label=' do
        summary "Label of affinity group"
        description <<-EOT
          Label of affinity group.
        EOT
        required
        before_action do |action, args, options|
          if options[:label].empty?
            raise ArgumentError, "Label is required"
          end
        end
      end
    end
    
  end

end
