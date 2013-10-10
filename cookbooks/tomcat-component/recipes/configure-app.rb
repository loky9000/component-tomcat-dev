execute "rm app dir" do
  command "rm -rf /tmp/app"
  action :run
end

dirname = File.dirname(node['tomcat-component']['to'])

directory "/tmp/app/WEB-INF/#{dirname}" do
  mode 0777
  owner "root"
  group "root"
  action :create
  recursive true
end

#Generate database connection
template "/tmp/app/WEB-INF/#{node['tomcat-component']['to']}" do
  source "database.properties.erb"
  variables({
    :host => node['mysql']['host'],
    :port => node['mysql']['port'],
    :database => node['mysql']['db_name'],
    :user => node['mysql']['db_user'],
    :password => node['mysql']['db_pass'],
  })
end

execute "copy app.war to app.final.war" do
  command "rm -rf /tmp/app.final.war; cp /tmp/app.war /tmp/app.final.war"
  action :run
end

package "zip" do
  action :install
end

execute "fill app.final.war" do
  command "cd /tmp/app; zip -r /tmp/app.final.war *"
  action :run
end

# Creating tomcat context xml
template '/tmp/app.xml' do
  source 'context.xml.erb'
  owner 'root'
  group 'root'
  mode '0777'
  variables(
      :war => '/tmp/app.final.war'
  )
end

directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :delete
end

link "#{node['tomcat']['context_dir']}/ROOT.xml" do
  to "/tmp/app.xml"
end

service "tomcat6" do
  action :restart
end
