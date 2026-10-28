# Jacob Krevat Dotfiles

My dotfiles, managed by GNU Stow.

## Fresh Machine Setup

Follow these steps to set up a new Mac with these dotfiles.

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Core Dependencies

```bash
# Shell and terminal tools
brew install stow git neovim tree-sitter-cli tmux

# Modern CLI replacements
brew install fzf zoxide bat lsd ripgrep delta

# Development tools
brew install jq

# Shell enhancements
brew install zsh-syntax-highlighting

# Optional but recommended
brew install git-delta k9s terraform go node mysql redis colima docker
```

### 3. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 4. Install Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 5. Install Node Version Manager (nvm)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### 6. Install Python Version Manager (pyenv)

```bash
brew install pyenv
```

### 7. Install Tmux Plugin Manager (tpm)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 8. Clone and Deploy Dotfiles

```bash
cd ~
git clone <YOUR_DOTFILES_REPO_URL> dotfiles
cd dotfiles
stow .
```

This will create symlinks from the dotfiles repository to your home directory.

### 9. Install Tmux Plugins

Start tmux and press `prefix + I` (default prefix is `Ctrl+b`, then `Shift+i`) to install tmux plugins.

### 10. Configure Powerlevel10k

```bash
p10k configure
```

Follow the interactive prompts to customize your prompt appearance.

## Machine-Specific Configuration

After deploying dotfiles, create these files manually (they are git-ignored for security).

`~/.zshrc` and `~/.gitconfig` are intentionally plain local files rather than symlinks. Installers that append to them write to the local copy instead of this repo. The shared config lives in `.config/zsh/zshrc.shared` and `.config/git/config`.

### Shell Entry Point

```bash
echo 'source ~/.config/zsh/zshrc.shared' > ~/.zshrc
```

### Git Configuration

`~/.gitconfig` must exist so that `git config --global` writes there instead of into the shared `~/.config/git/config`:

```bash
touch ~/.gitconfig
cat > ~/.gitconfig-local << EOF
[user]
    name = YOUR_NAME
    email = YOUR_EMAIL@example.com
EOF
```

### Machine-Specific Neovim Plugins

Lazy.nvim specs in `.config/nvim/lua/work/` are loaded only if that directory exists. It is git-ignored, so use it for plugins that should not be shared across machines.

### Custom Shell Configuration

Create `~/custom.sh` for machine-specific environment variables and aliases:

```bash
touch ~/custom.sh
chmod +x ~/custom.sh
```

This file is sourced by `zshrc.shared` and is not tracked in git.

### Go Configuration (Optional)

If using private Go modules, add to `~/custom.sh`:

```bash
export GOPRIVATE=github.com/YOUR_ORGANIZATION
```

Then create `~/.netrc`:

```bash
cat > ~/.netrc << EOF
machine github.com
login YOUR_GITHUB_USERNAME
password YOUR_GITHUB_TOKEN
EOF
chmod 600 ~/.netrc
```

### AWS Configuration (Optional)

AWS credentials are managed through `~/.aws/` directory. Configure using:

```bash
aws configure sso
```

## Neovim Setup

Neovim plugins will auto-install on first launch via Lazy.nvim. See `.config/nvim/README.md` for more details.

Treesitter parsers are compiled locally by `nvim-treesitter`, which needs `tree-sitter-cli` (installed above, not from npm) and a C compiler. The configured parsers install in the background on first launch, and parsers for other languages install the first time a file of that type is opened.

## Updating Dotfiles

To pull and apply updates from the repository:

```bash
cd ~/dotfiles
git pull
stow -R .  # Restow to update symlinks
```

## Uninstalling

To remove all symlinks:

```bash
cd ~/dotfiles
stow -D .
```
