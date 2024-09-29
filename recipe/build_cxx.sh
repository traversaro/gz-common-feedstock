#!/bin/sh

mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
    CMAKE_ARGS="${CMAKE_ARGS} -DGZ_PROFILER_REMOTERY:BOOL=OFF"
fi

if [ ${target_platform} == "linux-ppc64le" ]; then
  # Disable tests
  GZ_TEST_CMD=-DBUILD_TESTING:BOOL=OFF
  NUM_PARALLEL=-j1
else
  GZ_TEST_CMD=
  NUM_PARALLEL=
fi

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DFREEIMAGE_RUNS:BOOL=ON \
      -DFREEIMAGE_RUNS__TRYRUN_OUTPUT:STRING="" \
      -DFREEIMAGE_COMPILES:BOOL=ON \
      ${GZ_TEST_CMD}

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  # PERFORMANCE_* are performance tests, let's disable them as we can't assume 
  # anything related to the speed of the CI machines
  # SignalHandler disabled due to https://github.com/gazebosim/gz-common/issues/644#issuecomment-2381358169
  ctest --output-on-failure -C Release -E "PERFORMANCE_|SignalHandler"
fi
