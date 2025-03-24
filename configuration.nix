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
    neovim              # Éditeur de texte léger et rapide
    vscode              # Visual Studio Code (IDE polyvalent)
    jetbrains-toolbox   # Gestionnaire des IDE JetBrains
    godot_4             # Moteur de jeu Godot 4
    
    # ─────────────────────────────────────────────────────
    # OUTILS DE DÉVELOPPEMENT
    # ─────────────────────────────────────────────────────
    
    ## Gestion des versions et dépendances
    git                 # Gestionnaire de versions Git
    pkg-config          # Outil pour gérer les dépendances C/C++
    readline            # Gestion des entrées en ligne de commande
    openssl             # Bibliothèque de chiffrement
    libffi              # Interface d’appel de fonctions C
    libyaml             # Parsing YAML
    zlib                # Compression
    
    ## Langages de programmation
    
    ### JavaScript / TypeScript
    nodejs              # Runtime JS
    bun                 # Runtime JS alternatif plus rapide
    
    ### Java, Kotlin & Spring
    jdk8                # Java Development Kit 8 (legacy)
    jdk17               # Java Development Kit 17 (LTS)
    jdk21               # Java Development Kit 21 (dernier stable)
    kotlin              # Langage Kotlin
    gradle              # Outil de build pour JVM
    maven               # Gestionnaire de dépendances Java
    spring-boot-cli     # CLI pour Spring Boot
    
    ### Go
    go                  # Langage Go
    air                 # Hot reload pour Go
    
    ### Rust
    rustup              # Gestionnaire Rust
    
    ### Zig
    zig                 # Langage Zig
    
    ### Assembleur
    nasm                # Assembleur x86
    
    ### PHP & Laravel
    php                 # PHP
    laravel             # Framework Laravel
    
    ### Ruby & Rails
    ruby                # Ruby
    rbenv               # Gestionnaire de versions Ruby
    
    ## Développement Mobile
    flutter             # SDK Flutter
    
    ## Compilation et outils de build
    gcc                 # Compilateur C/C++
    gnumake             # Makefile
    cmake               # Build C++
    
    # ─────────────────────────────────────────────────────
    # BASES DE DONNÉES
    # ─────────────────────────────────────────────────────
    postgresql          # SGBD relationnel Open Source
    postgresql.lib      # Bibliothèque PostgreSQL
    sqlite              # Base de données légère
    redis               # Cache / stockage en RAM
    
    # ─────────────────────────────────────────────────────
    # OUTILS CLI & SHELL
    # ─────────────────────────────────────────────────────
    tmux                # Multiplexeur de terminaux
    fzf                 # Recherche floue dans le terminal
    fastfetch           # Fetch d’infos système rapide
    curl                # Requêtes HTTP en ligne de commande
    wget                # Téléchargement HTTP
    gh                  # CLI GitHub
    gitleaks            # Détection de secrets dans Git
    httpie              # Alternative plus lisible à curl
    lsd                 # Better LS
    
    # ─────────────────────────────────────────────────────
    # VIRTUALISATION & CONTAINERS
    # ─────────────────────────────────────────────────────
    qemu                # Virtualisation KVM/QEMU
    virt-manager        # Interface graphique pour QEMU
    virt-viewer         # Visionneuse VM
    libvirt             # Gestionnaire de virtualisation
    ollama              # Exécution de modèles IA locaux
    docker-compose      # Orchestration de containers Docker
    nvidia-container-toolkit # Support NVIDIA pour containers
    nvidia-docker       # Docker avec GPU NVIDIA
    kubernetes          # Orchestration avancée
    minikube            # Kubernetes en local
    
    # ─────────────────────────────────────────────────────
    # APPLICATIONS DESKTOP UTILES
    # ─────────────────────────────────────────────────────
    obsidian            # Notes en Markdown
    lmstudio            # Interface pour LLMs locaux
    onlyoffice-bin      # Suite bureautique alternative
    blender             # Modélisation 3D
    obs-studio          # Enregistrement & streaming
    vlc                 # Lecteur multimédia
    
    # ─────────────────────────────────────────────────────
    # NAVIGATION & COMMUNICATION
    # ─────────────────────────────────────────────────────
    librewolf           # Fork de Firefox, axé sur la vie privée
    (discord.override { withVencord = true; }) # Discord + Vencord
    element-desktop     # Client Matrix
    parsec-bin          # Remote Desktop Gaming
    ngrok               # Tunnel réseau sécurisé
    
    # ─────────────────────────────────────────────────────
    # GAMING
    # ─────────────────────────────────────────────────────
    lutris              # Gestion des jeux sous Linux
    osu-lazer           # Version open-source de Osu!
    
    # ─────────────────────────────────────────────────────
    # OUTILS ANDROID & MOBILE
    # ─────────────────────────────────────────────────────
    android-tools       # ADB & Fastboot pour Android
    eza
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
