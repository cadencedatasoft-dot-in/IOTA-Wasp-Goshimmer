#!/bin/bash

currentdir=$(pwd)
echo $currentdir
sudo apt-get install jq

rungoshimmer () {
    git clone --branch v0.7.7 https://github.com/iotaledger/goshimmer.git
    cd goshimmer
    go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
    ./scripts/build.sh
    wget -O snapshot.bin https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin
    ./goshimmer --node.enablePlugins=remotelog,networkdelay,spammer,prometheus,txstream,faucet --faucet.seed=Dz8LkHNDNxMNGvw5bSpSbWs6woFtWbd8EfGBzXHjUPZ7
}

export -f rungoshimmer
gnome-terminal --tab -e "bash -c 'rungoshimmer'"


runwasp () {
    # You may change the branch here
    git clone --branch v0.2.5 https://github.com/iotaledger/wasp.git
    cd wasp
    go get github.com/lucas-clemente/quic-go@v0.26.0
    make
    ./wasp-cli init
    ./wasp-cli set goshimmer.api 127.0.0.1:5000
    ./wasp-cli set wasp.0.api 127.0.0.1:9090
    ./wasp-cli set wasp.0.nanomsg 127.0.0.1:5550
    ./wasp-cli set wasp.0.peering 127.0.0.1:4000
    jq '.nodeconn.address = "127.0.0.1:5000"' config.json > tmp.$$.json && mv tmp.$$.json config.json
    ./wasp
}

export -f runwasp
gnome-terminal --tab -e "bash -c 'runwasp'"

fgs="$currentdir/goshimmer/goshimmer"
while [ ! -f $fgs ]
do
    sleep 30s
done

fw="$currentdir/wasp/wasp" 
while [ ! -f $fw ] 
do 
    sleep 30s 
done 

# Wait and request for funds 
cd "$currentdir/wasp"
./wasp-cli request-funds
