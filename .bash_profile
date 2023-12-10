# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [[ -f "$HOME/.bashrc" && -z "$_Z_IGNORE_THIS_BASH_RC_LOADING_LOCK" ]]; then
	. "$HOME/.bashrc"
    fi
fi

# SSH agent, as recommended by https://gist.github.com/darrenpmeyer/e7ad217d929f87a7b7052b3282d1b24c
ssh_pid_file="$HOME/.config/ssh-agent.pid"
SSH_AUTH_SOCK="$HOME/.config/ssh-agent.sock"
if [ -z "$SSH_AGENT_PID" ]
then
	# no PID exported, try to get it from pidfile
	SSH_AGENT_PID=$(cat "$ssh_pid_file")
fi

if ! kill -0 $SSH_AGENT_PID &> /dev/null
then
	# the agent is not running, start it
	rm -f "$SSH_AUTH_SOCK" &> /dev/null
	rm -f "$ssh_pid_file" &> /dev/null
	>&2 echo "Starting SSH agent, since it's not running; this can take a moment"
	eval "$(ssh-agent -s -a "$SSH_AUTH_SOCK")"
	echo "$SSH_AGENT_PID" > "$ssh_pid_file"
	ssh-add -A 2>/dev/null

	>&2 echo "Started ssh-agent with '$SSH_AUTH_SOCK'"
else
  if [ -z "$_ECHO_PROFILE_COMMONS" ]; then
	  >&2 echo "Using shared ssh-agent on '$SSH_AUTH_SOCK' ($SSH_AGENT_PID)"
  fi
fi
export SSH_AGENT_PID
export SSH_AUTH_SOCK

### Automatic node stuff
find_nvm_root() {
  if [ -d "$HOME/.nvm/.git" ]; then
    echo 'found nvm'
    return 0
  else
    echo 'could not find nvm'
    return 1
  fi
}
if [ find_nvm_root ]
then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

  # Set Node.js version from .nvmrc in current directory
  nvm_auto_use() {
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version="$(cat "$nvmrc_path")"

      if [ "$node_version" != "$nvmrc_node_version" ]; then
        nvm use &> /dev/null
      fi
    else
      nvm use default &> /dev/null
    fi
  } &> /dev/null

  nvm_auto_use
else
  if [ -z "$_ECHO_PROFILE_COMMONS" ]; then
    echo 'Consider executing'
    echo '  brew install nvm'
  fi
fi
### End automatic node stuff
### Automatic Rust stuff
if ls ~/.cargo/ &> /dev/null; then
  . "$HOME/.cargo/env"
else
  if [ -z "$_ECHO_PROFILE_COMMONS" ]; then
    echo "Maybe install Rust"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  fi
fi
### End automatic Rust stuff
### Automatic path shenanigans
for PATH_SUFFIX in /home/linuxbrew/.linuxbrew/bin /usr/local/cuda-12.3/bin /usr/local/go/bin; do
  if ls $PATH_SUFFIX &> /dev/null; then
	  echo $PATH | grep $PATH_SUFFIX &> /dev/null || export PATH="$PATH:$PATH_SUFFIX"
  fi
done
for PATH_PREFIX in /home/linuxbrew/.linuxbrew/opt/python@3.10/bin; do
  if ls $PATH_PREFIX &> /dev/null; then
	  echo $PATH | grep $PATH_PREFIX &> /dev/null || export PATH="$PATH_PREFIX:$PATH"
  fi
done
### End automatic path shenanigans
### Automatic brew stuff
if ! brew help &> /dev/null; then
  if [ -z "$_ECHO_PROFILE_COMMONS" ]; then
    echo "Maybe install brew"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  fi
fi
### End automatic brew stuff
### Automatic update command
export DISTRO=`grep ^NAME= /etc/os-release | cut -d '"' -f2`
export DISTRO_PRETTY=`grep ^PRETTY_NAME= /etc/os-release | cut -d '"' -f2`
if [[ "$DISTRO" -eq "Ubuntu" ]]; then
  export _PACKAGE_MANAGER=apt
else
  echo "Not an Ubuntu; unsure how to update"
  export _PACKAGE_MANAGER=undefined
fi
alias update-all="sudo $_PACKAGE_MANAGER update && sudo $_PACKAGE_MANAGER upgrade -y && sudo $_PACKAGE_MANAGER dist-upgrade -y && sudo $_PACKAGE_MANAGER autoremove"
### End automatic update command

### exports
export EDITOR="vim"
export GPG_TTY=$(tty)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
export _ECHO_PROFILE_COMMONS='disabled'


### aliases
alias activate='if [ `command -v deactivate` ]; then deactivate; fi; ls ./venv/bin/activate &> /dev/null && . ./venv/bin/activate || echo No pythonic virtual environment found. Perhaps one of the following? && for dir in `find . -maxdepth 3 -type d -name "*venv*"`; do find $dir -maxdepth 2 -type f -name "activate"; done;'
alias unify-ssh-agent='SSH_AGENT_PID=$(cat "$HOME/.config/ssh-agent.pid")'
alias refresh-bash-profile='. ~/.bash_profile'
