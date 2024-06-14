# dua-foundation

Dockerfiles and build configurations for the base units of the Distributed Unified Architecture.

## Currently supported images

The following images contain the base units of the Distributed Unified Architecture. They are intended to be used as a base for other images, and are not intended to be used directly, representing the hardware abstraction layer of DUA:

- [x] [`x86-base`](Dockerfile.x86-base) Basic x86 deployment environment.
- [x] [`x86-dev`](Dockerfile.x86-dev) Development environment for x86 systems.
- [x] [`x86-cudev`](Dockerfile.x86-cudev) As above, but with CUDA support and packages; based on official Nvidia images.
- [x] [`armv8-base`](Dockerfile.armv8-base) Basic ARMv8 deployment environment.
- [x] [`armv8-dev`](Dockerfile.armv8-dev) Development environment for ARMv8 systems, including Apple Silicon Macs.
- [x] [`jetson5c7`](Dockerfile.jetson5c7) Full environment based on JetPack 5.0.2, Compute Capabilities 7.2; intended for Jetson Xavier NX/AGX Xavier.
- [x] [`jetson4c5`](Dockerfile.jetson4c5) Full environment based on JetPack 4.6.1, Compute Capabilities 5.3; intended for Jetson Nano.
- [x] [`jetson4c6`](Dockerfile.jetson4c6) Full environment based on JetPack 4.6.3, Compute Capabilities 6.2; intended for Jetson TX2.

See the individual Dockerfiles for more information, build steps, and image contents.

---

## License

This work is licensed under the GNU General Public License v3.0. See the [`LICENSE`](LICENSE) file for details.

## Copyright

Copyright (c) 2023, Intelligent Systems Lab, University of Rome Tor Vergata
