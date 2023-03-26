add_mlir_conversion_library(MLIRClosureToLLVM
  ClosureToLLVM.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/sigi-mlir/Conversion/ClosureToLLVM

  DEPENDS
  ClosureConversionPassIncGen

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  ClosureIR
  ClosureTransforms
  MLIRDialectUtils
  MLIRFuncDialect
  MLIRTransformUtils
  MLIRReconcileUnrealizedCasts
  )