# Use your Forgejo server

Connect Tailscale before using Forgejo from the Mac. Keep sash powered on.

## Sign in

Open <https://sash.tail437275.ts.net:8443/> and sign in as `ash` with the
password supplied during setup. Open <https://sash.tail437275.ts.net:8443/ash/ash-sash>
to view the NixOS configuration repository.

## Check SSH access

Run this on either the Mac or sash:

```sh
ssh -T forgejo
```

Expect a greeting that says you authenticated as `ash`. Forgejo does not provide
shell access, so the message about shell access is normal. To open a Linux shell
on sash from the Mac, run `ssh sash` instead.

The aliases `forgejo` and `sash-git` select the same Git server and registered
key on each machine. SSH uses the username `git`; the web account and repository
owner are `ash`. The old Mac alias `forgejo` was renamed to `forgejo-arch`.

## Create a project

1. Sign in to Forgejo and open <https://sash.tail437275.ts.net:8443/repo/create>.
2. Choose owner `ash`, enter a name such as `my-project`, and keep it private.
3. For a new project, initialize it with a README and use `main` as the default branch.
4. Click **Create Repository**.
5. Clone it on the machine where you want to work:

```sh
git clone forgejo:ash/my-project.git
cd my-project
```

Edit the files, then commit and push:

```sh
git add .
git commit -m "Describe your change"
git push
```

On the other machine, clone the same URL or run `git pull --ff-only` inside an
existing clone before editing. Both machines use the same clone command.

## Upload an existing Git repository

Create an empty Forgejo repository with the same intended name. Leave README,
license, and gitignore initialization off so it has no competing first commit.

Inside your existing local repository:

```sh
git remote add forgejo forgejo:ash/my-project.git
git push forgejo HEAD
```

This keeps your existing `origin` and branch tracking. If `origin` is GitHub,
use these commands to publish a change to both servers:

```sh
git push origin HEAD
git push forgejo HEAD
```

The two remotes are separate copies. They do not mirror automatically.

## Clone the NixOS configuration

From the Mac:

```sh
git clone forgejo:ash/ash-sash.git
```

The existing configuration checkout on sash is `/home/ash/ash-sash`.
Do not clone over that directory. It already has `origin` for GitHub and
`forgejo` for the private server. Inspect them with `git remote -v`.

## Use clone URLs from the web interface

Select the SSH clone URL in Forgejo. URLs like this also work on both machines:

```sh
git clone ssh://git@sash.tail437275.ts.net:2222/ash/my-project.git
```

The hostname entry in each SSH config selects the registered key for these
full URLs. HTTPS Git authentication is separate from SSH key authentication.

## Inspect the service and backups

From the Mac:

```sh
ssh sash 'systemctl status forgejo --no-pager'
ssh sash 'systemctl list-timers forgejo-dump.timer --no-pager'
```

On sash:

```sh
journalctl -u forgejo -n 50 --no-pager
sudo ls -lh /var/lib/forgejo/dump
```

To make an extra backup immediately:

```sh
sudo systemctl start forgejo-dump
```

Copy backups off sash to protect against failure of its disk. For example,
choose an archive on sash, copy it into ash's home with permission restricted
to ash, then use `scp sash:ARCHIVE.zip .` on the Mac. Keep the archives private,
since they contain repository data and the runtime server configuration.

## Restore SSH configuration entries

The reference entries are in `ssh/mac.conf` and `ssh/sash.conf`. Merge the
appropriate entries into `~/.ssh/config`; preserve your other hosts. Existing
aliases with the same names must be updated instead of duplicated. Set the file
permission to `600`. The referenced private keys must remain on their own
machines, outside this repository.
