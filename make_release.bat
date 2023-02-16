@ECHO OFF
TITLE Plot Manager Make Release Script

IF "%CMAKE_BUILD_PRESET%"=="" (
	SET CMAKE_BUILD_PRESET=windows-release
)

cmake --preset %CMAKE_BUILD_PRESET% && ^
cmake --build --preset %CMAKE_BUILD_PRESET% && ^
cpack -C Release --config ./build/%CMAKE_BUILD_PRESET%/CPackConfig.cmake -B ./build/%CMAKE_BUILD_PRESET%/!package