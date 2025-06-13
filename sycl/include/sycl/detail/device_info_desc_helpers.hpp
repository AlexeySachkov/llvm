//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once

#include <sycl/aspects.hpp>
#include <sycl/detail/defines_elementary.hpp>
#include <sycl/ext/oneapi/experimental/forward_progress.hpp>
#include <sycl/info/device.hpp>
#include <ur_api.h>

#include <cstdint>
#include <string>
#include <vector>

namespace sycl {
inline namespace _V1 {

#define __SYCL_PARAM_TRAITS_SPEC(Namespace, DescType, Desc, ReturnT, UrCode)   \
  namespace Namespace {                                                        \
  namespace info {                                                             \
  namespace DescType {                                                         \
  struct Desc {                                                                \
    using return_type = ReturnT;                                               \
  };                                                                           \
  } /*DescType*/                                                               \
  } /*info*/                                                                   \
  } /*Namespace*/

#define __SYCL_PARAM_TRAITS_TEMPLATE_SPEC(Namespace, DescType, Desc, ReturnT,  \
                                          UrCode)                              \
  namespace Namespace {                                                        \
  namespace info {                                                             \
  namespace DescType {                                                         \
  template <> struct Desc {                                                    \
    using return_type = ReturnT;                                               \
  };                                                                           \
  } /*namespace DescType */                                                    \
  } /*namespace info */                                                        \
  } /*namespace Namespace */

#include <sycl/info/ext_codeplay_device_traits.def>
#include <sycl/info/ext_intel_device_traits.def>
#include <sycl/info/ext_oneapi_device_traits.def>

#undef __SYCL_PARAM_TRAITS_SPEC
#undef __SYCL_PARAM_TRAITS_TEMPLATE_SPEC

namespace detail {

template <typename T> struct is_device_info_desc : std::false_type {};
// Normally we would just use std::enable_if to limit valid get_info template
// arguments. However, there is a mangling mismatch of
// "std::enable_if<is*_desc::value>::type" between gcc clang (it appears that
// gcc lacks a E terminator for unresolved-qualifier-level sequence). As a
// workaround, we use return_type alias from is_*info_desc that doesn't run into
// the same problem.
// TODO remove once this gcc/clang discrepancy is resolved

#define __SYCL_PARAM_TRAITS_SPEC(DescType, Desc, ReturnT, UrCode)              \
  template <>                                                                  \
  struct is_##DescType##_info_desc<info::DescType::Desc> : std::true_type {    \
    using return_type = info::DescType::Desc::return_type;                     \
  };
#define __SYCL_PARAM_TRAITS_SPEC_SPECIALIZED(DescType, Desc, ReturnT, UrCode)  \
  __SYCL_PARAM_TRAITS_SPEC(DescType, Desc, ReturnT, UrCode)

#include <sycl/info/device_traits.def>

#undef __SYCL_PARAM_TRAITS_SPEC
#undef __SYCL_PARAM_TRAITS_SPEC_SPECIALIZED

#define __SYCL_PARAM_TRAITS_SPEC(Namespace, DescType, Desc, ReturnT, UrCode)   \
  template <>                                                                  \
  struct is_##DescType##_info_desc<Namespace::info::DescType::Desc>            \
      : std::true_type {                                                       \
    using return_type = Namespace::info::DescType::Desc::return_type;          \
  };
#include <sycl/info/ext_codeplay_device_traits.def>
#include <sycl/info/ext_intel_device_traits.def>
#include <sycl/info/ext_oneapi_device_traits.def>
#undef __SYCL_PARAM_TRAITS_SPEC

} // namespace detail
} // namespace _V1
} // namespace sycl
