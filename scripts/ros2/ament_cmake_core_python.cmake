if(NOT TARGET Python3::Interpreter)
  # Remove the CMake version requirement but keep the intent
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.20)
    cmake_policy(SET CMP0094 NEW)
    set(Python3_FIND_UNVERSIONED_NAMES FIRST)
  endif()

  # Add explicit hints for Python before finding it
  if(DEFINED ENV{PYTHON_EXECUTABLE})
    set(Python3_EXECUTABLE $ENV{PYTHON_EXECUTABLE})
  endif()

  # Fallback behavior for older CMake versions
  if(CMAKE_VERSION VERSION_LESS 3.20)
    # First try finding Python using any hints we have
    find_package(Python3 QUIET COMPONENTS Interpreter)

    if(NOT Python3_FOUND)
      # If that fails, try finding the system Python3
      find_program(PYTHON3_EXECUTABLE python3)
      if(PYTHON3_EXECUTABLE)
        set(Python3_EXECUTABLE ${PYTHON3_EXECUTABLE})
        find_package(Python3 REQUIRED COMPONENTS Interpreter)
      else()
        # Last resort - try any Python3
        find_package(Python3 REQUIRED COMPONENTS Interpreter)
      endif()
    endif()
  else()
    find_package(Python3 REQUIRED COMPONENTS Interpreter)
  endif()
endif()
