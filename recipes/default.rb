if platform_family?('rhel') 
  include_recipe "yum"
  include_recipe "yum::epel"
  
  if node['platform_version'].to_f < 6.0
    include_recipe "jpackage"
  end
end

if node['platform'] == "ubuntu"
  execute "update packages cache" do
    command "apt-get update"
  end
end

include_recipe "tomcat"

if platform_family?('rhel')
  execute "stop iptables" do
    command "if [ -e '/sbin/iptables' ]; then bash -c '/etc/init.d/iptables stop'; else echo $?; fi"
  end
end

if platform_family?('debian')
  execute "stop iptables" do
    command "if [ -e '/sbin/iptables' ]; then bash -c ' iptables -F'; else echo $?; fi"
  end
end  

