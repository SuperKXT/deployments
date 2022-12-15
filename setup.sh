#!/usr/bin/env bash

BLUE='\e[34m'
GREEN='\e[32m'
GREY='\e[37m'
NC='\e[0m'

echo -e "\n${BLUE}-- FRONTEND --${NC}"
echo -e -n "${GREY}Github User [WiMetrixDev]:${NC} "
read -r frontend_user
frontend_user=${frontend_user:-WiMetrixDev}
while [ -z "${frontend_repo}" ]; do
	echo -e -n "${GREY}Github Repo:${NC} "
	read -r frontend_repo
done
while [ -z "${frontend_token}" ]; do
	echo -e -n "${GREY}Access Token:${NC} "
	read -r frontend_token
done

echo -e "\n${BLUE}-- BACKEND --${NC}"
echo -e -n "${GREY}Github User [WiMetrixDev]:${NC} "
read -r backend_user
backend_user=${backend_user:-WiMetrixDev}
while [ -z "${backend_repo}" ]; do
	echo -e -n "${GREY}Github Repo:${NC} "
	read -r backend_repo
done
while [ -z "${backend_token}" ]; do
	echo -e -n "${GREY}Access Token:${NC} "
	read -r backend_token
done

# install nvm
if ! git --version; then
	while ! git --version; do
		echo -e "\n${BLUE}Downloading Git...${NC}"
		sudo apt update
		sudo apt install git-all
		echo -e "${GREEN}Git Installed!${NC}"
	done
else
	echo -e "${GREEN}Git Already Installed!${NC}"
fi

# install nvm
if ! nvm --version; then
	while ! nvm --version; do
		echo -e "\n${BLUE}Downloading NVM...${NC}"
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
		echo -e "${GREEN}NVM Installed!${NC}"
		NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
		export NVM_DIR
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
	done
else
	echo -e "${GREEN}NVM Already Installed!${NC}"
fi

echo -e "\n${BLUE}Downloading Node...${NC}"
# istall node
nvm install lts/*
nvm alias default lts/*
nvm use default
# enable corepack and pnpm
corepack enable
corepack prepare pnpm@latest --activate
echo -e "${GREEN}Node Installed!${NC}"

if ! code --version; then
	# Install VS Code
	echo -e "\n${BLUE}Downloading VS Code...${NC}"
	wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -out code.deb
	./code.deb
	echo -e "${GREEN}VS Code Installed!${NC}"
else
	echo -e "${GREEN}VS Code Already Installed!${NC}"
fi

echo -e "\n${BLUE}Download PM2...${NC}"
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
echo -e "${GREEN}PM2 Installed! And configured as a service${NC}"

# create directories
mkdir frontend
mkdir backend

if ! test -f "runner.tar.gz"; then
	# Download the action runner
	echo -e "\n${BLUE}Downloading Github Action Runner...${NC}"
	curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-linux-x64-2.299.1.tar.gz
	# Optional: Validate the hash
	echo "147c14700c6cb997421b9a239c012197f11ea9854cd901ee88ead6fe73a72c74  runner.tar.gz" | shasum -a 256 -c
	echo -e "${GREEN}Action Runner Downloaded!${NC}"
else
	echo -e "${GREEN}Action Runner Already Downloaded!${NC}"
fi

echo -e "\n${BLUE}Setting Up Frontend Runner...${NC}"
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
echo -e "${GREEN}Frontend Runner Started!${NC}"

echo -e "\n${BLUE}Setting Up Backend Runner...${NC}"
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
echo -e "${GREEN}Backend Runner Started!${NC}\n"
