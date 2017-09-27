#!/bin/bash -eu
function command_exists {
  command -v "$1" > /dev/null;
}

if ! command_exists pm2 ; then
  echo "installing pm2..."
  npm install -g pm2
fi

if [ -e /app/node_modules ]; then
  echo "Installed node module."
else
  echo "Installing node modules..."
  cp /app/package.json /tmp/.
  cd /tmp && npm install
  ln -s /tmp/node_modules /app/.
fi

cd /app && npm run dev
