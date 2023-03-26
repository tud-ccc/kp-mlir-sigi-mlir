################################################################################
# check-sigi-mlir
#
# The sigi-mlir regression test project.
################################################################################

project(check-sigi-mlir)

# Configure the testing site configuration.
configure_lit_site_cfg(
        ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
        ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
    MAIN_CONFIG
        ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
)
set(TEST_DEPENDS
    FileCheck count not
    sigi-opt
)

# Create the test suite.
add_lit_testsuite(${PROJECT_NAME}
    "Running the sigi-mlir regression tests"
    ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS
        ${TEST_DEPENDS}
)
add_lit_testsuites(SIGIMLIR
    ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS
        ${TEST_DEPENDS}
)
