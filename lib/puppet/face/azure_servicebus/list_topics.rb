#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'tilt'
require 'puppet/core/utility'

Puppet::Face.define :azure_servicebus, '1.0.0' do
  action :list_topics do

    summary 'List topics'

    description 'List topics'

    Puppet::ServiceBus.add_default_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_service_bus = Azure::ServiceBusService.new
      topics = azure_service_bus.list_topics
      template = Tilt.new(Puppet::ServiceBus.views('topics.erb'))
      template.render(nil, topics:  topics)
    end

    returns 'NONE'

    examples <<-'EOT'
      $  puppet azure_servicebus list_topics --sb-namespace busname \
         --sb-access-key GHdnD/E49P4SJG8UVEeABOeZRc=

    EOT
  end
end
