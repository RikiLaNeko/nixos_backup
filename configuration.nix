# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
  
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  #boot.kernelParams = [ "psmouse.synaptics_intertouch=0"];
  #boot.kernelModules = [ "i2c_hid" "psmouse"];
  security.polkit.enable = true;

   
  #VirtualBox
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;
  users.extraGroups.vboxusers.members = [ "dedsec" ];
  
  networking.hostName = "dedsec-nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
   networking.networkmanager.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };



  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;


  nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  substituters = [
    "https://cache.nixos.org"
    "https://ghostty.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
  ];
  };
  

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  


  fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts.githubRelease
  dina-font
  proggyfonts
 
   ];

  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = false;
    # Whether to enable XWayland
    xwayland.enable = true;
  };



  home-manager.users.dedsec = {
  programs.zoxide.enable = true;
  home.stateVersion = "24.11";
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
		offload = {
			enable = true;
			enableOffloadCmd = true;
		};
		# Make sure to use the correct Bus ID values for your system!
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:14:0:0";
                # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
	};

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
   services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
   services.displayManager.sddm.enable = true;
   services.desktopManager.plasma6.enable = true;



  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
      services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dedsec = {
    isNormalUser = true;
    description = "dedsec";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [

    ];
  };



  
  # Install steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  nixpkgs.config = {
  allowUnfree = true;  # Permet d'installer des paquets non-libres
  experimental-features = "nix-command flakes";  # Active les fonctionnalités nécessaires
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  # ─────────────────────────────────────────────────────
  # ÉDITEURS DE TEXTE & IDE
  # ─────────────────────────────────────────────────────
  neovim              # Éditeur de texte (ne pas oublier pour éditer configuration.nix !)
  vscode              # Visual Studio Code
  jetbrains-toolbox   # Outil pour gérer les IDE JetBrains
  godot_4             # Moteur de jeu Godot 4

  # ─────────────────────────────────────────────────────
  # OUTILS DE DÉVELOPPEMENT
  # ─────────────────────────────────────────────────────

  ## Gestionnaire de versions & outils généraux
  git                 # Gestionnaire de versions
  pkg-config          # Utilitaire pour gérer les bibliothèques
  readline            # Bibliothèque pour la gestion de l'entrée utilisateur en ligne de commande
  sqlite              # Base de données légère
  openssl             # Bibliothèque cryptographique
  libffi              # Interface pour appels de fonctions C
  libyaml             # Support YAML
  zlib                # Bibliothèque de compression

  ## Langages de programmation

  ### JavaScript / TypeScript
  nodejs              # JavaScript Runtime
  bun                 # JavaScript / TypeScript Runtime sécurisé

  ### Go
  go                  # Langage de programmation Go
  air                 # Live reload pour Go

  ### Rust
  rustup              # Rust (avec gestionnaire de versions)

  ### Zig
  zig                 # Langage de programmation Zig

  ### Assembleur
  nasm                # Assembleur pour x86

  ### Java & écosystème Spring
  jdk8                # Java Development Kit 8
  jdk17               # Java Development Kit 17
  jdk21               # Java Development Kit 21
  gradle              # Outil de build pour Java
  maven               # Gestionnaire de dépendances Java
  spring-boot-cli     # CLI pour Spring Boot

  ### PHP & Laravel
  php                 # Langage PHP
  laravel             # Framework PHP

  ### Ruby
  ruby                # Langage Ruby
  rbenv               # Gestionnaire de versions Ruby

  ## Développement Mobile
  flutter             # SDK Flutter

  ## Compilation et outils de build
  gcc                 # Compilateur C/C++
  gnumake             # Outil de compilation Make
  cmake               # Outil de build C++

  # ─────────────────────────────────────────────────────
  # OUTILS CLI & SHELL
  # ─────────────────────────────────────────────────────
  tmux                # Multiplexeur de terminaux
  fzf                 # Recherche floue
  fastfetch           # Fetch d'infos système rapide
  curl                # Client HTTP
  wget                # Client HTTP
  gh                  # GitHub CLI
  gitleaks            # Détection de secrets dans Git
  httpie              # Client HTTP amélioré

  # ─────────────────────────────────────────────────────
  # OUTILS SYSTÈME
  # ─────────────────────────────────────────────────────
  home-manager        # Gestionnaire de configuration utilisateur
  dconf               # Configuration de l'environnement de bureau
  xdg-desktop-portal-hyprland # Portail pour Hyprland
  xwayland            # Compatibilité X11 sous Wayland
  lshw                # Affichage des infos matérielles
  alsa-lib            # Bibliothèque ALSA (son)
  udev                # Gestion des périphériques
  nvidia-container-toolkit # Outils pour exécuter des conteneurs sur GPU NVIDIA
  nvidia-docker       # Docker avec support GPU NVIDIA
  docker-compose      # Gestion de conteneurs
  librewolf           # Fork de firefox mais libre

  # ─────────────────────────────────────────────────────
  # APPLICATIONS DESKTOP UTILES
  # ─────────────────────────────────────────────────────
  obsidian            # Prise de notes Markdown
  lmstudio            # Interface pour modèles IA locaux
  onlyoffice-bin      # Suite bureautique
  blender             # Modélisation 3D
  obs-studio          # Streaming et enregistrement
  vlc                 # Lecteur multimédia

  # ─────────────────────────────────────────────────────
  # RÉSEAU & COMMUNICATION
  # ─────────────────────────────────────────────────────
  (discord.override {
    withVencord = true; # Modifications pour Discord
  })
  element-desktop     # Client Matrix
  parsec-bin          # Remote desktop gaming
  ngrok               # Tunnel réseau

  # ─────────────────────────────────────────────────────
  # GAMING
  # ─────────────────────────────────────────────────────
  osu-lazer           # Version open-source d'Osu!
  sm64ex-coop         # Super Mario 64 modifié en coop

  # ─────────────────────────────────────────────────────
  # OUTILS ANDROID & MOBILE
  # ─────────────────────────────────────────────────────
  android-tools       # Outils ADB et Fastboot
];






  #Docker
  virtualisation.docker = {
  enable = true;
  };

  virtualisation.docker.daemon.settings = {
    runtimes = {
      nvidia = {
        path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
      };
    };
    default-runtime = "nvidia";  # Set NVIDIA as the default runtime
  };


  virtualisation.docker.rootless = {
  enable = true;
  setSocketVariable = true;
  };
  
 hardware.nvidia-container-toolkit.enable = true;  
  

systemd.services.ollama = {
  description = "Ollama Serve";
  wantedBy = [ "multi-user.target" ];
  after = [ "network.target" ];
  serviceConfig = {
    ExecStart = "/nix/store/667fn01apbb6ia0hjh4ai7pyxj8acihb-ollama-0.3.12/bin/ollama serve";
    Restart = "always";
    User = "dedsec";
    Environment = [
      "HOME=/home/dedsec"  # Assurez-vous que c'est bien votre chemin HOME
      "OLLAMA_HOST=0.0.0.0:11434"  # Permet à Ollama d'écouter sur toutes les interfaces
    ];
  };
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # LightDM configuration
  # services.xserver.displayManager.lightdm.enable = true;

}
