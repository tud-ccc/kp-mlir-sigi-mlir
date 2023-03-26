set(LLVM_TARGET_DEFINITIONS ClosurePasses.td)
mlir_tablegen(ClosurePasses.h.inc -gen-pass-decls -name ClosureConversion)
add_public_tablegen_target(ClosureConversionPassIncGen)

add_mlir_doc(ClosurePasses ClosureConversionPasses ./ -gen-pass-doc)

set(LLVM_TARGET_DEFINITIONS SigiPasses.td)
mlir_tablegen(SigiPasses.h.inc -gen-pass-decls -name SigiConversion)
add_public_tablegen_target(SigiConversionPassIncGen)

add_mlir_doc(SigiPasses SigiConversionPasses ./ -gen-pass-doc)
