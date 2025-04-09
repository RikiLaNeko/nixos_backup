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
  boot.kernelParams = [ "intel_iommu=on" ];
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
  networking = {
    hostName = "dedsec-nixos";
    networkmanager.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 11434 ]; # SSH, HTTP, HTTPS, Ollama
    allowedUDPPorts = [ 53 ]; # DNS
  };


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

  services.thermald.enable = true; # Gestion thermique
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75; # Commence à charger à 75%
      STOP_CHARGE_THRESH_BAT0 = 80; # Arrête de charger à 80%
    };
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

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
    xkb = {
      layout = "fr";
      variant = "";
    };
  };
  services.libinput.enable = true;

  # Désactivation de Plasma 6
  services.desktopManager.plasma6.enable = false;

  # Désactivation de SDDM
  services.displayManager.sddm.enable = false;

  # Activation de Ly comme gestionnaire de connexion
  services.displayManager.ly = {
    enable = true;
    settings = {
      animate = true; # Activer les animations
      animation = "matrix"; # Utiliser l'animation Matrix
      animation_fps = 24; # Cadence d'images pour l'animation (optionnel)
      # Autres paramètres pour personnaliser l'apparence
      # Les paramètres spécifiques peuvent varier selon la version de Ly
      hide_borders = true;
      margin_box_h = 2;
      margin_box_v = 1;
      input_len = 34;
      min_refresh_delta = 5;
      term_reset_cmd = "tput reset";
    };
  };

  # Activation de Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Pour la compatibilité avec les applications X11
  };

  console.keyMap = "fr";
  ##########################
  # Audio & Son            #
  ##########################
  services.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = false;
    alsa.support32Bit = false;
    pulse.enable = false;
  };

  ##########################
  # Imprimantes & Services #
  ##########################
  services.printing.enable = true;
  services.openssh = {
    enable = true;
    extraConfig = ''
      PermitRootLogin yes
    '';
  };



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
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "kvm" "qemu" "audio" ];
    packages = with pkgs; [ ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  ##########################
  # Paquets Système    	#
  ##########################
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────
    # SYSTÈME & UTILITAIRES
    # ─────────────────────────────────────────────────────
    refind # Gestionnaire de démarrage pour systèmes UEFI
    pciutils # Outils d'interrogation de bus PCI
    dnsmasq # Serveur DNS et DHCP léger
    nbd # Network Block Device
    virtiofsd # Démon pour le partage de fichiers virtio
    unzip # Décompression de fichiers ZIP
    zip # Compression de fichiers ZIP
    xdotool # Automatisation de clavier et souris X11
    waybar # Barre d'état
    rofi-wayland # Lanceur d'applications
    swww # Gestionnaire de fond d'écran
    wl-clipboard # Gestionnaire de presse-papier
    hyprpaper # Alternative pour les fonds d'écran
    xplorer # Gestionnaire de fichiers GUI
    pacman # Gestionnaire de paquets Arch Linux
    bluetui # Interface TUI pour Bluetooth
    brightnessctl # Contrôle de luminosité
    neo-cowsay # Version modernisée de cowsay
    figlet # Création de texte ASCII art
    sl # Train ASCII animé
    cava # Visualiseur audio console
    fortune # Messages de fortune aléatoires
    grim # Capture d'écran pour Wayland
    slurp # Sélection de région pour Wayland
    cmatrix # Effet de "Matrix" en terminal
    pipes # Animation de tuyaux en ASCII
    networkmanagerapplet # Applet de gestion réseau
    lm_sensors # Monitoring de capteurs systèmes
    playerctl # Contrôle des lecteurs multimédias
    libnotify # Bibliothèque pour les notifications
    killall # Utilitaire pour tuer des processus
    pavucontrol # Contrôle de volume PulseAudio
    pulsemixer # Mixeur audio en console
    kubernetes-helm # Gestionnaire de paquets Kubernetes
    mako # Daemon de notification pour Wayland
    swaylock-effects # Écran de verrouillage avec effets

    # Outils pour laptop
    powertop # Analyse de consommation d'énergie
    acpi # Information sur la batterie

    # Sauvegarde
    restic # Outil de backup léger et rapide

    # ─────────────────────────────────────────────────────
    # ÉDITEURS DE TEXTE & IDE
    # ─────────────────────────────────────────────────────
    neovim # Éditeur de texte avancé
    vscode # Visual Studio Code
    jetbrains-toolbox # Gestionnaire d'IDE JetBrains
    obsidian # Gestionnaire de notes

    # ─────────────────────────────────────────────────────
    # OUTILS DE DÉVELOPPEMENT
    # ─────────────────────────────────────────────────────
    ## Gestion des versions et dépendances
    git # Système de contrôle de version
    pkg-config # Outil pour les dépendances C/C++
    readline # Bibliothèque pour l'entrée en ligne de commande
    openssl # Bibliothèque de chiffrement
    libffi # Interface d'appel de fonctions
    libyaml # Parser YAML
    zlib # Bibliothèque de compression
    gtk3 # Toolkit d'interface graphique
    # Spécification explicite de la version ABI pour webkitgtk
    webkitgtk_4_1 # Moteur de rendu web avec version ABI spécifiée
    nsis # Installateur Windows
    upx # Compresseur d'exécutables

    ## Compilation et outils de build
    gcc # Compilateur C/C++
    gnumake # Outil de build
    cmake # Système de build multi-plateforme

    ## Langages de programmation
    ### JavaScript / TypeScript
    nodejs # Runtime JavaScript
    bun # Runtime JS moderne
    yay # Gestionnaire de paquets AUR

    ### Java Kotlin & Spring
    jdk8 # Java 8
    jdk17 # Java 17 LTS
    jdk21 # Java 21
    kotlin # Langage Kotlin
    gradle # Système de build Java/Kotlin
    maven # Gestionnaire de dépendances Java
    spring-boot-cli # CLI Spring Boot

    ### Go
    go # Langage Go
    air # Hot reload pour Go
    wails # Framework desktop Go + Web

    ### Rust
    rustup # Gestionnaire de versions Rust
    rustc # Compilateur Rust
    cargo-tauri # Framework desktop Rust + Web

    ### Zig
    zig # Langage Zig

    ### Assembleur
    nasm # Assembleur x86

    ### PHP & Laravel
    php # Langage PHP
    laravel # Framework Laravel

    ### Ruby & Rails
    ruby # Langage Ruby
    rbenv # Gestionnaire de versions Ruby

    ### Python
    python3 # Python 3
    python3Packages.pip # Gestionnaire de paquets Python
    python3Packages.virtualenv # Environnements virtuels Python

    ### C#
    mono # Implémentation .NET
    dotnet-sdk # SDK .NET officiel

    ## Développement Mobile
    flutter # Framework UI multi-plateforme

    ## Outils de développement Nix
    nixpkgs-fmt # Formatage de fichiers Nix
    nixd # Serveur LSP pour Nix
    devbox # Environnements de développement
    direnv # Environnements par répertoire
    just # Alternative à Make
    difftastic # Outil de diff syntaxique

    # ─────────────────────────────────────────────────────
    # MOTEURS & OUTILS DE DÉVELOPPEMENT DE JEUX
    # ─────────────────────────────────────────────────────
    godot_4 # Moteur de jeu Godot 4
    unityhub # Hub Unity
    scenebuilder # Créateur d'interfaces JavaFX
    blender # Modeleur 3D
    gimp # Éditeur d'images

    # ─────────────────────────────────────────────────────
    # BASES DE DONNÉES
    # ─────────────────────────────────────────────────────
    postgresql # SGBD PostgreSQL
    postgresql.lib # Bibliothèque PostgreSQL
    sqlite # Base de données légère
    redis # Stockage clé-valeur en mémoire
    dbeaver-bin # Client SQL universel

    # ─────────────────────────────────────────────────────
    # OUTILS CLI & SHELL
    # ─────────────────────────────────────────────────────
    tmux # Multiplexeur de terminaux
    zellij # Alternative moderne à tmux
    fzf # Recherche floue
    curl # Transfert de données
    wget # Téléchargement HTTP
    gh # CLI GitHub
    gitleaks # Détection de secrets
    httpie # Client HTTP convivial
    ghostty # Terminal moderne
    eza # Alternative à ls
    bat # Alternative à cat
    fd # Alternative à find
    ripgrep # Alternative à grep
    btop # Moniteur système
    tldr # Alternative simplifiée à man
    atuin # Historique de shell amélioré
    yazi # Gestionnaire de fichiers TUI
    mprocs # Gestion de processus multiples
    hugo # Générateur de sites statiques
    zoxide # Navigation intelligente
    jq # Processeur JSON
    tree # Affichage arborescent
    nmap # Scanner réseau
    fastfetch # Information système
    taskwarrior3 # Gestionnaire de tâches
    jenkins # Serveur d'intégration continue

    # ─────────────────────────────────────────────────────
    # VIRTUALISATION & CONTAINERS
    # ─────────────────────────────────────────────────────
    qemu_full # Émulateur et virtualisation
    virt-manager # Interface graphique libvirt
    virt-viewer # Visualisation VM
    libvirt # API de virtualisation
    ollama # Gestionnaire de modèles LLM
    docker-compose # Orchestration Docker
    nvidia-container-toolkit # Support GPU pour conteneurs
    nvidia-docker # Docker avec support NVIDIA
    kubernetes # Orchestration de conteneurs
    minikube # Kubernetes local
    podman # Alternative à Docker
    stern # Logs multi-pods Kubernetes
    k9s # Interface TUI Kubernetes

    # ─────────────────────────────────────────────────────
    # NAVIGATION & COMMUNICATION
    # ─────────────────────────────────────────────────────
    librewolf # Navigateur axé sur la vie privée
    (discord.override { withVencord = true; }) # Discord amélioré
    element-desktop # Client Matrix
    parsec-bin # Bureau à distance gaming
    teams-for-linux # Client Teams non-officiel
    simplex-chat-desktop # Messagerie sécurisée
    calibre # Gestion d'e-books

    # ─────────────────────────────────────────────────────
    # GAMING
    # ─────────────────────────────────────────────────────
    lutris # Gestionnaire de jeux
    osu-lazer # Jeu de rythme
    prismlauncher # Lanceur Minecraft
    heroic # Client Epic Games et GOG
    wine # Compatibilité Windows
    steam # Plateforme de jeux
    gamemode # Optimisations pour jeux

    # ─────────────────────────────────────────────────────
    # AUDIO & MULTIMÉDIA
    # ─────────────────────────────────────────────────────
    lmms # Station audio numérique
    clementine # Lecteur audio
    scdl # Téléchargement SoundCloud
    ffmpeg # Traitement audio/vidéo
    vlc # Lecteur multimédia
    mpv # Lecteur vidéo minimaliste
    audacity # Éditeur audio

    # Codecs et bibliothèques multimédia
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly

    # ─────────────────────────────────────────────────────
    # LAZY
    # ─────────────────────────────────────────────────────
    lazygit # Interface TUI Git
    lazydocker # Interface TUI Docker
    lazysql # Interface TUI SQL

    # ─────────────────────────────────────────────────────
    # RÉSEAU & ACCÈS DISTANT
    # ─────────────────────────────────────────────────────
    ngrok # Tunnels sécurisés
    wireguard-tools # VPN moderne
    openvpn # Solution VPN classique
    sshfs # Montage SSH
    filezilla # Client FTP/SFTP

    # ─────────────────────────────────────────────────────
    # OUTILS ANDROID & MOBILE
    # ─────────────────────────────────────────────────────
    android-tools # ADB & Fastboot
    scrcpy # Mirroring Android
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
    "d /var/lib/postgresql 0700 postgres postgres -"
    "d /run/postgresql 0755 postgres postgres -"
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

  environment.variables = {
    TERMINAL = "ghostty";
    DEFAULT_TERM = "ghostty";
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false; # Ne redémarre pas automatiquement
    dates = "04:00"; # À 4h du matin
    randomizedDelaySec = "45min"; # Délai aléatoire pour éviter la charge sur les serveurs
  };


  ##########################
  # Version d'état         #
  ##########################
  system.stateVersion = "24.11";
}
