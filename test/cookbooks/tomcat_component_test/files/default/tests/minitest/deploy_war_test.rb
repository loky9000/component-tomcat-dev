require 'minitest/spec'

describe_recipe 'tomcat-component::deploy_war' do
  it "deploy war to tomcat" do
    assert File.exist?("#{node['tomcat']['webapp_dir']}/petclinic.war")
  end
  it "create context.xml in tomcat config" do
    assert File.exist?("#{node['tomcat']['context_dir']}/petclinic.xml")
  end
end

sleep(30)  
require 'open-uri'
def is_page_correct?(url, content)
  return open(url).read().include?(content)
end
describe_recipe 'tomcat-component::deploy_war' do
  it 'tomcat war has correct content' do
    assert is_page_correct?("http://#{node['ipaddress']}:8080/petclinic/", "Spring") == true, "Expected content is present on webpage"
  end
end
