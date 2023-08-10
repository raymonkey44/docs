#!/bin/bash
set -e
. "${WLB_SCRIPT_FOLDER:-$(dirname "$(readlink -f "$BASH_SOURCE")")}/helpers.sh"

BLD_CONFIG_BUILD_NAME="gsh";
BLD_CONFIG_CONFIG_CMD_ADDL="" #--disable-nls --enable-static
BLD_CONFIG_GNU_LIBS_USED=0
BLD_CONFIG_ADD_WIN_ARGV_LIB=0
BLD_CONFIG_BUILD_MSVC_RUNTIME_INFO_ADD_TO_C_AND_LDFLAGS=1
function ourmain() {
	startcommon;

if test 5 -gt 100; then
		echo "Just move the fi down as you want to skip steps, or pass the step to skip to (per below) as the first arg"
fi
	if [[ -z $SKIP_STEP || $SKIP_STEP == "checkout" ]]; then
		git clone --recurse-submodules https://github.com/AdaCore/gsh.git .
		add_items_to_gitignore;
		SKIP_STEP=""
		sed -i -E 's#"-fpreserve-control-flow",##g' *.gpr os/*.gpr c/*.gpr gsh/*.gpr
#		sed -i -E 's#"-fdump-scos"##g' *.gpr os/*.gpr c/*.gpr gsh/*.gpr
		sed -i -E 's#.+dev.*##g;s#([ \t]+).+gprbuild#\1gprbuild#g;/^[[:space:]]*$/d' Makefile
		rm -rf gnutools
		mkdir -p gnutools/bin
	fi

	setup_build_env;
	if [[ $BLD_CONFIG_GNU_LIBS_USED -eq "1" ]]; then
		if [[ -z $SKIP_STEP || $SKIP_STEP == "gnulib" ]]; then
			gnulib_switch_to_master_and_patch;
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
	
	if [[ -z $SKIP_STEP || $SKIP_STEP == "tools" ]]; then
		SKIP_STEP=""
		wget https://github.com/alire-project/alire/releases/download/v1.2.2/alr-1.2.2-bin-x86_64-windows.zip -O alr.zip
		unzip ./alr.zip
		cd $BLD_CONFIG_SRC_FOLDER
	fi
	LIN_PATH=`cygpath -u "$BLD_CONFIG_SRC_FOLDER"`
	export PATH="$LIN_PATH/bin:$PATH"

	if [[ -z $SKIP_STEP || $SKIP_STEP == "proj_init" ]]; then
		alr -n init --in-place --no-skel --bin posix_shell
	fi
	#these print env commands actually are what ends up triggering the dep downloads so takes awhile first time
	ENV_ADD=`alr -n printenv --unix | grep -v " PATH=" |  sed -E 's#\\\\#/#g'`
	PATH_ENV_ADD=`alr -n printenv --unix | grep " PATH=" | sed -E 's#([A-Za-z]):([^;]+)#/\\1\\2#g;s#\\\\#/#g;s#;#:#g;s#^[^"]+"##;s#"$##'`
	echo "ENV ADD IS SET TO: $ENV_ADD"


	echo "HWG"
	eval "$ENV_ADD"
	export PATH="$PATH_ENV_ADD"
	#export GPR_PROJECT_PATH="$GPR_PROJECT_PATH;${BLD_CONFIG_SRC_FOLDER}/os;${BLD_CONFIG_SRC_FOLDER}/c;${BLD_CONFIG_SRC_FOLDER}/gsh"
	
	cd $BLD_CONFIG_SRC_FOLDER
	# -k keep going    -vP2 -vh --keep-temp-files
	MAKE_CMD="gprbuild --no-complete-output -d  -j1 -p -P posix_shell -XBUILD=dev" #originally we used their makefile thus the modification above, but really no reason to do so it only does two commands
	if [[ -n "${LOG_MAKE_RUN}" ]]; then
		run_logged_make $MAKE_CMD
	fi

	$MAKE_CMD
	mkdir -p $BLD_CONFIG_INSTALL_FOLDER/bin
	cp obj/prod/gsh.exe "$BLD_CONFIG_INSTALL_FOLDER/bin"
	finalcommon;
}
ourmain;



	# cmake_config_run -DINSTALL_PKGCONFIG_DIR:PATH="${BLD_CONFIG_INSTALL_FOLDER}/lib/pkgconfig" -DENABLE_BINARY_COMPATIBLE_POSIX_API:BOOL="1"

	# if [[ -n "${LOG_MAKE_RUN}" ]]; then
	# 	run_logged_make cmake --build "${CMAKE_BUILD_DIR}" --config $BLD_CONFIG_CMAKE_BUILD_TARGET_AUTO --verbose #this wont actually work as we dont use our wrappers but maybe one day
	# fi

	# cmake --build "${CMAKE_BUILD_DIR}" --config $BLD_CONFIG_CMAKE_BUILD_TARGET_AUTO --verbose
	# cmake --install "${CMAKE_BUILD_DIR}"