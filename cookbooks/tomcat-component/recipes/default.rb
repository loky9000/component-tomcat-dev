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

git_url="/tmp/gittest"
new_git_url = "#{node['scm']['repository']}?#{node['scm']['revision']}"
cur_git_url = ""

if File.exist?("#{git_url}")
  cur_git_url = File.read("#{git_url}")
end

if !"#{cur_git_url}".eql? "#{new_git_url}"

  if node['scm']['provider'] == "git" or node['scm']['provider'] == "subversion"
    if node['platform'] == "centos" && node['platform_version'].to_f > 6.0
      include_recipe "ark"
      include_recipe "maven::maven2"
    else
      package "maven2" do
        action :install
      end
    end
  end

  include_recipe 'git'

  if node['platform'] == "centos"
    remote_file "/usr/share/tomcat6/lib/mysql-connector.jar" do
      source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.6/mysql-connector-java-5.1.6.jar"
      owner 'root'
      group 'root'
      mode 00644
    end

    if node['platform_version'].to_f > 6.0
      remote_file "/usr/share/tomcat6/lib/tomcat-dbcp.jar" do
        source "http://repo1.maven.org/maven2/org/apache/tomcat/dbcp/6.0.26/dbcp-6.0.26.jar"
        owner 'root'
        group 'root'
        mode 00644
      end
    end
  end

  case node['scm']['provider']
    when "git"
      bash " clean /tmp/webapp" do
        code <<-EEND
          rm -rf /tmp/webapp
        EEND
      end
      git "/tmp/webapp" do
        repository node['scm']['repository']
        revision node['scm']['revision']
        action :sync
      end
    when "subversion"
      Chef::Provider::Subversion
    when "remotefile"
      Chef::Provider::RemoteFile::Deploy
    when "file"
      Chef::Provider::File::Deploy
  end

  execute "package" do
    command "cd /tmp/webapp; mvn clean package && cp /tmp/webapp/target/*.war /tmp/webapp.war"
    notifies :restart, "service[tomcat]"
  end


  database ||= Mash.new
  database['driver'] = node['database']['driver']
  database['adapter'] = node['database']['adapter']
  database['host'] = node['database']['host'].join(",")
  database['port'] = node['database']['port']
  database['name'] = node['database']['name']
  database['username'] = node['database']['user']
  database['password'] = node['database']['password']
  database['max_active'] = 8
  database['max_idle'] = 8
  database['max_wait'] = -1

  template '/tmp/webapp.xml' do
    source 'webapp-context.xml.erb'
    owner 'root'
    group 'root'
    mode '0777'
    variables(
        :app => "/",
        :database => database,
        :war => '/tmp/webapp.war'
    )
  end

  directory "#{node['tomcat']['webapp_dir']}/ROOT" do
    recursive true
    action :delete
  end

  link "#{node['tomcat']['context_dir']}/ROOT.xml" do
    to "/tmp/webapp.xml"
  end

  if platform_family?('rhel')
    execute "stop iptables" do
      command "/etc/init.d/iptables stop"
    end
  end

  if platform_family?('debian')
    execute "stop iptables" do
      command "iptables -F"
    end
  end  

  File.open("#{git_url}", 'w') { |file| file.write("#{node['scm']['repository']}?#{node['scm']['revision']}") }

end
