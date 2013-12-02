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
require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'winrm'

module Puppet
  module Core
    module RemoteConnection

      def scp_remote_upload(server, login, ssh_opts, local_path, remote_path)
        begin
          Net::SCP.start(server, login, ssh_opts) do |scp|
            scp.upload! local_path, remote_path
          end
        rescue Net::SSH::HostKeyMismatch => e
          puts "remembering new key: #{e.fingerprint}"
          e.remember_host!
          retry
        rescue Net::SSH::AuthenticationFailed => user
          raise "Authentication failure for user #{user}.".inspect
        rescue Exception => e
          raise e.message.inspect
        end
      end

      def ssh_remote_execute(server, login, ssh_opts, command)
        puts "Executing remote command ..."
        puts "Command: #{command}"

        buffer = String.new
        stdout = String.new
        exit_code = nil

        begin
          Net::SSH.start(server, login, ssh_opts) do |session|
            session.open_channel do |channel|
            
              channel.request_pty do |c, success|
                raise "could not request pty" unless success
                channel.on_data do |ch, data|
                  if data =~ /\[sudo\]/ || data =~ /Password/i
                    channel.send_data "#{ssh_opts[:password]}\n"
                  end

                  buffer << data
                  stdout << data
                  if buffer =~ /\n/
                    lines = buffer.split("\n")
                    buffer = lines.length > 1 ? lines.pop : String.new
                    lines.each do |line|
                      puts line
                    end
                  end
                end
                channel.on_eof do |ch|
                  # Display anything remaining in the buffer
                  unless buffer.empty?
                    puts buffer
                  end
                end
                channel.on_request("exit-status") do |ch, data|
                  exit_code = data.read_long
                  puts "SSH Command Exit Code: #{exit_code}"
                end
                # Finally execute the command
                channel.exec(command)
              end
            end
            session.loop
          end
        rescue Net::SSH::HostKeyMismatch => e
          puts "remembering new key: #{e.fingerprint}"
          e.remember_host!
          retry
        rescue Net::SSH::AuthenticationFailed => user
          raise "Authentication failure for user #{user}.".inspect
        rescue Exception => e
          puts e.message
        end

        puts "Executing remote command ... Done"
        { :exit_code => exit_code, :stdout => stdout }
      end

      def winrm_remote_execute(node_ip, login, password, cmds, endpoint_protocol, port)
        endpoint = "#{endpoint_protocol}://#{node_ip}:#{port}/wsman"
        winrm = WinRM::WinRMWebService.new(endpoint,
          :plaintext,
          :user => login,
          :pass => password,
          :basic_auth_only => true)
        cmds.each do |cmd|
          puts "Executing command #{cmd}"
          winrm.cmd(cmd) do |stdout, stderr|
            STDOUT.print stdout
            STDERR.print stderr
          end
        end
      end
    
    end
  end
end