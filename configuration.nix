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
  # SYSTÈME & UTILITAIRES
  # ─────────────────────────────────────────────────────
  refind               # Gestionnaire de démarrage pour systèmes UEFI
  pciutils             # Outils d'interrogation de bus PCI
  dnsmasq              # Serveur DNS et DHCP léger
  nbd                  # Network Block Device
  virtiofsd            # Démon pour le partage de fichiers virtio
  unzip                # Décompression de fichiers ZIP
  zip                  # Compression de fichiers ZIP
  xdotool              # Automatisation de clavier et souris X11

  # ─────────────────────────────────────────────────────
  # ÉDITEURS DE TEXTE & IDE
  # ─────────────────────────────────────────────────────
  neovim               # Éditeur de texte léger et rapide, avec de nombreuses extensions
  vscode               # Visual Studio Code (IDE polyvalent) avec support d'extensions
  jetbrains-toolbox    # Gestionnaire des IDE JetBrains (IntelliJ IDEA, PyCharm, etc.)
  obsidian             # Gestionnaire de notes et base de connaissances

  # ─────────────────────────────────────────────────────
  # OUTILS DE DÉVELOPPEMENT
  # ─────────────────────────────────────────────────────
  ## Gestion des versions et dépendances
  git                  # Gestionnaire de versions Git pour le contrôle de source
  pkg-config           # Outil pour gérer les dépendances C/C++ via des fichiers de configuration
  readline             # Gestion des entrées en ligne de commande pour une meilleure UX
  openssl              # Bibliothèque de chiffrement, utilisée dans la sécurité des applications
  libffi               # Interface d'appel de fonctions C pour les bindings entre langages
  libyaml              # Librairie pour parser et écrire du YAML, très utilisé dans les configurations
  zlib                 # Compression des données, utilisée par de nombreux outils et applications
  gtk3                 # Toolkit d'interface graphique
  webkitgtk            # Moteur de rendu web pour GTK
  nsis                 # Installateur pour Windows
  upx                  # Compresseur d'exécutables

  ## Compilation et outils de build
  gcc                  # Compilateur C/C++, l'un des plus utilisés
  gnumake              # Makefile, utile pour automatiser les tâches de build
  cmake                # Outil de build C++ multiplateforme

  ## Langages de programmation
  ### JavaScript / TypeScript
  nodejs               # Runtime JS pour exécuter des applications JavaScript côté serveur
  bun                  # Runtime JS alternatif plus rapide, incluant un bundler et un gestionnaire de paquets

  ### Java, Kotlin & Spring
  jdk8                 # Java Development Kit 8 (legacy), pour les applications Java anciennes
  jdk17                # Java Development Kit 17 (LTS), version stable et à long terme
  jdk21                # Java Development Kit 21 (dernier stable), dernière version de Java
  kotlin               # Langage Kotlin pour le développement moderne et multiplateforme
  gradle               # Outil de build pour JVM, avec support Kotlin, Groovy et autres
  maven                # Gestionnaire de dépendances Java, utilisé dans de nombreux projets Java
  spring-boot-cli      # CLI pour Spring Boot, simplifie le démarrage d'applications Spring

  ### Go
  go                   # Langage Go, connu pour sa simplicité et ses performances élevées
  air                  # Hot reload pour Go, permet de recharger automatiquement les applications Go
  wails                # Framework pour créer des applications desktop avec Go et Web Technologies

  ### Rust
  rustup               # Gestionnaire Rust pour gérer les versions et les outils Rust
  rustc                # Compilateur Rust
  cargo-tauri          # Framework pour créer des applications desktop avec Rust et Web Technologies

  ### Zig
  zig                  # Langage Zig, connu pour sa performance et sa gestion manuelle de la mémoire

  ### Assembleur
  nasm                 # Assembleur x86, utilisé pour écrire du code bas niveau performant

  ### PHP & Laravel
  php                  # PHP, langage populaire pour le développement web
  laravel              # Framework Laravel, connu pour sa simplicité et ses bonnes pratiques en PHP

  ### Ruby & Rails
  ruby                 # Ruby, langage de programmation dynamique
  rbenv                # Gestionnaire de versions Ruby pour faciliter la gestion de plusieurs versions

  ### Python
  python3              # Python 3, très utilisé pour le développement de scripts et d'applications
  python3Packages.pip  # Gestionnaire de paquets Python
  python3Packages.virtualenv # Environnements virtuels pour Python

  ### C#
  mono                 # Implémentation open-source de .NET
  dotnet-sdk           # SDK officiel pour .NET, nécessaire au développement en C#

  ## Développement Mobile
  flutter              # SDK Flutter pour le développement mobile multiplateforme

  ## Outils de développement Nix
  nixpkgs-fmt          # Formatage de fichiers Nix
  nixd                 # Serveur LSP pour le langage Nix, utile pour l'édition de fichiers .nix
  devbox               # Gestion simplifiée des environnements de développement
  direnv               # Chargement automatique des variables d'environnement par projet
  just                 # Alternative moderne à Makefile pour automatiser des tâches
  difftastic           # Diff amélioré avec reconnaissance syntaxique

  # ─────────────────────────────────────────────────────
  # MOTEURS & OUTILS DE DÉVELOPPEMENT DE JEUX
  # ─────────────────────────────────────────────────────
  godot_4              # Moteur de jeu Godot 4, open source pour la création de jeux vidéo
  unityhub             # Gestionnaire Unity
  scenebuilder         # Outil pour créer des interfaces JavaFX
  blender              # Modélisation 3D, animation et rendu
  gimp                 # Édition d'images et création graphique

  # ─────────────────────────────────────────────────────
  # BASES DE DONNÉES
  # ─────────────────────────────────────────────────────
  postgresql           # SGBD relationnel Open Source, robuste et largement utilisé
  postgresql.lib       # Bibliothèque PostgreSQL pour les applications C/C++ et autres
  sqlite               # Base de données légère, utilisée dans les applications mobiles ou embarquées
  redis                # Cache / stockage en RAM pour des performances accrues

  # ─────────────────────────────────────────────────────
  # OUTILS CLI & SHELL
  # ─────────────────────────────────────────────────────
  tmux                 # Multiplexeur de terminaux, permet de gérer plusieurs sessions (Gardée le temps de s'habituée a zellij)
  zellij               # Alternative moderne à tmux avec interfaces tiling, modes et plugins. Écrit en Rust avec une meilleure UX
  fzf                  # Recherche floue dans le terminal, améliore l'efficacité de navigation
  curl                 # Requêtes HTTP en ligne de commande
  wget                 # Téléchargement HTTP
  gh                   # CLI GitHub pour gérer les dépôts GitHub directement depuis le terminal
  gitleaks             # Détection de secrets dans Git
  httpie               # Alternative plus lisible à curl
  ghostty              # Terminal moderne
  eza                  # Meilleur `ls` pour un affichage enrichi avec icônes et couleurs
  bat                  # Meilleur `cat` avec coloration syntaxique et meilleure lisibilité
  fd                   # Recherche rapide et efficace de fichiers, alternative à `find`
  ripgrep              # Recherche de texte ultra-rapide dans des fichiers, alternative à `grep`
  btop                 # Moniteur système avec une interface graphique très claire
  tldr                 # Résumés simplifiés des pages man pour une consultation rapide
  atuin                # Historique de commande avancé avec synchronisation optionnelle
  yazi                 # Gestionnaire de fichiers en terminal avec interface moderne
  mprocs               # Gestion de plusieurs processus dans le terminal
  hugo                 # Générateur de sites statiques rapide
  zoxide               # Navigation rapide entre dossiers
  jq                   # Traitement de données JSON en ligne de commande
  tree                 # Affichage récursif des dossiers
  nmap                 # Scanner de ports réseau
  fastfetch            # Affichage d'informations système avec style || nouveau neofetch
  taskwarrior3         # Gestionnaire de tâches en CLI hautement configurable avec gestion de priorités et échéances
  jenkins              # Extendable open source continuous integration server 

  # ─────────────────────────────────────────────────────
  # VIRTUALISATION & CONTAINERS
  # ─────────────────────────────────────────────────────
  qemu_full            # Émulateur et virtualisation matérielle
  virt-manager         # Interface graphique pour gérer les machines virtuelles avec libvirt
  virt-viewer          # Visionneuse pour se connecter aux machines virtuelles
  libvirt              # Bibliothèque et outil CLI pour gérer les machines virtuelles
  ollama               # Gestionnaire de modèles LLM en local
  docker-compose       # Orchestration de conteneurs Docker
  nvidia-container-toolkit # Outils pour exécuter des conteneurs GPU avec NVIDIA
  nvidia-docker        # Extension Docker pour l'accélération GPU
  kubernetes           # Orchestration de conteneurs à grande échelle
  minikube             # Exécution locale d'un cluster Kubernetes
  podman               # Alternative à Docker sans démon centralisé
  stern                # Affichage des logs de plusieurs pods Kubernetes en temps réel
  k9s                  # Interface en terminal pour gérer Kubernetes

  # ─────────────────────────────────────────────────────
  # NAVIGATION & COMMUNICATION
  # ─────────────────────────────────────────────────────
  librewolf            # Fork de Firefox, axé sur la vie privée
  (discord.override { withVencord = true; }) # Discord + Vencord
  element-desktop      # Client Matrix
  parsec-bin           # Remote Desktop Gaming
  teams-for-linux      # Client non officiel de Microsoft Teams pour Linux
  simplex-chat-desktop # Client de messagerie privée
  calibre              # Gestion d'e-books et bibliothèque numérique

  # ─────────────────────────────────────────────────────
  # GAMING
  # ─────────────────────────────────────────────────────
  lutris               # Gestion des jeux sous Linux
  osu-lazer            # Version open-source de Osu!
  prismlauncher        # Minecraft launcher alternatif
  heroic               # Client pour Epic Games & GOG sur Linux
  wine                 # Couche de compatibilité Windows
  steam                # Plateforme de jeux
  gamemode             # Optimisations pour les jeux

  # ─────────────────────────────────────────────────────
  # AUDIO & MULTIMÉDIA
  # ─────────────────────────────────────────────────────
  lmms                 # Station audionumérique pour la création musicale
  clementine           # Lecteur audio avancé
  scdl                 # Téléchargement de musiques SoundCloud
  ffmpeg               # Outil de traitement et conversion audio/vidéo
  vlc                  # Lecteur multimédia polyvalent
  mpv                  # Lecteur vidéo minimaliste
  audacity             # Éditeur audio

  # Codecs et bibliothèques multimédia
  gst_all_1.gstreamer
  gst_all_1.gst-plugins-base
  gst_all_1.gst-plugins-good
  gst_all_1.gst-plugins-bad
  gst_all_1.gst-plugins-ugly

  # ─────────────────────────────────────────────────────
  # LAZY
  # ─────────────────────────────────────────────────────
  lazygit              # Interface TUI pour Git avec visualisation de branches, gestion de commits et résolution de conflits
  lazydocker           # Gestionnaire de conteneurs Docker en TUI avec monitoring de ressources et logs en temps réel
  lazysql              # Interface TUI pour bases de données SQL avec visualisation des données et édition simplifiée



  # ─────────────────────────────────────────────────────
  # RÉSEAU & ACCÈS DISTANT
  # ─────────────────────────────────────────────────────
  ngrok                # Tunnel réseau sécurisé
  wireguard-tools      # VPN moderne et sécurisé
  openvpn              # Solution VPN classique
  sshfs                # Montage de systèmes de fichiers via SSH
  filezilla            # Client FTP/SFTP graphique

  # ─────────────────────────────────────────────────────
  # OUTILS ANDROID & MOBILE
  # ─────────────────────────────────────────────────────
  android-tools        # ADB & Fastboot pour Android
  scrcpy               # Affichage et contrôle d'appareils Android
];




  ##########################
  # Services Spécifiques   #
  ##########################

  systemd.services.postgresql = {



    description = "PostgreSQL Database Server";


    wantedBy = [ "multi-user.target" ];


    after = [ "network.target" ];


    serviceConfig = {


      ExecStart = "/run/current-system/sw/bin/postgres -D /var/lib/postgresql/data";


      ExecReload = "/run/current-system/sw/bin/pg_ctl reload -D /var/lib/postgresql/data";


      ExecStop = "/run/current-system/sw/bin/pg_ctl stop -D /var/lib/postgresql/data";


      Restart = "always";


      User = "postgres";


      Group = "postgres";


      Environment = [


        "PGDATA=/var/lib/postgresql/data"


        "PGPORT=5432"


      ];


    };


  };


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

  ##########################
  # Version d'état         #
  ##########################
  system.stateVersion = "24.11";
}
