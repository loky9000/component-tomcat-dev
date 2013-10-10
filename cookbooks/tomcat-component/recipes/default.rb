#
# Cookbook name: deploy tomcat app
# Recipe: default
#
#Copyright 2013, Qubell
#

# Creating app war
if not node['tomcat-component']['deploy']['git']['url'].empty?
  execute "clear" do
    command "rm -rf /tmp/app"
    action :run
  end

  case node[:platform]
  when "debian", "ubuntu"
    package "git-core" do
      action :install
    end
  else
    package "git" do
      action :install
    end
  end

  git "/tmp/app" do
    repository node['tomcat-component']['deploy']['git']['url']
    reference node['tomcat-component']['deploy']['git']['revision']
    action :sync
  end

  package "maven2" do
    action :install
  end

  execute "package" do
    command "cd /tmp/app; mvn clean package"
    action :run
  end

  execute "move" do
    command "cd /tmp/app; cp target/*.war /tmp/app.war; rm -rf /tmp/app"
    action :run
  end
end

# Creating tomcat context xml

template '/tmp/app.xml' do
  source 'context.xml.erb'
  owner 'root'
  group 'root'
  mode '0777'
  variables(
      :war => '/tmp/app.war'
  )
end

directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :delete
end

link "#{node['tomcat']['context_dir']}/ROOT.xml" do
  to "/tmp/app.xml"
end
