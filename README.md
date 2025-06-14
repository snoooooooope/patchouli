# Patchouli
[![License](https://img.shields.io/badge/LICENSE-MIT-8A2BE2?style=for-the-badge&logo=open-source-initiative&logoColor=8A2BE2&labelColor=000000&color=8A2BE2&border=1px_solid_#333333)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/SHELL-POSIX-89E051?style=for-the-badge&logo=terminal&logoColor=89E051&labelColor=000000&color=89E051&border=1px_solid_#333333)](https://pubs.opengroup.org/onlinepubs/9699919799/utilitiesZ2.html)

A universal diff and patch tool that works across different version control systems with consistent output formatting and automatic VCS detection.
## Why Patchouli?
- **Consistent Output**: Uniform patch formatting across Git, Mercurial, and plain files.
- **VCS Agnostic**: Automatically detects your VCS or falls back to standard mode.
- **User-Friendly**: Simplified commands for common workflows.
### Quick Install (Recommended)
```bash
# Clone the repository
git clone https://git.cyno.space/ryan/patchouli.git
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
   git clone https://git.cyno.space/ryan/patchouli.git ~/scripts/patchouli
   ```
3. **Make the script executable**:
   ```bash
   chmod +x ~/scripts/patchouli/bin/patchouli.sh
   ```
4. **Add to PATH**:
   ```bash
   echo 'export PATH="$HOME/scripts/patchouli/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```
### Dependencies
Ensure you have the following installed:
- **Bash 4.0+** (for core functionality).
- **[Gum](https://github.com/charmbracelet/gum)** (because its yummy)
- **Core utilities**: `diff`, `patch`.
- **Optional VCS support**:
  - **Git 2.0+** (for Git integration).
  - **Mercurial 5.0+** (for Mercurial integration).
### Verify Installation
Run the following command to confirm `patchouli` is installed correctly:
```bash
patchouli --version
```
You should see the current version (`1.1.2` or later) printed to the terminal.
## Usage
### Basic Commands
```bash
# Show general help
patchouli help
# Show command-specific help
patchouli diff help
patchouli patch help
# Show version
patchouli --version
# Diff two files (standard diff)
patchouli diff old_file new_file -o output.patch
# Apply a patch (standard patch)
patchouli patch changes.patch
patchouli patch changes.patch -i  # Interactive mode
```
---
### VCS Integration
```bash
# Create VCS diff (auto-detects Git/Mercurial)
patchouli diff <file> -o changes.patch          # Current changes
patchouli diff -n 3 -o changes.patch     # Last 3 commits/changesets
patchouli diff -s HEAD~2 -o changes.patch # Since specific reference
# Apply patch using VCS
patchouli patch changes.patch            # Standard apply
patchouli patch changes.patch -i         # Interactive (Git only)
patchouli patch changes.patch -3         # 3-way merge (Git only)
patchouli patch changes.patch -f         # Force apply (Mercurial only)
```
---
## Troubleshooting
- **Error: "Patch failed"**: Ensure the patch file matches the target files. Use `-i` for interactive conflict resolution.
- **Permission issues**: Use `sudo` for global installation or ensure your `~/scripts` directory is in `PATH`.
---
## Community
- Report issues: [Cyno Issues](https://git.cyno.space/ryan/patchouli/issues) | [GitHub Issues](https://github.com/snoooooooope/patchouli/issues)
- Contribute: See [Contributing](#contributing) below.
---
## Contributing
1.  **Install Jujutsu**: Make sure you have [**Jujutsu**](https://github.com/jj-vcs/jj) installed on your system.

2.  **Clone the repository**: Clone the project using Jujutsu:
    ```bash
    jj git clone https://git.cyno.space/ryan/patchouli.git
    ```

3.  **Keep Up-to-Date**: Regularly update your local repository with the `main` branch before starting new work:
    ```bash
    jj git fetch
    jj rebase -r main
    ```
    
4.  **Start New Work**: Create a new commit to start your changes. This commit becomes your editable working copy:
    ```bash
    jj new @ main
    ```
    *Tip*: If you're fixing an existing commit, you can use `jj edit <commit_id>`. Jujutsu will automatically rebase descendants.

5.  **Make Your Changes**: Edit the code in your working directory. Jujutsu automatically tracks these changes in your current working-copy commit.

6.  **Describe Your Commit**: Once your changes form a single, logical unit, add a clear commit message:
    ```bash
    jj describe -m "Your commit message"
    ```
    
    **Commit Message Format**: Start with a topic (e.g., `cli: add new --foo option` or `docs: update quickstart guide`). Be concise and descriptive.
7.  **Create Atomic Commits**: If your work involves multiple distinct changes, use Jujutsu's tools to split them:
    * `jj split` (interactive splitting)
    * `jj fold` or `jj squash` (to combine commits)
    Each commit should represent a single, isolated, and logically complete change.

8.  **Include Tests & Docs**: New code should include corresponding tests. Update documentation as needed. Tests and documentation belong in the *same commit* as the code they relate to.

9.  **Review Locally**: Always review your changes before sending them for review:
    ```bash
    jj diff
    jj log
    ```
    
10. **Push to GitHub**: Push your bookmark to GitHub. Jujutsu will force-push, which is normal:
    ```bash
    jj git push --change @-
    ```

11. **Open a Pull Request (PR)**: On GitHub, create a PR from your bookmark to the `main` branch. Use the PR description for any context or discussion.

**Addressing Review Comments**:

* **Amend the Original Commit(s)**: Do not create new "fixup" commits on top of your existing ones. Instead, directly modify the commit(s) that need changes. Use `jj edit <commit_id>` to make a specific commit your working-copy commit. Make your changes and then `jj describe` it. Jujutsu will automatically rebase any descendant commits, keeping your history clean.
* **Force Push Again**: After amending your commits, push your bookmark to your fork again:
    ```bash
    jj git push --change @-
    ```
    This updates your existing PR on GitHub with the revised history.

## License
Patchouli is MIT licensed.
