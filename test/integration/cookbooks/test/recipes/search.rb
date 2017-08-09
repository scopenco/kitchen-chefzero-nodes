#
# Cookbook Name:: test
# Resource:: search
#
# Copyright 2015 Andrei Skopenko
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

sftp_node = search(:node, "name:sftp-* AND platform:#{node['platform']}").first
pp sftp_node['ipaddress']
ruby_block 'save sftp attributes' do
  block do
    parent = File.join(ENV['TEMP'] || '/tmp', 'kitchen')
    IO.write(File.join(parent, 'sftp.json'), sftp_node.to_json)
  end
end

win_node = search(:node, 'platform:windows').first
pp win_node['ipaddress']
ruby_block 'save win attributes' do
  block do
    parent = File.join(ENV['TEMP'] || '/tmp', 'kitchen')
    IO.write(File.join(parent, 'win.json'), win_node.to_json)
  end
end
