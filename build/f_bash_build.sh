#!/bin/bash

OUR_PATH="$(readlink -f "$0")";
CALL_CMD="$1"

#cmds: bootstrap autoconf log_make

SCRIPT_FOLDER="$(dirname "${OUR_PATH}")"
if [[ ! -z "$WLB_SCRIPT_FOLDER" ]]; then
	SCRIPT_FOLDER="${WLB_SCRIPT_FOLDER}"
fi
. "$SCRIPT_FOLDER/helpers.sh" "${CALL_CMD}" "${OUR_PATH}"

PreInitialize;
#BLD_CONFIG_LOG_ON_AT_INIT=0


BLD_CONFIG_BUILD_NAME="bash";
#BLD_CONFIG_BUILD_FOLDER_NAME="myapp2"; #if you want it compiling in a diff folder
BLD_CONFIG_CONFIG_CMD_ADDL="--enable-static-link --enable-dependency-tracking --disable-nls" #--disable-nls --enable-static
BLD_CONFIG_ADD_WIN_ARGV_LIB=0

#many of these taken from the original imports bash wanted to do
BLD_CONFIG_GNU_LIBS_ADDL=( "nonblocking" "termios" "terminfo" "ttyname_r" "isatty" "signal-h" "free-posix" "malloc-gnu" "mkfifo" "mbscspn" "sys_select" "getlogin" "getcwd" "gethostname"  "wcswidth" "wcwidth" "wmemchr" "sleep" "isblank" "sys_wait" "getrusage" "getentropy" "sys_random" "pselect" "fpurge" "alloca" "vasprintf-gnu"  "getcwd" "strcase" "strcasestr" "strerror" "nstrftime" "strnlen" "strstr" "strtod" "strtol" "strtoul" "strtoll" "strtoull" "strtoumax" "dprintf" "strchrnul" "strdup-posix" "gettimeofday"  "timespec" "getopt-gnu" "lock" "symlink" "symlinkat" "config-h" "ioctl" "unistd" "dirent" "sys_stat" "sys_types" "sys_file" "stdbool" "stat-time" "dirname" "attribute" "dirfd" "dup2" "dup3" "readlink" "stat-macros" "lstat" "stat-size" "stat-time" "open" "openat" "stdopen" "fcntl" "fcntl-h" "errno"  )

