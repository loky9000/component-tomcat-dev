#
#Tomcat component additional libs installation to tomcat
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

require 'uri'
uri = URI.parse(node['tomcat-component']['lib_uri'])
file_name = File.basename(uri.path)

if ( node['tomcat-component']['lib_uri'].start_with?('http', 'ftp') )
  remote_file "/tmp/#{file_name}" do
    source node['tomcat-component']['lib_uri']
  end

  execute "extract #{file_name}" do
    command "tar -xzvf /tmp/#{file_name} -C #{node['tomcat']['lib_dir']}/"
    notifies :restart, "service[tomcat]", :immediately
  end
end

if ( node['tomcat-component']['lib_uri'].start_with?('file') )
  url = node['tomcat-component']['lib_uri']
  file_path = URI.parse(url).path
  execute "extract #{file_path}" do
    command "tar -xzvf #{file_path} -C #{node['tomcat']['lib_dir']}"
    notifies :restart, "service[tomcat]", :immediately
  end
end
