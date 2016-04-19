# Process this file with autoconf to produce a configure script and generate
# a Makefile.

# Inspired by configure.ac from crosstool-NG
# (C) 2013-2014 Douglas Jerome <djerome@crosslinux.org>
# (C) 2013 crosstool-NG authors. See complete list at:
#     http://crosstool-ng.org/hg/crosstool-ng/log/tip/configure.ac

AC_PREREQ([2.67])
AC_INIT([crosslinux],
        [m4_esyscmd_s([cat .version])],
        [http://groups.google.com/group/crosslinux/],
        [crosslinux],
        [http://crosslinux.net/])

# -----------------------------------------------------------------------------
# Define macro(s).
# -----------------------------------------------------------------------------

# Check for required program.
#
AC_DEFUN(
   [ACX_PATH_PROG_REQ],
   [AC_PATH_PROG([$1], [$2])
   AS_IF(
      [test -z "$$1"],
      [AC_MSG_ERROR([missing required tool: $2])])
   ])

# -----------------------------------------------------------------------------
# Check the configure options.
# -----------------------------------------------------------------------------

# --enable-local=no \... These must be used to enable the use of --prefix
# --disable-local   /    The default is --enable-local=yes

AC_ARG_ENABLE(
   [local],
   [AS_HELP_STRING([--disable-local], [configure for installation; enables use of --prefix*])])
AC_SUBST([enable_local], [${enable_local:-yes}])

if test x$enable_local = "xn";  then enable_local=no; fi
if test x$enable_local = "xN";  then enable_local=no; fi
if test x$enable_local = "xNo"; then enable_local=no; fi
if test x$enable_local = "xNO"; then enable_local=no; fi

if test x$enable_local = "xy";   then enable_local=yes; fi
if test x$enable_local = "xY";   then enable_local=yes; fi
if test x$enable_local = "xYes"; then enable_local=yes; fi
if test x$enable_local = "xYES"; then enable_local=yes; fi

# -----------------------------------------------------------------------------
# Check for required programs.
# -----------------------------------------------------------------------------

ACX_PATH_PROG_REQ([bzip2],    [bzip2])
ACX_PATH_PROG_REQ([find],     [find])
ACX_PATH_PROG_REQ([gzip],     [gzip])
ACX_PATH_PROG_REQ([install],  [install])
ACX_PATH_PROG_REQ([ln],       [ln])
ACX_PATH_PROG_REQ([make],     [make])
ACX_PATH_PROG_REQ([patch],    [patch])
ACX_PATH_PROG_REQ([tar],      [tar])
ACX_PATH_PROG_REQ([wget],     [wget])
ACX_PATH_PROG_REQ([xz],       [xz])

AC_SUBST([BZIP2],    [$ac_cv_path_bzip2])
AC_SUBST([FIND],     [$ac_cv_path_find])
AC_SUBST([GZIP],     [$ac_cv_path_gzip])
AC_SUBST([INSTALL],  [$ac_cv_path_install])
AC_SUBST([LN],       [$ac_cv_path_ln])
AC_SUBST([MAKE],     [$ac_cv_path_make])
AC_SUBST([PATCH],    [$ac_cv_path_patch])
AC_SUBST([TAR],      [$ac_cv_path_tar])
AC_SUBST([WGET],     [$ac_cv_path_wget])
AC_SUBST([XZ],       [$ac_cv_path_xz])

# -----------------------------------------------------------------------------
# Check some program particulars.
# -----------------------------------------------------------------------------

AC_PROG_EGREP
AC_PROG_GREP
AS_IF(
   [test ! "$EGREP" = "$GREP -E"],
   [AC_MSG_ERROR([egrep is not $GREP -E])])
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_SED
AC_MSG_CHECKING([whether sed understands -r -i -e])
touch .cl-bt.sed.test
if ${SED} -r -i -e 's/foo/bar/' .cl-bt.sed.test >/dev/null 2>&1; then
   rm -f .cl-bt.sed.test
   AC_MSG_RESULT([yes])
else
   rm -f .cl-bt.sed.test
   AC_MSG_RESULT([no])
   AC_MSG_ERROR([Your sed just cannot get the job done. Way to go, hoser.])
fi

# -----------------------------------------------------------------------------
# Check for proper program versions.
# -----------------------------------------------------------------------------

# Check for automake >= 1.10 version.
# -----------------------------------
#
AC_CACHE_VAL([ac_cv_path_automake],
   [AC_ARG_WITH([automake],
      AS_HELP_STRING([--with-automake=PATH],
                     [Specify the full PATH to GNU automake >= 1.10]),
      [ac_cv_path_automake=$withval])])
AC_CACHE_CHECK([for GNU automake >= 1.10], [ac_cv_path_automake],
   [AC_PATH_PROGS_FEATURE_CHECK([automake], [automake],
      [[automake_ver=$($ac_path_automake --version 2>&1 \
                       | $EGREP '\(GNU automake\) (1\.[[:digit:]]{2,}|[2-9][[:digit:]]*\.)')
        test -n "$automake_ver" && ac_cv_path_automake=$ac_path_automake ac_path_automake_found=:]],
      [AC_MSG_RESULT([no])
       AC_MSG_ERROR([could not find GNU automake >= 1.10])])])
AC_SUBST([AUTOMAKE], [$ac_cv_path_automake])

# Check for GNU awk.
# ------------------
#
AC_CACHE_VAL([ac_cv_path_awk],
   [AC_ARG_WITH([awk],
      AS_HELP_STRING([--with-awk=PATH],
                     [Specify the full PATH to GNU awk]),
      [ac_cv_path_awk=$withval])])
AC_CACHE_CHECK([for GNU awk], [ac_cv_path_awk],
   [AC_PATH_PROGS_FEATURE_CHECK([awk], [awk gawk],
      [[awk_ver=$($ac_path_awk --version 2>&1 \
                   | $EGREP '^GNU Awk ')
        test -n "$awk_ver" && ac_cv_path_awk=$ac_path_awk ac_path_awk_found=:]],
      [AC_MSG_RESULT([no])
       AC_MSG_ERROR([could not find GNU awk])])])
AC_SUBST([AWK], [$ac_cv_path_awk])

# Check for bash.
# ---------------
#
AC_CACHE_VAL([ac_cv_path_bash],
   [AC_ARG_WITH([bash],
      AS_HELP_STRING([--with-bash=PATH],
                       [Specify the full PATH to GNU bash >= 3.1]),
      [ac_cv_path_bash=$withval])])
AC_CACHE_CHECK([for bash >= 3.1], [ac_cv_path_bash],
   [AC_PATH_PROGS_FEATURE_CHECK([bash], [bash],
      [[bash_ver=$($ac_path_bash --version 2>&1 \
                    | $EGREP '^GNU bash, version (3\.[1-9]|4)')
        test -n "$bash_ver" && ac_cv_path_bash=$ac_path_bash ac_path_bash_found=:]],
      [AC_MSG_RESULT([no])
       AC_MSG_ERROR([could not find bash >= 3.1])])])
AC_SUBST([BASH], [$ac_cv_path_bash])

# -----------------------------------------------------------------------------
# Check for some programs, but don't fail; report if missing.
# -----------------------------------------------------------------------------

AC_CHECK_PROGS([genisoimage], [genisoimage])
AC_CHECK_PROGS([as86],        [as86])

# -----------------------------------------------------------------------------
# Miscellaneous variables are handled here.
# -----------------------------------------------------------------------------

AC_SUBST([DATE],[$(date +%Y-%m-%d)])

# -----------------------------------------------------------------------------
# Fixup the install directory paths based upon --disable-local.
# -----------------------------------------------------------------------------

AC_SUBST([sublibdir])
AC_SUBST([subdocdir])
AS_IF(
   [test x"$enable_local" = x"no"],
   [AC_MSG_NOTICE([enabling --prefix* because --disable-local is set])
    sublibdir="/cl-bt.\${PACKAGE_VERSION}"
    subdocdir="/cl-bt.\${PACKAGE_VERSION}"
    kconfig_prefix="${prefix}/lib/cl-bt.${PACKAGE_VERSION}"],
   [prefix=$(pwd)
    exec_prefix='${prefix}'
    datarootdir='${exec_prefix}'
    bindir='${exec_prefix}'
    libdir='${exec_prefix}'
    docdir='${exec_prefix}'
    mandir='${exec_prefix}'
    subdocdir=""
    sublibdir=""
    kconfig_prefix="${prefix}"])

# -----------------------------------------------------------------------------
# Generate files from the *.in files.  Configure in the kconfig directory.
# -----------------------------------------------------------------------------

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([host-tools/Makefile])
(
echo ""
echo "Configuring kconfig..."
cd kconfig
./configure \
	--prefix="${kconfig_prefix}/kconfig-exec" \
	--bindir="${kconfig_prefix}/kconfig-exec" \
	--libdir="${kconfig_prefix}/kconfig-exec" \
	--enable-mconf \
	--enable-nconf \
	--disable-gconf \
	--disable-qconf
if test $? -ne 0; then
   echo ""
   echo "=> Something went wrong with kconf ./configure."
   echo ""
   exit 1
fi
echo "=> Done configuring kconfig."
echo ""
) || exit 1

# -----------------------------------------------------------------------------
# Make the configure output.
# -----------------------------------------------------------------------------

AC_OUTPUT

AC_MSG_RESULT([
Configuration for ${PACKAGE_NAME}-${PACKAGE_VERSION}:])

if test -z "$ac_cv_prog_as86" -o -z "$ac_cv_prog_genisoimage"; then
   echo ""
   if test -z "$ac_cv_prog_as86"; then
      echo "** WARNING: missing as86, crosslinux cannot make lilo"
   fi
   if test -z "$ac_cv_prog_genisoimage"; then
      echo "** WARNING: missing genisoimage, crosslinux cannot make ISO images"
   fi
fi

AC_MSG_RESULT([
     PACKAGE_NAME ......... ${PACKAGE_NAME}
     PACKAGE_VERSION ...... ${PACKAGE_VERSION}
     PACKAGE_TARNAME ...... ${PACKAGE_TARNAME}
     PACKAGE_URL .......... ${PACKAGE_URL}
     PACKAGE_BUGREPORT .... ${PACKAGE_BUGREPORT}

     local (no install mode): ${enable_local}

     prefix:      ${prefix}
     exec_prefix: ${exec_prefix}
     datarootdir: ${datarootdir}
     bindir:      ${bindir}
     libdir:      ${libdir}${sublibdir}
     docdir:      ${docdir}${subdocdir}
     mandir:      ${mandir}
])

