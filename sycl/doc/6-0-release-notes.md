# Intel SYCL Compiler release 6.0.0

## Dependencies included in the release

- [oneapi-src/unified-runtime@v0.10.8](https://github.com/oneapi-src/unified-runtime/releases/tag/v0.10.8)

## Components included in the release

- clang version `19.0.0`
- SYCL runtime version 8.0.0 (as indicated by predefined macro
  `__LIBSYCL_MAJOR_VERSION`, `__LIBSYCL_MINOR_VERSION` and
  `__LIBSYCL_PATCH_VERSION`)

## Compatibility with previous releases

This is a first formal release in this repo and therefore there are no other
releases to be compatible with.

However, the repo has existed for a while and this release is **not** compatible
with builds produced from older commits, because there were ABI-breaking changes
made to the codebase just prior taking the `sycl-rel-6_0_0` branch.

## Compatibility with oneAPI

[Intel(R) oneAPI DPC++/C++ Compiler][oneapi-dpcpp]
version 2025.0 leverages codebase from `sycl-rel-6_0_0` branch and it is the
closest oneAPI DPC++/C++ compiler release to this one (in terms of available
features and bugfixes).

**However**, this **does not** guarantee any feature or bugfix parity between
these two releases.

## Validation & quality expectations

In general, list of supported hardware and operating systems should match the
one provided by Intel(R) oneAPI DPC++/C++ Compiler for version 2025.0, see
corresponding [system requirements][oneapi-dpcpp-system-reqs].

However, we **did not** perform the same exaustive testing of this open-source
branch and therefore there could be some unique issues that are not present in
Intel (R) oneAPI DPC++/C++ Compiler version 2025.0.

You can find full validation logs for the branch
[here](https://github.com/intel/llvm/actions/runs/12794684274/job/35672684082),
but a summary of it will also be posted below.

### [End to end tests][sycl-e2e]

The following hardware and software configurations were tested:

Driver versions listed as reported by
`sycl::device::get_info<info::device::driver_version>()`.

- Windows
  - Driver version: 32.0.101.6129
  - Intel(R) oneAPI Unified Runtime over Level-Zero on
    Intel(R) Iris(R) Xe Graphics 12.0.0
    - Driver version: [1.5.31093](https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html)
  - Intel(R) OpenCL Graphics on Intel(R) Iris(R) Xe Graphics OpenCL 3.0 NEO
    - Driver version: [32.0.101.6129](https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html)
- Linux (Ubuntu 22.04)
  - Intel(R) OpenCL Graphics on Intel(R) Iris(R) Xe Graphics OpenCL 3.0 NEO
    - Driver version: [24.52.32224.5](https://github.com/intel/compute-runtime/releases/tag/24.52.32224.5)
  - Intel(R) oneAPI Unified Runtime over Level-Zero on
    Intel(R) Iris(R) Xe Graphics 12.0.0
    - Driver version: [1.6.32224.500000](https://github.com/intel/compute-runtime/releases/tag/24.52.32224.5)
  - Intel(R) OpenCL on
    11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80 Ghz OpenCL 3.0
    - Driver version: [2024.18.10.0.08_160000](https://github.com/intel/llvm/releases/tag/2024-WW43)
  - AMD HIP BACKEND on AMD Radeon RX 6700 XT gfx1031
    - Driver version: [HIP 60342.13](https://rocm.docs.amd.com/en/docs-6.1.1/about/release-notes.html)
  - NVIDIA CUDA BACKEND on NVIDIA A10G 8.6
    - Driver version: [CUDA 12.1](https://developer.nvidia.com/cuda-12-6-1-download-archive)

### [SYCL CTS][sycl-cts]

- Linux (Ubuntu 22.04)
  - Intel(R) OpenCL on
    11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80 Ghz OpenCL 3.0
    - Driver version: [2024.18.10.0.08_160000](https://github.com/intel/llvm/releases/tag/2024-WW43)
  - Intel(R) oneAPI Unified Runtime over Level-Zero on
    Intel(R) Iris(R) Xe Graphics 12.0.0
    - Driver version: [1.6.32224.500000](https://github.com/intel/compute-runtime/releases/tag/24.52.32224.5)

We use the latest available CTS in our validation, but `sycl-rel-6.0.0` is an
old branch already and there were some CTS changes made which make them fail.

Known failures are:
- `test_header` CTS target cannot be compiled, because definition of
  `SYCL_LANGUAGE_VERSION` does not match the latest version of the SYCL 2020
  specification. See KhronosGroup/SYCL-Docs#634
- `test_language` CTS target cannot be compiled, because the compiler does not
  abide to all new rules for constant-evaluated expression from the latest
  version of the SYCL 2020 specification. See KhronosGroup/SYCL-Docs#388
- `multi_ptr` CTS target cannot be compiled, because implementation for
  `decorated_generic_ptr` and `raw_generic_ptr` aliases is missing.
  See KhronosGroup/SYCL-Docs#598

## How to use

This release does not provide a pre-built binaries of our SYCL compiler and
simply marks a known good commit on a corresponding release branch which can be
used for building the compiler and the runtime for your needs. To do so, follow
[Get Started Guide](https://github.com/intel/llvm/blob/sycl-rel-6_0_0/sycl/doc/GetStartedGuide.md)

[oneapi-dpcpp]: https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-compiler.html
[oneapi-dpcpp-system-reqs]: https://www.intel.com/content/www/us/en/developer/articles/system-requirements/intel-oneapi-dpcpp-system-requirements.html
[sycl-e2e]: https://github.com/intel/llvm/tree/sycl-rel-6_0_0/sycl/test-e2e
[sycl-cts]: https://github.com/KhronosGroup/SYCL-CTS
