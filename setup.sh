#!/usr/bin/env bash

BLUE='\e[34m'
GREEN='\e[32m'
GREY='\e[37m'
NC='\e[0m'

while ! command -v ssh &>/dev/null; do
	echo -e "\n${BLUE}Installing OpenSSH...${NC}"
	sudo apt update
	sudo apt -qq install -y openssh-server
	sudo systemctl enable ssh
	sudo systemctl start ssh
done
echo -e "${GREEN}OpenSSH Installed and enabled!${NC}"

while ! command -v -p /usr/sbin/ufw ufw &>/dev/null; do
	echo -e "\n${BLUE}Installing UFW...${NC}"
	sudo apt update
	sudo apt -qq install -y ufw
	sudo ufw enable
	sudo ufw allow OpenSSH
	sudo ufw allow http
	sudo ufw allow https
done
echo -e "${GREEN}UFW enabled and configured!${NC}"

while ! command -v git &>/dev/null; do
	echo -e "\n${BLUE}Installing Git...${NC}"
	sudo apt update
	sudo apt -qq install -y git-all
done
echo -e "${GREEN}Git Installed!${NC}"

while ! command -v curl &>/dev/null; do
	echo -e "\n${BLUE}Installing Curl...${NC}"
	sudo apt update
	sudo apt -qq install -y curl
done
echo -e "${GREEN}Curl Installed!${NC}"

while ! command -v jq &>/dev/null; do
	echo -e "\n${BLUE}Installing Jq...${NC}"
	sudo apt update
	sudo apt -qq install -y jq
done
echo -e "${GREEN}Jq Installed!${NC}"

while ! command -v nvm &>/dev/null; do
	sudo apt -qq uninstall -y node
	echo -e "\n${BLUE}Downloading NVM...${NC}"
	curl -o- --progress-bar https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
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

while ! command -v code &>/dev/null; do
	echo -e "\n${BLUE}Downloading VS Code...${NC}"
	wget -q --show-progress 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O code.deb
	sudo dpkg -i ./code.deb
	echo -e "${GREEN}VS Code Installed!${NC}"
done

if ! test -f "pm2-install-main"; then
	echo -e "\n${BLUE}Download PM2...${NC}"
	wget -q --show-progress https://github.com/jessety/pm2-installer/archive/main.zip -O main.zip
	unzip main.zip
	rm -f main.zip
fi
cd pm2-installer-main || exit
npm run configure
npm run setup
cd .. || exit
rm -rf ./pm2-insalle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r-main
echo -e "${GREEN}PM2 Installed! And configured as a service${NC}"

# Copy node libs to usr/local/bin to enable use with sudo
node_version="$(node --version)"
for name in node npm pnpm yarn pm2; do
	sudo ln -s "$NVM_DIR/versions/node/$node_version/bin/$name" "/usr/local/bin/$name"
done

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
curl --progress-bar https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s -- -s "$frontend_user"/"$frontend_repo" -l "$label" -n frontend-"$label"
cd ..
echo -e "${GREEN}Frontend Runner Started!${NC}"

echo -e "\n${BLUE}Setting Up Backend Runner...${NC}"
mkdir backend
cd backend || exit
curl --progress-bar https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s -- -s "$backend_user"/"$backend_repo" -l "$label" -n backend-"$label"
cd ..
echo -e "${GREEN}Backend Runner Started!${NC}\n"
