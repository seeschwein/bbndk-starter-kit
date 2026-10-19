if(NOT DEFINED ENV{QNX_HOST})
  message(FATAL_ERROR "QNX_HOST is not set")
endif()

if(NOT DEFINED ENV{QNX_TARGET})
  message(FATAL_ERROR "QNX_TARGET is not set")
endif()

set(BB10_QT_BIN "$ENV{QNX_HOST}/usr/bin")
find_program(BB10_MOC moc HINTS "${BB10_QT_BIN}" REQUIRED)
find_program(BB10_RCC rcc HINTS "${BB10_QT_BIN}" REQUIRED)
find_program(BB10_UIC uic HINTS "${BB10_QT_BIN}" REQUIRED)

function(bb10_wrap_cpp out_var)
  set(outputs)
  foreach(header IN LISTS ARGN)
    get_filename_component(name "${header}" NAME_WE)
    set(output "${CMAKE_CURRENT_BINARY_DIR}/moc_${name}.cpp")
    add_custom_command(
      OUTPUT "${output}"
      COMMAND "${BB10_MOC}" -o "${output}" "${CMAKE_CURRENT_SOURCE_DIR}/${header}"
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${header}"
      VERBATIM
    )
    list(APPEND outputs "${output}")
  endforeach()
  set(${out_var} "${outputs}" PARENT_SCOPE)
endfunction()

function(bb10_add_resources out_var)
  set(outputs)
  foreach(qrc IN LISTS ARGN)
    get_filename_component(name "${qrc}" NAME_WE)
    set(output "${CMAKE_CURRENT_BINARY_DIR}/qrc_${name}.cpp")
    add_custom_command(
      OUTPUT "${output}"
      COMMAND "${BB10_RCC}" -name "${name}" -o "${output}" "${CMAKE_CURRENT_SOURCE_DIR}/${qrc}"
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${qrc}"
      VERBATIM
    )
    list(APPEND outputs "${output}")
  endforeach()
  set(${out_var} "${outputs}" PARENT_SCOPE)
endfunction()
