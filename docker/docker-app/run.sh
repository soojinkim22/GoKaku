#!/bin/bash -eu
function command_exists {
  command -v "$1" > /dev/null;
}

NPM_VERSION="$(npm --version)"
if [[ "$NPM_VERSION" < 5 ]]; then
  echo "upgrade npm..."
  npm install -g npm@5
fi

if [ -e /app/node_modules ]; then
  echo "Installed node module."
else
  echo "Installing node modules..."
  cp /app/package.json /tmp/.
  cd /tmp && npm install
  ln -s /tmp/node_modules /app/.
fi

cd /app && npm start
