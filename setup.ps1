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

#Install gh
While ($true) {
	Try {
		$null = gh --version
		if (-not $retrying) {
			Write-Host "GH CLI is already installed." -ForegroundColor Green
		}
		break
	}
	Catch [System.Management.Automation.CommandNotFoundException] {
		if ($retrying) {
			Throw "GH CLI is not installed, and installation on demand failed."
		}
		Write-Host "`nDownloading GH CLI For Windows.." -ForegroundColor Blue

		Write-Host "GH CLI Installed!" -ForegroundColor Green
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

# Create directories
New-Item frontend
New-Item backend

Write-Host "`nDownloading Github Action Runner..." -ForegroundColor Blue
# Download the action runner
Remove-Item -Recurse -Path runner
New-Item runner
Set-Location runner
git init
git remote add origin https://github.com/actions/runner
gh release download -p "*win-x64-[0-9].[0-9][0-9][0-9].[0-9].zip" -O runner.zip
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/runner.zip", "$PWD")
Remove-Item -Path runner.zip
Set-Location ..
Copy-Item -Recurse runner/* frontend/
Copy-Item -Recurse runner/* backend/
Remove-item -Recurse -Path runner
Write-Host "Action Runner Downloaded!" -ForegroundColor Green

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
While ([string]::IsNullOrWhiteSpace($frontend_token)) {
	Write-Host "Access Token: " -ForegroundColor Gray -NoNewline
	$frontend_token = Read-Host
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
While ([string]::IsNullOrWhiteSpace($backend_token)) {
	Write-Host "Access Token: " -ForegroundColor Gray -NoNewline
	$backend_token = Read-Host
}

Write-Host "`nSetting Up Frontend Runner..." -ForegroundColor Blue
Set-Location frontend
./config.cmd --url https://github.com/$frontend_user/$frontend_repo --token $frontend_token
Set-Location ..
Write-Host "Frontend Runner Started!" -ForegroundColor Green

rite-Host "`nSetting Up Backend Runner..." -ForegroundColor Blue
Set-Location backend
./config.cmd --url https://github.com/$backend_user/$backend_repo --token $backend_token
Set-Location ..
Write-Host "Backend Runner Started!" -ForegroundColor Green
