{ pkgs, lib, user, ... }: {

  home.stateVersion        = "25.05";
  programs.home-manager.enable = true;

  # ── PACKAGES (common to both systems) ────────────────────────────────────
  home.packages = with pkgs; [
    # ── File navigation ───────────────────────────────────────────────────
    yazi              # file manager TUI
    eza               # better ls
    fd                # better find
    dust           # disk usage visualiser (binary: dust)
    ncdu              # disk usage TUI

    # ── Search & filter ───────────────────────────────────────────────────
    fzf
    ripgrep
    skim              # sk — second fuzzy finder (used in pdf alias)

    # ── Text & data ───────────────────────────────────────────────────────
    bat               # better cat
    jq                # JSON processor

    # ── Development ───────────────────────────────────────────────────────
    git
    git-lfs
    lazygit
    typst
    tinymist          # typst LSP

    # ── System monitoring ─────────────────────────────────────────────────
    btop

    # ── Network ───────────────────────────────────────────────────────────
    wget
    nmap

    # ── Media ─────────────────────────────────────────────────────────────
    spotify-player

    # ── Documents ─────────────────────────────────────────────────────────

    # ── Build tooling ─────────────────────────────────────────────────────
    cmake
    ninja

    # ── Productivity ──────────────────────────────────────────────────────
    fastfetch
    pay-respects
    watchexec
    pandoc

    # ── Python tooling ────────────────────────────────────────────────────
    # conda manages ML envs separately at /opt/miniconda3
    uv                # fast Python package/project manager
    pipx              # isolated CLI tool installer

    # ── JVM ───────────────────────────────────────────────────────────────
    # SDKMAN manages per-project Java versions; jdk21 is the global default
    jdk21
    maven

    # ── Languages ─────────────────────────────────────────────────────────
    zig

    # ── Misc ──────────────────────────────────────────────────────────────
    tesseract         # OCR
    sl                # important productivity tool 🚂
    mc                # midnight commander

  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # ── Linux: fonts (on macOS these are in hosts/hades.nix fonts.packages)
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    newcomputermodern

    # ── Linux: GUI apps (comment out if you prefer to keep these as snaps)
    discord
    thunderbird

    # ── Linux: ghostty (on macOS it's a Homebrew cask)
    ghostty
  ];


  # ── ZSH ──────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;

    # ── .zshenv — sourced for ALL shell instances (interactive + non) ──────
    envExtra = ''
      # Cargo / Rust (managed externally via rustup)
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

      # Local user bins
      export PATH="$HOME/.local/bin:$PATH"
    '';

    # ── .zprofile — login shells only ─────────────────────────────────────
    profileExtra = ''
      # opencode self-managed binary (Linux path; on macOS brew puts it in PATH)
      export PATH="$HOME/.opencode/bin:$PATH"
    '';

    # ── .zshrc — interactive shell ─────────────────────────────────────────
    initContent = ''
      # ── Prompt ─────────────────────────────────────────────────────────
      PS1="%F{#eed49f}%n%f@%m: %F{#7dc4e4}%1~%f$ "

      # ── NVM (managed externally) ───────────────────────────────────────
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ]          && . "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

      # ── Conda (managed externally at /opt/miniconda3) ──────────────────
      __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
      if [ $? -eq 0 ]; then
        eval "$__conda_setup"
      else
        [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ] \
          && . "/opt/miniconda3/etc/profile.d/conda.sh" \
          || export PATH="/opt/miniconda3/bin:$PATH"
      fi
      unset __conda_setup
      conda deactivate >/dev/null 2>&1 || true

      # ── SDKMAN (managed externally) ────────────────────────────────────
      export SDKMAN_DIR="$HOME/.sdkman"
      [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] \
        && source "$SDKMAN_DIR/bin/sdkman-init.sh"

      # ── cd then ls ─────────────────────────────────────────────────────
      function cdl() { builtin cd "$@" && ls; }

      # ── RISC-V helpers ─────────────────────────────────────────────────
      # Tools: riscv64-linux-gnu-{as,ld,gcc} + qemu-riscv64
      # Linux: sudo apt install gcc-riscv64-linux-gnu qemu-user
      # macOS: brew install riscv64-elf-binutils qemu (adjust prefixes)
      alias rvrun='qemu-riscv64'
      rvasmrun() {
        local f="$1" out="''${2:-''${1%.*}}"
        riscv64-linux-gnu-as  "$f"    -o "$out.o" &&
        riscv64-linux-gnu-ld  "$out.o" -o "$out"  &&
        qemu-riscv64 "./$out"
      }
      rvgccrun() {
        local f="$1" out="''${2:-''${1%.*}}"
        riscv64-linux-gnu-gcc -O0 -g -static "$f" -o "$out" &&
        qemu-riscv64 "./$out"
      }
      rvhelp() { cat <<'RISCVEOF'
RISC-V helpers
  rvrun   <elf>            run a RISC-V ELF with QEMU user-mode
  rvasmrun <file.s> [out]  assemble + link + run (requires _start)
  rvgccrun <file.c> [out]  compile static + run
RISCVEOF
      }
    '';

    shellAliases = {
      # ── Git ──────────────────────────────────────────────────────────────
      g   = "git";
      gs  = "git status";
      ga  = "git add";
      gaa = "git add .";
      gc  = "git commit -m";
      gp  = "git push";
      gf  = "git fetch";
      gpu = "git pull";
      gb  = "git branch";
      gch = "git checkout";
      gl  = "git log --oneline --graph --decorate";
      gd  = "git diff";
      lg  = "lazygit";

      # ── Navigation ────────────────────────────────────────────────────────
      ".."  = "cd ..";
      grep  = "grep --color=auto";
      c     = "clear";
      ex    = "exit";

      # ── eza (ls replacement) ──────────────────────────────────────────────
      la = "eza -ha";
      ls = "eza -h";
      ll = "eza -hlS";

      # ── Documents ─────────────────────────────────────────────────────────
      fz  = "fzf";

      # ── Conda ─────────────────────────────────────────────────────────────
      cond = "conda deactivate";
      cona = "conda activate";

      # ── Tmux ──────────────────────────────────────────────────────────────
      tm   = "tmux";
      tma  = "tmux attach";
      tmk  = "tmux kill-session";
      tml  = "tmux ls";
      tmka = "tmux kill-session -a";

      # ── Apps & tools ──────────────────────────────────────────────────────
      oc      = "opencode";
      tc      = "typst compile";
      tw      = "typst watch";
      p       = "python3";
      rs      = "source ~/.zshrc";
      y       = "yazi";
      vi      = "nvim";
      spotify = "spotify_player";

      # ── Docker ────────────────────────────────────────────────────────────
      d   = "docker";
      dc  = "docker compose";
      dcu = "docker compose up";
      dcd = "docker compose down";
      dr  = "docker run";
      dpu = "docker pull";
      dps = "docker ps -a";
    };

    sessionVariables = {
      TERM   = "xterm-256color";
      EDITOR = "nvim";
    };
  };


  # ── GIT ──────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user.name = "frheg";
      user.email = "fredric.hegland@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };


  # ── TMUX ─────────────────────────────────────────────────────────────────
  # TPM is replaced by home-manager's native plugin management.
  # Plugins are sourced automatically — no `run tpm` needed.
  programs.tmux = {
    enable       = true;
    prefix       = "C-a";
    escapeTime   = 10;
    historyLimit = 200000;
    mouse        = true;
    keyMode      = "vi";
    baseIndex    = 1;
    terminal     = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      resurrect          # save/restore sessions
      continuum          # auto-save sessions
      battery            # #{battery_percentage}
      cpu                # #{cpu_percentage} #{ram_percentage} #{gpu_percentage}
      yank               # system clipboard in copy mode
      {
        plugin      = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor              "mocha"
          set -g @catppuccin_window_status_style "rounded"
        '';
      }
    ];

    extraConfig = ''
      setw -g pane-base-index 1

      # ── Unbind conflicting defaults ────────────────────────────────────
      unbind '"'
      unbind %
      unbind o
      unbind v
      unbind s

      # ── Pane: create ──────────────────────────────────────────────────
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      # ── Pane: navigate (vim keys) ─────────────────────────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind Tab last-pane

      # ── Pane: resize ──────────────────────────────────────────────────
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ── Pane: zoom ────────────────────────────────────────────────────
      bind z resize-pane -Z

      # ── Windows ───────────────────────────────────────────────────────
      bind c new-window   -c "#{pane_current_path}"
      bind x kill-window
      bind n next-window
      bind p previous-window
      bind b last-window
      bind w choose-tree -Zw
      bind 1 select-window -t 1
      bind 2 select-window -t 2
      bind 3 select-window -t 3
      bind 4 select-window -t 4
      bind 5 select-window -t 5
      bind 6 select-window -t 6
      bind 7 select-window -t 7
      bind 8 select-window -t 8
      bind 9 select-window -t 9

      # ── Sessions ──────────────────────────────────────────────────────
      bind d detach
      bind S choose-tree -Zs

      # ── Reload config ─────────────────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # ── Popups ────────────────────────────────────────────────────────
      unbind t
      bind t display-popup -E -w 90% -h 90% "btop"

      bind m run-shell 'tmux has-session -t spotify 2>/dev/null || tmux new-session -d -s spotify spotify_player; tmux display-popup -E "tmux attach -t spotify"'

      # ── Status bar ────────────────────────────────────────────────────
      set  -g status on
      set  -g status-position     bottom
      set  -g status-interval     3
      set  -g status-left-length  80
      set  -g status-right-length 180
      set  -g status-justify      left
      set  -g status-style        "bg=#1e1e2e,fg=#cdd6f4"

      # Left: session + window + pane + current command
      set -g status-left '#[fg=#11111b,bg=#cba6f7] #S #[fg=#cdd6f4,bg=#313244] #I:#W.#P #{pane_current_command} '

      setw -g window-status-format         '#[fg=#cdd6f4,bg=#313244] #I:#W '
      setw -g window-status-current-format '#[fg=#11111b,bg=#cba6f7] #I:#W '
      setw -g window-status-separator      ""

      # Right: git branch + CPU + RAM (+ GPU/VRAM on Linux only)
      set  -g status-right ""
      set -ag status-right '#[fg=#11111b,bg=#a6e3a1]#(b=$(git -C "#{pane_current_path}" branch --show-current 2>/dev/null); [ -n "$b" ] && printf " git:%s " "$b")'
      set -ag status-right '#[fg=#11111b,bg=#89b4fa] CPU #{cpu_percentage} '
      set -ag status-right '#[fg=#11111b,bg=#94e2d5] RAM #{ram_percentage} '
      ${lib.optionalString pkgs.stdenv.isLinux ''
        set -ag status-right '#[fg=#11111b,bg=#fab387] GPU #{gpu_percentage} '
        set -ag status-right '#[fg=#11111b,bg=#f38ba8] VRAM #{gram_percentage} '
      ''}
    '';
  };


  # ── NEOVIM ───────────────────────────────────────────────────────────────
  # Bare functional config — full setup to follow separately.
  programs.neovim = {
    withRuby = true;
    withPython3 = true;
    enable        = true;
    defaultEditor = true;
    initLua = ''
      -- ── Options ────────────────────────────────────────────────────────
      vim.opt.number         = true
      vim.opt.relativenumber = true
      vim.opt.expandtab      = true
      vim.opt.tabstop        = 2
      vim.opt.shiftwidth     = 2
      vim.opt.scrolloff      = 8
      vim.opt.signcolumn     = "yes"
      vim.opt.wrap           = false
      vim.opt.ignorecase     = true
      vim.opt.smartcase      = true
      vim.opt.splitright     = true
      vim.opt.splitbelow     = true
      vim.opt.termguicolors  = true
      vim.opt.clipboard      = "unnamedplus"
      vim.opt.undofile       = true

      -- ── Leader key ─────────────────────────────────────────────────────
      vim.g.mapleader      = " "
      vim.g.maplocalleader = " "

      -- ── Basic keymaps ──────────────────────────────────────────────────
      local map = vim.keymap.set
      map("n", "<Esc>",   "<cmd>nohlsearch<CR>")
      map("n", "<C-h>",   "<C-w>h")
      map("n", "<C-j>",   "<C-w>j")
      map("n", "<C-k>",   "<C-w>k")
      map("n", "<C-l>",   "<C-w>l")
      map("n", "[d",      vim.diagnostic.goto_prev)
      map("n", "]d",      vim.diagnostic.goto_next)
    '';
  };


  # ── GHOSTTY CONFIG ───────────────────────────────────────────────────────
  # macos-* options are conditionally added; Ghostty ignores them on Linux
  # but we explicitly guard them to keep the config clean.
  home.file.".config/ghostty/config".text = ''
    theme = catppuccin-mocha

    font-size               = 15
    font-family             = Iosevka NFM
    font-family-bold        = Iosevka NFM Bold
    font-family-italic      = Iosevka NFM Italic
    font-family-bold-italic = Iosevka NFM Bold Italic

    alpha-blending          = linear-corrected
    background-opacity      = 1.0
    mouse-hide-while-typing = true
    keybind                 = super+r=reload_config
    cursor-text             = 000000

    ${lib.optionalString pkgs.stdenv.isDarwin ''
      macos-titlebar-style = hidden
      macos-option-as-alt  = false
    ''}
  '';

  # ── Ghostty themes ────────────────────────────────────────────────────────
  home.file.".config/ghostty/themes/catppuccin-mocha".text = ''
    background           = 1e1e2e
    foreground           = cdd6f4
    cursor-color         = f5e0dc
    selection-background = 313244
    selection-foreground = cdd6f4
    palette = 0=#45475a
    palette = 1=#f38ba8
    palette = 2=#a6e3a1
    palette = 3=#f9e2af
    palette = 4=#89b4fa
    palette = 5=#f5c2e7
    palette = 6=#94e2d5
    palette = 7=#bac2de
    palette = 8=#585b70
    palette = 9=#f38ba8
    palette = 10=#a6e3a1
    palette = 11=#f9e2af
    palette = 12=#89b4fa
    palette = 13=#f5c2e7
    palette = 14=#94e2d5
    palette = 15=#a6adc8
  '';

  home.file.".config/ghostty/themes/catppuccin-macchiato".text = ''
    background           = 24273a
    foreground           = cad3f5
    cursor-color         = f4dbd6
    selection-background = 363a4f
    selection-foreground = cad3f5
    palette = 0=#494d64
    palette = 1=#ed8796
    palette = 2=#a6da95
    palette = 3=#eed49f
    palette = 4=#8aadf4
    palette = 5=#f5bde6
    palette = 6=#8bd5ca
    palette = 7=#b8c0e0
    palette = 8=#5b6078
    palette = 9=#ed8796
    palette = 10=#a6da95
    palette = 11=#eed49f
    palette = 12=#8aadf4
    palette = 13=#f5bde6
    palette = 14=#8bd5ca
    palette = 15=#a5adcb
  '';

  home.file.".config/ghostty/themes/catppuccin-latte".text = ''
    background           = eff1f5
    foreground           = 4c4f69
    cursor-color         = dc8a78
    selection-background = acb0be
    selection-foreground = 4c4f69
    palette = 0=#5c5f77
    palette = 1=#d20f39
    palette = 2=#40a02b
    palette = 3=#df8e1d
    palette = 4=#1e66f5
    palette = 5=#ea76cb
    palette = 6=#179299
    palette = 7=#acb0be
    palette = 8=#6c6f85
    palette = 9=#d20f39
    palette = 10=#40a02b
    palette = 11=#df8e1d
    palette = 12=#1e66f5
    palette = 13=#ea76cb
    palette = 14=#179299
    palette = 15=#bcc0cc
  '';
}
