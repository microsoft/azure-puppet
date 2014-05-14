#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
module Puppet
  module OptionValidation
    def validate_bootstrap_options(options)
      if options[:ssh_user] && options[:winrm_user]
        os = nil
      elsif options[:ssh_user]
        os = 'Linux'
      elsif options[:winrm_user]
        os = 'Windows'
      end

      case os
      when 'Linux'
        case
        when options[:private_key_file].nil? && options[:password].nil?
          fail ArgumentError, 'Password or Private key is require for bootstrap.'
        end
      when 'Windows'
        case
        when options[:password].nil?
          fail ArgumentError, 'Password is require for windows vm bootstrap.'
        end
      else
        fail ArgumentError, 'Either winrm_user or ssh_user is required'
      end
    end
  end
end
