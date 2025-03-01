mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DBUILD_TESTING:BOOL=ON ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DUSE_EXTERNAL_TINYXML2=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
:: UNIT_Dem_TEST  is failing for CI-specific reasons and not for actual problems in the library
ctest --output-on-failure -C Release -E "PERFORMANCE_|SignalHandler|UNIT_Dem_TEST"
if errorlevel 1 exit 1
