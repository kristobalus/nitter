#!/bin/bash

echo "$NITTER_GUEST_ACCOUNTS_URL"
cp /config/nitter.conf /src/nitter.conf
wget -O /src/guest_accounts.json "$NITTER_GUEST_ACCOUNTS_URL"
./nitter
