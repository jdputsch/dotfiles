#!/usr/bin/env bash
# mdx_utils.bash
#
#  Library of utility functions for Bash scripts that work with MDX
#

# Set TOP_PID  variable is not already set
if [[ -z "${TOP_PID}" ]]; then
    readonly TOP_PID=$$
fi

# Add arguments to beginning of PATH variable:
#   - ensure each argument is PATH only once
#   - pathprepend P1 P2 P3, results in PATH=P1:P2:P3:...
#
pathprepend() {
    local ARG
    for (( i=$#; i>0; i-- )); do
        ARG=${!i}
        PATH=${PATH//":$ARG"/} #delete any instances in the middle or at the end
        PATH=${PATH//"$ARG:"/} #delete any instances at the beginning
        export PATH="$ARG:$PATH" #prepend to beginning
    done
}

abspath() {
    (
    cd -P "$(dirname "$1")"
    printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
    )
}

# Search up the path tree for a file
#  Args:
#    look_for - file to find
#    dir      - optional directory to use as starting point
# Always returns the absolute path of the
upsearch () {
    look_for="$1"
    path=${2:-$(pwd)}
    while [[ "${path}" != "" && ! -e "${path}/${look_for}" ]]; do
        path=${path%/*}
    done
    if [[ -z "${path}" ]]; then
        echo ""
        return 1
    else
        echo $(abspath "${path}/${look_for}")
        return 0
    fi
}

# signal our script to terminate, using this routines allows us to
# terminate from sub-shells.
#
# Args:
#    signal - optional signal to send our script
abort() {
    signal=${1:-TERM}
    kill -${signal} ${TOP_PID}
}

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}


# Prompt the user
#    - return 1 if an answer starting with 'q' or "Q" is entered
#    - return X if an answer starting with 'x' or "X" is entered
#    - otherwise return "Y"
#  Args:
#     prompt - the prompt string to present to the user
doit_skip_or_quit () {
    local prompt="$1"
    read -p "${prompt} [X to skip, Q to quit]: " ans
    case "${ans}" in
        [qQ]*) echo "Q"; abort;;
        [xX]*) echo "X"; return 0 ;;
        *) echo "Y" ; return 0;;
    esac
}

# Ensure our current directory is in a workspace with the given
# MDX IPL
#
# Args:
#    mdx_ipl - A methodics IPL which needs to be in our workspace
#
# Return:
#    9 if mdx_ipl is in our workspace
#    1 and abort() if mdx_ipl is not in workspace
ipl_in_workspace_p() {
    local mdx_ipl=$1
    local ws_dir=${2:-$(pwd)}
    local manifest_file=""
    local lib
    local ip
    local line
    local version
    local has_ipl
    valid_ipv_name ${mdx_ipl} || return 1
    eval $(parse_mdx_ipv $mdx_ipl)
    mdx_ipl=${lib}.${ip}@.${line}
    manifest_file=$(upsearch .methodics/ws_manifest.json ${ws_dir}) || return 1
    ws_resource_lines=$(jq -r '(.resources[], .top_ipv).ipid
                                | "\(.library).\(.ip)@.\(.line)"' \
                        ${manifest_file})
    echo "${ws_resource_lines}" | grep -q ${mdx_ipl}
    return $?
}

# Return location of an IP in the workspace
#
# Args:
#    mdx_ip - A methodics IP, IPL, IPV which needs to be in our workspace
#
# Return:
#    0 , "ip_path", if mdx_ipl is in our workspace
#    1 , "", and abort() if mdx_ipl is not in workspace
ip_path_in_workspace() {
    local mdx_ipl=$1
    local manifest_file=""
    local lib
    local ip
    local line
    local version
    local ip_path=""
    valid_ipv_name ${mdx_ipl} || return 1
    eval $(parse_mdx_ipv $mdx_ipl)
    mdx_ipl=${lib}.${ip}@.${line}
    manifest_file=$(upsearch .methodics/ws_manifest.json) || return 1
    ip_path=$(jq -r '(.resources[], .top_ipv)
                                | select((.ipid.library == "'${lib}'") and
                                         (.ipid.ip == "'${ip}'"))
                                | .path//""' \
                        ${manifest_file})
    echo "${ip_path}"
    return 0
}

# Validate an MDX IPV
# NOTE this only checks the syntax, not whether the IPV exists
valid_ipv_name() {
    [[ $1 =~ ^[^.]+[.][^@.]+(@([^.]+)?([.].*)?)?$ ]] || return 1
    [[ $1 = *@. ]] && return 1
    return 0
}


# Return set of x=y strings that can be used to set variables
# based on an MDX_IPV
# The strings are of the format ${base}_x
#
# Args:
#    base    - the base of the returned variable name
#    mdx_ipv - an MDX_IPV which we parse
parse_mdx_ipv() {
    local base=$1 ; shift
    local mdx_ipv=$1; shift
    local lib=""
    local ip=""
    local version=""
    local line="TRUNK"
    if [ -z "$mdx_ipv" ]; then
        mdx_ipv=${base}
        base=""
    fi
    if echo ${mdx_ipv} | grep -q "@"; then
        version=${mdx_ipv##*@}
        if echo ${version} | egrep -q "[.]"; then
            line=${version##*.}
        fi
        version=${version%%.*}
    fi
    lib=${mdx_ipv%%@*}
    ip=${lib##*.}
    lib=${lib%%.*}
    echo ${base}lib=${lib}
    echo ${base}ip=${ip}
    echo ${base}version=${version}
    echo ${base}line=${line}
    if [[ -z "${lib}" ]] || [[ -z "${ip}" ]]; then
        return 1
    fi
    return 0
}

# Return the list of resources for an MDX_IPV
#
# Args:
#    mdx_ipv - the MDX_IPV we are getting the resources for
get_ipv_resources() {
    local mdx_ipv=$1
    local ipv_json=""
    local ipv_resources=""
    valid_ipv_name ${mdx_ipv} || return 1
    ipv_json=$(pi ip ls --format json ${mdx_ipv})
    if [ $? != 0 ]; then
        err "Could not get IPV information for ${mdx_ipv}"
        return 1
    fi
    ipv_resources=$(echo "$ipv_json" | \
        jq -r '.[]
               | .ipv.resources[]
               | .ipid
               | "\(.library).\(.ip)@\(.alias//.version).\(.line)"')
     if [[ $? != 0 ]] || [[ -z "${ipv_resources}" ]]; then
         err "Could not get resources from IPV JSON"
         return 1
     fi
     echo "$ipv_resources"
     return 0
}

# get_fileset
#   Get the list of files for a given IPV
#
get_fileset() {
    local mdx_ipv=$1
    valid_ipv_name ${mdx_ipv} || return 1
    ipv_fileset=$(pi ip ls --contents --format json ${mdx_ipv} \
        | jq -r '.[] | .ipv.contents.fileset[]')
    status=$?
    echo "${ipv_fileset}"
    return ${status}
}
