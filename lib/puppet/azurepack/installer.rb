#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'erb'

module Puppet
  module AzurePack
    module Installer
      class << self
        def build_installer_template(name, options = {})
          # binding is a kernel method
          ERB.new(File.read(find_template(name))).result(binding)
        end

        def lib_script_dir
          File.join(File.dirname(__FILE__), 'scripts')
        end

        def find_template(name)
          user_script = File.expand_path("../#{name}.erb", __FILE__)
          puts user_script
          return user_script if File.exists?(user_script)
          lib_script = File.join(lib_script_dir, "#{name}.erb")
          if File.exists?(lib_script)
            lib_script
          else
            fail "Could not find installation template for #{name}"
          end
        end
      end
    end
  end
end
