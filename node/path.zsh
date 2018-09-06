export NP=$(which node)
export BP=${NP%bin/node} #this replaces the string '/bin/node'
export LP="${BP}lib/node_modules"
export NODE_PATH="$LP"
