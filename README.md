# Scarlet redwood kernel — KSU-Next (legacy, manual) + SuSFS v2.1.0

A custom kernel for the Xiaomi **redwood / redwoodin** (Redmi Note 11 Pro / SM7325,
`sm7325`) built on Linux 5.4 (non-GKI).

This tree is **based on [Atom-X-Devs/scarlet_xiaomi_sm7325](https://github.com/Atom-X-Devs/scarlet_xiaomi_sm7325)**
(Scarlet kernel, licensed **GPL-2.0**), tag `v6.0`, with a KernelSU-Next + SuSFS root
stack integrated and several backports/fixes applied on top.

## What's changed on top of Scarlet v6.0

- **KernelSU-Next `v3.1.0-legacy-susfs` (manual hooks).** The FLAT-layout, manual/inline
  hooking variant of KernelSU-Next is vendored under `KernelSU-Next/` and wired into the
  tree via the `drivers/kernelsu` symlink (`CONFIG_KSU`).
- **SuSFS v2.1.0 kernel core.** Native SuSFS support (`SUSFS_VERSION "v2.1.0"`) integrated
  into the kernel.
- **UAPI-2 backport.** `KERNEL_SU_UAPI_VERSION 2` backported into the legacy driver so the
  modern KernelSU-Next **v3.3.0** manager / `ksud` handshakes correctly with this
  legacy-hook kernel.
- **SET_SEPOLICY inline backport.** The v3.3.0 inline sepolicy argument format
  (`{u32 cmd; u32 subcmd;}` + inline `[len][bytes][\0]` args) was ported into the legacy
  `kernel/selinux/rules.c` parser, keeping legacy's in-place `get_policydb()`. This fixes
  sepolicy rules from modules (e.g. Zygisk forks) being silently discarded at boot.
- **simple_lmk sysfs hide.** The `module_param()` permissions for `slmk_minfree`,
  `slmk_timeout`, and `slmk_vmpressure` in `drivers/android/simple_lmk.c` are set to `0`
  so the `/sys/module/simple_lmk` fingerprint is not exposed (compiled-in defaults still
  apply; the LMK itself is unchanged and still starts normally).

## Building

Toolchain: a glibc-patched Clang (this tree was built with Neutron Clang). With the
toolchain in place, from the repo root:

```sh
./build.sh
```

`build.sh` drives the defconfig + `make` and packages the resulting `Image` into an
AnyKernel3 flashable zip. Build output lands in `out/` (git-ignored).

## Credits / lineage

- **[Scarlet kernel](https://github.com/Atom-X-Devs/scarlet_xiaomi_sm7325)** by Atom-X-Devs — the base kernel (GPL-2.0).
- **[KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)** — root solution (manual-hook legacy variant).
- **[SuSFS](https://gitlab.com/simonpunk/susfs4ksu)** — kernel-side hiding framework (v2.1.0).

## License

GPL-2.0, inherited from the Linux kernel and the Scarlet base. See `LICENSE` and `COPYING`.
