# Add all rabbitmq nodes to the hosts file with their short name.
instances = node[:opsworks][:layers][:emailmq][:instances]

rabbit_nodes = instances.map{ |name, attrs| "rabbit@#{name}" }
node.set['rabbitmq']['cluster_disk_nodes'] = rabbit_nodes

include_recipe 'rabbitmq'

rabbitmq_user "guest" do
  action :delete
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  password node['rabbitmq_cluster']['password']
  action :add
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  vhost "/"
  permissions ".* .* .*"
  action :set_permissions
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  tag "administrator"
  action :set_tags
end

rabbitmq_policy "ha-two" do
  pattern "^(?!amq\\.).*"
  params "ha-mode" => "exactly", "ha-params" => 2
  priority 1
  action :set
end
