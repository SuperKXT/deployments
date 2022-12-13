# Set correct permission in powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

$frontend_token = READ-HOST -Prompt "Access Token For The Frontend:"
$backend_token = READ-HOST -Prompt "Access Token For The Backend:"

# Install node
Write-Host 'Downloading Node js'
Invoke-WebRequest 'https://nodejs.org/dist/v18.12.1/node-v18.12.1-x86.msi' -OutFile node.msi
Start-Process .\node.msi -Wait
rm .\node.msi
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
corepack enable
corepack prepare pnpm@latest --activate
Write-Host 'Node Installed!'

# Install Git
Write-Host 'Downloading the git for windows installer'
Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe' -OutFile git.exe
Start-Process .\git.exe -Wait
rm .\git.exe
Write-Host 'Git Installed!'

# Install VS Code
Write-Host 'Downloading Visual Studio Code'
Invoke-WebRequest 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64' -OutFile code.exe
Start-Process .\code.exe -Wait
$env:Path += ';C:\Program Files\Git\bin\;C:\Program Files\Git\cnd\'
rm .\code.exe
Write-Host 'VS Code Installed!'

# Create directories
mkdir deployment
Set-Location deployment
mkdir frontend
mkdir backend
Set-Location ..

# Install PM2 https://github.com/jessety/pm2-installer
Write-Host 'Downloading PM2'
Invoke-WebRequest 'https://github.com/jessety/pm2-installer/archive/main.zip' -OutFile pm2.zip
Expand-Archive pm2.zip .\
rm pm2.zip
Set-Location pm2-installer-main
npm run configure
npm run configure-policy
npm run setup
$env:PM2_HOME='C:\ProgramData\pm2\home'
# Copy and run any additional command you are asked to run after running the above
Set-Location ..
rmdir pm2-installer-main
Write-Host 'PM2 Installed! And configured as a service'
