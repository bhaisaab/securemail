from fabric.api import *
import getpass
import sys

# Enforce sysadmin params
env.user = "bhaisaab"
env.port = "1009"

# Forward local agent
env.forward_agent = True

# Move to a reusable map/hash module
env.roledefs = {
                   "baagi": [""],
               }

# Add role to capture all nodes
all_servers = []
for key in env.roledefs:
    all_servers = all_servers + env.roledefs[key]

env.roledefs["all"] = all_servers

if len(env.hosts) != 0:
    for key in env.roledefs.keys():
        env.roledefs[key] = []


print """
   _____          __                         __
  /  _  \  __ ___/  |_  ____   _____ _____ _/  |_  ___________
 /  /_\  \|  |  \   __\/  _ \ /     \\\\__  \\\\   __\/  _ \_  __ \\
/    |    \  |  /|  | (  <_> )  Y Y  \/ __ \|  | (  <_> )  | \/
\____|__  /____/ |__|  \____/|__|_|  (____  /__|  \____/|__|
        \/                         \/     \/
"""

print "Tasks:", env['tasks']
print "Roles:", env['roles']
print "Hosts:", env['hosts']
print "SSH Port:", env['port']


if "init" not in sys.argv and not env.password:
    env.password = getpass.getpass("Enter OTP for sudo ops: ")


def info():
    run("uname -a")
    run("lsb_release -a")
    run("uptime")
    run("last | head -5")
    run("hostname && hostname -f")


def upgrade():
    sudo("apt-get update && apt-get upgrade -V")


def noop():
    sudo("cd /etc/puppet/ && git clean -fd && git checkout -- /etc/puppet/ && git pull --rebase origin master")
    sudo("puppet apply --modulepath /etc/puppet/modules --noop /etc/puppet/manifests/site.pp --templatedir /etc/puppet/templates/")


def deploy():
    """
    Runs puppet apply
    """
    sudo("cd /etc/puppet/ && git clean -fd && git checkout -- /etc/puppet/ && git pull --rebase origin master")
    sudo("puppet apply --modulepath /etc/puppet/modules /etc/puppet/manifests/site.pp --templatedir /etc/puppet/templates/ --debug")


def reboot():
    sudo("reboot")

def setup_sslkeys(role):
    put("./ssl/%s.pem" % role, "/etc/ssl/private/")
    put("./ssl/%s.key" % role, "/etc/ssl/private/")
    put("./ssl/%s.csr" % role, "/etc/ssl/private/")
    run("chmod 640 /etc/ssl/private/*")

def init():
    """
    Assumed that root user will setup initial environment before admin takes control
    """
    if len(env.hosts) > 1:
        print "WARNING: You're initializing more than one host in one go!"

    env.user = "root"
    env.port = "22"

    # host info
    info()

    # basic package management
    run("apt-get update && apt-get upgrade -y")
    run("apt-get purge -y exim* mutt procmail bind9 apache2* php5* mysql* mailagent")
    run("apt-get install --no-install-recommends -y vim htop sudo openssh-client ssh wget gcc build-essential python-pip git tig")

    # append local public key to authorized_keys
    put("~/.ssh/id_rsa.pub", "/tmp")
    run("mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys")

    # fix ulimits
    run("echo -e '* \t soft \t nofile \t 64000' >> /etc/security/limits.conf")
    run("echo -e '* \t hard \t nofile \t 128000' >> /etc/security/limits.conf")
    run("echo -e 'root \t soft \t nofile \t 64000' >> /etc/security/limits.conf")
    run("echo -e 'root \t hard \t nofile \t 128000' >> /etc/security/limits.conf")

    # install puppet based on Debian codename
    run("if [ `lsb_release --codename | grep wheezy | wc -l` -eq 1 ]; then cd /tmp && wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb && dpkg -i puppetlabs-release-wheezy.deb; else cd /tmp && wget http://apt.puppetlabs.com/puppetlabs-release-squeeze.deb && dpkg -i puppetlabs-release-squeeze.deb; fi")

    # setup ssl keys
    setup_sslkeys(env.roles[0])

    # install puppet and git, clone repo
    run("apt-get update && apt-get install puppet -y --no-install-recommends")
    run("cd /etc && rm -fr puppet && git clone https://github.com/baagi/devops.git puppet")

    # first deploy
    deploy()
