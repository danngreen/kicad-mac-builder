include(ExternalProject)

ExternalProject_Add(
        kicad
        PREFIX  kicad
        DEPENDS python wxpython wxwidgets six ngspice
        GIT_REPOSITORY ${KICAD_URL}
        GIT_TAG ${KICAD_TAG}
        UPDATE_COMMAND      ""
        PATCH_COMMAND       ${BIN_DIR}/git-multipatch.sh ${CMAKE_SOURCE_DIR}/patches/kicad/*.patch
        CMAKE_ARGS  ${KICAD_CMAKE_ARGS}
)

ExternalProject_Add_Step(
        kicad
        install-docs-to-app
        COMMENT "Installing docs into KiCad.app"
        DEPENDEES install
        COMMAND mkdir -p ${KICAD_INSTALL_DIR}/kicad.app/Contents/SharedSupport/help/
        COMMAND cp -r ${CMAKE_BINARY_DIR}/docs/kicad-doc-HEAD/share/doc/kicad/help/en ${KICAD_INSTALL_DIR}/kicad.app/Contents/SharedSupport/help/
        COMMAND find ${KICAD_INSTALL_DIR}/kicad.app/Contents/SharedSupport/help -name "*.epub" -type f -delete
        COMMAND find ${KICAD_INSTALL_DIR}/kicad.app/Contents/SharedSupport/help -name "*.pdf" -type f -delete
)

ExternalProject_Add_Step(
        kicad
        verify-app
        COMMENT "Checking that all loader dependencies are system-provided or relative"
        DEPENDEES install
        COMMAND ${BIN_DIR}/verify-app.sh ${KICAD_INSTALL_DIR}/kicad.app
)

ExternalProject_Add_Step(
        kicad
        verify-cli-python
        COMMENT "Checking bin/python and bin/pythonw"
        DEPENDEES install
        COMMAND ${BIN_DIR}/verify-cli-python.sh ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/pythonw
        COMMAND ${BIN_DIR}/verify-cli-python.sh ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/Python.framework/Versions/2.7/bin/pythonw
        COMMAND ${BIN_DIR}/verify-cli-python.sh ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python
        COMMAND ${BIN_DIR}/verify-cli-python.sh ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/Python.framework/Versions/2.7/bin/python
)

ExternalProject_Add_Step(
        kicad
        remove-pyc-and-pyo
        COMMENT "Removing pyc and pyo files"
        DEPENDEES verify-cli-python install-six
        DEPENDS kicad
        COMMAND find ${KICAD_INSTALL_DIR}/kicad.app/ -type f -name \*.pyc -o -name \*.pyo -delete
)

ExternalProject_Add_Step(
        kicad
        install-six
        COMMENT "Installing six into PYTHONPATH for easier debugging"
        DEPENDEES install
        COMMAND cp ${six_DIR}/six.py ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/python/site-packages/
)

ExternalProject_Add_Step(
        kicad
        fixup-pcbnew-so
        COMMENT "Fixing loader dependencies so _pcbnew.so works both internal and external to KiCad."
        DEPENDEES install
        COMMAND ${BIN_DIR}/fixup-pcbnew-so.sh  ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/
)

ExternalProject_Add_Step(
        kicad
        verify-pcbnew-so
        COMMENT "Checking the importing of pcbnew"
        DEPENDEES fixup-pcbnew-so
        WORKING_DIRECTORY ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/python/site-packages/
        COMMAND ${KICAD_INSTALL_DIR}/kicad.app/Contents/Frameworks/Python.framework/Versions/Current/bin/python -m pcbnew
)
