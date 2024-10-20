# Build recipes for this project.
#

# Load environment vars from .env file
# Write LLVM_BUILD_DIR="path" into that file or set this env var in your shell.
set dotenv-load := true

llvm_prefix := env_var("LLVM_BUILD_DIR")
build_type := env_var_or_default("LLVM_BUILD_TYPE", "RelWithDebInfo")
build_dir := "build"

# execute cmake -- this is only needed on the first build
cmake:
    cmake -S . -B {{build_dir}} \
        -G Ninja \
        -DCMAKE_BUILD_TYPE={{build_type}} \
        -DLLVM_DIR={{llvm_prefix}}/lib/cmake/llvm \
        -DMLIR_DIR={{llvm_prefix}}/lib/cmake/mlir \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_LINKER="/bin/ld.lld"

# execute a specific ninja target
doNinja *ARGS:
    ninja -C{{build_dir}} {{ARGS}}


# run build --first build needs cmake though
build: doNinja

alias b := build 

# run tests
test: (doNinja "check-sigi-mlir")

sigi-opt *ARGS:
    {{build_dir}}/bin/sigi-opt {{ARGS}}


sigi-opt-expr EXPR *ARGS:
    just -f ../sigi-frontend/justfile exprToMlir '{{EXPR}}' | \
        {{build_dir}}/bin/sigi-opt {{ARGS}}

sigi-opt-help: (sigi-opt "--help")

# Start a gdb session on sigi-opt.
debug-sigi-opt *ARGS:
    gdb --args {{build_dir}}/bin/sigi-opt {{ARGS}}

# Invoke he LLVM IR compiler.
llc *ARGS: 
    {{llvm_prefix}}/bin/llc {{ARGS}}


# Lowers Sigi all the way to LLVM IR. Temporary files are left there.
llvmDialectIntoExecutable FILE:
    #!/bin/bash
    FILEBASE={{FILE}}
    FILEBASE=${FILEBASE%.*}
    FILEBASE=${FILEBASE%.llvm}
    {{llvm_prefix}}/bin/mlir-translate -mlir-to-llvmir {{FILE}} > ${FILEBASE}.ll
    # creates {{FILE}}.s
    {{llvm_prefix}}/bin/llc -O0 ${FILEBASE}.ll
    clang -fuse-ld=lld -L{{build_dir}}/lib -lSigiRuntime ${FILEBASE}.s -g -o ${FILEBASE}.exe -no-pie

# Lowers Sigi all the way to LLVM IR. Temporary files are left there.
sigiToLlvmIr FILE:
    #!/bin/bash
    FILEBASE={{FILE}}
    FILEBASE=${FILEBASE%.*}
    {{build_dir}}/bin/sigi-opt --closure-inline --inline --sigi-insert-drop-checks --convert-arith-to-llvm --convert-scf-to-cf --convert-sigi-to-llvm -cse --llvm-legalize-for-export --mlir-print-ir-after-failure --mlir-print-stacktrace-on-diagnostic {{FILE}} > $FILEBASE.llvm.mlir
    just llvmDialectIntoExecutable $FILEBASE.llvm.mlir

# Lowers closure all the way to LLVM IR. Temporary files are left there.
closureToLlvmIr FILE:
    #!/bin/bash
    FILEBASE={{FILE}}
    FILEBASE=${FILEBASE%.*}
    {{build_dir}}/bin/sigi-opt --convert-closure-to-llvm --convert-arith-to-llvm -cse --llvm-legalize-for-export --mlir-print-ir-after-failure --mlir-print-stacktrace-on-diagnostic {{FILE}} | tee $FILEBASE.llvm.mlir
    just llvmDialectIntoExecutable $FILEBASE.llvm.mlir

closureToLlvmIrOpt FILE:
    {{build_dir}}/bin/sigi-opt --convert-closure-to-llvm --convert-arith-to-llvm -cse --llvm-legalize-for-export --mlir-print-ir-after-failure --mlir-print-stacktrace-on-diagnostic {{FILE}} | tee {{FILE}}.llvm.mlir
    {{llvm_prefix}}/bin/mlir-translate -mlir-to-llvmir {{FILE}}.llvm.mlir | tee {{FILE}}.ll
    {{llvm_prefix}}/bin/opt -O3 -S {{FILE}}.ll | tee {{FILE}}.opt.ll
    # creates {{FILE}}.s
    {{llvm_prefix}}/bin/llc -O0 {{FILE}}.opt.ll
    clang -fuse-ld=lld {{FILE}}.s -g -o {{FILE}}.exe -no-pie
    

addNewDialect DIALECT_NAME DIALECT_NS:
    just --justfile ./dialectTemplate/justfile applyTemplate {{DIALECT_NAME}} {{DIALECT_NS}} "sigi-mlir" {{justfile_directory()}}

compileRuntime: (doNinja "SigiRuntime")
runRuntimeTest: compileRuntime
    clang sandbox/runtimeTest.c -g -o sandbox/runtimeTest
    ./sandbox/runtimeTest
