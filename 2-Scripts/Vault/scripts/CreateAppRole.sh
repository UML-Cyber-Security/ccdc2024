#!/bin/bash
vault write auth/approle/role/my-approle token_ttl=1h token_max_ttl=24h
vault read auth/approle/role/my-approle/role-id
