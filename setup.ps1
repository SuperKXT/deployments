# Set correct permission in powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
[Net.ServicePointManager]::SecurityProtocol = 'Tls, Tls11, Tls12, Ssl3'

Write-Host '-- FRONTEND --'
$frontend_user = Read-Host -Prompt 'Github User [WiMetrix]:'
if ([string]::IsNullOrWhiteSpace($frontend_user)) {
	$frontend_user = 'WiMetrix'
}
While ([string]::IsNullOrWhiteSpace($frontend_repo)) {
	$frontend_repo = Read-Host -Prompt 'Github Repo:'
}
While ([string]::IsNullOrWhiteSpace($frontend_token)) {
	$frontend_token = Read-Host -Prompt 'Access Token:'
}

Write-Host '-- BACKEND --'
$backend_user = Read-Host -Prompt 'Github User [WiMetrix]:'
if ([string]::IsNullOrWhiteSpace($backend_user)) {
	$backend_user = 'WiMetrix'
}
While ([string]::IsNullOrWhiteSpace($backend_repo)) {
	$backend_repo = Read-Host -Prompt 'Github Repo:'
}
While ([string]::IsNullOrWhiteSpace($backend_token)) {
	$backend_token = Read-Host -Prompt 'Access Token:'
}

# Install node
Write-Host 'Downloading Node js...'
Invoke-WebRequest 'https://nodejs.org/dist/v18.12.1/node-v18.12.1-x86.msi' -OutFile node.msi
Start-Process .\node.msi -Wait
rm .\node.msi
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
corepack enable
corepack prepare pnpm@latest --activate
Write-Host 'Node Installed!'

# Install Git
Write-Host 'Downloading Git For Windows..'
Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe' -OutFile git.exe
Start-Process .\git.exe -Wait
rm .\git.exe
Write-Host 'Git Installed!'

# Install VS Code
Write-Host 'Downloading VS Code...'
Invoke-WebRequest 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64' -OutFile code.exe
Start-Process .\code.exe -Wait
$env:Path += ';C:\Program Files\Git\bin\;C:\Program Files\Git\cnd\'
rm .\code.exe
Write-Host 'VS Code Installed!'

# Install PM2 https://github.com/jessety/pm2-installer
Write-Host 'Downloading PM2...'
Invoke-WebRequest 'https://github.com/jessety/pm2-installer/archive/main.zip' -OutFile pm2.zip
Expand-Archive pm2.zip .\
rm pm2.zip
Set-Location pm2-installer-main
npm run configure
npm run configure-policy
npm run setup
$env:PM2_HOME = 'C:\ProgramData\pm2\home'
# Copy and run any additional command you are asked to run after running the above
Set-Location ..
rmdir pm2-installer-main
Write-Host 'PM2 Installed! And configured as a service'

# Create directories
mkdir frontend
mkdir backend

Write-Host 'Downloading Github Action Runner...'
# Download the action runner
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-win-x64-2.299.1.zip -OutFile runner.zip
# Optional: Validate the hash
if ((Get-FileHash -Path runner.zip -Algorithm SHA256).Hash.ToUpper() -ne 'f7940b16451d6352c38066005f3ee6688b53971fcc20e4726c7907b32bfdf539'.ToUpper()) { throw 'Computed checksum did not match' }
Write-Host 'Action Runner Downloaded!'

Write-Host 'Setting Up Frontend Runner...'
# Setup frontend action runner
Copy-Item ./runner.zip ./frontend/
Set-Location frontend
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/runner.zip", "$PWD")
Remove-Item ./runner.zip
# Extract the installer
./config.cmd --url https://github.com/$frontend_user/$frontend_repo --token $frontend_token
Set-Location ..
Write-Host 'Frontend Runner Started!'

Write-Host 'Setting Up Backend Runner...'
# Setup frontend action runner
Copy-Item ./runner.zip ./backend/
Set-Location backend
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/runner.zip", "$PWD")
Remove-Item ./runner.zip
# Extract the installer
./config.cmd --url https://github.com/$backend_user/$backend_repo --token $backend_token
Set-Location ..
Write-Host 'Backend Runner Started!'
