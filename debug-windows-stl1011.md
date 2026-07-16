# Windows STL1011 build debugging

Status: [OPEN]
Session: windows-stl1011

## Symptoms

- `flutter build windows --release` fails in `permission_handler_windows_plugin.vcxproj`.
- MSVC reports STL1011 from `experimental/coroutine`.
- The project-level suppression added previously did not resolve the CI build.

## Hypotheses

- H1: The actual CMake target name differs from `permission_handler_windows`.
- H2: The compile definition is applied outside the effective plugin target scope.
- H3: The CI build does not contain the current `windows/CMakeLists.txt` change.
- H4: Plugin-specific `/WX` or generated configuration prevents the definition from taking effect.
- H5: CMake cache or generated files retain the old configuration.

## Evidence

- CI still reports STL1011 in `permission_handler_windows_plugin.vcxproj` after the project-level change.
- Generated CMake defines `PLUGIN_NAME` as `permission_handler_windows_plugin`.
- The previous condition tested `permission_handler_windows`, which is the project name, not the compiled target.
- H1 confirmed: the previous suppression was attached to no target.

## Changes

The Windows CMake target was corrected to `permission_handler_windows_plugin`.
