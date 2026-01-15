/* cmkconf.cmd: a configure script for cmake */
parse arg sBuildDir sArgs

sOpts =,
    '-DCMAKE_INSTALL_PREFIX=/@unixroot/usr/local',
    '-Dosal=cpp11',
    '-Denable-libinstpatch=0',
    '-G Ninja'

exit config( sBuildDir, sOpts, sArgs )

/**
 * Configure a build dir
 */
config: procedure
    parse arg sBuildDir, sOpts, sArgs

    /* Check parameters */
    if left( sBuildDir, 1 ) == '-' then
    do
        sArgs = strip( sBuildDir sArgs )
        sBuildDir = ''
    end
    sArgs = strip( sOpts sArgs )

    /* Check a build dir */
    if issrcdir( sBuildDir ) then
    do
        if sBuildDir \== '' then
        do
            say sBuildDir 'is a source directory!'

            return 1
        end

        /* default build dir */
        sBuildDir = 'build'
    end

    /* Find a top source dir */
    sCurDir = directory()
    sSrcDir = sCurDir
    do while \ issrcdir( sSrcDir )
        if length( sSrcDir ) < 4 then
        do
            /* Reached to a root directory */

            say 'Could not find a source directory!'

            /* Restore CWD */
            call directory sCurDir

            return 1
        end

        sSrcDir = directory( sSrcDir || '\..')
    end

    do while issrcdir( sSrcDir )
        sTopSrcDir = sSrcDir

        if length( sSrcDir ) < 4 then
        do
            /* Reached to a root directory */

            leave
        end

        sSrcDir = directory( sSrcDir || '\..')
    end

    /* Restore CWD */
    call directory sCurDir

    /* CD into a build dir */
    if directory( sBuildDir ) == '' then
    do
        'mkdir' sBuildDir '2>nul'
        if directory( sBuildDir ) == '' then
        do
            say 'Cannot change a directory to 'sBuildDir'!'

            return 1
        end
    end

    /* copy the configure script file */
    parse source . . sMe
    'copy' sMe '1>nul 2>nul'

    call setlocal

    /* For the cases using Make while configuring */
    call value 'LANG', 'C', 'OS2ENVIRONMENT'
    call value 'MAKESHELL', 'sh.exe', 'OS2ENVIRONMENT'

    /* Launch cmake */
    'cmake.exe' sTopSrcDir sArgs '2>&1 | tee cmkconf.log'
    ec = rc

    call endlocal

    return rc

/**
 * Check if the given build dir has been already configured
 */
isbuilddir: procedure
    parse arg sDir

    if sDir == '' then
        sDir = '.'

    return stream( strip( sDir, 'T', '\') || '\build.ninja', 'c', 'query exists') \== ''

/**
 * Check if the given dir is a source dir
 */
issrcdir: procedure
    parse arg sDir

    if sDir == '' then
        sDir = '.'

    return stream( strip( sDir, 'T', '\') || '\CMakeLists.txt', 'c', 'query exists') \== ''
