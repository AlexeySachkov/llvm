//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once

#include <ur_api.h>

#include <cstdint>
#include <string>
#include <vector>

namespace sycl {
inline namespace _V1 {

class device;
class kernel_id;
class platform;
template <int> class range;
template <int> class id;
enum class memory_order;
enum class memory_scope;
enum class aspect;

namespace detail {
// Type for Intel device UUID extension.
// For details about this extension, see
// sycl/doc/extensions/supported/sycl_ext_intel_device_info.md
using uuid_type = std::array<unsigned char, 16>;
} // namespace detail

namespace info {

enum class device_type : uint32_t {
  cpu = UR_DEVICE_TYPE_CPU,
  gpu = UR_DEVICE_TYPE_GPU,
  accelerator = UR_DEVICE_TYPE_FPGA,
  // TODO: evaluate the need for equivalent UR enums for these types
  custom,
  automatic,
  host,
  all = UR_DEVICE_TYPE_ALL
};

enum class fp_config : uint32_t {
  denorm = UR_DEVICE_FP_CAPABILITY_FLAG_DENORM,
  inf_nan = UR_DEVICE_FP_CAPABILITY_FLAG_INF_NAN,
  round_to_nearest = UR_DEVICE_FP_CAPABILITY_FLAG_ROUND_TO_NEAREST,
  round_to_zero = UR_DEVICE_FP_CAPABILITY_FLAG_ROUND_TO_ZERO,
  round_to_inf = UR_DEVICE_FP_CAPABILITY_FLAG_ROUND_TO_INF,
  fma = UR_DEVICE_FP_CAPABILITY_FLAG_FMA,
  correctly_rounded_divide_sqrt,
  soft_float
};

enum class local_mem_type : int { none, local, global };

enum class global_mem_cache_type : int { none, read_only, read_write };

enum class execution_capability : unsigned int {
  exec_kernel,
  exec_native_kernel
};

enum class partition_property : intptr_t {
  no_partition = 0,
  partition_equally = UR_DEVICE_PARTITION_EQUALLY,
  partition_by_counts = UR_DEVICE_PARTITION_BY_COUNTS,
  partition_by_affinity_domain = UR_DEVICE_PARTITION_BY_AFFINITY_DOMAIN,
  ext_intel_partition_by_cslice = UR_DEVICE_PARTITION_BY_CSLICE
};

enum class partition_affinity_domain : intptr_t {
  not_applicable = 0,
  numa = UR_DEVICE_AFFINITY_DOMAIN_FLAG_NUMA,
  L4_cache = UR_DEVICE_AFFINITY_DOMAIN_FLAG_L4_CACHE,
  L3_cache = UR_DEVICE_AFFINITY_DOMAIN_FLAG_L3_CACHE,
  L2_cache = UR_DEVICE_AFFINITY_DOMAIN_FLAG_L2_CACHE,
  L1_cache = UR_DEVICE_AFFINITY_DOMAIN_FLAG_L1_CACHE,
  next_partitionable = UR_DEVICE_AFFINITY_DOMAIN_FLAG_NEXT_PARTITIONABLE
};

namespace device {

#define __SYCL_PARAM_TRAITS_SPEC(DescType, Desc, ReturnT, UrCode)              \
  struct Desc {                                                                \
    using return_type = ReturnT;                                               \
  };

#define __SYCL_PARAM_TRAITS_DEPRECATED(Desc, Message)                          \
  struct __SYCL2020_DEPRECATED(Message) Desc;
#include <sycl/info/device_traits_2020_deprecated.def>
#undef __SYCL_PARAM_TRAITS_DEPRECATED

#define __SYCL_PARAM_TRAITS_DEPRECATED(Desc, Message)                          \
  struct __SYCL_DEPRECATED(Message) Desc;
#include <sycl/info/device_traits_deprecated.def>
#undef __SYCL_PARAM_TRAITS_DEPRECATED

template <int> struct max_work_item_sizes;
#define __SYCL_PARAM_TRAITS_TEMPLATE_SPEC(DescType, Desc, ReturnT, UrCode)     \
  template <> struct Desc {                                                    \
    using return_type = ReturnT;                                               \
  };
#define __SYCL_PARAM_TRAITS_SPEC_SPECIALIZED(DescType, Desc, ReturnT, UrCode)  \
  __SYCL_PARAM_TRAITS_SPEC(DescType, Desc, ReturnT, UrCode)

#include <sycl/info/device_traits.def>
#undef __SYCL_PARAM_TRAITS_SPEC_SPECIALIZED
#undef __SYCL_PARAM_TRAITS_TEMPLATE_SPEC
#undef __SYCL_PARAM_TRAITS_SPEC

} // namespace device
} // namespace info

namespace ext::oneapi::experimental {

enum class architecture : uint64_t;
namespace matrix {
struct combination;
}

namespace info::device {

template <int Dimensions> struct max_work_groups;
template <ext::oneapi::experimental::execution_scope>
struct work_group_progress_capabilities;
template <ext::oneapi::experimental::execution_scope>
struct sub_group_progress_capabilities;
template <ext::oneapi::experimental::execution_scope>
struct work_item_progress_capabilities;

} // namespace info::device
} // namespace ext::oneapi::experimental

namespace ext::intel {
enum class throttle_reason {
  power_cap,
  current_limit,
  thermal_limit,
  psu_alert,
  sw_range,
  hw_range,
  other
};
} // namespace ext::intel
} // namespace _V1
} // namespace sycl
