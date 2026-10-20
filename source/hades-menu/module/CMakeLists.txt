add_library(HadesMainMenuApiLib SHARED)

include_directories (
   src/.
   ../include
)

file(GLOB_RECURSE MOD_FILES src/*.cpp src/*.h)

target_sources(
    HadesMainMenuApiLib
    PUBLIC
        ${MOD_FILES}
)

target_link_libraries(HadesMainMenuApiLib PRIVATE liblua)
target_precompile_headers(HadesMainMenuApiLib PRIVATE src/pch.h)
