#!/bin/sh

docker run -d --rm --name=crate01 \
	--net=crate -p 4201:4200 \
  	--env CRATE_HEAP_SIZE=2g \
        -v "/tmp/crate/multiple/01:/data" \
	crate -Cnetwork.host=_site_ \
              -Cdiscovery.seed_hosts=crate02,crate03 \
              -Ccluster.initial_master_nodes=crate01,crate02,crate03
