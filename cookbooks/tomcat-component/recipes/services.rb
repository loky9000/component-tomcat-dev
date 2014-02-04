#
# Manage service
#
service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => false, :status => true
  end
  action [:stop, :start, :restart]
end

execute "wait tomcat " do
  command "sleep 60"
end
