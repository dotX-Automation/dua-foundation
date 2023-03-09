# dua-foundation

Dockerfiles and build configurations for the base units of the Distributed Unified Architecture.

## Currently supported images

The following images contain the base units of the Distributed Unified Architecture. They are intended to be used as a base for other images, and are not intended to be used directly, representing the hardware abstraction layer of DUA:

- [x] [`x86-base`](Dockerfile.x86-base) Basic x86 deployment environment.
- [x] [`x86-dev`](Dockerfile.x86-dev) Development environment for x86 systems.
- [x] [`x86-cudev`](Dockerfile.x86-cudev) As above, but with CUDA support and packages; based on official Nvidia images.
- [x] [`armv8-base`](Dockerfile.armv8-base) Basic ARMv8 deployment environment.
- [x] [`armv8-dev`](Dockerfile.armv8-dev) Development environment for ARMv8 systems.
- [x] [`jetson5c7`](Dockerfile.jetson5c7) Full environment based on JetPack 5.0.2, Compute Capabilities 7.2; intended for Jetson Xavier NX/AGX Xavier.

See the individual Dockerfiles for more information, build steps, and image contents.

## Usage

**This repository is for internal use only. Building these images requires a fully configured Buildx installation and many hours on a powerful machine, as well as a lot of disk space.**

To request changes, updates or new images, please open an issue.

### Workflow

Each Dockerfile builds a base unit image.

Dockefiles are independent and can be built separately. This is to ensure that each base unit can be configured independently, since the hardware they support may vary.

#### [`docker-compose.yml`](docker-compose.yml)

Used to build and run the images in a controlled environment. Each build step is defined as a service, and the services are ordered in a way that ensures that the images are built in the correct order. Important build arguments are as follows:

- `DUA_UTILS_VERSION`: The version of the [`dua-utils`](https://github.com/IntelligentSystemsLabUTV/dua-utils) package to install in the image; used as a timestamp to invalidate the cache and trigger a rebuild upon each new version.

**The contents of this file are also intended as a reference to write Compose files for other projects that are based on DUA.**

#### [`build_images.sh`](build_images.sh)

Helper script to build all images.

#### [`save_images.sh`](save_images.sh)

Helper script to save all images to a compressed archive (requires `pigz`).

### Host system requirements

#### For all base units

- Docker
- Docker Compose V2
- `pigz`

#### For `x86-*` base units

- Ubuntu 22.04 is preferred (but other distros should work too)

#### For `x86-cudev` base unit

- `nvidia-container-toolkit` (optional, for `x86-cudev`)

#### For `armv8-*` base units

- Ubuntu 22.04 is preferred (but other distros should work too)

#### For `jetson5c7` base unit

- JetPack 5.0.2, since the base image is also based on JetPack 5.0.2
- Nvidia Container Runtime configured as the one and only Docker runtime
- Running Docker on an NVMe SSD mounted on the carrier board is also suggested to improve performance and reduce wear on the eMMC, as well as I/O bottlenecks

It is suggested to enter configurations similar to the following in `/etc/docker/daemon.json`:

```json
{
    "data-root": "/mnt/NX_NVME/docker",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```

---

## License

This work is licensed under the GNU General Public License v3.0. See the [`LICENSE`](LICENSE) file for details.

## Copyright

Copyright (c) 2023, Intelligent Systems Lab, University of Rome "Tor Vergata"
