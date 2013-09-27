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
  module Core
    module Utility

      def random_string(str='azure',no_of_char=5)
        str+(0...no_of_char).map{ ('a'..'z').to_a[rand(26)] }.join
      end

      def ask_for_password(options, os_type)
        regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}/
        password = options[:password]
        return options if !password.nil? && !password.match(regex).nil?
        password_required = 'y'
        if (options[:private_key_file] && options[:certificate_file] && os_type == 'Linux')
          password_required = ask("\nDo you want to enable password authentication (y/n)? ")  {
            |pass| pass.validate = /^y{1}$|^n{1}$/
          }
        end
        if password_required == 'y' or os_type == 'Windows'
          puts "The supplied password must be 6-72 characters long and meet password complexity requirements."
          puts "Require atleast 1 captial letter and digit."
          options[:password] = ask("\nPASSWORD?  ") { |pass| pass.echo ="*"; pass.validate = regex }
        end

        options
      end

      def test_tcp_connection(server)
        unless (server && server.ipaddress)
          Loggerx.error_with_exit("Instance is not running.")
          exit 1
        end
        puts("\n")
        if server.os_type == 'Linux'
          ip = server.ipaddress
          port = server.tcp_endpoints.collect{|x| x["PublicPort"] if x["Name"] == 'SSH'}.compact.first
          Loggerx.info "Waiting for sshd on #{ip}:#{port}"

          print("# ") until tcp_test_ssh(ip,port) {
            sleep  10
            Loggerx.info "done"
          }
        elsif  server.os_type == 'Windows'
          ip = server.ipaddress
          port = 5985
          Loggerx.info "Waiting for winrm on #{ip}:#{port}"

          print("# ") until tcp_test_winrm(ip,port) {
            sleep  10
            Loggerx.success("done")
          }
        end
      end

      def tcp_test_ssh(fqdn, sshport)
        tcp_socket = TCPSocket.new(fqdn, sshport)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          puts "\n"
          Loggerx.info("sshd accepting connections on #{fqdn}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue SocketError
        sleep 2
        false
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def tcp_test_winrm(ip_addr, port)
        hostname = ip_addr
        TCPSocket.new(hostname, port)
        return true
      rescue SocketError
        sleep 2
        false
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      rescue Errno::ENETUNREACH
        sleep 2
        false
      end
  
    end
  end
end

class String

  def fix(size=18, padstr=' ')
    self[0...size].ljust(size, padstr)
  end

end