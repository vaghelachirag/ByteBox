@echo off
REM Build script that disables icon tree-shaking to work around iconsax package issue
REM Usage: build_without_tree_shake.bat [build_type]
REM Example: build_without_tree_shake.bat apk
REM Example: build_without_tree_shake.bat appbundle

set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=apk

echo Building Flutter app with --no-tree-shake-icons flag...
echo Build type: %BUILD_TYPE%

flutter build %BUILD_TYPE% --no-tree-shake-icons

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
) else (
    echo.
    echo Build failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

