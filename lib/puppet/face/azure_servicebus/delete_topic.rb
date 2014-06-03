#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
Puppet::Face.define :azure_servicebus, '1.0.0' do
  action :delete_topic   do

    summary 'Delete a topic using service bus object.'

    description <<-'EOT'
      Delete a topic using service bus object.
    EOT

    Puppet::ServiceBus.add_servicebus_topic_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_service_bus = Azure::ServiceBusService.new
      azure_service_bus.delete_topic(options[:topic_name])
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_servicebus delete_topic --sb-namespace busname \
      --topic-name topic-name --sb-access-key 4XJib8UcKEu8VG8UVEpABOeZRc=

    EOT
  end
end
