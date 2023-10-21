add_mlir_dialect_library(SigiTransforms
    SigiConversionUtil.cpp

    DEPENDS
        SigiIR

    LINK_LIBS PUBLIC
        MLIRIR
        MLIRParser
        MLIRSideEffectInterfaces
)
