//==------- info_desc.hpp - SYCL information descriptors -------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once

#include <sycl/detail/defines_elementary.hpp> // for __SYCL2020_DEPRECATED
#include <ur_api.h>

// FIXME: .def files included to this file use all sorts of SYCL objects like
// id, range, traits, etc. We have to include some headers before including .def
// files.
#include <sycl/aspects.hpp>
#include <sycl/detail/type_traits.hpp>
#include <sycl/ext/oneapi/experimental/device_architecture.hpp>
#include <sycl/ext/oneapi/experimental/forward_progress.hpp>
#include <sycl/ext/oneapi/matrix/query-types.hpp>

#include <sycl/range.hpp>

// This is used in trait .def files when there isn't a corresponding backend
// query but we still need a value to instantiate the template.
#define __SYCL_TRAIT_HANDLED_IN_RT 0

namespace sycl {
inline namespace _V1 {

class device;
class platform;
class kernel_id;
enum class memory_scope;
enum class memory_order;

// TODO: stop using OpenCL directly, use UR.
namespace info {
#define __SYCL_PARAM_TRAITS_SPEC(DescType, Desc, ReturnT, UrCode)              \
  struct Desc {                                                                \
    using return_type = ReturnT;                                               \
  };
// A.1 Platform information desctiptors
namespace platform {
// TODO Despite giving this deprecation warning, we're still yet to implement
// info::device::aspects.
struct __SYCL2020_DEPRECATED("deprecated in SYCL 2020, use device::get_info() "
                             "with info::device::aspects instead") extensions;
#include <sycl/info/platform_traits.def>
} // namespace platform

// A.4 Queue information descriptors
namespace queue {
#include <sycl/info/queue_traits.def>
} // namespace queue

// A.5 Kernel information desctiptors
namespace kernel {
#include <sycl/info/kernel_traits.def>
} // namespace kernel

namespace kernel_device_specific {
#include <sycl/info/kernel_device_specific_traits.def>
} // namespace kernel_device_specific

// A.6 Event information desctiptors
enum class event_command_status : int32_t {
  submitted = UR_EVENT_STATUS_SUBMITTED,
  running = UR_EVENT_STATUS_RUNNING,
  complete = UR_EVENT_STATUS_COMPLETE,
  // Since all BE values are positive, it is safe to use a negative value If you
  // add other ext_oneapi values
  ext_oneapi_unknown = -1
};

namespace event {
#include <sycl/info/event_traits.def>
} // namespace event
namespace event_profiling {
#include <sycl/info/event_profiling_traits.def>
} // namespace event_profiling
#undef __SYCL_PARAM_TRAITS_SPEC

// Provide an alias to the return type for each of the info parameters
template <typename T, T param> class param_traits {};

template <typename T, T param> struct compatibility_param_traits {};

#define __SYCL_PARAM_TRAITS_SPEC(param_type, param, ret_type)                  \
  template <> class param_traits<param_type, param_type::param> {              \
  public:                                                                      \
    using return_type = ret_type;                                              \
  };
#undef __SYCL_PARAM_TRAITS_SPEC
} // namespace info

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

#define __SYCL_PARAM_TRAITS_TEMPLATE_PARTIAL_SPEC(Namespace, Desctype, Desc,   \
                                                  ReturnT, UrCode)             \
  namespace Namespace::info {                                                  \
  namespace Desctype {                                                         \
  template <int Dimensions> struct Desc {                                      \
    using return_type = ReturnT<Dimensions>;                                   \
  };                                                                           \
  }                                                                            \
  }

#include <sycl/info/ext_intel_kernel_info_traits.def>
#include <sycl/info/ext_oneapi_kernel_queue_specific_traits.def>

#undef __SYCL_PARAM_TRAITS_SPEC
#undef __SYCL_PARAM_TRAITS_TEMPLATE_SPEC
#undef __SYCL_PARAM_TRAITS_TEMPLATE_PARTIAL_SPEC
} // namespace _V1
} // namespace sycl
