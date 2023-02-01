# dua-foundation

Dockerfiles and build configurations for the base units of the Distributed Unified Architecture.

## Currently supported images

- [x] [`x86-base`](Dockerfile.x86-base)

See the individual Dockerfiles for more information, build steps, and image contents.

## Usage

**This repository is for internal use only.**

To request changes, updates or new images, please open an issue.

### Workflow

Each Dockerfile builds a base unit image.

Dockefiles are independent and can be built separately. This is to ensure that each base unit can be configured independently, since the hardware they support may vary.

[`docker-compose.yml`](docker-compose.yml) is used to build and run the images in a controlled environment.

[`build_images.sh`](build_images.sh) is a helper script to build all images.

[`save_images.sh`](save_images.sh) is a helper script to save all images to a compressed archive (requires `pigz`).

---

## License

This work is licensed under the GNU General Public License v3.0. See the [`LICENSE`](LICENSE) file for details.

## Copyright

Copyright (c) 2023, Intelligent Systems Lab, University of Rome "Tor Vergata"
