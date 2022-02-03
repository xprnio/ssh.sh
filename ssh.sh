#!/bin/env bash

POSITIONAL_ARGS=()

# Catch the hostname and identity file from the arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--hostname)
      SAVE_HOSTNAME="$2"
      shift
      shift
      ;;
    -i)
      SAVE_IDENTITY_FILE="$2"
      shift
      shift
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}"

# The final argument should be [user@]hostname
for i in $@; do :; done
SAVE_HOSTNAME_DEST="$i"

# Get the user from the user@hostname
# If there is no user specified, use current user
function get_user() {
  has_user="$(echo $1 | grep '@')"
  if [[ "$has_user" != "" ]]; then
    echo "$1" | awk '{split($0,a,"@"); print a[1]}'
  else
    echo "$(whoami)"
  fi
}

# Get the hostname from user@hostname
function get_hostname() {
  has_user="$(echo $1 | grep '@')"
  if [[ "$has_user" != "" ]]; then
    echo "$1" | awk '{split($0,a,"@"); print a[2]}'
  else
    echo "$1"
  fi
}

# Create an SSH config block for the alias
function create_config(){
  echo "Host $1"
  echo "    Hostname $2"
  echo "    User $3"
  [[ "$4" != "" ]] && echo "    IdentityFile $4"
}

# Save the SSH config into ~/.ssh/config
function save_host_config(){
  echo "" >> ~/.ssh/config
  echo "$(create_config $@)" >> "$HOME/.ssh/config"
}

# Save hostname only if one was specified
if [[ "$SAVE_HOSTNAME" != "" && "$SAVE_HOSTNAME_DEST" != "" ]]; then
  alias="$SAVE_HOSTNAME"
  dest="$SAVE_HOSTNAME_DEST"
  ident="$SAVE_IDENTITY_FILE"

  # check if already aliased
  content="$(cat "$HOME/.ssh/config" | grep "$alias")"

  if [[ "$content" == "" ]]; then
    hostname="$(get_hostname $dest)"
    user="$(get_user $dest)"
    echo "saving $SAVE_HOSTNAME for $SAVE_HOSTNAME_DEST"
    save_host_config "$alias" "$hostname" "$user" "$ident"
  else
    echo "alias '$alias' already set for $dest"
    exit 1
  fi
fi

# Call ssh with other arguments
ssh ${POSITIONAL_ARGS[@]}
