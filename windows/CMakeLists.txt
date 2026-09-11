# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(music_fse LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "music_fse")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

function(patch_cargokit_symlink_resolver plugin_name)
  set(script_path "${FLUTTER_MANAGED_DIR}/ephemeral/.plugin_symlinks/${plugin_name}/cargokit/cmake/resolve_symlinks.ps1")
  if(NOT EXISTS "${script_path}")
  return()
  endif()

  file(WRITE "${script_path}" [=[function Normalize-LinkTarget {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory)]
    [object] $Target,
    [Parameter(Mandatory)]
    [string] $BasePath
  )

  if ($Target -is [array]) {
    $Target = $Target[0]
  }

  [string] $normalized = [string] $Target
  $normalized = $normalized.Trim()
  $normalized = $normalized -replace '^[\\/]\?\?[\\/]', ''
  $normalized = $normalized -replace '^[\\/]{2}\?[\\/]', ''

  if (-not [System.IO.Path]::IsPathRooted($normalized)) {
    $normalized = Join-Path $BasePath $normalized
  }

  return [System.IO.Path]::GetFullPath($normalized)
}

function Resolve-Symlinks {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string] $Path
  )

  [string] $fullPath = [System.IO.Path]::GetFullPath($Path)
  [string[]] $parts = $fullPath -split '[\\/]'
  [string] $realPath = ''
  [int] $startIndex = 0

  if ($parts.Length -gt 0 -and $parts[0].EndsWith(':')) {
    $realPath = "$($parts[0])\\"
    $startIndex = 1
  }

  for ($index = $startIndex; $index -lt $parts.Length; $index++) {
    [string] $part = $parts[$index]
    if ([string]::IsNullOrWhiteSpace($part)) {
      continue
    }

    if ([string]::IsNullOrEmpty($realPath) -or $realPath -eq '\\') {
      $realPath = "$realPath$part"
    } else {
      $realPath = Join-Path $realPath $part
    }

    $item = Get-Item -LiteralPath $realPath -Force -ErrorAction Stop
    if ($null -ne $item.LinkTarget) {
      $realPath = Normalize-LinkTarget -Target $item.LinkTarget -BasePath (Split-Path -Parent $realPath)
    }
  }

  $realPath
}

$path = Resolve-Symlinks -Path $args[0]
Write-Host $path
]=])
endfunction()

function(ensure_rust_toolchain plugin_name)
  set(plugin_windows_dir "${FLUTTER_MANAGED_DIR}/ephemeral/.plugin_symlinks/${plugin_name}/windows")
  if(NOT EXISTS "${plugin_windows_dir}")
    return()
  endif()

  find_program(CARGO_EXECUTABLE cargo)
  find_program(RUSTC_EXECUTABLE rustc)
  if(NOT CARGO_EXECUTABLE OR NOT RUSTC_EXECUTABLE)
    message(FATAL_ERROR
      "Windows builds require the Rust toolchain because ${plugin_name} is built via CargoKit. "
      "Install Rust with rustup (https://rustup.rs/) so both cargo and rustc are on PATH, then restart your terminal and rerun the build."
    )
  endif()
endfunction()

function(patch_just_audio_windows_disable_auto_smtc)
  set(player_header_path "${FLUTTER_MANAGED_DIR}/ephemeral/.plugin_symlinks/just_audio_windows/windows/player.hpp")
  if(NOT EXISTS "${player_header_path}")
    return()
  endif()

  file(READ "${player_header_path}" player_header_contents)
  string(REPLACE "\r\n" "\n" player_header_contents "${player_header_contents}")

  string(REPLACE
    "    id = idx;\n\n    // Set up channels"
    "    id = idx;\n\n    // Music FSE provides its own Windows SMTC session via smtc_windows.\n    // Disable MediaPlayer's automatic SMTC bridge to avoid duplicate media tiles.\n    mediaPlayer.CommandManager().IsEnabled(false)\;\n\n    // Set up channels"
    patched_player_header_contents
    "${player_header_contents}"
  )
  string(REPLACE "\\;" ";" patched_player_header_contents "${patched_player_header_contents}")

  if("${player_header_contents}" STREQUAL "${patched_player_header_contents}")
    return()
  endif()

  file(WRITE "${player_header_path}" "${patched_player_header_contents}")
endfunction()

patch_cargokit_symlink_resolver(metadata_god)
patch_cargokit_symlink_resolver(smtc_windows)
ensure_rust_toolchain(metadata_god)
ensure_rust_toolchain(smtc_windows)
patch_just_audio_windows_disable_auto_smtc()

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)
