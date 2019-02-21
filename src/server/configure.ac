dnl Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT(Webservices, 1.0)


AC_CANONICAL_SYSTEM
AM_INIT_AUTOMAKE()

AC_PROG_CXX
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES(Makefile connections/Makefile data/Makefile services/Makefile services/mt/Makefile services/preprocess/Makefile)

AC_LANG(C++)

AM_PROG_AR()

dnl AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LIBTOOL
LT_INIT 

AC_CONFIG_MACRO_DIR([m4])

dnl AC_PROG_MAKE_SET


dnl check for header files


AC_HEADER_STDC
AC_CHECK_HEADERS([stack string list vector map],,AC_MSG_WARN(STL classes missing ?))
AC_CHECK_HEADERS([ext/hash_map ext/hash_set],,AC_MSG_WARN(SGI extensions ?))

AX_PYTHON_DEVEL

AM_CXXFLAGS="$AM_CXXFLAGS -I/usr/include/libxml2/ $PYTHON_CPPFLAGS"
LIBS="$PYTHON_LIBS $PYTHON_EXTRA_LIBS $LIBS"


##########################################################################
# adding the XXX library (e.g. with static name 'libXXX.a')
##########################################################################


AC_ARG_WITH([lamtram], 
    [AS_HELP_STRING([--with-lamtram=prefix], 
        [try this for a non-standard install with NMT])], 
    [lamtramPATHSET=1], 
    [lamtramPATHSET=0]) 



AX_BOOST_BASE([1.49],[] , AC_MSG_ERROR([Boost 1.49 or later is required]))
AX_BOOST_REGEX
AM_CXXFLAGS="$AM_CXXFLAGS $BOOST_CPPFLAGS"
AM_LDFLAGS="$AM_LDFLAGS $BOOST_LDFLAGS"
LIBS="$BOOST_REGEX_LIB $LIBS"

if test $lamtramPATHSET = 1 ; then 
# Check if we have rt/boost
AX_BOOST_SYSTEM
AX_BOOST_PROGRAM_OPTIONS
AX_BOOST_SERIALIZATION
AX_BOOST_IOSTREAMS
AX_BOOST_UNIT_TEST_FRAMEWORK
AX_BOOST_FILESYSTEM
AX_BOOST_TIMER
AX_BOOST_PYTHON
AX_BOOST_THREAD
LIBS="$BOOST_SYSTEM_LIB $BOOST_PROGRAM_OPTIONS_LIB $BOOST_SERIALIZATION_LIB $BOOST_IOSTREAMS_LIB $BOOST_UNIT_TEST_FRAMEWORK_LIB $BOOST_FILESYSTEM_LIB $BOOST_TIMER_LIB -lboost_chrono -l$BOOST_PYTHON_LIB $BOOST_THREAD_LIB $LIBS"
fi


AC_ARG_WITH([dynet], 
    [AS_HELP_STRING([--with-dynet=prefix], 
        [try this for a non-standard install with NMT])], 
    [dynetPATHSET=1], 
    [dynetPATHSET=0]) 

# if optional parameter used, extend path flags for compliler and linker 
if test $dynetPATHSET = 1 ; then 
    # extend the compiler and linker flags according to the path set 
    LIBS="-ldynet $LIBS"
    AM_CXXFLAGS="$AM_CXXFLAGS -I$with_dynet/include/" 
    AM_LDFLAGS="$AM_LDFLAGS -L$with_dynet/lib/" 
fi 

# if optional parameter used, extend path flags for compliler and linker 
if test $lamtramPATHSET = 1 ; then 
    # extend the compiler and linker flags according to the path set 
    LIBS="-llamtram $LIBS"
    AM_CXXFLAGS="$AM_CXXFLAGS -I$with_lamtram/include/" 
    AM_LDFLAGS="$AM_LDFLAGS -L$with_lamtram/lib/" 
    AC_DEFINE(LAMTRAMLIB,"1",[Use LAMTRAM])
fi 


AC_ARG_WITH([mongo], 
    [AS_HELP_STRING([--with-mongo=prefix], 
        [try this for a non-standard install with NMT])], 
    [mongoPATHSET=1], 
    [mongoPATHSET=0]) 

