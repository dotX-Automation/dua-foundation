# dua-foundation

Dockerfiles and build configurations for the base units of the Distributed Unified Architecture.

## Currently supported images

The following images contain the base units of the Distributed Unified Architecture. They are intended to be used as a base for other images, and are not intended to be used directly, representing the hardware abstraction layer of DUA:

- [x] [`x86-base`](Dockerfile.x86-base) Basic x86 deployment environment.
- [x] [`x86-dev`](Dockerfile.x86-dev) Development environment for x86 systems.
- [x] [`x86-cudev`](Dockerfile.x86-cudev) As above, but with CUDA support and packages; based on official Nvidia images.
- [x] [`x86-cudev-ai`](Dockerfile.x86-cudev-ai) As above, but with more Nvidia libraries and AI and ML frameworks.
- [x] [`armv8-base`](Dockerfile.armv8-base) Basic ARMv8 deployment environment.
- [x] [`armv8-dev`](Dockerfile.armv8-dev) Development environment for ARMv8 systems, including Apple Silicon Macs.
- [x] [`jetson5`](Dockerfile.jetson5) Full environment based on JetPack 5, for Nvidia Jetson devices.
- [x] [`jetson5-ai`](Dockerfile.jetson5-ai) Full environment based on ML JetPack 5 base image, with additional libraries and frameworks for AI and ML, for Nvidia Jetson devices.
- [x] [`jetsontx2`](Dockerfile.jetsontx2) Full environment based on JetPack 4.6.3; intended for Jetson TX2.
- [x] [`jetsonnano`](Dockerfile.jetsonnano) Full environment based on JetPack 4.6.1; intended for Jetson Nano.

See the individual Dockerfiles for more information, build steps, and image contents.

---

## Copyright and License

Copyright 2024 dotX Automation s.r.l.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
