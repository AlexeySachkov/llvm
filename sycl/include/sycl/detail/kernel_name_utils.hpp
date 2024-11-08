//==----------------------- kernel_name_utils.hpp --------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once

namespace sycl {
inline namespace _V1 {

namespace detail {
/// This class is the default KernelName template parameter type for kernel
/// invocation APIs such as single_task.
class auto_name {};

/// Helper struct to get a kernel name type based on given \c Name and \c Type
/// types: if \c Name is undefined (is a \c auto_name) then \c Type becomes
/// the \c Name.
template <typename Name, typename Type> struct get_kernel_name_t {
  using name = Name;
};

/// Specialization for the case when \c Name is undefined.
/// This is only legal with our compiler with the unnamed lambda extension or if
/// the kernel is a functor object. For the case where \c Type is a lambda
/// function and unnamed lambdas are disabled, the compiler will issue a
/// diagnostic.
template <typename Type> struct get_kernel_name_t<detail::auto_name, Type> {
  using name = Type;
};

} // namespace detail
} // namespace _V1
} // namespace sycl
