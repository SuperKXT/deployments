#!/usr/bin/env bash

echo "Frontend Details:"

read -rp 'Github User For The Frontend [WiMetrix]:' frontend_user
frontend_user=${frontend_user:-WiMetrix}

while [ -z "${frontend_repo}" ]; do
	read -rp 'Github Repo For The Frontend:' frontend_repo
done

while [ -z "${frontend_token}" ]; do
	read -rp 'Access Token For The Frontend:' frontend_token
done

echo "Backend Details:"

read -rp 'Github User For The Backend [WiMetrix]:' backend_user
frontend_user=${backend_user:-WiMetrix}

while [ -z "${backend_repo}" ]; do
	read -rp 'Github Repo For The Backend:' backend_repo
done

while [ -z "${backend_token}" ]; do
	read -rp 'Access Token For The Backend:' backend_token
done

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

# istall node
nvm install lts/*

# enable corepack and pnpm
corepack enable
corepack prepare pnpm@latest --activate

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

# create directories
mkdir frontend
mkdir backend

# Download the action runner
curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-linux-x64-2.299.1.tar.gz
# Optional: Validate the hash
echo "147c14700c6cb997421b9a239c012197f11ea9854cd901ee88ead6fe73a72c74  runner.tar.gz" | shasum -a 256 -c

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
