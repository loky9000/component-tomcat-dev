import os

from test_runner import BaseComponentTestCase
from qubell.api.private.testing import instance, environment, workflow, values

@environment({
    "default": {},
    "AmazonEC2_CentOS_63": {
        "policies": [{
            "action": "provisionVms",
            "parameter": "imageId",
            "value": "us-east-1/ami-eb6b0182"
        }, {
            "action": "provisionVms",
            "parameter": "vmIdentity",
            "value": "root"
        }]
    },
    "AmazonEC2_CentOS_53": {
        "policies": [{
            "action": "provisionVms",
            "parameter": "imageId",
            "value": "us-east-1/ami-beda31d7"
        }, {
            "action": "provisionVms",
            "parameter": "vmIdentity",
            "value": "root"
        }]
    },
    "AmazonEC2_Ubuntu_1204": {
        "policies": [{
            "action": "provisionVms",
            "parameter": "imageId",
            "value": "us-east-1/ami-d0f89fb9"
        }, {
            "action": "provisionVms",
            "parameter": "vmIdentity",
            "value": "ubuntu"
        }]
    },
    "AmazonEC2_Ubuntu_1004": {
        "policies": [{
            "action": "provisionVms",
            "parameter": "imageId",
            "value": "us-east-1/ami-0fac7566"
        }, {
            "action": "provisionVms",
            "parameter": "vmIdentity",
            "value": "ubuntu"
        }]
    }
})
class TomcatDevComponentTestCase(BaseComponentTestCase):
    name = "Application Server"
    meta = "https://raw.githubusercontent.com/qubell-bazaar/component-tomcat-dev/master/meta.yml" 
    apps = [{
        "name": name,
    }]

    @instance(byApplication=name)
    @values({"tomcat.app-hosts": "hosts", "tomcat.app-port": "port"})
    def test_port(self, instance, hosts, port):
        import socket

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((hosts, int(port)))

        assert result == 0

    @instance(byApplication=name)
    @workflow("tomcat.build-app", {"scm-provider": "git", "git-uri": "git://github.com/qubell/starter-java-web.git", "app-branch": "HEAD"})
    def test_build(self, instance):
        assert True
