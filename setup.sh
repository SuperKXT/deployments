#!/usr/bin/env bash

echo "-- FRONTEND --"
read -rp 'Github User [WiMetrix]:' frontend_user
frontend_user=${frontend_user:-WiMetrix}
while [ -z "${frontend_repo}" ]; do
	read -rp 'Github Repo:' frontend_repo
done
while [ -z "${frontend_token}" ]; do
	read -rp 'Access Token:' frontend_token
done

echo "-- BACKEND --"
read -rp 'Github User [WiMetrix]:' backend_user
frontend_user=${backend_user:-WiMetrix}
while [ -z "${backend_repo}" ]; do
	read -rp 'Github Repo:' backend_repo
done
while [ -z "${backend_token}" ]; do
	read -rp 'Access Token:' backend_token
done

echo 'Downloading NVM...'
# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
echo 'NVM Installed!'

echo 'Downloading Node...'
# istall node
nvm install lts/*
# enable corepack and pnpm
corepack enable
corepack prepare pnpm@latest --activate
echo 'Node Installed!'

# Install VS Code
echo 'Downloading VS Code...'
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -out code.deb
./code.deb
echo 'VS Code Installed!'

echo 'Download PM2...'
# install pm2 https://github.com/jessety/pm2-installer
wget https://github.com/jessety/pm2-installer/archive/main.zip
unzip main.zip
rm -f main.zip
cd pm2-installer-main || exit
npm run configure
npm run setup
cd .. || exit
rm -rf pm2-insaller-main
# Copy and run any additional command you are asked to run after running the above
echo 'PM2 Installed! And configured as a service'

# create directories
mkdir frontend
mkdir backend

echo 'Downloading Github Action Runner...'
# Download the action runner
curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-linux-x64-2.299.1.tar.gz
# Optional: Validate the hash
echo "147c14700c6cb997421b9a239c012197f11ea9854cd901ee88ead6fe73a72c74  runner.tar.gz" | shasum -a 256 -c
echo 'Action Runner Downloaded!'

echo 'Setting Up Frontend Runner...'
# Setup frontend action runner
cp -r ./runner.tar.gz ./frontend
tar xzf ./frontend/runner.tar.gz
rm -rf ./frontend/runner.tar.gz
cd frontend || exit
./config.sh --url https://github.com/"$frontend_user"/"$frontend_repo" --token "$frontend_token"
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
cd ..
echo 'Frontend Runner Started!'

echo 'Setting Up Backend Runner...'
# Setup backend action runner
cp -r ./runner.tar.gz ./backend
tar xzf ./backend/runner.tar.gz
rm -rf ./backend/runner.tar.gz
cd backend || exit
./config.sh --url https://github.com/"$backend_user"/"$backend_repo" --token "$backend_token"
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
cd ..
echo 'Backend Runner Started!'
