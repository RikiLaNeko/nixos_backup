{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  ##########################
  # Bootloader & Sécurité  #
  ##########################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  security.polkit.enable = true;

  ##########################
  # Virtualisation         #
  ##########################
  virtualisation.libvirtd.enable = true;
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
      default-runtime = "nvidia";
    };
  };

  ##########################
  # Réseau & Proxy         #
  ##########################
  networking.hostName = "dedsec-nixos";
  networking.networkmanager.enable = true;

  ##########################
  # Graphismes & Hardware  #
  ##########################
  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:14:0:0";
  };

  hardware.nvidia-container-toolkit.enable = true;

  ##########################
  # Time & International   #
  ##########################
  time.timeZone = "Europe/Paris";
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

  ##########################
  # X11 & Affichage        #
  ##########################
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    libinput.enable = true;
    xkb = {
      layout = "fr";
      variant = "";
    };
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  console.keyMap = "fr";

  ##########################
  # Audio & Son            #
  ##########################
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ##########################
  # Imprimantes & Services #
  ##########################
  services.printing.enable = true;
  services.openssh.enable = true;

  ##########################
  # Home Manager & Utilisateurs #
  ##########################
  home-manager.users.dedsec = {
    home.stateVersion = "24.11";
    programs.zoxide.enable = true;
  };

  users.users.dedsec = {
    isNormalUser = true;
    description = "dedsec";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "kvm" "qemu" ];
    packages = with pkgs; [ ];
  };

  ##########################
  # Paquets Système        #
  ##########################
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
    openssl             # Bibliothèque cryptographique
    libffi              # Interface pour appels de fonctions C
    libyaml
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

    ### Kotlin
    kotlin

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
    # BASE DE DONNEES
    # ─────────────────────────────────────────────────────
    postgresql          #BDD relationel opensource
    postgresql.lib
    sqlite              # Base de données légère
    redis               # BDD de chacing / ramdisk

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
    kubernetes          # Gestion de conteneurs plus poussée
    librewolf           # Fork de firefox mais libre
    qemu                # Machine virtuelle
    virt-manager
    virt-viewer
    ollama
    libvirt
    cdrkit

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

    # ─────────────────────────────────────────────────────
    # OUTILS ANDROID & MOBILE
    # ─────────────────────────────────────────────────────
    android-tools       # Outils ADB et Fastboot
  ];

  ##########################
  # Services Spécifiques   #
  ##########################
  systemd.services.kvm-api = {
    serviceConfig = {
      User = "dedsec";
      Group = "libvirtd";
      SupplementaryGroups = [ "kvm" "qemu" ];
    };
  };

  systemd.services.ollama = {
    description = "Ollama Serve";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "/nix/store/667fn01apbb6ia0hjh4ai7pyxj8acihb-ollama-0.3.12/bin/ollama serve";
      Restart = "always";
      User = "dedsec";
      Environment = [
        "HOME=/home/dedsec"
        "OLLAMA_HOST=0.0.0.0:11434"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images 0770 root libvirtd -"
  ];

  ##########################
  # Programmes Divers      #
  ##########################
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  ##########################
  # Nix & Flakes           #
  ##########################
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

  nixpkgs.config = {
    allowUnfree = true;
    experimental-features = "nix-command flakes";
  };

  ##########################
  # Version d'état         #
  ##########################
  system.stateVersion = "24.11";
}
