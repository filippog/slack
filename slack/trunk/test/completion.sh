#!/bin/bash
# vim:sw=2
# Writing bash completion unit tests is a PITA, but let's try it anyway.
#
# We can't pass args around to methods like in a more sophisticated language
# because bash is limited in how it deals with arrays.  So we resign ourselves
# to using globals.

set -e

tests_passed=0

COMPLETION_SLACK_CONF="${TEST_TMPDIR}/slack.conf"

setup_role_list() {
  . "${COMPLETION_SLACK_CONF}"
  mkdir -p "${CACHE}"
  cp "${ROLE_LIST}" "${CACHE}"/_role_list
}

cleanup() {
  if [ -n "${CACHE}" ] ; then
    rm -f "${CACHE}/_role_list"
    rmdir "${CACHE}"
  fi
}

array_compare() {
  if [ ${#expect[@]} -ne ${#actual[@]} ] ; then
    return 1
  fi

  local i=0
  for element in "${expect[@]}" ; do
    if [ "${actual[$i]}" != "${element}" ] ; then
      return 1
    fi
    i=$(($i + 1))
  done

  return 0
}

check_results() {
  actual=("${COMPREPLY[@]}")
  if ! array_compare ; then
    echo "FAILED"
    cat >&2 <<EOF
Completion on '${COMP_WORDS[@]}' failed:
    Expected: '${expect[@]}'
    Got:      '${actual[@]}'
EOF
    exit 1
  fi
  echo "OK"
  tests_passed=$(($tests_passed + 1))
}

begin_test() {
  echo -n "$1: "
}

setup_role_list
trap cleanup EXIT

. ../src/slack_completion

begin_test "basic completion"
COMP_CWORD=1
COMP_WORDS=(slack ro)
expect=(role1 role2.sub role3.sub.sub)
_slack
check_results

begin_test "different offset"
COMP_CWORD=2
COMP_WORDS=(slack -v ro)
expect=(role1 role2.sub role3.sub.sub)
_slack
check_results

begin_test "empty word"
COMP_CWORD=1
COMP_WORDS=(slack '')
expect=(role1 role2.sub role3.sub.sub)
_slack
check_results

begin_test "subroles"
COMP_CWORD=1
COMP_WORDS=(slack role3)
expect=(role3.sub.sub)
_slack
check_results

begin_test "other hosts"
HOSTNAME=fixedhost.example.com
COMP_CWORD=1
COMP_WORDS=(slack '')
expect=(examplerole)
_slack
unset HOSTNAME
check_results

begin_test "double dash option"
COMP_CWORD=1
COMP_WORDS=(slack --v)
expect=(--verbose --version)
_slack
check_results

begin_test "single dash option"
COMP_CWORD=1
COMP_WORDS=(slack -v)
expect=(-v)
_slack
check_results

begin_test "preview"
COMP_CWORD=2
COMP_WORDS=(slack --preview '')
expect=(simple prompt)
_slack
check_results

begin_test "preview with equals"
COMP_CWORD=1
COMP_WORDS=(slack --preview=)
expect=(simple prompt)
_slack
check_results

begin_test "sleep bogus"
COMP_CWORD=2
COMP_WORDS=(slack --sleep a)
expect=(60 900 1800 3600)
_slack
check_results

echo "${0##*/}: $tests_passed tests passed"
