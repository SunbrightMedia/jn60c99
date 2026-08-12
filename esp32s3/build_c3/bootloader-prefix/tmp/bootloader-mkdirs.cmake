# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/home/user/esp-idf/components/bootloader/subproject"
  "/home/user/jn60c99/esp32s3/build_c3/bootloader"
  "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix"
  "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix/tmp"
  "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix/src/bootloader-stamp"
  "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix/src"
  "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix/src/bootloader-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix/src/bootloader-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/user/jn60c99/esp32s3/build_c3/bootloader-prefix/src/bootloader-stamp${cfgdir}") # cfgdir has leading slash
endif()
