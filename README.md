# Patchouli

[![License](https://img.shields.io/badge/LICENSE-MIT-8A2BE2?style=for-the-badge&logo=open-source-initiative&logoColor=8A2BE2&labelColor=000000&color=8A2BE2&border=1px_solid_#333333)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/SHELL-POSIX-89E051?style=for-the-badge&logo=terminal&logoColor=89E051&labelColor=000000&color=89E051&border=1px_solid_#333333)](https://pubs.opengroup.org/onlinepubs/9699919799/utilitiesZ2.html)

A universal diff and patch tool that works across different version control systems with consistent output formatting and automatic VCS detection.

## Features

- **Streamlined Interface**: Single command for both standard and VCS-based operations.
- **VCS Support**: Git and Mercurial integration with automatic detection .
- **Interactive Mode**: Flag to confirm actions before execution.
- **Modular Design**: The modular design makes it easy to add support for any VCS with minimal shell script knowledge.

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
# Show general help
patchouli help

# Show command-specific help
patchouli help diff
patchouli help patch

# Show version
patchouli --version

# Diff two files (standard diff)
patchouli diff old_file new_file -o output.patch
patchouli diff file1 file2 -- -u  # Pass through standard diff options

# Apply a patch (standard patch)
patchouli patch changes.patch
patchouli patch changes.patch -i  # Interactive mode
```

### VCS Integration
```bash
# Create VCS diff (auto-detects Git/Mercurial)
patchouli diff -o changes.patch          # Current changes
patchouli diff -n 3 -o changes.patch     # Last 3 commits/changesets
patchouli diff -s HEAD~2 -o changes.patch # Since specific reference

# Apply patch using VCS
patchouli patch changes.patch            # Standard apply
patchouli patch changes.patch -i         # Interactive (Git only)
patchouli patch changes.patch -3         # 3-way merge (Git only)
patchouli patch changes.patch -f         # Force apply (Mercurial only)
```

### Advanced Options
```bash
# Custom output file
patchouli diff -o custom.patch
patchouli diff --output custom.patch

# Number of changes (VCS)
patchouli diff --num 5 -o changes.patch

# Since specific reference (commit/rev)
patchouli diff --since v1.0 -o changes.patch

# Pass through native VCS options
patchouli diff -- --unified=5  # Git/Mercurial specific options
```

### Configuration
```bash
# Customize colors (edit config/colors.conf)
# Set default options (edit config/defaults.conf)
```
## Issues
If you find an issue, please let me know via:

- [Sourcehut TODO](https://todo.sr.ht/~snoooooooope/Spaceman)
- [GitHub Pull Request](https://github.com/snoooooooope/patchouli/pulls)

## Contributing

Contributions are welcome from everyone! Here's how you can help:

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

## License

Patchouli is MIT licensed.
