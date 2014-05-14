#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'highline/import'

module Puppet
  module Core
    module Loggerx
      class << self
        def info(msg)
          puts msg.bold.white
        end

        def error_with_exit(msg)
          puts  msg.bold.red
          fail msg.bold.red
        end

        def warn(msg)
          fail msg.yellow
        end

        def error(msg)
          fail msg.bold.red
        end

        def exception_message(msg)
          print msg.bold.red
          fail msg.bold.red
        end

        def success(msg)
          msg_with_new_line = msg + "\n"
          print msg_with_new_line.green
        end
      end
    end

    module Utility
      def random_string(str = 'azure', no_of_char = 5)
        str + (0...no_of_char).map { ('a'..'z').to_a[rand(26)] }.join
      end

      def validate_file(filepath, filename, extensions)
        fail ArgumentError, "#{filename} file is required" if filepath.empty?

        unless test 'f', filepath
          fail ArgumentError, "Could not find file '#{filepath}'"
        end
        unless test 'r', filepath
          fail ArgumentError, "Could not read from file '#{filepath}'"
        end
        ext_msg = extensions.map { |ele| '.' + ele }.join(' or ')
        if filepath !~ /(#{extensions.join('|')})$/
          fail "#{filename} expects a #{ext_msg} file."
        end
      end

      def ask_for_password(options, os_type)
        regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}/
        password = options[:password]
        return options if !password.nil? && !password.match(regex).nil?
        password_required = 'y'
        if options[:private_key_file] && options[:certificate_file] && os_type == 'Linux'
          password_required = ask("\nDo you want to enable password authentication (y/n)? ")  do
            |pass| pass.validate = /^y{1}$|^n{1}$/
          end
        end
        if password_required == 'y' || os_type == 'Windows'
          puts 'The supplied password must be 6-72 characters long and meet password complexity requirements.'
          puts 'Require atleast 1 captial letter and digit.'
          options[:password] = ask("\nPASSWORD?  ") { |pass| pass.echo = '*'; pass.validate = regex }
        end
        options
      end

      def wait_for_connection(ipaddress, port)
        Loggerx.info "Waiting for sshd on #{ipaddress}:#{port}"
        print('# ') until test_ssh_connecton(ipaddress, port) do
          sleep 10
        end
      end

      def test_ssh_connecton(fqdn, sshport)
        tcp_socket = TCPSocket.new(fqdn, sshport)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Loggerx.info("Node #{fqdn} is accepting ssh connections.")
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

      def test_winrm_connecton(fqdn, port)
        Loggerx.info "Waiting for winrm on #{fqdn}:#{port}"
        tcp_socket = TCPSocket.new(fqdn, port)
        Loggerx.success 'done'
        return true
      rescue SocketError
        raise 'Socket Error'
      rescue Errno::ETIMEDOUT
        fail 'Connection timeout'
      rescue Errno::EPERM
        fail 'Operation not permitted'
      rescue Errno::ECONNREFUSED
        fail 'Connection Refused'
      rescue Errno::EHOSTUNREACH
        fail 'Not Reachable'
      rescue Errno::ENETUNREACH
        fail 'Not Reachable'
      ensure
        tcp_socket && tcp_socket.close
      end

      def wget_script
        wget_content = <<-WGET
URL = WScript.Arguments(0)
saveTo = WScript.Arguments(1)
Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP")
objXMLHTTP.open "GET", URL, false
objXMLHTTP.send()
If objXMLHTTP.Status = 200 Then
Set objADOStream = CreateObject("ADODB.Stream")
objADOStream.Open
objADOStream.Type = 1 'adTypeBinary
objADOStream.Write objXMLHTTP.ResponseBody
objADOStream.Position = 0
Set objFSO = Createobject("Scripting.FileSystemObject")
If objFSO.Fileexists(saveTo) Then objFSO.DeleteFile saveTo
Set objFSO = Nothing
objADOStream.SaveToFile saveTo
objADOStream.Close
Set objADOStream = Nothing
End if
Set objXMLHTTP = Nothing
WScript.Quit
        WGET
        wget_content
      end
    end
  end
end

class String
  def fix(size = 18, padstr = ' ')
    self[0...size].ljust(size, padstr)
  end

  { reset:  0,
    bold:  1,
    dark:  2,
    underline:  4,
    blink:  5,
    orange:  6,
    negative:  7,
    black: 30,
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    white: 37,
  }.each do |key, value|
    define_method key do
      "\e[#{value}m" + self + "\e[0m"
    end
  end
end
