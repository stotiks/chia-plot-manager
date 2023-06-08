cmake_minimum_required(VERSION 3.11)

if(NOT PLOT_MANAGER_VERSION MATCHES "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
	string(TIMESTAMP BUILD_TIMESTAMP "%Y%m%d")
	set(PLOT_MANAGER_VERSION "v0.0.0.${BUILD_TIMESTAMP}")
endif()

message(STATUS "PLOT_MANAGER_VERSION=${PLOT_MANAGER_VERSION}")

string(REGEX REPLACE "^v([0-9]+).*$" "\\1" PLOT_MANAGER_VERSION_MAJOR "${PLOT_MANAGER_VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.([0-9]+).*$" "\\1" PLOT_MANAGER_VERSION_MINOR  "${PLOT_MANAGER_VERSION}")
string(REGEX REPLACE "^v[0-9]+\\.[0-9]+\\.([0-9]+.*)$" "\\1" PLOT_MANAGER_VERSION_PATCH "${PLOT_MANAGER_VERSION}")

set(PLOT_MANAGER_VERSION_STRING "${PLOT_MANAGER_VERSION_MAJOR}.${PLOT_MANAGER_VERSION_MINOR}.${PLOT_MANAGER_VERSION_PATCH}")

set(CPACK_PACKAGE_VERSION ${PLOT_MANAGER_VERSION_STRING})
set(CPACK_PACKAGE_VERSION_MAJOR ${PLOT_MANAGER_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PLOT_MANAGER_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PLOT_MANAGER_VERSION_PATCH})

add_custom_target(plot_manager ALL)
set(PLOT_MANAGER_GIT_TAG "origin/main")
message(STATUS "Plot Manager will be built from: ${PLOT_MANAGER_GIT_TAG}")
include(FetchContent)
FetchContent_Declare(
	plot_manager
	GIT_REPOSITORY https://github.com/stotiks/mmx-node-gui.git
	GIT_TAG ${PLOT_MANAGER_GIT_TAG}
)
FetchContent_MakeAvailable(plot_manager)
add_custom_command(TARGET plot_manager POST_BUILD
        COMMAND ${CMAKE_MAKE_PROGRAM} PlotManager/PlotManager.csproj -restore -m
			/p:Configuration=Release
			/p:PlatformTarget=x64
			/p:OutputPath=${plot_manager_SOURCE_DIR}/bin/Release
			/p:Version=${PLOT_MANAGER_VERSION_STRING}
			/p:FileVersion=${PLOT_MANAGER_VERSION_STRING}
		WORKING_DIRECTORY ${plot_manager_SOURCE_DIR}
)
set(plot_manager_RELEASE_DIR ${plot_manager_SOURCE_DIR}/bin/CPack_PlotManager_Release)
install(DIRECTORY ${plot_manager_RELEASE_DIR}/ DESTINATION ./ COMPONENT gui)


set(GIGAHORSE_GIT_TAG "origin/master")
FetchContent_Declare(
    chia_gigahorse
    GIT_REPOSITORY https://github.com/madMAx43v3r/chia-gigahorse.git
    GIT_TAG ${GIGAHORSE_GIT_TAG}
)
FetchContent_MakeAvailable(chia_gigahorse)

set (GH_DESTINATION ./gigahorse/)

set(GH_CPU_PLOTTER_PATH ${chia_gigahorse_SOURCE_DIR}/cpu-plotter/windows)
install(DIRECTORY ${GH_CPU_PLOTTER_PATH}/ DESTINATION ${GH_DESTINATION} COMPONENT plotters)

set(GH_CUDA_PLOTTER_PATH ${chia_gigahorse_SOURCE_DIR}/cuda-plotter/windows)
install(DIRECTORY ${GH_CUDA_PLOTTER_PATH}/ DESTINATION ${GH_DESTINATION} COMPONENT plotters)

set(GH_PLOT_SINK_PATH ${chia_gigahorse_SOURCE_DIR}/plot-sink/windows)
install(DIRECTORY ${GH_PLOT_SINK_PATH}/ DESTINATION ${GH_DESTINATION} COMPONENT tools)

set(GH_CHIAPOS_PATH ${chia_gigahorse_SOURCE_DIR}/chiapos/windows)
install(DIRECTORY ${GH_CHIAPOS_PATH}/ DESTINATION ${GH_DESTINATION} COMPONENT tools)

include(FetchContent)
FetchContent_Declare(plotter_k32
URL https://github.com/MMX-World/mmx-plotter/releases/download/1.1.8/chia_plot-1.1.8.exe
URL_HASH SHA256=EF00C99423CB9980CA0DC59CCE076E12BFE4DBA1ACC99E17FA9CFD163604FF77
DOWNLOAD_NO_EXTRACT true
)
FetchContent_MakeAvailable(plotter_k32)
set (MMX_PLOTTER_K32_PATH ${plotter_k32_SOURCE_DIR}/chia_plot-1.1.8.exe)

FetchContent_Declare(plotter_k34
URL https://github.com/MMX-World/mmx-plotter/releases/download/1.1.8/chia_plot_k34-1.1.8.exe
URL_HASH SHA256=3329661BCE509A08638E99352A9607C3ADEAB11DD4B462895FCBEFDC4F22231F
DOWNLOAD_NO_EXTRACT true
)
FetchContent_MakeAvailable(plotter_k34)
set (MMX_PLOTTER_K34_PATH ${plotter_k34_SOURCE_DIR}/chia_plot_k34-1.1.8.exe)

install(FILES ${MMX_PLOTTER_K32_PATH} DESTINATION ./ RENAME chia_plot.exe COMPONENT plotters)
install(FILES ${MMX_PLOTTER_K34_PATH} DESTINATION ./ RENAME chia_plot_k34.exe COMPONENT plotters)

set(CPACK_PACKAGE_NAME "Plot Manager")
set(CPACK_PACKAGE_VENDOR "madMAx43v3r")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Plot Manager for madMAx43v3r plotters")
set(CPACK_RESOURCE_FILE_LICENSE ${PROJECT_SOURCE_DIR}/LICENSE)
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/madMAx43v3r/")


set(MAIN_EXE "PlotManager.exe")
set(MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/icon.ico")

set(CPACK_NSIS_MUI_ICON ${MUI_ICON})
set(CPACK_NSIS_INSTALLED_ICON_NAME ${MAIN_EXE})

set(CPACK_NSIS_PACKAGE_NAME ${CPACK_PACKAGE_NAME})

set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})

get_cmake_property(CPACK_COMPONENTS_ALL COMPONENTS)
list(REMOVE_ITEM CPACK_COMPONENTS_ALL "Unspecified")

set(CPACK_NSIS_MENU_LINKS
	${MAIN_EXE} ${CPACK_PACKAGE_NAME}
	PlotSincGui.exe "Plot Sinc"
	ReComputeServerGui.exe "Recompute Server"
)

set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)


include(CPack)

cpack_add_component(gui
	DISPLAY_NAME "GUI"
	REQUIRED)

cpack_add_component(plotters
	DISPLAY_NAME "Plotters"
	REQUIRED)

cpack_add_component(tools
	DISPLAY_NAME "Tools"
	REQUIRED)
