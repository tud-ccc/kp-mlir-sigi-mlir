add_mlir_dialect_library(ClosureTransforms
    ClosureConversionUtil.cpp

    DEPENDS
        ClosureIR

    LINK_LIBS PUBLIC
        MLIRIR
        MLIRParser
        MLIRSideEffectInterfaces
)
