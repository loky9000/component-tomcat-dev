#
#Recipe will deploy war to tomcat
#

service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => false, :status => true
  end
  action :nothing
end

#download war file
require 'uri'

if ( node['tomcat-component']['war_uri'].start_with?('http', 'ftp') )
  uri = URI.parse(node['tomcat-component']['war_uri'])
  file_name = File.basename(uri.path)
  app_name = file_name[0...-4]

  remote_file "/tmp/#{file_name}" do
    source node['tomcat-component']['war_uri']
  end
  
  file_path = "/tmp/#{file_name}"
  
elsif ( node['tomcat-component']['war_uri'].start_with?('file') )
  url = node['tomcat-component']['war_uri']
  file_path = URI.parse(url).path
  file_name = File.basename(file_path)
  app_name = File.basename(file_name)[0...-4]
end

#cleanup tomcat before deploy
file "#{node['tomcat']['webapp_dir']}/#{file_name}" do
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
  cp -fr #{file_path} #{node['tomcat']['webapp_dir']}/
  chmod 644 #{node['tomcat']['webapp_dir']}/#{file_name}
  chown #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['tomcat']['webapp_dir']}/#{file_name}
  EOH
end

#create context file
if (! node['context'].nil?) 
  template "#{node['tomcat']['context_dir']}/#{app_name}.xml" do
    owner node["tomcat"]["user"]
    group node["tomcat"]["group"]
    source "context.xml.erb"
    variables({
      :war_path => "#{node['tomcat']['webapp_dir']}/#{file_name}",
      :environments => node["context"].to_hash.fetch("environments", {}),
      :resources => node["context"].to_hash.fetch("resources", {})
    })
    notifies :restart, "service[tomcat]", :immediately
  end
end

