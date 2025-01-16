# Helldivers 2 Mod Manager CLI

- [Helldivers 2 Mod Manager CLI](#helldivers-2-mod-manager-cli)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Available commands](#available-commands)
    - [Basic usage](#basic-usage)
      - [Install a mod](#install-a-mod)
      - [Uninstall a mod](#uninstall-a-mod)
      - [Enable/disable mods](#enabledisable-mods)
      - [List installed mods](#list-installed-mods)
  - [Advanced usage](#advanced-usage)
    - [Shortcuts](#shortcuts)
    - [Exporting and importing](#exporting-and-importing)
    - [Resetting all installed mods](#resetting-all-installed-mods)
    - [Database location and details](#database-location-and-details)
  - [Contributing](#contributing)
  - [Planned features](#planned-features)

Helldivers 2 Mod Manager CLI is a command line interface for managing Helldivers 2 mods. Since there is no mod manager GUI for Helldivers 2 on Linux yet, this small script aims to provide a simple way to manage mods on Linux.

## Installation

To install/update Helldivers 2 Mod Manager CLI run the following command in your terminal:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/install.sh)"
```

Running this script will require sudo permissions. **DO NOT TRUST** random scripts from the internet. If you want to review the script before running it, check out the mod repository for yourself.

## Usage

The script gets added to `/usr/local/bin/h2mm` and can be used by running `h2mm` in your shell, which will show the help message explaining how to use the script.

```bash
h2mm
```

### Available commands

- `install` - Install a mod with files
- `uninstall` - Uninstall a mod by name
- `list` - List all installed mods
- `enable` - Enable a mod by name
- `disable` - Disable a mod by name
- `export <zip_name>` - Export installed mods to a zip file
- `import <zip_name>` - Import mods from a zip file
- `reset` - Reset all installed mods
- `help` - Display the help message

### Basic usage

#### Install a mod

```bash
h2mm install /path/to/mod.zip
h2mm install /path/to/mod/files
h2mm install -n "Example mod" mod.patch_0 mod.patch_0.stream # -n is mandatory when using files
h2mm install -n "Example mod" mod* # using a wildcard to include all files
```

> Currently, if the mod has more than 1 variant, you need to install the one you want by unarchiving it separately.

#### Uninstall a mod

```bash
h2mm uninstall "Example mod"
h2mm uninstall -i 1 # uninstall mod with index 1
```


#### Enable/disable mods

```bash
h2mm enable "Example mod"
h2mm enable -i 1 # enable mod with index 1
h2mm disable "Example mod"
h2mm disable -i 1 # disable mod with index 1
```

#### List installed mods

```bash
h2mm list
```

## Advanced usage

### Shortcuts

You can use the short form of commands to save some time. The shortcuts are:

- `i` for `install`
- `u` for `uninstall`
- `e` for `enable`
- `d` for `disable`
- `l` for `list`
- `ex` for `export`
- `im` for `import`
- `r` for `reset`

### Exporting and importing

You can export all installed mods to a zip file and import mods from the same file. This can be useful for sharing mods with others or for backing up your mods. The zip file will be saved in the current directory.

```bash
h2mm export modpack1.zip
h2mm import modpack2.zip
```

### Resetting all installed mods

You can reset all installed mods by running the following command. This will remove all installed mods and the database, in case things go wild.

```bash
h2mm reset
```

### Database location and details

The database is stored in the `Helldivers 2` install directory, under the `data` folder with the name `mods.csv`, where the mods are also installed. The database is a simple CSV file which you can use to manually manage mods if needed, you can mostly use it to rename or reorder mods.

## Contributing

Feel free to contribute to this project by creating a pull request or opening an issue.

## Planned features

- [x] Check for mod updates
- [x] Enable/disable mods
- [ ] Install mods in batches
- [ ] Easier way to change mod presets
- [ ] Find a way to make use of `manifest.json` and simplify installing variants
- [x] [DEV] Change to `.tar.gz` for exporting and importing
- [x] [DEV] Provide fixes for breaking updates
- [ ] [DEV] Optimize code - throw errors in 1 line
- [ ] [DEV] Rewrite some code to be more readable
