# Set correct permission in powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

# Open Required ports in Firewall
New-NetFirewallRule -DisplayName 'App Ports (TCP)' -Profile 'Private' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3000-3010, 4000-4010, 5000-5010

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
		Write-Host "`nDownloading Git For Windows.." -ForegroundColor Cyan
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
		Write-Host "`nDownloading Node js..." -ForegroundColor Cyan
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
$retrying = $false
While ($true) {
	Try {
		$null = code --version
		if (-not $retrying ) {
			Write-Host "VS Code is already installed." -ForegroundColor Green
		}
		break
	}
	Catch [System.Management.Automation.CommandNotFoundException] {
		if ($retrying ) {
			Throw "VS Code is not installed, and installation on demand failed."
		}
		Write-Host "`nDownloading VS Code..." -ForegroundColor Cyan
		Invoke-WebRequest "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -OutFile code.exe
		Start-Process -Path code.exe -Wait
		Remove-Item -Path code.exe
		Write-Host "VS Code Installed!" -ForegroundColor Green
		$retrying = $true
	}
}


# Install Postman
$retrying = $false
While ($true) {
	Try {
		$null = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* |
		Where-Object { $_.DisplayName -eq "Postman" } |
		Select-Object -ExpandProperty DisplayVersion
		if (-not $retrying) {
			Write-Host "Postman is already installed." -ForegroundColor Green
		}
		break
	}
	Catch {
		if ($retrying) {
			Throw "Postman is not installed, and installation on demand failed."
		}
		Write-Host "`nDownloading Postman..." -ForegroundColor Cyan
		Invoke-WebRequest "https://dl.pstmn.io/download/latest/win64" -OutFile postman.exe
		Start-Process -Path postman.exe -Wait
		Remove-Item -Path postman.exe
		Write-Host "Postman Installed!" -ForegroundColor Green
		$retrying = $true
	}
}

# Install PM2 https://github.com/jessety/pm2-installer
$retrying = $false
While ($true) {
	Try {
		$null = pm2 --version
		if (-not $retrying) {
			Write-Host "PM2 is already installed." -ForegroundColor Green
		}
		break
	}
	Catch {
		if ($retrying) {
			Throw "PM2 is not installed, and installation on demand failed."
		}
		# Install PM2 if not already present
		Write-Host "`nDownloading PM2..."-ForegroundColor Cyan
		Invoke-WebRequest "https://github.com/jessety/pm2-installer/archive/main.zip" -OutFile pm2.zip
		Expand-Archive pm2.zip .\
		Remove-Item	-Path pm2.zip
		Set-Location pm2-installer-main
		npm run configure
		npm run configure-policy
		npm run setup
		$env:PM2_HOME = "C:\ProgramData\pm2\home"
		# Copy and run any additional command you are asked to run after running the above
		Set-Location ..
		Remove-Item	-Recurse	-Path pm2-installer-main
		Write-Host "PM2 Installed! And configured as a service"	-ForegroundColor Green
		$retrying = $true
	}
}

Write-Host "`nDownloading Github Action Runner..." -ForegroundColor Cyan
$response = Invoke-RestMethod "https://api.github.com/repos/actions/runner/releases/latest"
$latest_version_label = $response.tag_name
$latest_version = $latest_version_label.substring(1)
$runner_file = "actions-runner-win-x64-${latest_version}.zip"
If (-not (Test-Path $runner_file)) {
	$runner_url = "https://github.com/actions/runner/releases/download/${latest_version_label}/${runner_file}"
	Write-Host "Downloading $latest_version_label..." -ForegroundColor Cyan
	Write-Host $runner_url -ForegroundColor Cyan

	Invoke-WebRequest $runner_url -O $runner_file
}
Else {
	Write-Host "`n$($runner_file) exists. skipping download." -ForegroundColor Cyan
}
Write-Host "Action Runner Downloaded!" -ForegroundColor Green

Write-Host "Github Personal Access Token: "  -ForegroundColor Gray -NoNewline
$token = Read-Host

$title   = 'Add Another?'
$msg     = 'Do you want to setup another action runner?'
$options = '&Yes', '&No'
$default = 1  # 0=Yes, 1=No

do {
	Write-Host "`n-- RUNNER SETUP --" -ForegroundColor Cyan

	Write-Host "Enter the name for the runner: "  -ForegroundColor Gray -NoNewline
	$name = Read-Host

	Remove-Item -Recurse -Path $name
	New-Item -ItemType Directory $name
	Copy-Item ./$runner_file $name/
	Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/$name/$runner_file", "$PWD/$name")

	Write-Host "Please enter the tag to add to the runner [qa, production, dev]: "  -ForegroundColor Gray -NoNewline
	$label = Read-Host
	Write-Host "$token"

	Write-Host "Github User [WiMetrixDev]: " -ForegroundColor Gray -NoNewline
	$user = Read-Host
	If ([string]::IsNullOrWhiteSpace($user)) {
		$user = "WiMetrixDev"
	}
	While ([string]::IsNullOrWhiteSpace($repo)) {
		Write-Host "Github Repo: " -ForegroundColor Gray -NoNewline
		$repo = Read-Host
	}

	Write-Host "Generating a registration token..."
	$api_url = "https://api.github.com/repos/$user/$repo/actions/runners/registration-token"
	$response = Invoke-RestMethod -Method Post -Uri $api_url -Headers @{authorization = "token $token" }
	$token = $response.token
	if ($null -eq $token) {
		Write-Host "Failed to get a token"
		Exit-PSSession
	}
	Write-Host "$token"
	Set-Location $name
	.\config.cmd --unattended --url https://github.com/$user/$repo --token $token --name $name-$label --labels $label --work _work --runasservice
	Set-Location ..
	Write-Host "Runner Started!" -ForegroundColor Green

    $response = $Host.UI.PromptForChoice($title, $msg, $options, $default)
} until ($response -eq 1)
