// XFAIL: *
// Today we generate absolute nonsense for this case
//
// RUN: %clang_cc1 -fsycl-is-device -internal-isystem %S/Inputs -triple spir64-unknown-unknown -sycl-std=2020 -fsycl-int-header=%t.h %s
// RUN: FileCheck -input-file=%t.h %s
//
// The purpose of this test is to ensure that forward declarations of free
// function kernels are emitted properly.
// However, this test checks a specific scenario:
// - free function arguments are template template types

namespace ns {

template <typename T>
struct list {};

template <typename T>
struct array {};

} // namespace ns

template<typename T, template <typename> typename Container>
[[__sycl_detail__::add_ir_attributes_function("sycl-nd-range-kernel", 2)]]
void case_a(Container<T> Arg) {}
template void case_a(ns::list<int>);

// CHECK: template<typename T, template <typename> typename Container> void case_a(ns::list<int>);
// What we see: <typename T, > void case_a((anonymous)<T>);
