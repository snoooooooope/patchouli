# Patchouli

[![License: MIT](https://img.shields.io/badge/License-MIT-8A2BE2?style=for-the-badge&logo=open-source-initiative&logoColor=white)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

A universal diff and patch tool that works across different version control systems with consistent output formatting and automatic VCS detection.

## Features

- **Unified Interface**: Single command for both standard and VCS-based operations.
- **VCS Support**: Git and Mercurial integration with automatic detection.
- **Customizable**: Configurable color schemes, error handling, and defaults.
- **Interactive Mode**: Option to confirm actions before execution.
- **Modular Design**: Easy to extend with new VCS or command modules.

## Installation

### Quick Install (Recommended)
```bash
# Clone the repository
hg clone https://hg.sr.ht/~snoooooooope/patchouli  # Main repo (Mercurial)
git clone https://github.com/snoooooooope/patchouli.git  # Mirror (Git)

# Navigate to the project directory
cd patchouli

# Install globally with make
sudo make install  # Installs to /usr/local/bin
```

### Manual Installation
For manual installation, follow these steps to ensure the script is accessible system-wide:

1. **Create a scripts directory** (if it doesn't exist):
   ```bash
   mkdir -p ~/scripts
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/snoooooooope/patchouli.git ~/scripts/patchouli
   ```

3. **Symlink the main script**:
   ```bash
   ln -s ~/scripts/patchouli/bin/patchouli.sh /usr/local/bin/patchouli
   ```

4. **Make the script executable**:
   ```bash
   chmod +x /usr/local/bin/patchouli
   ```

### Dependencies
Ensure you have the following installed:
- **Bash 4.0+** (for core functionality).
- **Core utilities**: `diff`, `patch`.
- **Optional VCS support**:
  - **Git 2.0+** (for Git integration).
  - **Mercurial 5.0+** (for Mercurial integration).

### Verify Installation
Run the following command to confirm `patchouli` is installed correctly:
```bash
patchouli --version
```
You should see the current version (`1.0.0` or later) printed to the terminal.

## Usage

### Basic Commands
```bash
# Show help
patchouli help

# Diff two files
patchouli diff file1 file2 -o changes.patch

# Apply a patch
patchouli patch changes.patch
```

### VCS Integration
```bash
# Create diff of last 3 changes in current VCS
patchouli diff -n 3 -o changes.patch

# Create diff since specific reference (commit/rev)
patchouli diff -s HEAD~2 -o changes.patch

# Apply patch using VCS-specific method
patchouli patch changes.patch
```

### Advanced Options
```bash
# Interactive mode (confirm before applying)
patchouli patch changes.patch -i

# Force apply (Mercurial only)
patchouli patch changes.patch -f

# 3-way merge (Git only)
patchouli patch changes.patch -3
```

## Issues
If you find an issue, please let me know via:

- [Sourcehut TODO](https://todo.sr.ht/~snoooooooope/Spaceman)
- [GitHub Pull Request](https://github.com/snoooooooope/patchouli/pulls)

## Contributing

Contributions are welcome from everyone! Here's how you can help:

### Git Workflow
1. **Clone the repository**:
   ```bash
   git clone https://github.com/snoooooooope/patchouli.git
   ```
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature
   ```
3. **Commit your changes**:
   ```bash
   git commit -am 'Add some feature'
   ```
4. **Push to the branch**:
   ```bash
   git push origin feature/your-feature
   ```
5. **Open a pull request on GitHub**:
   - Navigate to the repository on GitHub.
   - Click "Compare & pull request" for your pushed branch.
   - Include a clear title and description of your changes.

### Mercurial (hg) Workflow for SourceHut
1. **Clone the repository**:
   ```bash
   hg clone https://hg.sr.ht/~snoooooooope/patchouli
   ```
2. **Create a bookmark for your feature**:
   ```bash
   hg bookmark feature/your-feature
   ```
3. **Commit your changes**:
   ```bash
   hg commit -m 'Add some feature'
   ```
4. **Push the bookmark to the remote repository**:
   ```bash
   hg push -B feature/your-feature
   ```
5. **Submit patches via email**:
   - Use `hg email` to send patches to the project's [mailing list](https://lists.sr.ht/~snoooooooope/patchouli).
   - Example:
     ```bash
     hg email --rev feature/your-feature --to ~snoooooooope/patchouli@lists.sr.ht
     ```
   - Include a clear subject prefix like `[PATCH lib/commands/diff.sh]`.

## License

Patchouli is MIT licensed.