BLD_CONFIG_CONFIG_ADDL_LIBS="-lpdcursesstaticd"
BLD_CONFIG_BUILD_DEBUG=1
BLD_CONFIG_BUILD_MSVC_RUNTIME_INFO_ADD_TO_C_AND_LDFLAGS=1
BLD_CONFIG_BUILD_MSVC_CL_DEBUG_OPTS+=" -DDEBUG"
BUILD_MSVC_IGNORE_WARNINGS=( 4068 )
# after including this script have:
function ourmain() {
	startcommon;
	export LDFLAGS="-LC:/software/ntest/pdcurses/final/lib/wincon" CFLAGS="-IC:/software/ntest/pdcurses/final/include -DYYDEBUG"
if test 5 -gt 100; then
		echo "Just move the fi down as you want to skip steps"
#fi

	git clone --recurse-submodules https://git.savannah.gnu.org/git/bash.git .

	git clone --recurse-submodules https://github.com/coreutils/gnulib
	git mv aclocal.m4 acinclude.m4 #aclocal will be autogened now
	git rm configure configure.in #old/generated
#	git rm config.h.in
	git mv Makefile.in Makefile.am
	sed -i -E 's/[.]o(bj)?\b/.$(OBJEXT)/g' Makefile.am builtins/Makefile.in lib/readline/Makefile.in lib/glob/Makefile.in  lib/sh/Makefile.in lib/termcap/Makefile.in lib/tilde/Makefile.in
	sed -i -E 's#AC_DEFUN\(([^][,]+),#AC_DEFUN\([\1],#g' acinclude.m4 #quoting fix
	sed -i -E 's#AC_DEFINE\(([a-z0-9A-Z_$]+)\)#AC_DEFINE([\1], [ 1 ], [ ])#g' configure.ac acinclude.m4 #define for autoheader properly
	sed -i -E 's#AC_DEFINE\((\[[a-zA-Z_]+\])\s*,\s*([^ ]+)\)#AC_DEFINE([\1], \2, [ ])#g' configure.ac acinclude.m4 #define for autoheader properly
	sed -i -E 's#AC_DEFINE_UNQUOTED\(([a-z0-9A-Z_$]+)\s*,\s*([^ ]+)\)#AC_DEFINE_UNQUOTED([\1], \2, [ ])#g' configure.ac acinclude.m4 #define for autoheader properly
	sed -i -E 's#AC_DEFINE_UNQUOTED\((\[[a-z0-9A-Z_$]+\])\s*,\s*([^ ]+)\)#AC_DEFINE_UNQUOTED(\1, \2, [ ])#g' configure.ac acinclude.m4 #define for autoheader properly

	echo "" > config.h.in
	cp gnulib/build-aux/bootstrap .
	cp gnulib/build-aux/bootstrap.conf .
	#echo "gnulib_tool_option_extras=\" --without-tests --symlink --m4-base=gl_m4 --lib=libgnu --source-base=gnu --cache-modules\"" >> bootstrap.conf #we commit it up so we dont need this
#fi
	gnulib_switch_to_master_and_patch;
fi
	if [[ -z $CALL_CMD || $CALL_CMD == "bootstrap" ]]; then
		gnulib_add_addl_modules_to_bootstrap;
	#### Switch to autoconf items
		setup_gnulibtool_py_autoconfwrapper #needed for generated .mk/.ac files but if just stock then the below line likely works
		gnulib_ensure_buildaux_scripts_copied;
		./bootstrap --no-bootstrap-sync --no-git --gnulib-srcdir=gnulib --skip-po --force
		sed -i -E 's#AM_CFLAGS =[ ]*$#AM_CFLAGS = @AM_CFLAGS@#g' gnu/Makefile.am
		CALL_CMD="" #to do all the other steps
	else
		gnulib_ensure_buildaux_scripts_copied
	fi
#fi
#	tee_cmd_outs aclocal -Igl_m4 --force --install --verbose -Im4
#	tee_cmd_outs autoconf --force --trace --verbose -Im4
#	tee_cmd_outs autoheader --verbose --debug -Ilib -Im4 --force
#fi
#fi
	#exit 1
	#autoconf
	#autoheader




#exit 1
	#sed -i -E 's/[.]a\b/.lib/g' Makefile.in builtins/Makefile.in

#export PERL_MM_USE_DEFAULT=1 PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"
#export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"
# PERL_MM_USE_DEFAULT=1 PERL_EXTUTILS_AUTOINSTALL="--defaultdeps" perl -MCPAN -e "install Devel::Trace"

#fi
	if [[ $CALL_CMD == "autoconf" ]]; then #not empty aLlowed as if we bootstrapped above we dont need to run nautoconf
		autoreconf --symlink --verbose --install --force -I gl_m4  --no-recursive
		
		CALL_CMD="" #to do all the other steps
	fi
	add_items_to_gitignore;

	cd $BLD_CONFIG_SRC_FOLDER
	if [[ -z $CALL_CMD || $CALL_CMD == "configure" ]]; then
		configure_fixes;
		configure_run;
	else
		setup_build_env;
	fi


	if [[ $CALL_CMD == "makefiles" ]]; then
		./config.status
	fi

	if [[ -z $CALL_CMD || $CALL_CMD == "log_make" ]]; then
	echo "RUNNING log_make"
	#	log_make;  #will log all the commands make would run to a file
	fi
	if [[ $CALL_CMD == "log_undefines" ]]; then
		FL="undefined.txt"
		echo "Logging undefined symbols to ${FL}"
		make | rg --no-line-number -oP "unresolved external symbol.+referenced" | sed -E 's#unresolved external symbol(.+)referenced#\1#g' | sort -u > $FL

	fi
	#cd lib
	#make -j 8 || make
	cd $BLD_CONFIG_SRC_FOLDER
	make debug.obj #needed by some others
	make -j 8 || make
	exit 1
	make install

	finalcommon;
}
ourmain;

