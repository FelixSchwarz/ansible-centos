#!/usr/bin/env python
from __future__ import unicode_literals

from io import StringIO
import os
import re
import subprocess
import sys
from xml.etree import ElementTree


__all__ = []

#log = open('/tmp/libvirt.log', 'w')
log = StringIO()
ROUTING_FILE = '/etc/sysconfig/routed_ips'


def libvirt_data(network_xml):
    root = ElementTree.fromstring(network_xml)
    device_name = root.find('network/bridge').get('name')
    device_ipv4 = root.find('network/ip').get('address')
    return (device_name, device_ipv4)


def addresses_for_network(address_data, network_name):
    addresses = []
    for line in address_data:
        if line.strip() == '':
            continue
        elif re.search('^\s*#', line):
            continue
        match = re.search('^\s*(\S+)\s+(\w+)\s*$', line)
        if not match:
            continue
        ip_str = match.group(1)
        net_name = match.group(2)
        if net_name != network_name:
            continue 
        addresses.append(ip_str)
    return addresses


def read_lines_from_file(filename):
    if not os.path.exists(filename):
        return
    with open(filename, 'r') as fp:
        for line in fp.readlines():
            yield line


def commands_to_setup_routing(action, device_name, device_ipv4, routed_ips):
    is_ipv6 = lambda ip_addr: (':' in ip_addr)

    commands = []
    for ip in routed_ips:
        ip_verb = 'add' if (action == 'started') else 'del'
        iptables_option = '-I' if (action == 'started') else '-D'

        if is_ipv6(ip):
            commands.extend((
                ('ip6tables', iptables_option, 'FORWARD', '-i', device_name, '--source', ip, '-j', 'ACCEPT'),
                ('ip6tables', iptables_option, 'FORWARD', '-o', device_name, '--destination', ip, '-j', 'ACCEPT'),
                ('ip', '-6', 'route', ip_verb, ip, 'dev', device_name),
            ))
        else:
            commands.extend((
                ('iptables', iptables_option, 'FORWARD', '-i', device_name, '--source', ip, '-j', 'ACCEPT'),
                ('iptables', iptables_option, 'FORWARD', '-o', device_name, '--destination', ip, '-j', 'ACCEPT'),
                ('ip', '-4', 'route', ip_verb, ip, 'via', device_ipv4, 'dev', device_name),
            ))
    return commands


# ,--- TEST DATA ---------------------------------------------------------------
NETWORK_XML = '''<hookData>
  <network>
    <name>routed</name>
    <uuid>2705561b-c7c8-4169-b9c3-8b0cdcfe8515</uuid>
    <forward mode='route'/>
    <bridge name='virbr1' stp='on' delay='0'/>
    <mac address='52:54:00:a8:e5:23'/>
    <ip address='192.168.99.1' netmask='255.255.255.255'></ip>
    <ip family='ipv6' address='badc:ab1e::' prefix='128'></ip>
  </network>
</hookData>
'''

ROUTE_DATA = '''
# some comment
10.1.1.5           routed
10.1.10.1          routed
10.10.1.1          routed
# badc:ab1e::da7a:1/128 routed
badc:ab1e:da7a:10::/96 routed
'''
# `-----------------------------------------------------------------------------

def main(argv):
    if len(argv) < 5:
        sys.stderr.write('usage: %s NETWORK_NAME ACTION STATUS -\n' % argv[0])
        log.write('error 1\n')
        return 1
    log.write('called for %r\n' % (argv,))
    name, action, state, network_xml = argv[1:5]
    if action not in ('started', 'stopped'):
        return 0
    handled_combinations = (
        ('started', 'begin'),
        ('stopped', 'end'),
    )
    if (action, state) not in handled_combinations:
        sys.stderr.write('unhandled combination: %s %s\n' % (action, state))
        return 2

    if network_xml == '-':
        network_xml = sys.stdin.read()
    device_name, device_ipv4 = libvirt_data(network_xml)
    log.write('device: %r -- ipv4 bridge %r\n' % (device_name, device_ipv4,))

    #address_lines = ROUTE_DATA.split('\n')
    address_lines = read_lines_from_file(ROUTING_FILE)
    routed_ips = addresses_for_network(address_lines, name)
    log.write('routed_ips: %r\n' % (routed_ips,))
    if not routed_ips:
        return

    commands = commands_to_setup_routing(action, device_name, device_ipv4, routed_ips)
    cmds_str = '\n'.join(map(lambda c: ' '.join(c), commands))
    log.write(cmds_str + '\n')
    for cmd in commands:
        subprocess.check_call(cmd, shell=False)


if __name__ == '__main__':
    argv = sys.argv
    #argv = ('', 'routed', 'started', 'begin', network_xml)
    rc = main(argv) or 0
    sys.exit(rc)

