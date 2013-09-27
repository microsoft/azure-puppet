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

Puppet::Face.define :database_server, '0.0.1' do
  action :delete_firewall do

    summary 'Delete Windows Azure sql database server firewall'

    description <<-'EOT'
      The delete action delete windows azure sql server firewall.
    EOT

    Puppet::DatabasePack.add_delete_firewall_options(self)

    when_invoked do |options|
      Puppet::DatabasePack.initialize_env_variable(options)
      db = Azure::Database::DatabaseService.new
      db.delete_sql_server_firewall_rule(options[:server_name], options[:rule_name])
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $  puppet database_server delete --management-certificate ~/exp/azuremanagement.pem\
         puppet database_server delete_firewall --management-certificate ~/exp/azuremanagement.pem\
         --azure-subscription-id=ID --management-endpoint=https://management.database.windows.net:8443/\
         --server-name=xlykw0su08 --rule-name rule1
    EOT
  end
end
