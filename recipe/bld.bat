setlocal EnableDelayedExpansion

mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON ^
    -DBOOST_ROOT=%LIBRARY_PREFIX% ^
    -DBoost_NO_SYSTEM_PATHS=ON ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DBoost_DEBUG=ON ^
    -DUSE_EXTERNAL_TINYXML=ON ^
    -DUSE_INTERNAL_URDF=OFF ^
    -DURDF_FOUND=ON ^
    -DURDF_INCLUDEDIR=%LIBRARY_PREFIX%\include ^
    -DURDF_LIBDIR=%LIBRARY_PREFIX%\lib ^
    "-DURDF_LIBRARIES=urdfdom_sensor;urdfdom_model_state;urdfdom_model;urdfdom_world" ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION"
if errorlevel 1 exit 1

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)
