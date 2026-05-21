#!/usr/bin/env bash
# After the Fabric test network is up, CA enrollment creates a random *_sk file in Admin's
# keystore. Explorer expects a stable path (priv_sk). This script symlinks priv_sk -> that file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
KEYSTORE="${REPO_ROOT}/fabric-sample-project/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore"

if [[ ! -d "$KEYSTORE" ]]; then
	echo "Keystore not found: $KEYSTORE" >&2
	echo "Bring up the test network first (e.g. fabric-sample-project/application/start.sh)." >&2
	exit 1
fi

shopt -s nullglob
keys=("$KEYSTORE"/*_sk)
shopt -u nullglob

if [[ ${#keys[@]} -eq 0 ]]; then
	echo "No private key (*_sk) under $KEYSTORE" >&2
	exit 1
fi

TARGET="${keys[0]}"
if [[ ${#keys[@]} -gt 1 ]]; then
	echo "Multiple *_sk files found; using: $TARGET" >&2
fi

PRIV="${KEYSTORE}/priv_sk"
if [[ -L "$PRIV" ]] || [[ ! -e "$PRIV" ]]; then
	rm -f "$PRIV"
	ln -sf "$(basename "$TARGET")" "$PRIV"
	echo "Created symlink $PRIV -> $(basename "$TARGET")"
elif [[ -f "$PRIV" ]]; then
	echo "priv_sk already exists as a regular file; leaving unchanged."
else
	echo "Unexpected priv_sk state; leaving unchanged."
fi
