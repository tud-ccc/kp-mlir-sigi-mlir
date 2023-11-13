add_mlir_conversion_library(MLIRSigiToLLVM
  SigiToLLVM.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/sigi-mlir/Conversion/SigiToLLVM
  ${MLIR_MAIN_INCLUDE_DIR}/sigi-mlir/Conversion/ClosureToLLVM

  DEPENDS
  SigiConversionPassIncGen

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  ClosureIR
  SigiIR
  MLIRDialectUtils
  MLIRFuncDialect
  MLIRTransformUtils
  MLIRReconcileUnrealizedCasts
  MLIRClosureToLLVM
  MLIRControlFlowToLLVM
)