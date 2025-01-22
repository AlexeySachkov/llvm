# Intel SYCL Compiler release 6.0.0

## Dependencies included in the release

- [oneapi-src/unified-runtime@v0.10.8](https://github.com/oneapi-src/unified-runtime/releases/tag/v0.10.8)

## Components included in the release

- clang version `19.0.0`
- SYCL runtime version 8.0.0 (as indicated by predefined macro `__LIBSYCL_MAJOR_VERSION`, `__LIBSYCL_MINOR_VERSION` & `__LIBSYCL_PATCH_VERSION`)

## Compatibility with previous releases

This is a first formal release in this repo and therefore there are no other releases to be compatible with.
However, the repo has existed for a while and this release is **not** compatible with builds produced from
older commits, because there were ABI-breaking changes made to the codebase just prior taking the `sycl-rel-6_0_0` branch.

## Compatibility with oneAPI

Intel (R) oneAPI DPC++/C++ Compiler version 2025.0 leverages codebase from `sycl-rel-6_0_0` branch and it is
the closest proprietary release to this one (in terms of available features and bugfixes).

**However**, this **does not** guarantee any feature or bugfix parity between these two releases.

## Validation & quality expectations

In general, list of supported hardware and operating systems should match the one provided by
[Intel (R) oneAPI DPC++/C++ Compiler](https://www.intel.com/content/www/us/en/developer/articles/system-requirements/intel-oneapi-dpcpp-system-requirements.html)
for version 2025.0. However, we **did not** perform the same exaustive testing of this
open-source branch and therefore there could be some unique issues that are not present in
Intel (R) oneAPI DPC++/C++ Compiler version 2025.0.

You can find full validation logs for the branch [here](https://github.com/intel/llvm/actions/runs/12794684274/job/35672684082), but a
summary of it will also be posted below.

### Windows

[End-to-end tests](https://github.com/intel/llvm/tree/sycl-rel-6_0_0/sycl/test-e2e) were launched in the following environment:

```
[level_zero:gpu][level_zero:0] Intel(R) oneAPI Unified Runtime over Level-Zero, Intel(R) Iris(R) Xe Graphics 12.0.0 [1.5.31093]
[opencl:gpu][opencl:0] Intel(R) OpenCL Graphics, Intel(R) Iris(R) Xe Graphics OpenCL 3.0 NEO  [32.0.101.6129]
```

Testing summary:

```
Total Discovered Tests: 2138
  Unsupported      :  954 (44.62%)
  Passed           : 1174 (54.91%)
  Expectedly Failed:   10 (0.47%)
  
Expectedly Failed Tests (10):
  SYCL :: Basic/buffer/reinterpret.cpp
  SYCL :: Basic/queue/release.cpp
  SYCL :: KernelAndProgram/disable-caching.cpp
  SYCL :: LLVMIntrinsicLowering/sub_byte_bitreverse.cpp
  SYCL :: OneapiDeviceSelector/illegal_input.cpp
  SYCL :: Regression/build_log.cpp
  SYCL :: Regression/context_is_destroyed_after_exception.cpp
  SYCL :: Regression/pi_release.cpp
  SYCL :: Regression/reduction_resource_leak_dw.cpp
  SYCL :: Scheduler/ReleaseResourcesTest.cpp
```

### Linux (Ubuntu 22.04)

[End-to-end tests](https://github.com/intel/llvm/tree/sycl-rel-6_0_0/sycl/test-e2e) were launched in the following environments:

```
[opencl:gpu][opencl:0] Intel(R) OpenCL Graphics, Intel(R) Iris(R) Xe Graphics OpenCL 3.0 NEO  [24.52.32224.5]
```

Testing summary:

```
Total Discovered Tests: 2138
  Unsupported      :  950 (44.43%)
  Passed           : 1162 (54.35%)
  Expectedly Failed:   26 (1.22%)
  
Expectedly Failed Tests (26):
  SYCL :: Assert/assert_in_kernels.cpp
  SYCL :: Assert/assert_in_multiple_tus.cpp
  SYCL :: Assert/assert_in_multiple_tus_one_ndebug.cpp
  SYCL :: Assert/assert_in_one_kernel.cpp
  SYCL :: Assert/assert_in_simultaneous_kernels.cpp
  SYCL :: Assert/assert_in_simultaneously_multiple_tus.cpp
  SYCL :: Assert/assert_in_simultaneously_multiple_tus_one_ndebug.cpp
  SYCL :: Basic/kernel_info.cpp
  SYCL :: GroupAlgorithm/root_group.cpp
  SYCL :: InlineAsm/asm_multiple_instructions.cpp
  SYCL :: InvokeSimd/Feature/ImplicitSubgroup/invoke_simd_struct.cpp
  SYCL :: InvokeSimd/Feature/invoke_simd_struct.cpp
  SYCL :: InvokeSimd/Spec/ImplicitSubgroup/tuple.cpp
  SYCL :: InvokeSimd/Spec/ImplicitSubgroup/tuple_return.cpp
  SYCL :: InvokeSimd/Spec/ImplicitSubgroup/tuple_vadd.cpp
  SYCL :: InvokeSimd/Spec/clang_run_error/accessor_argument.cpp
  SYCL :: InvokeSimd/Spec/clang_run_error/reference_argument.cpp
  SYCL :: InvokeSimd/Spec/simd_size/simd32_platform_error.cpp
  SYCL :: InvokeSimd/Spec/tuple.cpp
  SYCL :: InvokeSimd/Spec/tuple_return.cpp
  SYCL :: InvokeSimd/Spec/tuple_vadd.cpp
  SYCL :: KernelFusion/pointer_arg_function.cpp
  SYCL :: LLVMIntrinsicLowering/sub_byte_bitreverse.cpp
  SYCL :: OneapiDeviceSelector/illegal_input.cpp
  SYCL :: OnlineCompiler/online_compiler_OpenCL.cpp
  SYCL :: Regression/build_log.cpp
```

```
[level_zero:gpu][level_zero:0] Intel(R) oneAPI Unified Runtime over Level-Zero, Intel(R) Iris(R) Xe Graphics 12.0.0 [1.6.32224.500000]
```

Testing summary:

```
Total Discovered Tests: 2138
  Unsupported      :  699 (32.69%)
  Passed           : 1421 (66.46%)
  Expectedly Failed:   18 (0.84%)
  
Expectedly Failed Tests (18):
  SYCL :: Basic/buffer/reinterpret.cpp
  SYCL :: InlineAsm/asm_multiple_instructions.cpp
  SYCL :: InvokeSimd/Feature/ImplicitSubgroup/invoke_simd_struct.cpp
  SYCL :: InvokeSimd/Feature/invoke_simd_struct.cpp
  SYCL :: InvokeSimd/Spec/ImplicitSubgroup/tuple.cpp
  SYCL :: InvokeSimd/Spec/ImplicitSubgroup/tuple_return.cpp
  SYCL :: InvokeSimd/Spec/ImplicitSubgroup/tuple_vadd.cpp
  SYCL :: InvokeSimd/Spec/clang_run_error/accessor_argument.cpp
  SYCL :: InvokeSimd/Spec/clang_run_error/reference_argument.cpp
  SYCL :: InvokeSimd/Spec/simd_size/simd32_platform_error.cpp
  SYCL :: InvokeSimd/Spec/tuple.cpp
  SYCL :: InvokeSimd/Spec/tuple_return.cpp
  SYCL :: InvokeSimd/Spec/tuple_vadd.cpp
  SYCL :: KernelFusion/pointer_arg_function.cpp
  SYCL :: LLVMIntrinsicLowering/sub_byte_bitreverse.cpp
  SYCL :: OneapiDeviceSelector/illegal_input.cpp
  SYCL :: OnlineCompiler/online_compiler_L0.cpp
  SYCL :: Regression/build_log.cpp
```

```
[opencl:cpu][opencl:1] Intel(R) OpenCL, 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz OpenCL 3.0 (Build 0) [2024.18.10.0.08_160000]
```

Testing summary:

```
Total Discovered Tests: 2138
  Unsupported      : 1208 (56.50%)
  Passed           :  927 (43.36%)
  Expectedly Failed:    3 (0.14%)
  
Total Discovered Tests: 2138
  Unsupported      : 1208 (56.50%)
  Passed           :  927 (43.36%)
  Expectedly Failed:    3 (0.14%)
```

```
[hip:gpu][hip:0] AMD HIP BACKEND, AMD Radeon RX 6700 XT gfx1031 [HIP 60342.13]
```

Testing summary:

```
Total Discovered Tests: 2138
  Unsupported      : 1324 (61.93%)
  Passed           :  808 (37.79%)
  Expectedly Failed:    6 (0.28%)
  
Expectedly Failed Tests (6):
  SYCL :: Basic/built-ins.cpp
  SYCL :: KernelFusion/pointer_arg_function.cpp
  SYCL :: OneapiDeviceSelector/illegal_input.cpp
  SYCL :: Regression/build_log.cpp
  SYCL :: Sampler/normalized-clampedge-linear-float.cpp
  SYCL :: Sampler/normalized-clampedge-nearest.cpp
```

```
[cuda:gpu][cuda:0] NVIDIA CUDA BACKEND, NVIDIA A10G 8.6 [CUDA 12.1]
```

Testing summary:

```
Total Discovered Tests: 2138
  Unsupported      : 1143 (53.46%)
  Passed           :  988 (46.21%)
  Expectedly Failed:    7 (0.33%)

Expectedly Failed Tests (7):
  SYCL :: KernelFusion/pointer_arg_function.cpp
  SYCL :: OneapiDeviceSelector/illegal_input.cpp
  SYCL :: OptionalKernelFeatures/throw-exception-for-out-of-registers-on-kernel-launch.cpp
  SYCL :: Printf/int.cpp
  SYCL :: Regression/build_log.cpp
  SYCL :: Regression/kernel_bundle_ignore_sycl_external.cpp
  SYCL :: bindless_images/image_get_info.cpp
```

## How to use

This release does not provide a pre-built binaries of our SYCL compiler and simply
marks a known good commit on a corresponding release branch which can be used for
building the compiler and the runtime for your needs. To do so, follow
[Get Started Guide](https://github.com/intel/llvm/blob/sycl-rel-6_0_0/sycl/doc/GetStartedGuide.md)
