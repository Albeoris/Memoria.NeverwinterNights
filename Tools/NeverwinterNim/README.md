# neverwinter.nim build tools

This directory contains the minimal neverwinter.nim 2.3.1 utilities and runtime dependencies used by the repository build:

- `nwn_script_comp.exe` and `libnwnscriptcomp.dll` compile NWScript with the official compiler library.
- `nwn_asm.exe` validates generated NCS bytecode.
- `nwn_gff.exe` converts JSON resource descriptions to GFF resources such as UTI files.
- The bundled DLLs, certificate file, and minimal NWN root support these executables on a clean Windows GitHub runner.

Source: <https://github.com/niv/neverwinter.nim>

The complete upstream MIT license is in `LICENSE-neverwinter-nim.txt`.

