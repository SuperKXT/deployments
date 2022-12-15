# Deployment scripts and instructions

Scripts to deploy frontend and backend projects to self-hosted servers via github actions on Windows or Linux

## Details

- `(Linux only)` Install nvm
- Installs Node.js `(with nvm on Linux)`
- Enables corepack and updates pnpm
- `(Windows only)` Installs git
- Install VS Code
- Installs and sets up pm2 as as service with [`pm2-installer`](https://github.com/jessety/pm2-installer)
- Sets up Github Action Runners for frontend and backend as a service

---

❗️The Windows script does not use WinGet because some servers are not up to date and do not have WinGet

---

## Deployment

Open:

- Linux: `Bash`
- Window: `Elevated PowerShell`

Download the repository

```bash
git clone https://github.com/SuperKXT/deployments
```

Get the frontend and backend runner tokens

- Go to `github.com/{user}/{repo}/settings/actions/runners/new`
- Copy the token from the end of first command in the Configure section ![image](./images/token.png)

Run the script

- Windows

```powershell
./setup.ps1
```

- Linux

```bash
./setup.sh
```

When prompted provide the frontend and backend config

Add the appropriate tags to the runner (`production` or `qa`)

If on Windows, Start both runners as a windows service
