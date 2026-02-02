pipeline {
  agent any
  stages {
    stage("Parallel") {
      parallel {
        stage("Integration tests x86_64") {
          agent { label "x64" }
          steps {
            sh '''
              uv venv --python 3.10
              uv pip install -r requirements.txt
              VERSION=$(curl -s https://cratedb.com/versions.json | grep crate_testing | tr -d '" ' | cut -d ":" -f2)
              ./update.py --cratedb-version ${VERSION} > Dockerfile
            '''.stripIndent()
            sh 'uv run -m unittest -v'
          }
        }
        stage("Integration tests aarch64") {
          agent { label "aarch64" }
          steps {
            sh '''
              uv venv --python 3.10
              uv pip install -r requirements.txt
              VERSION=$(curl -s https://cratedb.com/versions.json | grep crate_testing | tr -d '" ' | cut -d ":" -f2)
              ./update.py --cratedb-version ${VERSION} > Dockerfile
            '''.stripIndent()
            sh 'uv run -m unittest -v'
          }
        }
        stage("Docker build & test x86_64") {
          agent { label "x64" }
          steps {
            sh 'git clean -xdff'
            checkout scm
            sh '''
              uv venv
              uv pip install -r requirements.txt
              VERSION=$(curl -s https://cratedb.com/versions.json | grep crate_testing | tr -d '" ' | cut -d ":" -f2)
              ./update.py --cratedb-version ${VERSION} > Dockerfile

              docker build \
                --pull \
                --platform linux/amd64 \
                --rm \
                --force-rm \
                --file ./Dockerfile . \
                --tag crate/crate:ci_test

              rm -rf ./official-images
              git clone --filter=blob:none https://github.com/docker-library/official-images.git ./official-images
              ./official-images/test/run.sh crate/crate:ci_test
            '''.stripIndent()
          }
        }

        stage("Docker build & test aarch64") {
          agent { label "aarch64" }
          steps {
            sh 'git clean -xdff'
            checkout scm
            sh '''
              uv venv
              uv pip install -r requirements.txt
              VERSION=$(curl -s https://cratedb.com/versions.json | grep crate_testing | tr -d '" ' | cut -d ":" -f2)
              ./update.py --cratedb-version ${VERSION} > Dockerfile

              docker build \
                --pull \
                --platform linux/arm64 \
                --rm \
                --force-rm \
                --file ./Dockerfile . \
                --tag crate/crate:ci_test

              rm -rf ./official-images
              git clone --filter=blob:none https://github.com/docker-library/official-images.git ./official-images
              ./official-images/test/run.sh crate/crate:ci_test
            '''.stripIndent()
          }
        }
      }
    }
  }
}
