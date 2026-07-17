#!/usr/bin/env bash
#
# Scarlet kernel build — one-command reproducible build.
# KernelSU-Next (legacy, manual-hook mode) + Scarlet v6.0.
#
# Usage:
#   ./build.sh            # regenerate config + build Image
#   ./build.sh config     # only regenerate the merged .config
#
set -euo pipefail

KERNEL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$KERNEL_DIR"

# --- Toolchain (Neutron Clang; LLVM=1 supplies as/ld/nm/objcopy/... ) ---
export PATH="$HOME/toolchains/neutron-clang/bin:$PATH"

# CROSS_COMPILE here is only the target-triple prefix that clang turns into
# --target=; ld.lld and the integrated assembler come from LLVM=1. The Android
# GCC prefixes named in build.config.common are not used in an LLVM=1 build.
MAKE_ARGS=(
	ARCH=arm64
	O=out
	LLVM=1
	LLVM_IAS=1
	CROSS_COMPILE=aarch64-linux-gnu-
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
	CLANG_TRIPLE=aarch64-linux-gnu-
)

DEFCONFIG="vendor/xiaomi-qgki_defconfig"
FRAGMENT="arch/arm64/configs/vendor/redwood.config"

regen_config() {
	echo ">> Base defconfig: $DEFCONFIG"
	make -s "${MAKE_ARGS[@]}" "$DEFCONFIG"
	echo ">> Merging fragment: $FRAGMENT"
	ARCH=arm64 scripts/kconfig/merge_config.sh -m -O out out/.config "$FRAGMENT"
	echo ">> Resolving (olddefconfig)"
	make -s "${MAKE_ARGS[@]}" olddefconfig
}

mkdir -p out
regen_config

if [[ "${1:-}" == "config" ]]; then
	echo ">> Config-only run complete: out/.config"
	exit 0
fi

echo ">> Building Image with -j$(nproc)"
make -j"$(nproc)" "${MAKE_ARGS[@]}" Image

echo ">> Done. Image: out/arch/arm64/boot/Image"
