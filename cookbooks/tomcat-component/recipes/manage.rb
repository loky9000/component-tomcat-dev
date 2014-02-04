#
# Manage services
#

node["tomcat"]["manage"]["services"].each do |srv|
  service srv do
      action node.tomcat.manage.action
  end
end
