#!/bin/sh

docker run -it --rm --name=$CONTAINER_NAME \
	--net=crate -p 4205:4200 \
  	--env CRATE_HEAP_SIZE=2g \
        -v "/tmp/crate/single:/data" \
	crate -Cnetwork.host=_site_ \
              -Cdiscovery.type=single-node
