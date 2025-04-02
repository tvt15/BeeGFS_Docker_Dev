savedcmd_/beegfs_client/build/../source/fault-inject/fault-inject.o := gcc-12 -Wp,-MMD,/beegfs_client/build/../source/fault-inject/.fault-inject.o.d -nostdinc -I./arch/x86/include -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./arch/x86/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/compiler-version.h -include ./include/linux/kconfig.h -I./ubuntu/include -include ./include/linux/compiler_types.h -D__KERNEL__ -fmacro-prefix-map=./= -std=gnu11 -fshort-wchar -funsigned-char -fno-common -fno-PIE -fno-strict-aliasing -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -fcf-protection=none -m64 -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 -mpreferred-stack-boundary=3 -mskip-rax-setup -mtune=generic -mno-red-zone -mcmodel=kernel -Wno-sign-compare -fno-asynchronous-unwind-tables -mindirect-branch=thunk-extern -mindirect-branch-register -mindirect-branch-cs-prefix -mfunction-return=thunk-extern -fno-jump-tables -mharden-sls=all -fpatchable-function-entry=16,16 -fno-delete-null-pointer-checks -O2 -fno-allow-store-data-races -fstack-protector-strong -fno-omit-frame-pointer -fno-optimize-sibling-calls -ftrivial-auto-var-init=zero -fno-stack-clash-protection -fzero-call-used-regs=used-gpr -pg -mrecord-mcount -mfentry -DCC_USING_FENTRY -falign-functions=16 -fno-strict-overflow -fno-stack-check -fconserve-stack -Wall -Wundef -Werror=implicit-function-declaration -Werror=implicit-int -Werror=return-type -Werror=strict-prototypes -Wno-format-security -Wno-trigraphs -Wno-frame-address -Wno-address-of-packed-member -Wmissing-declarations -Wmissing-prototypes -Wframe-larger-than=1024 -Wno-main -Wno-unused-but-set-variable -Wno-unused-const-variable -Wno-dangling-pointer -Wvla -Wno-pointer-sign -Wcast-function-type -Wno-stringop-overflow -Wno-array-bounds -Wno-alloc-size-larger-than -Wimplicit-fallthrough=5 -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init -Wenum-conversion -Wno-unused-but-set-variable -Wno-unused-const-variable -Wno-restrict -Wno-packed-not-aligned -Wno-format-overflow -Wno-format-truncation -Wno-stringop-truncation -Wno-override-init -Wno-missing-field-initializers -Wno-type-limits -Wno-shift-negative-value -Wno-maybe-uninitialized -Wno-sign-compare -g -gdwarf-5 -DKERNEL_HAS_SCHED_SIG_H -DKERNEL_HAS_LINUX_STDARG_H -DKERNEL_HAS_LINUX_FILELOCK_H -DKERNEL_HAS_STATX -DKERNEL_HAS_KREF_READ -DKERNEL_HAS_FILE_DENTRY -DKERNEL_HAS_SUPER_SETUP_BDI_NAME -DKERNEL_HAS_KERNEL_READ -DKERNEL_HAS_SKWQ_HAS_SLEEPER -DKERNEL_HAS_CURRENT_TIME_SPEC64 -DKERNEL_WAKE_UP_SYNC_KEY_HAS_3_ARGUMENTS -DKERNEL_HAS_IOV_ITER_KVEC_NO_TYPE_FLAG_IN_DIRECTION -DKERNEL_HAS_PROC_OPS -DKERNEL_HAS_SOCKPTR_T -DKERNEL_HAS_SOCK_SETSOCKOPT_SOCKPTR_T_PARAM -DKERNEL_HAS_TIME64 -DKERNEL_HAS_KTIME_GET_TS64 -DKERNEL_HAS_KTIME_GET_REAL_TS64 -DKERNEL_HAS_KTIME_GET_COARSE_REAL_TS64 -DKERNEL_HAS_KTIME_GET_TS64 -DKERNEL_HAS_KTIME_GET_REAL_TS64 -DKERNEL_HAS_KTIME_GET_COARSE_REAL_TS64 -DKERNEL_HAS_SETATTR_PREPARE -DKERNEL_HAS_GET_ACL -DKERNEL_HAS_POSIX_GET_ACL_IDMAP -DKERNEL_HAS_GET_INODE_ACL -DKERNEL_HAS_SET_ACL -DKERNEL_HAS_SET_ACL_DENTRY -DKERNEL_HAS_IDMAPPED_MOUNTS -DKERNEL_HAS_XATTR_HANDLERS_INODE_ARG -DKERNEL_HAS_CPU_IN_THREAD_INFO -DKERNEL_HAS_GENERIC_FILLATTR_REQUEST_MASK -DKERNEL_HAS_INODE_GET_SET_CTIME -DKERNEL_HAS_INODE_GET_SET_CTIME_MTIME_ATIME -DBEEGFS_NO_RDMA -DOFED_HAS_SET_SERVICE_TYPE -DOFED_RDMA_REJECT_NEEDS_REASON -DOFED_SPLIT_WR -DOFED_UNSAFE_GLOBAL_RKEY -DOFED_IB_DESTROY_CQ_IS_VOID -DKERNEL_HAS_IHOLD -DKERNEL_HAS_FSYNC_RANGE -DKERNEL_HAS_S_D_OP -DKERNEL_HAS_I_UID_READ -DKERNEL_HAS_ATOMIC_OPEN -DKERNEL_HAS_FILE_INODE -DKERNEL_HAS_CONST_XATTR_CONST_PTR_HANDLER -DKERNEL_HAS_CURRENT_UMASK -DKERNEL_HAS_SHOW_OPTIONS_DENTRY -DKERNEL_HAS_XATTR_HANDLER_PTR_ARG -DKERNEL_HAS_DENTRY_XATTR_HANDLER -DKERNEL_HAS_XATTR_HANDLER_NAME -DKERNEL_HAS_LOCKS_FILELOCK_INODE_WAIT -DKERNEL_HAS_GET_LINK -DKERNEL_HAS_I_MMAP_LOCK -DKERNEL_HAS_I_MMAP_RWSEM -DKERNEL_HAS_I_MMAP_CACHED_RBTREE -DKERNEL_HAS_INODE_LOCK -DKERNEL_HAS_FILE_REMOVE_PRIVS -DKERNEL_HAS_MEMDUP_USER -DKERNEL_HAS_FAULTATTR_DNAME -DKERNEL_HAS_SOCK_CREATE_KERN_NS -DKERNEL_HAS_SOCK_SENDMSG_NOLEN -DKERNEL_HAS_IOV_ITER_INIT_DIR -DKERNEL_HAS_ITER_KVEC -DKERNEL_HAS_IOV_ITER_TYPE -DKERNEL_HAS_ITER_BVEC -DKERNEL_HAS_ITER_IS_IOVEC -DKERNEL_HAS_ITER_IOV_ADDR -DKERNEL_HAS_SET_NLINK -DKERNEL_HAS_DENTRY_PATH_RAW -DKERNEL_HAS_ITER_FILE_SPLICE_WRITE -DKERNEL_HAS_ITERATE_DIR -DKERNEL_HAS_ENCODE_FH_INODE -DKERNEL_HAS_D_DELETE_CONST_ARG -DKERNEL_HAS_POSIX_ACL_XATTR_USERNS_ARG -DKERNEL_HAS_D_MAKE_ROOT -DKERNEL_HAS_GENERIC_WRITE_CHECKS_ITER -DKERNEL_HAS_SB_BDI -DKERNEL_HAS_COPY_FROM_ITER -DKERNEL_HAS_ALLOC_WORKQUEUE -DKERNEL_HAS_WAIT_QUEUE_ENTRY_T -DKERNEL_HAS_64BIT_TIMESTAMPS -DKERNEL_HAS_SB_NODIRATIME -DKERNEL_HAS_RENAME_FLAGS -DKERNEL_HAS_PARENT_INO -DKERNEL_HAS_SLAB_MEM_SPREAD -DKERNEL_HAS_NEW_PDE_DATA -DKERNEL_HAS_FOLIO -DKERNEL_HAS_READ_FOLIO -DKERNEL_WRITEPAGE_HAS_FOLIO -DKERNEL_HAS_IOV_ITER_GET_PAGES2 -I/beegfs_client/build/../source -I/beegfs_client/build/../include -Wextra -Wno-sign-compare -Wno-empty-body -Wno-unused-parameter -Wno-missing-field-initializers -DBEEGFS_MODULE_NAME_STR='"beegfs"' -std=gnu11 -Wno-type-limits -Wuninitialized '-DBEEGFS_VERSION=""'  -fsanitize=bounds-strict -fsanitize=shift -fsanitize=bool -fsanitize=enum  -DMODULE  -DKBUILD_BASENAME='"fault_inject"' -DKBUILD_MODNAME='"beegfs"' -D__KBUILD_MODNAME=kmod_beegfs -c -o /beegfs_client/build/../source/fault-inject/fault-inject.o /beegfs_client/build/../source/fault-inject/fault-inject.c   ; ./tools/objtool/objtool --hacks=jump_label --hacks=noinstr --hacks=skylake --retpoline --rethunk --sls --stackval --static-call --uaccess --prefix=16   --module /beegfs_client/build/../source/fault-inject/fault-inject.o

