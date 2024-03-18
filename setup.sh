#!/usr/bin/env bash

BLUE='\e[34m'
GREEN='\e[32m'
GREY='\e[37m'
NC='\e[0m'

while ! command -v unzip &>/dev/null; do
	echo -e "\n${BLUE}Installing unzip...${NC}"
	sudo apt update
	sudo apt -qq install -y unzip
done
echo -e "${GREEN}unzip Installed and enabled!${NC}"

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
done
sudo ufw enable
sudo ufw allow 4000:4010/tcp
sudo ufw allow 5000:5010/tcp
echo -e "${GREEN}UFW enabled and configured!${NC}"

while ! command -v git &>/dev/null; do
	echo -e "\n${BLUE}Installing Git...${NC}"
	sudo apt update
	sudo apt -qq install -y git-all
	git config core.longpaths true
	echo -e "${GREEN}Git Installed!${NC}"
done

while ! command -v curl &>/dev/null; do
	echo -e "\n${BLUE}Installing Curl...${NC}"
	sudo apt update
	sudo apt -qq install -y curl
	echo -e "${GREEN}Curl Installed!${NC}"
done

while ! command -v jq &>/dev/null; do
	echo -e "\n${BLUE}Installing Jq...${NC}"
	sudo apt update
	sudo apt -qq install -y jq
	echo -e "${GREEN}Jq Installed!${NC}"
done

while ! command -v nvm &>/dev/null; do
	sudo apt -qq uninstall -y node
	echo -e "\n${BLUE}Downloading NVM...${NC}"
	curl -o- --progress-bar https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
	NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	export NVM_DIR
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
	echo -e "${GREEN}NVM Installed!${NC}"
done

echo -e "\n${BLUE}Downloading Node...${NC}"
nvm install lts/*
nvm alias default lts/*
nvm use default
corepack enable
corepack prepare pnpm@latest --activate
echo -e "${GREEN}Node Installed!${NC}"

# install vs code
while ! command -v code &>/dev/null; do
	echo -e "\n${BLUE}Downloading VS Code...${NC}"
	wget -q --show-progress 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O code.deb
	sudo apt -qq install -y ./code.deb
	rm ./code.deb
	echo -e "${GREEN}VS Code Installed!${NC}"
done

#install postman
if ! command -v postman &>/dev/null; then
	echo -e "\n${BLUE}Downloading Postman...${NC}"
	curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh
	echo -e "${GREEN}Postman Installed!${NC}"
fi

# install azure data studio
if ! command -v azuredatastudio &>/dev/null; then
	echo -e "\n${BLUE}Installing Azure Data Studio...${NC}"
	wget -q --show-progress https://go.microsoft.com/fwlink/?linkid=2215528 -O ./azure.deb
	sudo apt -qq install -y ./azure.deb
	rm ./azure.deb
	echo -e "${GREEN}Azure Data Studio Installed!${NC}"
fi

# install pm2
if ! command -v pm2 &>/dev/null; then
	echo -e "\n${BLUE}Download PM2...${NC}"
	rm -rf ./pm2-insaller-main
	wget -q --show-progress https://github.com/jessety/pm2-installer/archive/main.zip -O main.zip
	unzip main.zip
	rm -f main.zip
	cd pm2-installer-main || exit
	npm run configure
	npm run setup
	cd .. || exit
	rm -rf ./pm2-insaller-main
	pm2 completion install
	echo -e "${GREEN}PM2 Installed! And configured as a service${NC}"
fi

# Copy node libs to usr/local/bin to enable use with sudo
node_version="$(node --version)"
for name in node npm pnpm yarn pm2; do
	sudo ln -sf "$NVM_DIR/versions/node/$node_version/bin/$name" "/usr/local/bin/$name"
done

echo -e "\n${BLUE}-- RUNNER SETUP --${NC}"
echo -e -n "${GREY}Github Personal Access Token:${NC} "
read -r token
export RUNNER_CFG_PAT="$token"

while :; do
	echo -e -n "${GREY}Please enter the name of the runner:${NC} "
	read -r name

	echo -e -n "${GREY}Please enter the tag to add to the runners [qa, production, dev]:${NC} "
	read -r label

	echo -e -n "${GREY}Github User [WiMetrixDev]:${NC} "
	read -r user
	user=${user:-WiMetrixDev}
	repo=''
	while [ -z "${repo}" ]; do
		echo -e -n "${GREY}Github Repo:${NC} "
		read -r repo
	done

	mkdir "$name"
	cd "$name" || exit
	curl --progress-bar https://raw.githubusercontent.com/actions/runner/main/scripts/create-latest-svc.sh | bash -s -- -s "$user" -l "$label" -n "$name"-"$label"
	cd ..
	echo -e "${GREEN}Runner Started!${NC}"

	echo -e "\n${GREY}Add Another Runner? ${NC}"
	read -p "Press Y for yes N for no: " -n 1 -r
	if [[ $REPLY =~ ^[Nn]$ ]]; then
		break
	fi
done
