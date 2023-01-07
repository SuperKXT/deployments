#!/usr/bin/env bash

BLUE='\e[34m'
GREEN='\e[32m'
GREY='\e[37m'
NC='\e[0m'

while ! gh --version; do
	type -p curl >/dev/null || sudo apt install curl -y
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
		sudo apt update &&
		sudo apt install gh -y
done
echo -e "${GREEN}GH CLI Installed!${NC}"

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

mkdir frontend
mkdir backend

if ! test -f "runner/runner.tar.gz"; then
	echo -e "\n${BLUE}Downloading Github Action Runner...${NC}"
	rm -rf ./runner
	mkdir runner
	cd runner || exit
	git init
	git remote add origin https://github.com/actions/runner
	gh release download -p "*linux-x64-([0-9.]+).tar.gz" -O runner.tar.gz
	tar xzf ./runner.tar.gz
	rm ./runner.tar.gz
	cd ..
	cp -r ./runner/* ./frontend
	cp -r ./runner/* ./backend
	rm -rf ./runner
	echo -e "${GREEN}Action Runner Downloaded!${NC}"
else
	echo -e "${GREEN}Action Runner Already Downloaded!${NC}"
fi

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

echo -e "\n${BLUE}Setting Up Frontend Runner...${NC}"
# Setup frontend action runner
cd frontend || exit
./config.sh --url https://github.com/"$frontend_user"/"$frontend_repo" --token "$frontend_token"
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
cd ..
echo -e "${GREEN}Frontend Runner Started!${NC}"

echo -e "\n${BLUE}Setting Up Backend Runner...${NC}"
# Setup backend action runner
cd backend || exit
./config.sh --url https://github.com/"$backend_user"/"$backend_repo" --token "$backend_token"
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
cd ..
echo -e "${GREEN}Backend Runner Started!${NC}\n"
