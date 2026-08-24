# Skills

A collection of reusable skills for software engineering, research, writing,
planning, and documentation workflows.

Each top-level directory is a self-contained skill with a `SKILL.md` file and,
where needed, supporting text resources or scripts.

The repository root is also an Amp directory plugin. Its minimal `index.ts`
entrypoint registers the existing skill directories in place, so the plugin and
the standalone collection share one copy of every skill. When installed in a
directory named `xdurana-skills`, Amp exposes the skills under qualified names
such as `xdurana-skills:code-review`.

## Install personally in Amp

Personal plugins are the persistent, user-wide scope: after they are published
to Amp's Personal Plugins repository, new threads and new orbs load them in every
project. Amp's URL installer only supports single-file plugins, so this directory
plugin is installed by mirroring this central repository into that repository
as a deployment snapshot.

First find the clone URL and whether your Personal Plugins repository already
exists:

```sh
amp plugins repositories
```

Use the canonical local checkout path:

```sh
personal_plugins="$HOME/.cache/amp/repositories/ampcode.com-user-plugins"
```

If `amp plugins repositories` says **exists**, clone it:

```sh
amp clone user-plugins "$personal_plugins"
```

If it says **no plugins yet**, initialize it instead. Replace `<clone-url>` with
the URL printed by `amp plugins repositories`:

```sh
personal_plugins_url="<clone-url>"
mkdir -p "$personal_plugins"
git -C "$personal_plugins" init -b main
git -C "$personal_plugins" config credential.helper '!amp git-credential-helper'
git -C "$personal_plugins" remote add origin "$personal_plugins_url"
git -C "$personal_plugins" commit --allow-empty -m "Initialize personal plugins"
```

Add this repository as the `xdurana-skills` directory plugin, then publish the
Personal Plugins repository:

```sh
source_checkout="$(mktemp -d)"
git clone --depth 1 https://github.com/xdurana/skills.git "$source_checkout"
mkdir -p "$personal_plugins/xdurana-skills"
git -C "$source_checkout" archive HEAD |
  tar -x -C "$personal_plugins/xdurana-skills"
rm -rf "$source_checkout"
git -C "$personal_plugins" add xdurana-skills
git -C "$personal_plugins" commit -m "Install xdurana skills"
git -C "$personal_plugins" push -u origin main
```

The push is the installation step that makes the plugin available to new Amp
threads and orbs. To pick it up in an already-running thread, ask Amp to reload
plugins; no restart is required. Verify discovery from a new shell or thread:

```sh
amp plugins list
amp skill info xdurana-skills:code-review
```

### Update an existing personal installation

This GitHub repository remains the only maintained source. The Personal Plugins
repository contains a deployment snapshot; do not edit its
`xdurana-skills/` directory directly. After changes land here, refresh and publish
that snapshot with:

```sh
source_checkout="$(mktemp -d)"
git clone --depth 1 https://github.com/xdurana/skills.git "$source_checkout"
rm -rf "$personal_plugins/xdurana-skills"
mkdir -p "$personal_plugins/xdurana-skills"
git -C "$source_checkout" archive HEAD |
  tar -x -C "$personal_plugins/xdurana-skills"
rm -rf "$source_checkout"
git -C "$personal_plugins" add --all xdurana-skills
git -C "$personal_plugins" commit -m "Update xdurana skills"
git -C "$personal_plugins" push origin main
```

New threads and orbs then receive the update automatically. Ask Amp to reload
plugins if the current thread also needs it. Reinstallation is only necessary if
the `xdurana-skills` snapshot was removed; in that case, repeat the installation
and push steps above.

## Updates

Configured sources are refreshed weekly by GitHub Actions. When changes are
available, the workflow opens or updates a pull request for review. It can also
be run manually from the repository's **Actions** tab. Merging one of those pull
requests updates this central repository; personal installations receive it after
the snapshot refresh and push steps above.
