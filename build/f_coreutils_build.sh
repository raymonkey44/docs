#!/bin/bash
set -e
. "${WLB_SCRIPT_FOLDER:-$(dirname "$(readlink -f "$BASH_SOURCE")")}/helpers.sh"

BLD_CONFIG_BUILD_NAME="coreutils";
BLD_CONFIG_CONFIG_CMD_ADDL="fu_cv_sys_mounted_getfsstat=yes fu_cv_sys_stat_statvfs=yes --enable-no-install-program=chcon,chgrp,chmod,chown,selinux,runcon,mknod,mkfifo,expr,tty,groups,group-list,id,kill,logname,nohup,ptx,split"
BLD_CONFIG_ADD_WIN_ARGV_LIB=1
BLD_CONFIG_CONFIG_ADDL_LIBS="-lAdvapi32"
BLD_CONFIG_GNU_LIBS_ADDL=( "ioctl" "symlink" "unistd" "sigpipe" "fprintf-posix" )
BLD_CONFIG_GNU_LIBS_USE_GNULIB_TOOL_PY=0

BLD_CONFIG_BUILD_MSVC_RUNTIME_INFO_ADD_TO_C_AND_LDFLAGS=1
#BLD_CONFIG_BUILD_DEBUG=1

function ourmain() {
	startcommon;

if test 5 -gt 100; then
		echo "Just move the fi down as you want to skip steps, or pass the step to skip to (per below) as the first arg"
fi
	if [[ -z $SKIP_STEP || $SKIP_STEP == "checkout" ]]; then
		git clone --recurse-submodules https://github.com/coreutils/coreutils .
		add_items_to_gitignore;
		SKIP_STEP=""
	fi
	
	osfixes_set_locations_dbg_add_to_libs;
	if [[ -z $SKIP_STEP || $SKIP_STEP == "our_patch" ]]; then
		apply_our_repo_patch; #looks in the patches folder for  repo_BUILD_NAME.patch and if found applies it.  Easy way to generate the patch from modified repo, go to your modified branch (make sure code committed) and run: git diff --color=never master > repo_NAME.patch
		osfixes_link_in_if_dbg_and_stg;
		osfixes_bare_compile;

		
		SKIP_STEP=""
	fi
	#osfixes_bare_compile;exit 1;
	
	if [[ $BLD_CONFIG_GNU_LIBS_USED -eq "1" ]]; then
		if [[ -z $SKIP_STEP || $SKIP_STEP == "gnulib" ]]; then
			gnulib_switch_to_master_and_patch;
			git checkout src/od.c src/fmt.c
			sed -i -E "s/([ \t,:;]|^)(CHAR|INT|LONG|SHORT)([ \t,:;]|\\$)/\1SS\2\3/g" src/od.c
			#MS defines WORD already so lets change it
			sed -i -E "s/WORD/GNUWORD/g" src/fmt.c
			SKIP_STEP=""
		fi
		cd $BLD_CONFIG_SRC_FOLDER

		if [[ -z $SKIP_STEP || $SKIP_STEP == "bootstrap" ]]; then
			gnulib_add_addl_modules_to_bootstrap;		
			gnulib_ensure_buildaux_scripts_copied;
			setup_gnulibtool_py_autoconfwrapper #needed for generated .mk/.ac files but if just stock then the below line likely works
			./bootstrap --no-bootstrap-sync --no-git --gnulib-srcdir=gnulib --skip-po
			SKIP_STEP=""
		fi
	fi
	if [[ $SKIP_STEP == "autoconf" ]]; then #not empty allowed as if we bootstrapped above we dont need to run nautoconf
		autoreconf --symlink --verbose --install
		SKIP_STEP=""
	fi

	cd $BLD_CONFIG_SRC_FOLDER
	if [[ -z $SKIP_STEP || $SKIP_STEP == "configure" ]]; then
		configure_fixes;
		configure_run;
		SKIP_STEP="";
	else
		setup_build_env;
	fi

	if [[ $SKIP_STEP == "makefiles" ]]; then #not empty and not setting empty as this is only a skip to step
		./config.status
	fi

	if [[ -n "${LOG_MAKE_RUN}" ]]; then
		run_logged_make;
	fi

	make -j 8 || make
	make_install

	finalcommon;
}
ourmain;

