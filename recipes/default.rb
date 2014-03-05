#
# Recipe build petclinic app from git
#

git_url="/tmp/gittest"
new_git_url = "#{node['scm']['repository']}?#{node['scm']['revision']}"
cur_git_url = ""

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

include_recipe "java"

if File.exist?("#{git_url}")
  cur_git_url = File.read("#{git_url}")
end

if !"#{cur_git_url}".eql? "#{new_git_url}"

  if node['scm']['provider'] == "git" or node['scm']['provider'] == "subversion"
    if node['platform'] == "centos" && node['platform_version'].to_f >= 6.0
      include_recipe "ark"
      include_recipe "maven::maven2"
    else
      package "maven2" do
        action :install
      end
    end
  end

  include_recipe 'git'

  case node['scm']['provider']
    when "git"
      bash " clean #{node['build']['dest_path']}/webapp" do
        code <<-EEND
          rm -rf #{node['build']['dest_path']}/webapp
        EEND
      end
      git "#{node['build']['dest_path']}/webapp" do
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
    command "cd #{node['build']['dest_path']}/webapp; mvn clean package && cp #{node['build']['dest_path']}/webapp/target/*.war #{node['build']['dest_path']}/#{node['build']['dest_name']}.war"
  end

  node.set['build']['package']="#{node['build']['dest_path']}/#{node['build']['dest_name']}.war"

  File.open("#{git_url}", 'w') { |file| file.write("#{node['scm']['repository']}?#{node['scm']['revision']}") }
end
