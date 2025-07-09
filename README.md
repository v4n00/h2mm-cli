# Helldivers 2 Mod Manager CLI

Helldivers 2 Mod Manager CLI is a command line interface for managing Helldivers 2 mods. Since there is no Linux mod manager available and I like being a nerd by using CLI tools instead of GUIs, this project was born.

## Installation

Pre-requisites:

- You must have the `unzip` package installed for `zip` archives;
- You might want to have the `unarchiver` package installed for `rar` and `7z` archives.

To install Helldivers 2 Mod Manager CLI run the following command in your terminal:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/install.sh)"
```

## Usage

The script gets added to `/usr/local/bin/h2mm` (or `$HOME/.local/bin` on Steam Deck) and can be used by running `h2mm` in your shell, which will show the help message explaining how to use the script.

```bash
h2mm
```

### Available commands

- `install` or `i` - Install a mod by the file provided (directory, zip, patch);
- `uninstall` or `u` - Uninstall a mod;
- `list` or `l` - List all installed mods;
- `enable` or `e` - Enable a mod;
- `disable` or `d` - Disable a mod;
- `rename` or `r` - Rename a mod;
- `order` or `o` - Change load order for a mod;
- `export` or `ex` - Export installed mods to a zip file;
- `import` or `im` - Import mods from a zip file;
- `modpack-create` or `mc` - Create a modpack from the currently installed mods;
- `modpack-switch` or `ms` - Switch to a modpack;
- `modpack-list` or `ml` - List all installed modpacks;
- `modpack-delete` or `md` - Delete a modpack;
- `modpack-overwrite` or `mo` - Overwrite a modpack;
- `modpack-reset` or `mr` - Reset all installed modpacks;
- `nexus-setup` or `ns` - Setup Nexus Mods integration;
- `update` or `up` - Update h2mm to latest version;
- `reset` or `rs` - Reset all installed mods;
- `help` or `h` - Display this help message.

### Examples

To find out how to use a command, you can run `h2mm <COMMAND> --help`.

#### Install mod(s)

```bash
h2mm install mod.zip
h2mm install /path/to/mod/directory/
h2mm install /path/to/mod.zip /path/to/mod2.zip /path/to/mod/files # bulk install mods
h2mm install -n "Example mod" mod.patch_0 mod.patch_0.stream # -n to specify name of the mod
```

> It's better to be in the directory where the mod files are located, so you don't have to specify the full path everytime you're installing a mod. Open a terminal and type `cd ~/Downloads` (which will change the directory to your Downloads folder) and then run the install command with just the file names.
>
> Also, use the Tab key to autocomplete the file names, as it will help you escape special characters likes spaces or quotes.

#### List installed mods

```bash
h2mm list
h2mm list -v # verbose mode
```

#### Uninstall a mod

```bash
h2mm uninstall -n "Example mod"
h2mm uninstall -i 3 # by index (get the index from the list command)
```

#### Enable/disable mods

```bash
h2mm enable -n "Example mod"
h2mm enable -i 3
h2mm disable -n "Example mod"
h2mm disable -i 3
```

#### Updating the script

```bash
h2mm update
```

## Nexus Mods integration

Nexus Mods integration allows you to use the 1-click install feature of Nexus Mods (with the "Vortex" or "Mod manager download" buttons). You can set up Nexus Mods integration by running the following command:

```bash
h2mm nexus-setup
```

You will be walked through the setup process, which will ask you for your Nexus Mods API key and your preferred terminal.

## Contributing

Feel free to contribute to this project by creating a pull request or opening an issue.
