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

The script gets added to `/usr/local/bin/h2mm` (or `$HOME/.local/bin` on Steam Deck) and can be used by running `h2mm` in your shell, which will print the help message along with all available commands.

```bash
h2mm --help
```

To find out how to use a command, you can run `h2mm COMMAND --help`. This is the most up-to-date source of information about the commands.

## Examples

```bash
h2mm install --help
h2mm install ~/Downloads/mod.zip
h2mm install ~/Downloads/mod\ files/
h2mm install a0b1c2d3.patch_0 a0b1c2d3.patch_0.stream -n "Example mod"
h2mm list
h2mm uninstall --index 3
h2mm modpack create "Example modpack"
h2mm modpack switch "Example modpack"
```

> When installing, it is recommended to be in the directory where mod archives are, or to use absolute paths. If you don't know how this works, use `cd ~/Downloads` to go to the Downloads folder, and then run `ls -la` to find the files you want to install. Use the Tab key to auto-complete file and folder names, this helps escape spaces and special characters.
>
> The `--index` flag can be used with commands that require a mod name, to use the mod index instead. You can find the mod index by running `h2mm list`.

## Nexus Mods integration

Nexus Mods integration allows you to use the 1-click install feature of Nexus Mods (with the "Vortex" or "Mod manager download" buttons). You can set up Nexus Mods integration by running `h2mm nexus-setup`. You will be walked through the setup process, which will ask you for your Nexus Mods API key and your preferred terminal.

## Contributing

Feel free to contribute to this project by creating a pull request or opening an issue.
