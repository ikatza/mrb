
CONFIGURE_FILE ( ${CMAKE_CURRENT_SOURCE_DIR}/local_setup.in
                 ${CMAKE_CURRENT_BINARY_DIR}/local_setup @ONLY )

CONFIGURE_FILE ( ${CMAKE_CURRENT_SOURCE_DIR}/local_mid.in
                 ${CMAKE_CURRENT_BINARY_DIR}/local_mid @ONLY )

INSTALL (FILES CMakeLists.txt.main
	       dbconfig
	       ${CMAKE_CURRENT_BINARY_DIR}/local_setup
	       ${CMAKE_CURRENT_BINARY_DIR}/local_mid
         DESTINATION ${product}/${version}/templates )

add_subdirectory(product)
