//==----------- kernel_arg_mask.hpp - SYCL KernelArgMask -------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once
#include <detail/device_binary_image.hpp>
#include <vector>

namespace sycl {
inline namespace _V1 {
namespace detail {

struct KernelArgMask {
  std::vector<bool> Mask;
  std::vector<kernel_param_desc_t> Args;
};

inline KernelArgMask createKernelArgMask(const ByteArray &MaskBytes, const ByteArray &ArgsBytes) {
  const int NBytesForSize = 8;
  const int NBitsInElement = 8;
  std::uint64_t SizeInBits = 0;

  KernelArgMask Result;
  for (int I = 0; I < NBytesForSize; ++I)
    SizeInBits |= static_cast<std::uint64_t>(MaskBytes[I]) << I * NBitsInElement;

  Result.Mask.reserve(SizeInBits);
  for (std::uint64_t I = 0; I < SizeInBits; ++I) {
    std::uint8_t Byte = MaskBytes[NBytesForSize + (I / NBitsInElement)];
    Result.push_back(Byte & (1 << (I % NBitsInElement)));
  }

  for (int I = 0; I < NBytesForSize; ++I)
    SizeInBits |= static_cast<std::uint64_t>(ArgsBytes[I]) << I * NBitsInElement;
  // We have a set of uint32_t triplets where every triplet describes a single
  // argument
  const NumArgs = SizeInBits / /* bits in byte */ 8 / sizeof(uint32_t) / 3;
  Result.Args.reserve(NumArgs);

  for (int I = 0; i < NumArgs; ++I) {
    auto Triplet = ArgsBytes.
  }

  


  return Result;
}
} // namespace detail
} // namespace _V1
} // namespace sycl
