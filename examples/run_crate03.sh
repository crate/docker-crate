#!/bin/sh

docker run -d --rm --name=crate03 \
	--net=crate -p 4203:4200 \
  	--env CRATE_HEAP_SIZE=1g \
        -v "/tmp/crate/multiple/03:/data" \
	crate -Cnetwork.host=_site_ \
              -Cdiscovery.seed_hosts=crate01,crate02 \
              -Ccluster.initial_master_nodes=crate01,crate02,crate03
