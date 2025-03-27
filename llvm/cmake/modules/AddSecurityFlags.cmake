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

macro(check_c_cxx_flag_support flag)
  string(MAKE_C_IDENTIFIER ${flag} flag_internal)
  message(CHECK_START "Looking if C and CXX compilers support ${flag}")
  check_c_compiler_flag(${flag} "C_SUPPORTS_${flag_internal}")
  check_cxx_compiler_flag(${flag} "CXX_SUPPORTS_${flag_internal}")

  if (C_SUPPORTS_${flag_internal} AND CXX_SUPPORTS_${flag_internal})
    message(CHECK_PASS "both compilers support, it will be used")
  else()
    message(CHECK_FAIL "one of compilers doesn't support it and it won't be used!")
  endif()
endmacro()

macro(add_compile_option_ext flag target)
  string(MAKE_C_IDENTIFIER ${flag} flag_internal)

  if (C_SUPPORTS_${flag_internal} AND CXX_SUPPORTS_${flag_internal})
    target_compile_options(${target} PRIVATE ${flag})
  endif()
endmacro()

set(extra_security_flags_level 0)

set(is_gcc FALSE)
set(is_clang FALSE)
set(is_icpx FALSE)
set(is_msvc FALSE)
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(is_gcc TRUE)
endif()
if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(is_clang TRUE)
endif()
if (CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
  set(is_icpx TRUE)
endif()
if (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  set(is_msvc TRUE)
endif()

if (EXTRA_SECURITY_FLAGS)
  if (EXTRA_SECURITY_FLAGS STREQUAL "default")
    set(extra_security_flags_level 1)
  elseif (EXTRA_SECURITY_FLAGS STREQUAL "sanitize")
    set(extra_security_flags_level 2)
  endif()

  if (extra_security_flags_level GREATER 0)
    message(STATUS "Extra security flags are requested to be applied")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
      message(WARNING "Extra security flags are designed to be applied to release builds only, applying them to debug builds can negatively impact debugging capabilities/experience")
    endif()

    # Query compiler flags support once to be able to add them later. To reduce
    # verbosity of logs, flags are only queried if they are expected to be
    # used/supported with/by the corresponding compiler. Therefore, this code
    # should be kept in sync with the apply_common_extra_security_flags
    # function.

    # Do we really need to check support for those flags, or we can assume them
    # to be always supported?

    # Enable  all necessary warnings
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      check_c_cxx_flag_support("-Wall")
      check_c_cxx_flag_support("-Wextra")
      check_c_cxx_flag_support("-Wconversion")
      check_c_cxx_flag_support("-Wimplicit-fallthrough")
    elseif (is_msvc OR (is_icpx AND WIN32))
      check_c_cxx_flag_support("/W4")
    endif()

    # Control flow integrity
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      check_c_cxx_flag_support("-fcf-protection=full")
    elseif (is_icpx AND WIN32)
      check_c_cxx_flag_support("/Qcf-protection:full")
    elseif (is_msvc)
      check_c_cxx_flag_support("/LTCG")
      check_c_cxx_flag_support("/sdl")
      check_c_cxx_flag_support("/guard:cf")
      check_c_cxx_flag_support("/CETCOMPAT")
    endif()

    # Format string defence
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      check_c_cxx_flag_support("-Wformat")
      check_c_cxx_flag_support("-Wformat-security")
      check_c_cxx_flag_support("-Werror=format-security")
    elseif (is_icpx AND WIN32)
      check_c_cxx_flag_support("/Wformat")
      check_c_cxx_flag_support("/Wformat-security")
    elseif (is_msvc)
      check_c_cxx_flag_support("/analyze")
    endif()

    # Inexecutable stack
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      # TODO: link flags -Wl,-z,noexecstack
    endif()

    # Position independent code
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      check_c_cxx_flag_support("-fPIC")
    elseif (is_msvc)
      check_c_cxx_flag_support("/Gy")
    endif()

    # Position independent execution
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      check_c_cxx_flag_support("-fPIE")
      # TODO: -pie link flag
    elseif (is_msvc)
      check_c_cxx_flag_support("/DYNAMICBASE")
      check_c_cxx_flag_support("/NXCOMPAT")
    endif()

    # Stack protection
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      check_c_cxx_flag_support("-fstack-protector-strong")
      check_c_cxx_flag_support("-fstack-clash-protection")
    elseif (is_msvc)
      check_c_cxx_flag_support("/GS")
    endif()
  endif()
endif()

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


function(apply_common_extra_security_flags target)
  # TODO: check if any of MSVC flags are actually link flags

  if (extra_security_flags_level GREATER_EQUAL 1) # default
    # Enable  all necessary warnings
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      add_compile_option_ext("-Wall" ${target})
      add_compile_option_ext("-Wextra" ${target})
      add_compile_option_ext("-Wconversion" ${target})
      add_compile_option_ext("-Wimplicit-fallthrough" ${target})
    elseif (is_msvc OR (is_icpx AND WIN32))
      add_compile_option_ext("/W4" ${target})
    endif()

    # Control flow integrity
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      add_compile_option_ext("-fcf-protection=full" ${target})
    elseif (is_icpx AND WIN32)
      add_compile_option_ext("/Qcf-protection:full" ${target})
    elseif (is_msvc)
      add_compile_option_ext("/LTCG" ${target})
      add_compile_option_ext("/sdl" ${target})
      add_compile_option_ext("/guard:cf" ${target})
      add_compile_option_ext("/CETCOMPAT" ${target})
    endif()

    # Format string defence
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      add_compile_option_ext("-Wformat" ${target})
      add_compile_option_ext("-Wformat-security" ${target})
      add_compile_option_ext("-Werror=format-security" ${target})
    elseif (is_icpx AND WIN32)
      add_compile_option_ext("/Wformat" ${target})
      add_compile_option_ext("/Wformat-security" ${target})
    elseif (is_msvc)
      add_compile_option_ext("/analyze" ${target})
    endif()

    # Inexecutable stack
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      # TODO: link flags -Wl,-z,noexecstack
    endif()

    # Position independent code
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      add_compile_option_ext("-fPIC" ${target})
    elseif (is_msvc)
      add_compile_option_ext("/Gy" ${target})
    endif()

    # Position independent execution
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      add_compile_option_ext("-fPIE" ${target})
      # TODO: -pie link flag
    elseif (is_msvc)
      add_compile_option_ext("/DYNAMICBASE" ${target})
      add_compile_option_ext("/NXCOMPAT" ${target})
    endif()

    # Preprocessor macro
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      target_compile_definitions(${target}
        PRIVATE
          _FORTIFY_SOURCE=3
          _GLIBCXX_ASSERTIONS
      )
    endif()

    # Read-only relocation
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      # TODO: -Wl,-z,relro link flag
    endif()

    # Stack and heap overlap protection
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      # TODO: -Wl,-z,now link flag
      # TODO: -Wl,-z,nodlopen link flag
    endif()

    # Stack protection
    if (is_clang OR is_gcc OR (is_icpx AND NOT WIN32))
      add_compile_option_ext("-fstack-protector-strong" ${target})
      add_compile_option_ext("-fstack-clash-protection" ${target})
    elseif (is_msvc)
      add_compile_option_ext("/GS" ${target})
    endif()
  endif()

  if (extra_security_flags_level GREATER_EQUAL 2) # sanitize
    # TODO: -fsanitize=cfi
  endif()
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

