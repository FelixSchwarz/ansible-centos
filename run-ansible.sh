#!/bin/sh
set -x

# Most useful arguments:
# --tags=wip
#   To run only a subset of all rules. See http://docs.ansible.com/playbooks_tags.html
# --limit $HOSTNAME_FROM_INVENTORY
#   To only run ansible against a specific host
# --check --diff
#   See if ansible thinks it needs to do something
# --list-tasks
#   Show what would be run
# --list-hosts
#   Show which hosts would be affected

cd "$(dirname "$0")"

ansible-playbook \
	--force-handlers \
	--inventory hosts \
	site.yml \
	$@
