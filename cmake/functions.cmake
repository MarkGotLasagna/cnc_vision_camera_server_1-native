################################################################## FUNCTIONS
### CHECK ENV VARIABLE IS SET OR NOT
# This is for CMAKE only, will not show up in terminal with echo
function(set_env_if_not_set var_name default_value)
    if(NOT DEFINED ENV{${var_name}} OR "$ENV{${var_name}}" STREQUAL "")
        set(ENV{${var_name}} "${default_value}")
        message(STATUS "Set environment variable ${var_name} to: ${default_value}")
    endif()
endfunction(set_env_if_not_set var_name default_value)
##################################################################