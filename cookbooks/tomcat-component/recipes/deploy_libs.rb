#
#Tomcat component additional libs installation to tomcat
#

package "zip" do
  action :install
end

service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => false, :status => true
  end
  action :stop
end

require 'uri'
lib_uri = node['tomcat-component']['lib_uri']
lib_uri.each do |lib|
  uri = URI.parse(lib)
  file_name = File.basename(uri.path)
  ext_name = File.extname(file_name)
  target_file = "/tmp/#{file_name}"

  #check is extention zip|tar.gz
  #if ext_name != ('zip','gz','jar') 
  if ( ! %w{.zip .gz .jar}.include?(ext_name))
    fail "not supported"
  end

  #download to target_file
  if ( lib.start_with?('http','ftp'))
    remote_file "#{target_file}" do
      source lib
    end
  elsif ( lib.start_with?('file'))
    target_file = URI.parse(lib).path 
  end

  #extract archive to tomcat libs
  case ext_name
  when ".gz"
    execute "extract #{target_file}" do
      command "tar -xzvf #{target_file} -C #{node['tomcat']['lib_dir']}/"
    end
  when ".zip"
    execute "extract #{target_file}" do
      command "unzip -o #{target_file} -d #{node['tomcat']['lib_dir']}/"
    end
  #copy lib to tomcat libs
  when ".jar"
    execute "copy #{target_file}" do
      command "cp -rf #{target_file} #{node['tomcat']['lib_dir']}/"
    end
  end
end

service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => false, :status => true
  end
  action :start
end

execute "wait tomcat up" do
  command "sleep 30"
end
