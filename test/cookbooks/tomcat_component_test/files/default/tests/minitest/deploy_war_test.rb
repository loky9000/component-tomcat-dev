require 'minitest/spec'
require 'open-uri'
def is_page_correct?(url, content)
  return open(url).read().include?(content)
end
def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content"
end



describe_recipe 'tomcat-component::deploy_war' do
   it "copy to tomcat webapp_dir and verify mode, owner and group " do 
    file_name = node['tomcat-component']['war']['appname']
    assert_file "#{node['tomcat']['webapp_dir']}/#{file_name}", "#{node['tomcat']['user']}", "#{node['tomcat']['group']}", "644"
  end

   it "create context file if create_context is true" do 
   case node['tomcat-component']['create_context']
  when true
   file("#{node['tomcat']['context_dir']}/petclinic.xml").must_exist
   assert_include_content("#{node['tomcat']['context_dir']}/petclinic.xml", "#{node['tomcat-component']['context']['context_attrs']['docBase']}")
   end
 end

sleep(30)  

  it 'tomcat war has correct content' do
    assert is_page_correct?("http://#{node['ipaddress']}:8080/petclinic/", "Spring") == true, "Expected content is present on webpage"
  end
end
