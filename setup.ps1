# Set correct permission in powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

# Install Git
$retrying = $false
While ($true) {
	Try {
		$null = git --version
		if (-not $retrying) {
			Write-Host "Git is already installed." -ForegroundColor Green
		}
		git config --system core.autocrlf input
		git config --system core.eol lf
		git config --system core.longpaths true
		break
	}
	Catch [System.Management.Automation.CommandNotFoundException] {
		if ($retrying) {
			Throw "Git is not installed, and installation on demand failed."
		}
		Write-Host "`nDownloading Git For Windows.." -ForegroundColor Blue
		Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe" -OutFile git.exe
		Start-Process -Path git.exe -Wait
		Remove-Item -Path git.exe
		$env:Path += ";C:\Program Files\Git\bin\;C:\Program Files\Git\cmd\"
		Write-Host "Git Installed!" -ForegroundColor Green
		$retrying = $true
	}
}

# Install node
$retrying = $false
While ($true) {
	Try {
		$null = node --version
		if (-not $retrying) {
			Write-Host "Node is already installed." -ForegroundColor Green
		}
		git config --system core.longpaths true
		break
	}
	Catch [System.Management.Automation.CommandNotFoundException] {
		if ($retrying) {
			Throw "Node is not installed, and installation on demand failed."
		}
		WWrite-Host "`nDownloading Node js..." -ForegroundColor Blue
		Invoke-WebRequest "https://nodejs.org/dist/v18.12.1/node-v18.12.1-x86.msi" -OutFile node.msi
		Start-Process -Path node.msi -Wait
		Remove-Item -Path node.msi
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
		corepack enable
		corepack prepare pnpm@latest --activate
		Write-Host "Node Installed!" -ForegroundColor Green
		$retrying = $true
	}
}


# Install VS Code
Write-Host "`nDownloading VS Code..." -ForegroundColor Blue
Invoke-WebRequest "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -OutFile code.exe
Start-Process -Path code.exe -Wait
Remove-Item -Path code.exe
Write-Host "VS Code Installed!" -ForegroundColor Green

# Install PM2 https://github.com/jessety/pm2-installer
Write-Host "`nDownloading PM2..." -ForegroundColor Blue
Invoke-WebRequest "https://github.com/jessety/pm2-installer/archive/main.zip" -OutFile pm2.zip
Expand-Archive pm2.zip .\
Remove-Item -Path pm2.zip
Set-Location pm2-installer-main
npm run configure
npm run configure-policy
npm run setup
$env:PM2_HOME = "C:\ProgramData\pm2\home"
# Copy and run any additional command you are asked to run after running the above
Set-Location ..
Remove-Item -Recurse -Path pm2-installer-main
Write-Host "PM2 Installed! And configured as a service" -ForegroundColor Green

Write-Host "`nDownloading Github Action Runner..." -ForegroundColor Blue
$response = Invoke-RestMethod "https://api.github.com/repos/actions/runner/releases/latest"
$latest_version_label = $response.tag_name
$latest_version = $latest_version_label.substring(1)
$runner_file = "actions-runner-win-x64-${latest_version}.zip"
If (-not (Test-Path $runner_file)) {
	$runner_url = "https://github.com/actions/runner/releases/download/${latest_version_label}/${runner_file}"
	Write-Host "Downloading $latest_version_label..." -ForegroundColor Blue
	Write-Host $runner_url -ForegroundColor Blue

	Invoke-WebRequest $runner_url -O $runner_file
}
Else {
	Write-Host "`n$($runner_file) exists. skipping download." -ForegroundColor Blue
}
Remove-Item -Recurse -Path frontend
Remove-Item -Recurse -Path backend
New-Item -ItemType Directory frontend
New-Item -ItemType Directory backend
Copy-Item ./$runner_file frontend/
Copy-Item ./$runner_file backend/
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/frontend/$runner_file", "$PWD/frontend")
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/backend/$runner_file", "$PWD/backend")
Write-Host "Action Runner Downloaded!" -ForegroundColor Green

Write-Host "`n-- RUNNER SETUP --" -ForegroundColor Blue
Write-Host "Github Personal Access Token: "  -ForegroundColor Gray -NoNewline
$token = Read-Host
Write-Host "Please enter the tag to add to the runners [qa, production, dev]: "  -ForegroundColor Gray -NoNewline
$label = Read-Host
Write-Host "$token"

Write-Host "`n-- FRONTEND --" -ForegroundColor Blue
Write-Host "Github User [WiMetrixDev]: " -ForegroundColor Gray -NoNewline
$frontend_user = Read-Host
If ([string]::IsNullOrWhiteSpace($frontend_user)) {
	$frontend_user = "WiMetrixDev"
}
While ([string]::IsNullOrWhiteSpace($frontend_repo)) {
	Write-Host "Github Repo: " -ForegroundColor Gray -NoNewline
	$frontend_repo = Read-Host
}

Write-Host "`n-- BACKEND --" -ForegroundColor Blue
Write-Host "Github User [WiMetrixDev]: " -ForegroundColor Gray -NoNewline
$backend_user = Read-Host
If ([string]::IsNullOrWhiteSpace($backend_user)) {
	$backend_user = "WiMetrixDev"
}
While ([string]::IsNullOrWhiteSpace($backend_repo)) {
	Write-Host "Github Repo: " -ForegroundColor Gray -NoNewline
	$backend_repo = Read-Host
}

Write-Host "`nSetting Up Frontend Runner..." -ForegroundColor Blue
Write-Host "Generating a registration token..."
$frontend_api_url = "https://api.github.com/repos/$frontend_user/$frontend_repo/actions/runners/registration-token"
$frontend_response = Invoke-RestMethod -Method Post -Uri $frontend_api_url -Headers @{authorization = "token $token" }
$frontend_token = $frontend_response.token
if ($null -eq $frontend_token) {
	Write-Host "Failed to get a token"
	Exit-PSSession
}
Write-Host "$frontend_token"
Set-Location frontend
.\config.cmd --unattended --url https://github.com/$frontend_user/$frontend_repo --token $token --name frontend-$label --labels $label --work _work
.\svc.ps1 install
.\svc.ps1 start
Set-Location ..
Write-Host "Frontend Runner Started!" -ForegroundColor Green

Write-Host "`nSetting Up Backend Runner..." -ForegroundColor Blue
Write-Host "Generating a registration token..."
$backend_api_url = "https://api.github.com/repos/$backend_user/$backend_repo/actions/runners/registration-token"
$backend_response = Invoke-RestMethod -Method Post -Uri $backend_api_url -Headers @{authorization = "token $token" }
$backend_token = $backend_response.token
if ($null -eq $backend_token) {
	Write-Host "Failed to get a token"
	Exit-PSSession
}
Set-Location backend
.\config.cmd --unattended --url https://github.com/$backend_user/$backend_repo --token $token --name backend-$label --labels $label --work _work
.\svc.ps1 install
.\svc.ps1 start
Set-Location ..
Write-Host "Backend Runner Started!" -ForegroundColor Green
