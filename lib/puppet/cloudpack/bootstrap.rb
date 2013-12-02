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
require 'puppet/core/remote_connection'
require 'puppet/core/utility'
require 'puppet/cloudpack/installer'
require 'tempfile'
include Puppet::Core::RemoteConnection
include Puppet::Core::Utility
  
module Puppet
  module CloudPack
    module BootStrap
      class << self
        def start(params)
          puts "Installing puppet node on #{params[:node_ipaddress]}\n"
          puts
          if params[:winrm_user]
            bootstrap_windows_node(params)
          elsif params[:ssh_user]
            results = bootstrap_linux_node(params)
            if results[:exit_code] != 0 then
              puts  "The installation script exited with a non-zero exit status, indicating a failure."
            end
          else
            raise "Missing option ssh_user or winrm_user"
          end
         
        end

        def bootstrap_windows_node(params)
          node_ip = params[:node_ipaddress]
          master_ip = params[:puppet_master_ip]
          login = params[:winrm_user]
          password = params[:password]
          if params[:winrm_transport] == 'https'
            winrm_port = params[:winrm_port] || 5986
            endpoint_protocol = 'https'
          else
            winrm_port = params[:winrm_port] || 5985
            endpoint_protocol = 'http'
          end
          
          cmds = []
          cmds << "mkdir C:\\puppet"
          wget_script.each_line do |line|
            ln = line.gsub("\n"," ")
            cmds << "echo #{ln} >> C:\\puppet\\wget.vbs"
          end
          cmds << "cscript /nologo C:\\puppet\\wget.vbs https://downloads.puppetlabs.com/windows/puppet-3.3.2.msi %TEMP%\\puppet.msi"
          cmds << "copy %TEMP%\\puppet.msi C:\\puppet\\puppet.msi"
          cmds << "msiexec /qn /i c:\\puppet\\puppet.msi PUPPET_MASTER_SERVER=#{master_ip}"
          cmds << 'sc config puppet start= demand'
          winrm_remote_execute(node_ip, login, password, cmds, endpoint_protocol, winrm_port)
        end

        def bootstrap_linux_node(params)
          login =  params[:ssh_user]
          ssh_opts = { }
          if params[:password]
            ssh_opts[:password] = params[:password]
          else
            ssh_opts[:keys] = [params[:private_key_file]]
          end
          ssh_opts[:paranoid] = false
          ssh_opts[:port] = params[:ssh_port] || 22
          options = {:environment=>'production', :puppet_master_ip => params[:puppet_master_ip]}
          options[:tmp_dir] = File.join('/', 'tmp', random_string('puppet-tmp-location-',10))
          create_tmpdir_cmd = "bash -c 'umask 077; mkdir #{options[:tmp_dir]}'"
          ssh_remote_execute(params[:node_ipaddress], login, ssh_opts, create_tmpdir_cmd)
          tmp_script_file = compile_template(options)
          remote_script_path = File.join(options[:tmp_dir], "puppet_installation_script.sh")
          scp_remote_upload(params[:node_ipaddress], login, ssh_opts, tmp_script_file.path, remote_script_path)
          cmd_prefix = login == 'root' ? '' : 'sudo '
          install_command = "#{cmd_prefix}bash -c 'chmod u+x #{remote_script_path};  sed -i 's/\r//' #{remote_script_path}; #{remote_script_path}'"
          ssh_remote_execute(params[:node_ipaddress], login, ssh_opts, install_command)
        end

        def compile_template(options)
          puts "Installing Puppet ..."
          install_script = Installer.build_installer_template('puppet-community', options)
          puts("Compiled installation script:")
          begin
            f = Tempfile.open('install_script')
            f.write(install_script)
            f
          rescue Exception => e
            puts e
          ensure
            f.close
          end
        end
      end
    end
  end
end