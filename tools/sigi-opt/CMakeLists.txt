################################################################################
# sigi-opt
#
# The sigi-mlir optimizer driver.
################################################################################

project(sigi-opt)

add_executable(${PROJECT_NAME}
    sigi-opt.cpp
)

# Link all standard MLIR dialect and conversion libs.
get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
get_property(extension_libs GLOBAL PROPERTY MLIR_EXTENSION_LIBS)
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        MLIROptLib
        ${dialect_libs}
        ${conversion_libs}
        ${extension_libs}
        LLVMSupport
        MLIRFuncAllExtensions
)
