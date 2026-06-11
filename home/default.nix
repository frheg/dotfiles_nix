{ pkgs, lib, user, ... }: {

  home.stateVersion        = "25.05";
  programs.home-manager.enable = true;

  # ── PACKAGES (common to both systems) ────────────────────────────────────
  home.packages = with pkgs; [
    # ── File navigation ───────────────────────────────────────────────────
    yazi              # file manager TUI
    eza               # better ls
    fd                # better find
    dust              # disk usage visualiser (binary: dust)
    ncdu              # disk usage TUI
    tree              # visual listing of directories

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
    python3Packages.jupyterlab  # browser-based Python notebook/lab environment

    # ── JVM ───────────────────────────────────────────────────────────────
    # SDKMAN manages per-project Java versions; jdk21 is the global default
    jdk21
    maven

    # ── Languages ─────────────────────────────────────────────────────────
    zig

    # ── Neovim language servers / formatters ──────────────────────────────
    # Nix manages external editor tools. Neovim plugins call these binaries.
    nil                              # Nix language server
    nixfmt                           # Nix formatter
    lua-language-server              # Lua language server
    stylua                           # Lua formatter
    pyright                          # Python type-checking language server
    ruff                             # Python linter/formatter
    typescript-language-server       # TypeScript/JavaScript language server
    prettier                         # JS/TS/JSON/Markdown formatter
    marksman                         # Markdown language server
    taplo                            # TOML language server
    tree-sitter                      # Treesitter parser compiler
    clang-tools                      # C/C++ language server: clangd
    bash-language-server             # Bash language server
    dockerfile-language-server # Dockerfile language server
    vscode-langservers-extracted     # HTML/CSS/JSON/ESLint language servers
    yaml-language-server             # YAML language server

    # ── Misc ──────────────────────────────────────────────────────────────
    tesseract         # OCR
    sl                # important productivity tool 🚂
    mc                # midnight commander

  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # ── Linux: clipboard integration for Neovim/tmux/terminal ──────────────
    wl-clipboard                     # Wayland clipboard provider: wl-copy/wl-paste
    xclip                            # X11 clipboard fallback
    
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

      # ── Conda (managed externally) ─────────────────────────────────────
      for conda_root in "$HOME/anaconda3" "$HOME/miniconda3" "/opt/miniconda3"; do
        if [ -x "$conda_root/bin/conda" ]; then
          __conda_setup="$("$conda_root/bin/conda" shell.zsh hook 2>/dev/null)"
          if [ $? -eq 0 ]; then
            eval "$__conda_setup"
          elif [ -f "$conda_root/etc/profile.d/conda.sh" ]; then
            . "$conda_root/etc/profile.d/conda.sh"
          fi
          break
        fi
      done
      unset __conda_setup conda_root
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
      cdnix = "cd ~/.config/dotfiles_nix/";

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


  home.file.".config/tmux/scripts/mem-macos.sh" = {
    source = ../config/tmux/scripts/mem-macos.sh;
    executable = true;
  };

  home.file.".config/tmux/scripts/net-down.sh" = {
    source = ../config/tmux/scripts/net-down.sh;
    executable = true;
  };

  home.file.".config/tmux/scripts/net-up.sh" = {
    source = ../config/tmux/scripts/net-up.sh;
    executable = true;
  };

  home.file.".config/tmux/scripts/cpu-linux.sh" = {
    source = ../config/tmux/scripts/cpu-linux.sh;
    executable = true;
  };

  home.file.".config/tmux/scripts/net-linux.sh" = {
    source = ../config/tmux/scripts/net-linux.sh;
    executable = true;
  };

  home.file.".config/tmux/scripts/gpu-linux.sh" = {
    source = ../config/tmux/scripts/gpu-linux.sh;
    executable = true;
  };

  home.file.".config/tmux/scripts/vram-linux.sh" = {
    source = ../config/tmux/scripts/vram-linux.sh;
    executable = true;
  };

  # ── TMUX ─────────────────────────────────────────────────────────────────

  # Source of truth for tmux. Generated file:

  # ~/.config/tmux/tmux.conf
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
      resurrect
      continuum
      battery
      cpu
      yank
      net-speed
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
        '';
      }
    ];
    extraConfig = ''
      ##### QUALITY OF LIFE #####
      set -g set-clipboard on
      set -g allow-passthrough on
      set -g renumber-windows on
      setw -g pane-base-index 1

      ##### UNBIND DEFAULTS THAT CONFLICT #####
      unbind '"'
      unbind %
      unbind o

      ##### PANES: CREATE #####
      unbind v
      unbind s
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      ##### PANES: NAVIGATE #####
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind Tab last-pane

      ##### PANES: RESIZE #####
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      ##### PANES: ZOOM #####
      bind z resize-pane -Z

      ##### WINDOWS #####
      bind c new-window -c "#{pane_current_path}"
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

      ##### SESSIONS #####
      bind d detach
      bind S choose-tree -Zs

      ##### RELOAD CONFIG #####
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      ##### POPUPS #####
      unbind t
      bind t display-popup -E -w 90% -h 90% "btop"

      ##### SPOTIFY #####
      bind m run-shell 'tmux has-session -t spotify 2>/dev/null || tmux new-session -d -s spotify "/bin/zsh -lc spotify_player"; tmux display-popup -E "/bin/zsh -lc \"tmux attach -t spotify\""'

      ##################
      ### STATUS BAR ###
      ##################
      set -g status on
      set -g status-position top
      set -g status-interval 3
      set -g status-left-length 80
      set -g status-right-length 220
      set -g status-justify left
      set -g status-style "bg=default,fg=#6c7086"

      set -g status-left ""

      setw -g window-status-format         "#[fg=#6c7086] #I.#P:#W "
      setw -g window-status-current-format "#[fg=#cba6f7,bold] #I.#P:#W "
      setw -g window-status-separator      "#[fg=#313244,nobold]"

      set -g status-right ""

      ${lib.optionalString pkgs.stdenv.isDarwin ''
        set -ag status-right "#[fg=#89b4fa]cpu #[fg=#a6adc8]#(top -l 1 -s 0 | awk '/CPU usage/ {print $3}')#[fg=#45475a] | "
        set -ag status-right "#[fg=#94e2d5]ram #[fg=#a6adc8]#(~/.config/tmux/scripts/mem-macos.sh)#[fg=#45475a] | "
        set -ag status-right "#[fg=#b4befe]↓ #[fg=#a6adc8]#(~/.config/tmux/scripts/net-down.sh)#[fg=#45475a] | "
        set -ag status-right "#[fg=#f5c2e7]↑ #[fg=#a6adc8]#(~/.config/tmux/scripts/net-up.sh) "
      ''}

      ${lib.optionalString pkgs.stdenv.isLinux ''
        set -ag status-right "#[fg=#89b4fa]cpu #[fg=#a6adc8]#(~/.config/tmux/scripts/cpu-linux.sh)#[fg=#45475a] | "
        set -ag status-right "#[fg=#94e2d5]ram #[fg=#a6adc8]#(free -h | awk '/^Mem:/ {print $3\"/\"$2}')#[fg=#45475a] | "
        set -ag status-right "#[fg=#b4befe]↓ #[fg=#a6adc8]#(~/.config/tmux/scripts/net-linux.sh down)#[fg=#45475a] | "
        set -ag status-right "#[fg=#f5c2e7]↑ #[fg=#a6adc8]#(~/.config/tmux/scripts/net-linux.sh up)#[fg=#45475a] | "
        set -ag status-right "#[fg=#fab387]gpu #[fg=#a6adc8]#(~/.config/tmux/scripts/gpu-linux.sh)#[fg=#45475a] | "
        set -ag status-right "#[fg=#f38ba8]vram #[fg=#a6adc8]#(~/.config/tmux/scripts/vram-linux.sh) "
      ''}
    '';
  };

  # ── NEOVIM CONFIG FILES ──────────────────────────────────────────────────
  # Home Manager places these Lua files under ~/.config/nvim.
  # programs.neovim.initLua below is the generated entry point that requires them.

  # Core editor behavior: options, keymaps, and lazy.nvim bootstrap.
  home.file.".config/nvim/lua/core/options.lua".source = ../config/nvim/lua/core/options.lua;
  home.file.".config/nvim/lua/core/keymaps.lua".source = ../config/nvim/lua/core/keymaps.lua;
  home.file.".config/nvim/lua/core/lazy.lua".source = ../config/nvim/lua/core/lazy.lua;

  # Theme: Catppuccin colorscheme, transparency, and visual base styling.
  home.file.".config/nvim/lua/plugins/colorscheme.lua".source = ../config/nvim/lua/plugins/colorscheme.lua;

  # UI: lualine statusline and which-key keybinding discovery.
  home.file.".config/nvim/lua/plugins/ui.lua".source = ../config/nvim/lua/plugins/ui.lua;

  # Dashboard: custom Neovim start screen with shortcuts and plugin stats.
  home.file.".config/nvim/lua/plugins/dashboard.lua".source = ../config/nvim/lua/plugins/dashboard.lua; 

  # Fuzzy finding: Telescope file search, live grep, buffer list, and help search.
  home.file.".config/nvim/lua/plugins/telescope.lua".source = ../config/nvim/lua/plugins/telescope.lua;

  # Syntax parsing/highlighting: Treesitter parsers and highlighting.
  home.file.".config/nvim/lua/plugins/treesitter.lua".source = ../config/nvim/lua/plugins/treesitter.lua;

  # Git UI: gutter signs, blame, hunk preview/stage/reset, Fugitive, Diffview.
  home.file.".config/nvim/lua/plugins/git.lua".source = ../config/nvim/lua/plugins/git.lua;

  # Language intelligence: native Neovim LSP setup using Nix-managed servers.
  home.file.".config/nvim/lua/plugins/lsp.lua".source = ../config/nvim/lua/plugins/lsp.lua;

  # Formatting: conform.nvim maps filetypes to Nix-managed formatters.
  home.file.".config/nvim/lua/plugins/format.lua".source = ../config/nvim/lua/plugins/format.lua;

  # Navigation: yazi.nvim file explorer and flash.nvim fast jump motions.
  home.file.".config/nvim/lua/plugins/navigation.lua".source = ../config/nvim/lua/plugins/navigation.lua;

  # Editing helpers: Comment.nvim for toggling comments with gc/gcc.
  home.file.".config/nvim/lua/plugins/editing.lua".source = ../config/nvim/lua/plugins/editing.lua;

  # Completion: blink.cmp completion engine, snippets, ghost text, and LSP completion.
  home.file.".config/nvim/lua/plugins/blink.lua".source = ../config/nvim/lua/plugins/blink.lua;

  # Text objects: Treesitter-aware function/class selections and movement.
  home.file.".config/nvim/lua/plugins/treesitter-textobjects.lua".source = ../config/nvim/lua/plugins/treesitter-textobjects.lua;
  
  # Bufferline: tmux-like list of open Neovim buffers at the top.
  home.file.".config/nvim/lua/plugins/bufferline.lua".source = ../config/nvim/lua/plugins/bufferline.lua;
   
  # ── NEOVIM ───────────────────────────────────────────────────────────────
  # Bare functional config — full setup to follow separately.
  programs.neovim = {
    withRuby = true;
    withPython3 = true;
    enable        = true;
    defaultEditor = true;

    initLua = ''
      require("core.options")
      require("core.keymaps")
      require("core.lazy")
    '';
  };


  # ── GHOSTTY CONFIG ───────────────────────────────────────────────────────
  # macos-* options are conditionally added; Ghostty ignores them on Linux
  # but we explicitly guard them to keep the config clean.
  home.file.".config/ghostty/config".source = ../config/ghostty/config;

  # ── Ghostty themes ────────────────────────────────────────────────────────
  home.file.".config/ghostty/themes/catppuccin-mocha".source = ../config/ghostty/themes/catppuccin-mocha;

  home.file.".config/ghostty/themes/catppuccin-macchiato".source = ../config/ghostty/themes/catppuccin-macchiato;

  home.file.".config/ghostty/themes/catppuccin-latte".source = ../config/ghostty/themes/catppuccin-latte;
}
