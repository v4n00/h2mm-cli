# Helldivers 2 Mod Manager CLI

Helldivers 2 Mod Manager CLI is a command line interface for managing Helldivers 2 mods. Since there is no Linux mod manager available and I like being a nerd by using CLI tools instead of GUIs, this project was born.

- [Helldivers 2 Mod Manager CLI](#helldivers-2-mod-manager-cli)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Available commands](#available-commands)
    - [Basic usage](#basic-usage)
      - [Install mod(s)](#install-mods)
      - [Uninstall a mod](#uninstall-a-mod)
      - [Enable/disable mods](#enabledisable-mods)
      - [List installed mods](#list-installed-mods)
  - [Compatibility](#compatibility)
  - [Advanced usage](#advanced-usage)
    - [Shortcuts](#shortcuts)
    - [Exporting and importing](#exporting-and-importing)
    - [Resetting all installed mods](#resetting-all-installed-mods)
    - [Database location and details](#database-location-and-details)
  - [Contributing](#contributing)
  - [Planned features](#planned-features)

## Installation

To install/update Helldivers 2 Mod Manager CLI run the following command in your terminal:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/install.sh)"
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
- `export` - Export installed mods to a zip file
- `import` - Import mods from a zip file
- `reset` - Reset all installed mods
- `help` - Display the help message

### Basic usage

#### Install mod(s)

```bash
h2mm install /path/to/mod.zip
h2mm install /path/to/mod/files
h2mm install /path/to/mod.zip /path/to/mod2.zip /path/to/mod/files
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

## Compatibility

The script is developed and tested on Arch Linux, but it should work on other Linux distributions as well. If you encounter any issues, please open an issue on the repository.

Status of platforms:

- Linux :white_check_mark:
- Steam Deck - untested (should work) :grey_question:
- WSL :white_check_mark:

> The script works on WSL, but you need to specify the path to the Helldivers 2 mods directory manually, to find your Windows partition head to `/mnt/` and from there go to your Helldivers 2 data directory, on a typical install it should be on `/mnt/c/Program\ Files\ \(x86\)/Steam/steamapps/common/Helldivers\ 2/data`. You also need to have `unzip` installed, which can be done by running `sudo apt install unzip`.

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
- [x] Install mods in batches
- [ ] Easier way to change mod presets
- [ ] Find a way to make use of `manifest.json` and simplify installing variants
- [x] [DEV] Change to `.tar.gz` for exporting and importing
- [x] [DEV] Provide fixes for breaking updates
- [x] [DEV] Optimize code - throw errors in 1 line
- [ ] [DEV] Import/export treat breaking changes
- [ ] [DEV] Rewrite some code to be more readable
