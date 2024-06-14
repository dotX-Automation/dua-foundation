# dua-foundation

Dockerfiles and build configurations for the base units of the Distributed Unified Architecture.

## Currently supported images

The following images contain the base units of the Distributed Unified Architecture. They are intended to be used as a base for other images, and are not intended to be used directly, representing the hardware abstraction layer of DUA:

- [x] [`x86-base`](Dockerfile.x86-base) Basic x86 deployment environment.
- [x] [`x86-dev`](Dockerfile.x86-dev) Development environment for x86 systems.
- [x] [`x86-cudev`](Dockerfile.x86-cudev) As above, but with CUDA support and packages; based on official Nvidia images.
- [x] [`armv8-base`](Dockerfile.armv8-base) Basic ARMv8 deployment environment.
- [x] [`armv8-dev`](Dockerfile.armv8-dev) Development environment for ARMv8 systems, including Apple Silicon Macs.
- [x] [`jetson5`](Dockerfile.jetson5) Full environment based on JetPack 5, for Nvidia Jetson devices.
- [x] [`jetsontx2`](Dockerfile.jetsontx2) Full environment based on JetPack 4.6.3; intended for Jetson TX2.
- [x] [`jetsonnano`](Dockerfile.jetsonnano) Full environment based on JetPack 4.6.1; intended for Jetson Nano.

See the individual Dockerfiles for more information, build steps, and image contents.

---

## License

This work is licensed under the GNU General Public License v3.0. See the [`LICENSE`](LICENSE) file for details.

## Copyright

Copyright (c) 2023, Intelligent Systems Lab, University of Rome Tor Vergata
