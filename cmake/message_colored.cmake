if(NOT WIN32)
  string(ASCII 27 Esc)
  set(CR "${Esc}[m")   # Color Reset
  set(CB "${Esc}[1m")  # Color Bold
  set(R "${Esc}[31m")  # Color Red
  set(G "${Esc}[32m")  # Color Green
  set(Y "${Esc}[33m")  # Color Yellow
  set(B "${Esc}[34m")  # Color Blue
  set(M "${Esc}[35m")  # Color Magenta
  set(C "${Esc}[36m")  # Color Cyan
  set(White       "${Esc}[37m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldGreen   "${Esc}[1;32m")
  set(BoldYellow  "${Esc}[1;33m")
  set(BoldBlue    "${Esc}[1;34m")
  set(BoldMagenta "${Esc}[1;35m")
  set(BoldCyan    "${Esc}[1;36m")
  set(BoldWhite   "${Esc}[1;37m")
endif()