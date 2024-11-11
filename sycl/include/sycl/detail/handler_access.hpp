//==-------------------------- handler_access.hpp --------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Helper class to provide access to private members of handler, but without the
// need to list everyone who needs that access as a friend.
//
//===----------------------------------------------------------------------===//

#include <sycl/handler.hpp>
#include <sycl/kernel.hpp>

namespace sycl {
inline namespace _V1 {
namespace detail {
class HandlerAccess {
public:
  static void internalProfilingTagImpl(handler &Handler) {
    Handler.internalProfilingTagImpl();
  }

  template <typename RangeT, typename PropertiesT>
  static void parallelForImpl(handler &Handler, RangeT Range, PropertiesT Props,
                              kernel Kernel) {
    Handler.parallel_for_impl(Range, Props, Kernel);
  }
};
} // namespace detail

} // namespace _V1
} // namespace sycl
