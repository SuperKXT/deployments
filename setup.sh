#!/usr/bin/env bash

BLUE='\e[34m'
GREEN='\e[32m'
GREY='\e[37m'
NC='\e[0m'

while ! git --version; do
	echo -e "\n${BLUE}Downloading Git...${NC}"
	sudo apt update
	sudo apt install git-all
done
echo -e "${GREEN}Git Installed!${NC}"

while ! nvm --version; do
	echo -e "\n${BLUE}Downloading NVM...${NC}"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
	NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	export NVM_DIR
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
done
echo -e "${GREEN}NVM Installed!${NC}"

echo -e "\n${BLUE}Downloading Node...${NC}"
nvm install lts/*
nvm alias default lts/*
nvm use default
corepack enable
corepack prepare pnpm@latest --activate
echo -e "${GREEN}Node Installed!${NC}"

while ! code --version &>/dev/null; do
	echo -e "\n${BLUE}Downloading VS Code...${NC}"
	wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O code.deb
	sudo dpkg -i ./code.deb
	echo -e "${GREEN}VS Code Installed!${NC}"
done

if ! test -f "pm2-install-main"; then
	echo -e "\n${BLUE}Download PM2...${NC}"
	wget https://github.com/jessety/pm2-installer/archive/main.zip
	unzip main.zip
	rm -f main.zip
fi
cd pm2-installer-main || exit
npm run configure
npm run setup
cd .. || exit
rm -rf ./pm2-insaller-main
echo -e "${GREEN}PM2 Installed! And configured as a service${NC}"

echo -e "\n${BLUE}-- RUNNER SETUP --${NC}"
echo -e -n "${GREY}Github Personal Access Token:${NC} "
read -r token
export RUNNER_CFG_PAT="$token"
echo -e -n "${GREY}Please enter the tag to add to the runners [qa, production, dev]:${NC} "
read -r label

echo -e "\n${BLUE}-- FRONTEND --${NC}"
echo -e -n "${GREY}Github User [WiMetrixDev]:${NC} "
read -r frontend_user
frontend_user=${frontend_user:-WiMetrixDev}
while [ -z "${frontend_repo}" ]; do
	echo -e -n "${GREY}Github Repo:${NC} "
	read -r frontend_repo
done

echo -e "\n${BLUE}-- BACKEND --${NC}"
echo -e -n "${GREY}Github User [WiMetrixDev]:${NC} "
read -r backend_user
backend_user=${backend_user:-WiMetrixDev}
while [ -z "${backend_repo}" ]; do
	echo -e -n "${GREY}Github Repo:${NC} "
	read -r backend_repo
done

echo -e "\n${BLUE}Setting Up Frontend Runner...${NC}"
mkdir frontend
cd frontend || exit
curl -s https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s -- -s "$frontend_user"/"$frontend_repo" -l "$label" -n frontend-"$label"
cd ..
echo -e "${GREEN}Frontend Runner Started!${NC}"

echo -e "\n${BLUE}Setting Up Backend Runner...${NC}"
mkdir backend
cd backend || exit
curl -s https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s -- -s "$backend_user"/"$backend_repo" -l "$label" -n backend-"$label"
cd ..
echo -e "${GREEN}Backend Runner Started!${NC}\n"
