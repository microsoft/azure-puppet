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
require 'erb'

module Puppet
  module CloudPack
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
            raise "Could not find installation template for #{name}"
          end
        end
      end
    end
  end
end

