add_mlir_dialect_library(SigiTransforms
    InsertDropChecksPass.cpp

    DEPENDS
        SigiIR
        ClosureIR

    LINK_LIBS PUBLIC
        MLIRIR
        MLIRParser
        MLIRSideEffectInterfaces
)
