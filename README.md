# Deployment scripts and instructions

Scripts to deploy frontend and backend projects to self-hosted servers via
github actions on Windows or Linux

## Details

- Installs git
- `(Linux only)` Installs nvm
- Installs Node.js `(with nvm on Linux)`
- Enables corepack and updates pnpm
- Installs VS Code
- Install Postman
- Installs and sets up pm2 as as service with
  [`pm2-installer`](https://github.com/jessety/pm2-installer)
- Sets up Github Action Runners for frontend and backend as a service

---

❗️The Windows script does not use WinGet because some servers are not up to date
and do not have WinGet

---

## Deployment

Open:

- Linux: `Bash`
- Window: `Elevated PowerShell`

Download the repository

```bash
git clone https://github.com/SuperKXT/deployments
```

Get a Personal Access Token for the account where the repositories exist.
The token must have `repo` access.

Run the script

- Windows (run in an elevated powershell terminal)

```powershell
./setup.ps1
```

- Linux

```bash
chmod u+x ./setup.sh
./setup.sh
```

Add the appropriate tags to the runner (`dev`, `qa`, or `production`)

When prompted provide the frontend and backend user and repo name

If on Windows, Start both runners as a windows service

---
Check out the automated scripts here for more information:
<https://github.com/actions/runner/blob/main/docs/automate.md>
