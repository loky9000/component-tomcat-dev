#
# Recipe build petclinic app from git
#

git_url="/tmp/gittest"
new_git_url = "#{node['scm']['repository']}?#{node['scm']['revision']}"
cur_git_url = ""

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
    command "cd /tmp/webapp; mvn clean package -Dmaven.test.skip=true && cp /tmp/webapp/target/*.war /tmp/ROOT.war"
  end

  File.open("#{git_url}", 'w') { |file| file.write("#{node['scm']['repository']}?#{node['scm']['revision']}") }
end
