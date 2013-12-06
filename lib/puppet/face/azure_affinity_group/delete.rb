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

Puppet::Face.define :azure_affinity_group, '0.0.1' do
  action :delete   do

    summary 'Delete affinity group.'

    description <<-'EOT'
      The delete action delete a affinity group.
    EOT

    Puppet::AffinityGroup.add_delete_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new      
      begin
        affinity_group_service.delete_affinity_group(options[:affinity_group_name])
      rescue Exception => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinity_group delete --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --affinity-group-name ag-name
    EOT
  end
end
