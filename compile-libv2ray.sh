#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NDK_HOME="${NDK_HOME:-$ANDROID_HOME/ndk/30.0.16248370}"

echo "==> Preparing patched Xray-core..."
pushd "$__dir/AndroidLibXrayLite"

XRAY_COMMIT="a4a3dff5b20c2faae567b742c172c7b95e75c083" # Latest v26.10.31
rm -rf xray-core-src
echo "Cloning Xray-core commit $XRAY_COMMIT..."
git clone https://github.com/XTLS/Xray-core.git xray-core-src
pushd xray-core-src
git checkout "$XRAY_COMMIT"
popd

echo "Patching validateOutboundTransportSecurity in Xray-core..."
python3 -c "
with open('xray-core-src/infra/conf/xray.go', 'r', encoding='utf-8') as f:
    s = f.read()

target = 'func validateOutboundTransportSecurity(rawConfig interface{}, senderSettings *proxyman.SenderConfig) error {'
replacement = '''func validateOutboundTransportSecurity(rawConfig interface{}, senderSettings *proxyman.SenderConfig) error {
	return nil // Patched: allow unencrypted VLESS / Trojan outbounds
'''

if target in s:
    s = s.replace(target, replacement, 1)
    with open('xray-core-src/infra/conf/xray.go', 'w', encoding='utf-8') as f:
        f.write(s)
    print('SUCCESS: xray.go patched')
else:
    print('ERROR: target not found in xray.go')
    exit(1)
"

echo "Updating go.mod replace directive..."
go mod edit -replace github.com/xtls/xray-core=./xray-core-src
go mod tidy

echo "Downloading geo assets..."
mkdir -p assets data
bash gen_assets.sh download
cp -v data/*.dat assets/

echo "Installing gomobile and compiling libv2ray.aar..."
go install golang.org/x/mobile/cmd/gomobile@latest
export PATH=$PATH:$(go env GOPATH)/bin
export ANDROID_NDK_HOME="$NDK_HOME"
gomobile init
gomobile bind -v -androidapi 24 -trimpath -ldflags='-s -w -buildid= -checklinkname=0' -o libv2ray.aar ./

mkdir -p "$__dir/V2rayNG/app/libs"
cp -v libv2ray.aar "$__dir/V2rayNG/app/libs/libv2ray.aar"

popd
echo "==> libv2ray.aar build complete with patched latest Xray-core!"
