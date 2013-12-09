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

Puppet::Face.define :azure_sqldb, '0.0.1' do
  action :reset_password do

    summary 'Reset password of sql database server.'

    description <<-'EOT'
      The reset_passowrd action reset password of sql database server.
    EOT

    Puppet::SqlDatabase.add_reset_password_options(self)

    when_invoked do |options|
      Puppet::SqlDatabase.initialize_env_variable(options)
      db = Azure::SqlDatabaseManagementService.new
      db.reset_password(options[:server_name], options[:password])
      nil
    end

    examples <<-'EOT'
      $ puppet azure_sqldb reset_password --management-certificate ~/exp/azuremanagement.pem\
        --azure-subscription-id=368a3762-fce0 --management-endpoint=https://management.database.windows.net:8443/\
        --server-name hc786mm0l8 --password Ranjan@1234
    EOT
  end
end
