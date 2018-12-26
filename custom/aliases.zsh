# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias h="history"

# List all files colorized in long format
alias l="ls -lF ${colorflag}"

# List all files colorized in long format, including dot files
alias ll="ls -laF ${colorflag}"

### Docker
alias dq='docker rm -f $(docker ps -aq)'
alias de="docker exec -it"
alias dc="docker-compose"
alias da="docker ps -a"
alias dp="docker ps -aq"
alias dll='docker logs $(docker ps -lq)'
alias drm="docker rm "

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

# OMZ
alias reset="src"

# PIP
alias pip="python3 -m pip "