# if optional parameter used, extend path flags for compliler and linker 
if test $mongoPATHSET = 1 ; then 
    # extend the compiler and linker flags according to the path set 
    LIBS="-lmongocxx $LIBS"
    AM_CXXFLAGS="$AM_CXXFLAGS -I$with_mongo/include/mongocxx/v_noabi/ -I$with_mongo/include/bsoncxx/v_noabi/" 
    AM_LDFLAGS="$AM_LDFLAGS -L$with_mongo/lib/" 
    AC_DEFINE(MONGODB,"1",[Use MONGO])
fi 



AC_ARG_WITH([rapidxml],
    [AS_HELP_STRING([--with-rapidxml=prefix],
        [try this for a non-standard install prefix of the rapid xml light librarys])],
    [rapidxmlPATHSET=1],
    [rapidxmlPATHSET=0])

# if optional parameter used, extend path flags for compliler and linker
if test $rapidxmlPATHSET = 1 ; then
    # extend the compiler and linker flags according to the path set
    AM_CXXFLAGS="$AM_CXXFLAGS -I$with_rapidxml"
fi



AC_ARG_WITH([mediator],
    [AS_HELP_STRING([--with-mediator=prefix],
        [try this for a non-standard install prefix of the meditator librarys])],
    [mediatorPATHSET=1],
    [mediatorPATHSET=0])

# if optional parameter used, extend path flags for compliler and linker
if test $mediatorPATHSET = 1 ; then
    # extend the compiler and linker flags according to the path set
    AM_CXXFLAGS="$AM_CXXFLAGS -I$with_mediator/include/"
    AM_LDFLAGS="$AM_LDFLAGS -L$with_mediator/lib64/"
    LIBS="-lMCloud -lJibbigoShared -lxml2 -lcurl $LIBS"
    AC_DEFINE(MEDIATOR,"1",[Use Mediator])
fi





# introduce the optional configure parameter for a non-standard install prefix of XXX 
AC_ARG_WITH([ice], 
    [AS_HELP_STRING([--with-ice=prefix], 
        [try this for a non-standard install with ice mediator])], 
    [icePATHSET=1], 
    [icePATHSET=0]) 
         
# if optional parameter used, extend path flags for compliler and linker 
if test $icePATHSET = 1 ; then 
    # extend the compiler and linker flags according to the path set 
    LIBS="$LIBS -lIceMediator -lGlacier2 -lIce -lIceUtil"
    INCL=`echo $with_ice | sed -e "s|:|/include/ -I|g" -e "s|$|/include/|g"`
    LD=`echo $with_ice | sed -e "s|:|/lib/ -L|g" -e "s|$|/lib/|g"`
    AM_CXXFLAGS="$AM_CXXFLAGS -I$INCL" 
    AM_LDFLAGS="$AM_LDFLAGS -L$LD" 
    AC_DEFINE(ICELIB,"1",[Use ICE Libaray])
    #AM_LDFLAGS="$AM_LDFLAGS -L$with_srilm/lib/macosx" 
fi 


AC_ARG_WITH([openblas], 
    [AS_HELP_STRING([--with-openblas=prefix], 
        [try this for a non-standard install with NMT])], 
    [openblasPATHSET=1], 
    [openblasPATHSET=0]) 

# if optional parameter used, extend path flags for compliler and linker 
if test $openblasPATHSET = 1 ; then 
    # extend the compiler and linker flags according to the path set 
    LIBS="-lopenblas $LIBS"
    AM_CXXFLAGS="$AM_CXXFLAGS -I$with_openblas/include/" 
    AM_LDFLAGS="$AM_LDFLAGS -L$with_openblas/lib/" 
    #AM_LDFLAGS="$AM_LDFLAGS -L$with_srilm/lib/macosx" 
fi 






# Check for Eigen
AC_ARG_WITH(eigen,
	[AC_HELP_STRING([--with-eigen=DIR], [eigen in DIR])],
	[eigen_dir="${withval}"], [eigen_dir=''])
if test "x$eigen_dir" != "x"; then
  AM_CXXFLAGS="$AM_CXXFLAGS -I${eigen_dir}"
fi



#enable LMDB
AC_ARG_ENABLE([lmdb],
    AS_HELP_STRING([--enable-lmdb], [Enable lmdb model]))

AS_IF([test "x$enable_lmdb" = "xyes"], [
        AC_DEFINE(LMDB,"1",[Use LMDB])
	LIBS="-llmdb $LIBS"
])



LIBS="-pthread $LIBS"



##########################################################################




# distribute the changed variables among the Makefiles
AC_SUBST([LIBS])
AC_SUBST([AM_CXXFLAGS])
AC_SUBST([AM_LDFLAGS])


AC_OUTPUT

