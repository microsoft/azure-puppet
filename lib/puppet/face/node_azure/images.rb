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
require 'puppet/face/node_azure'

Puppet::Face.define :node_azure, '0.0.1' do
  action :images do

    summary 'List Windows Azure images'
    #arguments 'NONE'
    description <<-'EOT'
      The images action obtains a list of images from the cloud provider and
      displays them on the console output.  
    EOT

    Puppet::CloudAzurePack.add_default_options(self)

    when_invoked do |options|
      Puppet::CloudAzurePack.initialize_env_variable(options)
      virtual_machine_image_service = Azure::VirtualMachineImageService.new
      images = virtual_machine_image_service.list_virtual_machine_images
      puts Tilt.new(Puppet::CloudAzurePack.views('images.erb'), 1, :trim => '%').render(nil, :images => images)
    end
    
    returns 'Array of attribute hashes containing information about each Azure images.'

    examples <<-'EOT'
      $ puppet node_azure images --publish-settings-file azuremanagement.publishsettings --azure-subscription-id ID
      OS Type      OS Nmae
      Windows :  2cdc6229df6344129ee553dd3499f0d3__BizTalk-Server-2013-Beta
      Windows :  2cdc6229df6344129ee553dd3499f0d3__BizTalk-Server-2013-Beta-February-2013
      Linux   :  5112500ae3b842c8b9c604889f8753c3__OpenLogic-CentOS63JAN20130122
    EOT
  end
end
