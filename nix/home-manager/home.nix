# This is your home-manager configuration file
{ inputs, pkgs, ... }: let 
  username = "trevorj";
in {
  systemd.user.startServices = "sd-switch"; # Nicely reload system units when changing configs
  nixpkgs.config.allowUnfree = true; # Allow unfree packages (eg. nvidia drivers
  nixpkgs.config.allowUnfreePredicate = _: true; # Workaround for home-manager#2942

  # Setup username, directory, and packages for user
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion  = "24.11";
    packages = [ 
      pkgs.home-manager

      # applications
      pkgs.firefox
      pkgs.bitwarden
      inputs.ghostty.packages."${pkgs.system}".default

      # cli tools
      pkgs.neovim
      pkgs.tmux
      pkgs.zsh
      pkgs.starship
      pkgs.wget
      pkgs.git
      pkgs.fzf
      pkgs.ripgrep
      pkgs.xclip

      # language compilers
      pkgs.cargo
      pkgs.rustc
      pkgs.gcc
    ];
  };

  # configure git
  programs.git = {
    enable = true;
    userName = "Trevor Johnson";
    userEmail = "27569194+trevorgjohnson@users.noreply.github.com";
    extraConfig.include.path = "~/.config/dotfiles/.gitaliases";
  };

  # configure fzf
  programs.fzf= {
    enable = true;
    enableZshIntegration = true; 
    colors = {
      "bg+"="#313244,spinner:#f5e0dc,hl:#f38ba8";
      fg="#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc";
      marker="#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8";
    };
  };

  # configure zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      updatesys = "sudo nixos-rebuild switch --flake ~/.config/nix";
      updatehome = "home-manager switch --flake ~/.config/nix";
    };
    initExtra = ''
# starship
eval "$(starship init zsh)"

# fzf
source <(fzf --zsh)

# map yazi to 'y' and enable directory hopping after closing
function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
}
    '';
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          tag = "v0.7.1";
        };
      }
    ];
  };
}
