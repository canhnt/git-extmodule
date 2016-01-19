#!/bin/bash
#
# git-extmodule.sh: mimic the svn-externals feature
#
# This script is based on the git-external in ruby version by Daniel Cestari 2010
# (https://github.com/dcestari/git-external)
#
# Copyright 2016 Hippo B.V. (http://www.onehippo.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

MODULE_PREFIX='external'

dashless=$(basename "$0" | sed -e 's/-/ /')

set -e

if [ $# -eq 0 ]; then
	set -- help
fi

root_dir="`git rev-parse --show-toplevel`/"
config_file="$root_dir".gitexternals
ignore_file="$root_dir".gitignore

if [[ ! -e $config_file ]]; then
	touch $config_file
fi

modules=
# return a list of external modules from config file to the global variable $modules
get_modules() {			
	local result=`git config --file $config_file --list | grep ^$MODULE_PREFIX | cut -d. -f2 | sort | uniq`
	if [[ -n $result ]]; then		
		modules=($result)		
		return 0;
	fi
	return 1;
}

# read a configuration setting from config file
get_config() {	
	name=$1	
	option=$2
	
	value=$(git config --file $config_file $MODULE_PREFIX.$name.$option)
	echo $value
}

get_module_config() {
	url=$(get_config $module "url")
	path=$(get_config $module "path")
	branch=$(get_config $module "branch")		
}

module_exists() {
	local name=$1
	if [[ $(git config --file $config_file -l | grep "$MODULE_PREFIX.$name") ]]; then 
		return 0;
	else
		return 1;
	fi
}

# Clone a single branch of the external module to the given path
init_module() {
	local name=$1
	local url=$2
	local path=$3
	local branch=${4:-'master'}

	echo "init module $name with $url, $path, $branch" >&2

	if [ -e $path/.git ]; then
		echo "Repository already exists" >&2
		return 1
	fi

	$(git clone $url -b $branch --single-branch $path)
}

# Check for uncommitted changes in the given path
has_uncommitted() {
	local name=$1
	if [[ -e $name ]]; then
		cd $name
		git diff-index --quiet 'HEAD'
		cd ..
		return $?	
	fi	
	return 1	
}

update_module() {
	local name=$1
	local url=$2
	local path=$3
	local branch=$4	
	
	if [ -e $path/.git ]; then
		cd $path
		if [[ $(has_uncommitted $path) ]]; then
			echo "$path - uncommitted changes detected, can not update repository" >&2		
		else
			echo "$path - updating branch '$branch'" >&2
			git pull origin "$branch" > /dev/null
		fi
		cd ..
	else
		echo "Error- Module '$path' is not initialized" >&2
	fi
}

command_help() {	
 cat <<EOF
Syntax: 
    $dashless add <repository-url> <path> [<branch>]	
    $dashless list
    $dashless rm <path>
    $dashless init
    $dashless update
    $dashless cmd '<command>'		

Description:
    add     :  create configuration for a new external repository module    
    list    :  list configuration of your repository
    rm      :  remove an external repository module
    init    :  initialize (git clone) external repositories
    update  :  update existing repositories to the latest version
    cmd     :  execute a command for all external repositories
EOF

}

command_add() {
	local url=$1;
	local path=$2;
	local branch=${3:-'origin/master'};
	# echo "Adding module '$path' from branch '$branch' of the repository '$url'" >&2

	$(command_rm $path)

	$(git config --file $config_file --add "$MODULE_PREFIX.$path.path" $path)
	$(git config --file $config_file --add "$MODULE_PREFIX.$path.url" $url)
	$(git config --file $config_file --add "$MODULE_PREFIX.$path.branch" $branch)

	echo $path >> $ignore_file
}

command_rm() {	
	local path=$1
	if module_exists "$path"; then
		$(git config --file $config_file --remove-section "$MODULE_PREFIX.$path")
	fi

	if [[ -e $ignore_file ]]; then		
		# remove path from ignore file
		ignores=() 
		while read -r line; do
			ignores+=($line); 
		done < "$ignore_file"
		# remove item
		ignores=(${ignores[@]/$path})

		# write update
		printf '%s\n' "${ignores[@]}" > "$ignore_file"	
	fi
}

command_init() {
	
	if get_modules; then		
		for module in ${modules[@]}; do
			get_module_config $module
			$(init_module $module $url $path $branch)
		done
	else
		echo "No external module found. Use command 'add' first" >&2
		return 1;
	fi
}

command_update() {
	if get_modules; then 
		for module in ${modules[@]}; do
			get_module_config $module
			$(update_module $module $url $path $branch)
		done
	else
		echo "No external module found. Use command 'init' first" >&2
		return 1;
	fi
}

command_list() {
	if get_modules; then	
		for module in ${modules[@]}; do
			get_module_config $module

			echo "[$module]"
			echo "    url:      $url"
			echo "    path:     $path"
			echo "    branch:   $branch"		
		done
	else
		echo "No external module found Use command 'add' first" >&2
		return 1;
	fi
}

command_cmd() {
	get_modules
	local cmd=$1
	for module in ${modules[@]}; do
		path=$(get_config $module "path")
		echo "$path - Executing '$cmd'" >&2
		cd $path
		$($cmd)
		cd ..
	done
}

cmd="$1"
shift

"command_$cmd" "$@"