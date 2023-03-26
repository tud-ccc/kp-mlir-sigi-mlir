add_mlir_dialect_library(ClosureIR
        ClosureBase.cpp
        ClosureOps.cpp
        ClosureTypes.cpp

    DEPENDS
        ClosureIncGen

    LINK_LIBS PUBLIC
        MLIRIR
        MLIRParser
        MLIRSideEffectInterfaces
)
