if [ ! -x `which n` ]; then
  manage install visionmedia/n
fi

if [ ! -x `which node` ]; then
  n latest
fi

# Install useful deps

# utility
npm install -g poe
npm install -g prettyjson
npm install -g tldr

# node
npm install -g nd
npm install -g tern
npm install -g webpack
npm install -g yarn

# server
npm install -g serve
npm install -g startup

# testing
npm install -g mocha

# typescript
npm install -g tslint
npm install -g typescript
npm install -g typescript-formatter