source_/beegfs_client/build/../source/fault-inject/fault-inject.o := /beegfs_client/build/../source/fault-inject/fault-inject.c

deps_/beegfs_client/build/../source/fault-inject/fault-inject.o := \
    $(wildcard include/config/FAULT_INJECTION) \
  include/linux/compiler-version.h \
    $(wildcard include/config/CC_VERSION_TEXT) \
  include/linux/kconfig.h \
    $(wildcard include/config/CPU_BIG_ENDIAN) \
    $(wildcard include/config/BOOGER) \
    $(wildcard include/config/FOO) \
  include/linux/compiler_types.h \
    $(wildcard include/config/DEBUG_INFO_BTF) \
    $(wildcard include/config/PAHOLE_HAS_BTF_TAG) \
    $(wildcard include/config/FUNCTION_ALIGNMENT) \
    $(wildcard include/config/CC_IS_GCC) \
    $(wildcard include/config/X86_64) \
    $(wildcard include/config/ARM64) \
    $(wildcard include/config/HAVE_ARCH_COMPILER_H) \
    $(wildcard include/config/CC_HAS_ASM_INLINE) \
  include/linux/compiler_attributes.h \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/RETPOLINE) \
    $(wildcard include/config/GCC_ASM_GOTO_OUTPUT_WORKAROUND) \
    $(wildcard include/config/ARCH_USE_BUILTIN_BSWAP) \
    $(wildcard include/config/SHADOW_CALL_STACK) \
    $(wildcard include/config/KCOV) \
  /beegfs_client/build/../source/fault-inject/fault-inject.h \
    $(wildcard include/config/DEBUG_FS) \
    $(wildcard include/config/FAULT_INJECTION_DEBUG_FS) \
  include/linux/types.h \
    $(wildcard include/config/HAVE_UID16) \
    $(wildcard include/config/UID16) \
    $(wildcard include/config/ARCH_DMA_ADDR_T_64BIT) \
    $(wildcard include/config/PHYS_ADDR_T_64BIT) \
    $(wildcard include/config/64BIT) \
    $(wildcard include/config/ARCH_32BIT_USTAT_F_TINODE) \
  include/uapi/linux/types.h \
  arch/x86/include/generated/uapi/asm/types.h \
  include/uapi/asm-generic/types.h \
  include/asm-generic/int-ll64.h \
  include/uapi/asm-generic/int-ll64.h \
  arch/x86/include/uapi/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/uapi/asm-generic/bitsperlong.h \
  include/uapi/linux/posix_types.h \
  include/linux/stddef.h \
  include/uapi/linux/stddef.h \
  arch/x86/include/asm/posix_types.h \
    $(wildcard include/config/X86_32) \
  arch/x86/include/uapi/asm/posix_types_64.h \
  include/uapi/asm-generic/posix_types.h \
  include/generated/uapi/linux/version.h \

/beegfs_client/build/../source/fault-inject/fault-inject.o: $(deps_/beegfs_client/build/../source/fault-inject/fault-inject.o)

$(deps_/beegfs_client/build/../source/fault-inject/fault-inject.o):

/beegfs_client/build/../source/fault-inject/fault-inject.o: $(wildcard ./tools/objtool/objtool)
