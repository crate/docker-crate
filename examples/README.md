# CrateDB Docker Examples

## Docker compose

The example file _docker-compose.yml_ describes three **crate** containers, 
_crate01_, _crate02_ and _crate03_, that can be run with 
[docker compose](https://docs.docker.com/compose/) by means of the command:

    <code>
        docker-compose up
    </code> 

### <a id="docker-compose-requisites"></a> Prerequisites

Before you run the example:

- Each container needs to map port 4200 to a unique port number on localhost. 
These ports are used to access the nodes' 
[Admin UI](https://crate.io/docs/clients/admin-ui/en/latest/).
In file _docker-compose.yml_, they are defined as 4201, 4202 and 4203, make 
sure these ports are available or change them. 

- The example runs on a dedicated docker network, **crate**, which you can 
created with command:

    <code>
        docker network create crate
    </code>

- Configuration parameters are added in the _command_ section with syntax:

    <code>
        -Cparameter-name=parameter-value
    </code>
    
    where all parameter names and their description can be found 
    [here](https://crate.io/docs/crate/reference/en/latest/config/index.html).

- Each container needs to mount their own volume on a unique folder in the
localhost's file system.
In file _docker-compose.yml_, folder **/tmp/crate** needs to exist. Each crate
instance then will use its own folder _01_, _02_ and _03_ respectively.
   
## Docker run single

The example: 

    <code>
        run_crate_single.sh
    </code>

### Prerequisites

Same prerequisites as in the [docker compose example](#docker-compose-requisites),
except regarding volumes:

- In file _run_crate_single.sh_, folder **/tmp/crate** needs to exist. The crate
  instance then will use its own folder _single_.  

## Docker run multiple

The examples: 

    <code>
        run_crate01.sh
        run_crate02.sh
        run_crate03.sh
    </code>

### Prerequisites

Same prerequisites as in the [docker compose example](#docker-compose-requisites),
except regarding volumes:

- In file _docker-compose.yml_, folder **/tmp/crate** needs to exist. Each crate
instance then will use its own folder _multiple/01_, _multiple/02_ and _multiple/03_ 
respectively.  
     
## Help

Looking for more help?

- See the [README.md](../README.rst) for more information.