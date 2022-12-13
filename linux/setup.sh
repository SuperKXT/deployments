#!/usr/bin/env bash

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

# istall node
nvm install lts/*

# enable corepack and pnpm
corepack enable
corepack prepare pnpm@latest --activate

# create directories
mkdir deployment
cd deployment || exit
mkdir frontend
mkdir backend

# install pm2 https://github.com/jessety/pm2-installer
wget https://github.com/jessety/pm2-installer/archive/main.zip
unzip main.zip
rm -f main.zip
cd pm2-installer-main || exit
npm run configure
npm run configure-policy
npm run setup
cd .. || exit
rm -rf pm2-insaller-main
# Copy and run any additional command you are asked to run after running the above
