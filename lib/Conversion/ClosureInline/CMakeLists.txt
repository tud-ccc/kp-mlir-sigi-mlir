add_mlir_conversion_library(MLIRClosureInline
  ClosureInlinePass.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/sigi-mlir/Conversion/ClosureInline

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