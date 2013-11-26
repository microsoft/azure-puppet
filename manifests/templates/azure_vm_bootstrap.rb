require 'rubygems'
require 'net/ssh'
require 'net/scp'

module RemoteConnection

  def scp_remote_upload(server, login, ssh_opts, local_path,remote_path)
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
end

module Utility

  def random_string(str='azure',no_of_char=5)
    str+(0...no_of_char).map{ ('a'..'z').to_a[rand(26)] }.join
  end
  
  def test_tcp_connection(ipaddress, os_type)
    unless (ipaddress)
      puts "Instance is not running."
      exit 1
    end
    puts("\n")
    if os_type == 'Linux'
      ip = ipaddress
      port = 22
      puts "Waiting for sshd on #{ip}:#{port}"

      print("# ") until tcp_test_ssh(ip,port) {
        sleep  10
        puts "done"
      }
    elsif  os_type == 'Windows'
      puts 'puppet installation on windows is not yet implemented.'
    else
      puts 'Unknown OS'
    end
  end

  def tcp_test_ssh(fqdn, sshport)
    tcp_socket = TCPSocket.new(fqdn, sshport)
    readable = IO.select([tcp_socket], nil, nil, 5)
    if readable
      puts "\n"
      puts "sshd accepting connections on #{fqdn}, banner is #{tcp_socket.gets}"
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

end

include RemoteConnection
include Utility
class BootStrap
  
  def self.start(params)
    puts "Installing puppet node on #{params[:node_ipaddress]}\n"
    puts
    login =  params[:vm_user]
    ssh_opts = { }
    if params[:password]
      ssh_opts[:password] = params[:password]
    else
      ssh_opts[:keys] = [params[:private_key_file]]
    end
    ssh_opts[:paranoid] = false
    ssh_opts[:port] = params[:ssh_port] || 22
    options = {:environment=>'production',:puppet_master_ip => params[:puppet_master_ip]}
    options[:tmp_dir] = File.join('/', 'tmp', random_string('puppet-tmp-location-',10))
    create_tmpdir_cmd = "bash -c 'umask 077; mkdir #{options[:tmp_dir]}'"
    ssh_remote_execute(params[:node_ipaddress], login, ssh_opts, create_tmpdir_cmd)
    remote_script_path = File.join(options[:tmp_dir], "puppet_installation_script.sh")
    local_script_path = '/tmp/windowsazure/vm/puppet-community.sh'
    scp_remote_upload(params[:node_ipaddress], login, ssh_opts, local_script_path, remote_script_path)
#        cmd_prefix = login == 'root' ? '' : 'sudo '
#        install_command = "#{cmd_prefix}bash -c 'chmod u+x #{remote_script_path};  sed -i 's/\r//' #{remote_script_path}; #{remote_script_path}'"
#        results = ssh_remote_execute(params[:node_ipaddress], login, ssh_opts, install_command)
#        if results[:exit_code] != 0 then
#          raise  "The installation script exited with a non-zero exit status, indicating a failure.".inspect
#        end
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
params = {}

