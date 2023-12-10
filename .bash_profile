# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
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
# else
# 	>&2 echo "ssh-agent on '$SSH_AUTH_SOCK' ($SSH_AGENT_PID)"
fi
export SSH_AGENT_PID
export SSH_AUTH_SOCK

### Automatic node stuff
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
      nvm use
    fi
  else
    nvm use default
  fi
}

nvm_auto_use

### End automatic node stuff

export EDITOR="vim"
export GPG_TTY=$(tty)

for PATH_INCLUSION in /home/linuxbrew/.linuxbrew/bin/ /usr/local/cuda-12.3/bin/; do
	echo $PATH | grep $PATH_INCLUSION 1>/dev/null || export PATH="$PATH:$PATH_INCLUSION"
done

PATH="/home/linuxbrew/.linuxbrew/opt/python@3.10/bin:$PATH"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

alias activate='if [ `command -v deactivate` ]; then deactivate; fi; ls ./venv/bin/activate 1>/dev/null 2>/dev/null && . ./venv/bin/activate || echo No pythonic virtual environment found. Perhaps one of the following? && for dir in `find . -maxdepth 3 -type d -name "*venv*"`; do find $dir -maxdepth 2 -type f -name "activate"; done;'
alias update-all='sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove'
alias unify-ssh-agent='SSH_AGENT_PID=$(cat "$HOME/.config/ssh-agent.pid")'
alias refresh-bash-profile='. ~/.bash_profile'

. "$HOME/.cargo/env"
