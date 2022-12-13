# Windows Deployments With Github Actions

- Get the frontend and backend runner
  - Go to `github.com/{user}/{repo}/settings/actions/runners/new`
  - Copy the token from the end of first command in the Configure section ![image](../images/token.png)
- Open an elevated powershell terminal
- Run the script
- When prompted provide the frontend and backend config
- Add the appropriate tags to the runner (`production` or `qa`)
- Start both runners as a windows service
