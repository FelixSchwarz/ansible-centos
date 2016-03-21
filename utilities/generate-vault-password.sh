#!/bin/sh

GPGKEY="0xANYTHING"

PASSWORDFILE=vault-password.gpg
if [ -e "${PASSWORDFILE}" ]; then
    echo "${PASSWORDFILE} already exists"
    exit
fi
pwgen --secure --symbols 80 -1 | gpg --encrypt -r "${GPGKEY}" --armor > "${PASSWORDFILE}"

# further reading:
# https://blog.erincall.com/p/using-pgp-to-encrypt-the-ansible-vault
# http://docs.ansible.com/ansible/playbooks_vault.html#creating-encrypted-files

