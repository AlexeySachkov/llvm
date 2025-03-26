macro(add_compile_option_ext flag target)
  string(MAKE_C_IDENTIFIER flag flag_internal)
  check_c_compiler_flag(flag "C_SUPPORTS_${flag_internal}")
  check_cxx_compiler_flag(flag "CXX_SUPPORTS_${flag_internal}")

  message(CHECK_START "Looking if C and CXX compilers support ${flag}")
  if (C_SUPPORTS_${flag_internal} AND CXX_SUPPORTS_${flag_internal})
    message(CHECK_PASS "both compilers support, it will be used")
    target_compile_options(target PRIVATE ${flag})
  else()
    message(CHECK_FAIL "one of compilers doesn't support it and it won't be used!")
  endif()
endmacro()

macro(add_link_option_ext flag name)
  include(CheckLinkerFlag)
  cmake_parse_arguments(ARG "" "" "" ${ARGN})
  check_linker_flag(CXX "${flag}" "LINKER_SUPPORTS_${name}")
  if(LINKER_SUPPORTS_${name})
    message(STATUS "Building with ${flag}")
    append("${flag}" ${ARG_UNPARSED_ARGUMENTS})
  else()
    message(WARNING "${flag} is not supported.")
  endif()
endmacro()

function(apply_common_extra_security_flags target)
  if (EXTRA_SECURITY_FLAGS STREQUAL "none")
  # No actions.
  elseif (EXTRA_SECURITY_FLAGS STREQUAL "default")
    append_common_extra_security_flags()
  elseif (EXTRA_SECURITY_FLAGS STREQUAL "sanitize")
  add_compile_option_ext("-Wformat" target)
  add_compile_option_ext("-Wformat-security" target)
  add_compile_option_ext("-Werror=format-security" target)
endfunction()

function(append_common_extra_security_flags)
  if( LLVM_ON_UNIX )
    # Fortify Source (strongly recommended):
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
      message(WARNING
        "-D_FORTIFY_SOURCE=2 can only be used with optimization.")
      message(WARNING "-D_FORTIFY_SOURCE=2 is not supported.")
    else()
      # Sanitizers do not work with checked memory functions,
      # such as __memset_chk. We do not build release packages
      # with sanitizers, so just avoid -D_FORTIFY_SOURCE=2
      # under LLVM_USE_SANITIZER.
      if (NOT LLVM_USE_SANITIZER)
        message(STATUS "Building with -D_FORTIFY_SOURCE=2")
        add_definitions(-D_FORTIFY_SOURCE=2)
      else()
        message(WARNING
          "-D_FORTIFY_SOURCE=2 dropped due to LLVM_USE_SANITIZER.")
      endif()
    endif()

    # Format String Defense
    add_compile_option_ext("-Wformat" WFORMAT)
    add_compile_option_ext("-Wformat-security" WFORMATSECURITY)
    add_compile_option_ext("-Werror=format-security" WERRORFORMATSECURITY)

    # Stack Protection
    add_compile_option_ext("-fstack-protector-strong" FSTACKPROTECTORSTRONG)

    # Full Relocation Read Only
    add_link_option_ext("-Wl,-z,relro" ZRELRO
      CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS
      CMAKE_SHARED_LINKER_FLAGS)

    # Immediate Binding (Bindnow)
    add_link_option_ext("-Wl,-z,now" ZNOW
      CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS
      CMAKE_SHARED_LINKER_FLAGS)
  endif()
endfunction()

# if ( EXTRA_SECURITY_FLAGS )
#     if (EXTRA_SECURITY_FLAGS STREQUAL "none")
#     # No actions.
#     elseif (EXTRA_SECURITY_FLAGS STREQUAL "default")
#       append_common_extra_security_flags()
#     elseif (EXTRA_SECURITY_FLAGS STREQUAL "sanitize")
#       append_common_extra_security_flags()
#       if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#         add_compile_option_ext("-fsanitize=cfi" FSANITIZE_CFI)
#         add_link_option_ext("-fsanitize=cfi" FSANITIZE_CFI_LINK
#           CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS
#           CMAKE_SHARED_LINKER_FLAGS)
#         # Recommended option although linking a DSO with SafeStack is not currently supported by compiler.
#         #add_compile_option_ext("-fsanitize=safe-stack" FSANITIZE_SAFESTACK)
#         #add_link_option_ext("-fsanitize=safe-stack" FSANITIZE_SAFESTACK_LINK
#         #  CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS
#         #  CMAKE_SHARED_LINKER_FLAGS)
#       else()
#         add_compile_option_ext("-fcf-protection=full -mcet" FCF_PROTECTION)
#         # need to align compile and link option set, link now is set unconditionally
#         add_link_option_ext("-fcf-protection=full -mcet" FCF_PROTECTION_LINK
#           CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS
#           CMAKE_SHARED_LINKER_FLAGS)
#       endif()
#     else()
#       message(FATAL_ERROR "Unsupported value of EXTRA_SECURITY_FLAGS: ${EXTRA_SECURITY_FLAGS}")
#     endif()
# endif()

