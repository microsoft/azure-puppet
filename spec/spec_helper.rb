#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

require 'puppet'
require 'puppet/face'
require 'azure'
require 'mocha/api'
gem 'rspec', '>=2.0.0'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha

  config.after :each do
    Puppet.settings.clear
    Puppet::Node::Environment.clear
    Puppet::Util::Storage.clear
    Puppet::Util::Log.close_all
  end

  config.before :each do
    $puppet_application_mode = nil
    $puppet_application_name = nil
    Puppet[:confdir] = '/dev/null'
    Puppet[:vardir] = '/dev/null'
    Puppet.settings[:bindaddress] = '127.0.0.1'
    @logs = []
    Puppet::Util::Log.newdestination(Puppet::Test::LogCollector.new(@logs))
  end
end
