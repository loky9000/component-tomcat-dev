#
#Recipe will deploy war to tomcat
#

service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  supports :restart => false, :status => true
  action :nothing
end

#download war file
require 'uri'

if ( node['tomcat-component']['war']['uri'].start_with?('http', 'ftp') )
  uri = URI.parse(node['tomcat-component']['war']['uri'])
  file_name = node['tomcat-component']['war']['appname']
  ext_name = File.extname(file_name)
  app_name = file_name[0...-4]
  
  remote_file "/tmp/#{file_name}" do
    source node['tomcat-component']['war']['uri']
  end
  
  file_path = "/tmp/#{file_name}"
  
elsif ( node['tomcat-component']['war']['uri'].start_with?('file') )
  url = node['tomcat-component']['war']['uri']
  file_path = URI.parse(url).path
  file_name = node['tomcat-component']['war']['appname']
  ext_name =  File.extname(file_name)
  app_name = File.basename(file_name)[0...-4]
end

  if ( ! %w{.war .jar}.include?(ext_name))
     fail "appname must be .war or .jar"
   end

#cleanup tomcat before deploy
file "#{node['tomcat']['webapp_dir']}/#{file_name}" do
  action :delete
end

file "#{node['tomcat']['context_dir']}/#{app_name}.xml" do
  action :delete
end

directory "#{node['tomcat']['webapp_dir']}/#{app_name}" do
  recursive true
  action :delete
end

#deploy war
bash "copy #{file_path} to tomcat" do
  user "root"
  code <<-EOH
  cp -fr #{file_path} #{node['tomcat']['webapp_dir']}/#{file_name}
  chmod 644 #{node['tomcat']['webapp_dir']}/#{file_name}
  chown #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['tomcat']['webapp_dir']}/#{file_name}
  EOH
end

#create context file
case node['tomcat-component']['create_context']
  when true
    template "#{node['tomcat']['context_dir']}/#{app_name}.xml" do
      owner node["tomcat"]["user"]
      group node["tomcat"]["group"]
      source "context.xml.erb"
      variables({
      :context_attrs => node["tomcat-component"]["context"].to_hash.fetch("context_attrs", {}),
      :context_nodes => node["tomcat-component"]["context"].to_hash.fetch("context_nodes", [])
    })
    notifies :restart, "service[tomcat]", :delayed
  end
end

