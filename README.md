# Crate on Alpine Linux

This is a feature/testing branch. **DO NOT MERGE !!!**

In order to support Sigar on Alpine Linux its necessary to build Sigar 1.6.4 
from source on an Alpine system. This will build the library and java binding.
According to that the sigar library gets linked to `musl libc` instead of
`glibc`.

## TODO
* Tests
* Host/maintain Sigar on own fork (currently https://github.com/ncopa/sigar.git)
