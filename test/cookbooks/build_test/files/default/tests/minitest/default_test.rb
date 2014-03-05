require 'minitest/spec'

describe_recipe "build::default" do
  it "install java package" do
    if node["platform_family"] == 'debian'
      package("openjdk-6-jdk").must_be_installed
    elsif node["platform_family"] == 'rhel'
      package("java-1.6.0-openjdk").must_be_installed
    end
  end
  it "install maven package" do
    if node["platform_family"] == 'debian'
      package("maven2").must_be_installed
    elsif node["platform_family"] == 'rhel'
      if node["platform_version"] >= '6.0'
        assert File.exist?("/usr/local/maven-2.2.1/bin/mvn")
      elsif node["platform_version"] < '6.0'
        assert File.exist?("/usr/bin/mvn")
      end
    end
  end
  it "install git package" do
    if node["platform_family"] == 'debian'
      if node["platform_version"] < '12.04'
        package("git-core").must_be_installed
      end
    else
      package("git").must_be_installed
    end
  end
  it "create application war package" do
    assert File.exist?("#{node['build']['package']}")
  end
end
