# Deploying applications with an SSH Deployment Key

[Follow this article for a full explanation on generating SSH Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

The commands below can be run in `git bash` or `powershell`.

## Generate an SSH Key

1. Run the following command. Replace `"your_email@example.com"` with an actual address.
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
2. When prompted for file name, enter an appropriate file name like below. 
Replace `Administrator` with the user, and `backend` with a descriptive name.
```bash
/c/Users/Administrator/.ssh/backend
```
3. Leave the passphrase empty

## Add the generated key to SSH config

1. Go to the ssh folder via command-line or via the file explorer.
```bash
cd /c/Users/Administrator/.ssh
```
2. Create a file called `config` if it doesn't exist.
3. Open the `config` file
4. Pase the following at the end of the file. Replace `backend` with the actual value.

```ruby
Host backend
   HostName github.com
   IdentityFile C:\Users\Administrator\.ssh\backend
   IdentitiesOnly yes
```
## Add the generated public key to the repo

1. Open and copy the contents of the public key file. The path should be something like the following
```bash
/c/Users/Administrator/.ssh/backend.pub
```
2. Go to your repo on github.
3. Click on Settings
4. Click on `Deploy keys` in `Security` section
5. Click on `Add deploy key` button
6. Give your key a name and copy the contents of the `.pub` file in the `Key` textarea.

> If you do not see the `Deploy keys` option, send the public key to someone with admin access to the repo to add it.

## Clone the repo using the ssh key

1. Open a command line in the folder where you want to clone the repo.
2. Run the following command replacing `backend`, `GithubUser`, and `GithubRepo` for actual values.
```bash
git clone git@backend:GithubUser/GithubRepo
```

> You now have read-only access to the repo and can run `git pull` in the created folder to get the changes.
