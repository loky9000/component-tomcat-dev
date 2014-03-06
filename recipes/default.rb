case node["platform_family"]
  when "rhel"
    include_recipe "yum"
    include_recipe "yum::epel"
  
    if node['platform_version'].to_f < 6.0
      include_recipe "jpackage"
    end
  end

case node['platform']
  when "ubuntu"
    execute "update packages cache" do
      command "apt-get update"
    end
  end

include_recipe "tomcat"

case node["platform_family"]
  when "rhel"
    service "iptables" do
      action :stop
    end
  when "debian"
    service "ufw" do
      action :stop
    end
  end
