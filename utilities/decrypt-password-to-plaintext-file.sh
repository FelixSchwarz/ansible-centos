#!/bin/bash

## encrypt:
# gpg --armor --encrypt < vault-password.txt > vault-password.gpg

gpg --decrypt < vault-password.gpg > vault-password.txt
