#
# Manage services
#
node["base"]["manage"]["services"].each do |srv|
  service srv do
      action node.base.manage.action
  end
end
