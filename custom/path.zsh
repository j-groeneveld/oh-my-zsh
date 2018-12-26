####################
## Front of PATH ##
####################

# Add ~/.local/bin to front
export PATH="~/.local/bin:$PATH";

# Add gettext
export PATH="/usr/local/opt/gettext/bin:$PATH"

####################
### Back of PATH ###
####################

# Add qt5
export PATH="$PATH:/usr/local/opt/qt5/bin"

# Add go
export PATH="$PATH:$GOPATH:$GOROOT/bin"

# Add correct python3 executable to path
export PATH="$PATH:/Users/jdg/Library/Python/3.7/bin"