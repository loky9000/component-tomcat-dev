import os

from test_runner import BaseComponentTestCase
from qubell.api.private.testing import instance, environment, workflow, values

@environment({
    "default": {},
})
class TomcatDevComponentTestCase(BaseComponentTestCase):
    name = "component-tomcat-dev"
    apps = [{
        "name": name,
        "file": os.path.realpath(os.path.join(os.path.dirname(__file__), '../%s.yml' % name))
    }]

    @instance(byApplication=name)
    @values({"tomcat.app-hosts": "hosts", "tomcat.app-port": "port"})
    def test_port(self, instance, hosts, port):
        import socket

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((hosts, int(port)))

        assert result == 0

