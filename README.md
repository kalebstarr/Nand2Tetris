# Nand2Tetris in Zig

This is me going through [Nand2Tetris](https://nand2tetris.org/) while trying out Zig for the first time.

## Requirements
- Zig **0.15.1** or newer

## Usage (Project 06)

Navigate to the `06/` directory, then either:

### Run directly:
```bash
zig build run -- <filename>.asm
```

### Or build + run manually:
```bash
zig build
./zig-out/bin/assembler <filename>.asm
```
