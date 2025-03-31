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
  networking = {
    hostName = "dedsec-nixos";
    networkmanager.enable = true;

    #bridges = {
    #  br0 = {
    #    interfaces = [ "eno1" ];
    #  };
    #};

    #interfaces = {
    #  br0 = {
    #    useDHCP = true;
    #  };
    #};

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
  # ÉDITEURS DE TEXTE & IDE
  # ─────────────────────────────────────────────────────
  neovim              # Éditeur de texte léger et rapide, avec de nombreuses extensions et personnalisations
  vscode              # Visual Studio Code (IDE polyvalent) avec support d'extensions variées
  jetbrains-toolbox   # Gestionnaire des IDE JetBrains (IntelliJ IDEA, PyCharm, etc.)
  godot_4             # Moteur de jeu Godot 4, open source pour la création de jeux vidéo

  # ─────────────────────────────────────────────────────
  # OUTILS DE DÉVELOPPEMENT
  # ─────────────────────────────────────────────────────
  ## Gestion des versions et dépendances
  git                 # Gestionnaire de versions Git pour le contrôle de source
  pkg-config          # Outil pour gérer les dépendances C/C++ via des fichiers de configuration
  readline            # Gestion des entrées en ligne de commande pour une meilleure UX
  openssl             # Bibliothèque de chiffrement, utilisée dans la sécurité des applications
  libffi              # Interface d'appel de fonctions C pour les bindings entre langages
  libyaml             # Librairie pour parser et écrire du YAML, très utilisé dans les configurations
  zlib                # Compression des données, utilisée par de nombreux outils et applications

  ## Langages de programmation
  ### JavaScript / TypeScript
  nodejs              # Runtime JS pour exécuter des applications JavaScript côté serveur
  bun                 # Runtime JS alternatif plus rapide, incluant un bundler et un gestionnaire de paquets

  ### Java, Kotlin & Spring
  jdk8                # Java Development Kit 8 (legacy), pour les applications Java anciennes
  jdk17               # Java Development Kit 17 (LTS), version stable et à long terme
  jdk21               # Java Development Kit 21 (dernier stable), dernière version de Java
  kotlin              # Langage Kotlin pour le développement moderne et multiplateforme
  gradle              # Outil de build pour JVM, avec support Kotlin, Groovy et autres
  maven               # Gestionnaire de dépendances Java, utilisé dans de nombreux projets Java
  spring-boot-cli     # CLI pour Spring Boot, simplifie le démarrage d'applications Spring

  ### Go
  go                  # Langage Go, connu pour sa simplicité et ses performances élevées
  air                 # Hot reload pour Go, permet de recharger automatiquement les applications Go pendant le développement

  ### Rust
  rustup              # Gestionnaire Rust pour gérer les versions et les outils Rust

  ### Zig
  zig                 # Langage Zig, connu pour sa performance et sa gestion manuelle de la mémoire

  ### Assembleur
  nasm                # Assembleur x86, utilisé pour écrire du code bas niveau performant

  ### PHP & Laravel
  php                 # PHP, langage populaire pour le développement web
  laravel             # Framework Laravel, connu pour sa simplicité et ses bonnes pratiques en PHP

  ### Ruby & Rails
  ruby                # Ruby, langage de programmation dynamique
  rbenv               # Gestionnaire de versions Ruby pour faciliter la gestion de plusieurs versions de Ruby

  ## Développement Mobile
  flutter             # SDK Flutter pour le développement mobile multiplateforme

  ## Compilation et outils de build
  gcc                 # Compilateur C/C++, l'un des plus utilisés
  gnumake             # Makefile, utile pour automatiser les tâches de build
  cmake               # Outil de build C++ multiplateforme

  ## Python
  python3             # Python 3, très utilisé pour le développement de scripts et d'applications

  ## Outils de développement Nix
  nixpkgs-fmt         # Formatage de fichiers Nix
  nixd                # Serveur LSP pour le langage Nix, utile pour l'édition de fichiers .nix
  devbox              # Gestion simplifiée des environnements de développement
  direnv              # Chargement automatique des variables d’environnement par projet
  just                # Alternative moderne à Makefile pour automatiser des tâches
  difftastic          # Diff amélioré avec reconnaissance syntaxique

  # ─────────────────────────────────────────────────────
  # BASES DE DONNÉES
  # ─────────────────────────────────────────────────────
  postgresql          # SGBD relationnel Open Source, robuste et largement utilisé
  postgresql.lib      # Bibliothèque PostgreSQL pour les applications C/C++ et autres
  sqlite              # Base de données légère, utilisée dans les applications mobiles ou embarquées
  redis               # Cache / stockage en RAM pour des performances accrues

  # ─────────────────────────────────────────────────────
  # OUTILS CLI & SHELL
  # ─────────────────────────────────────────────────────
  tmux                # Multiplexeur de terminaux, permet de gérer plusieurs sessions dans un terminal
  fzf                 # Recherche floue dans le terminal, améliore l'efficacité de navigation
  curl                # Requêtes HTTP en ligne de commande
  wget                # Téléchargement HTTP
  gh                  # CLI GitHub pour gérer les dépôts GitHub directement depuis le terminal
  gitleaks            # Détection de secrets dans Git
  httpie              # Alternative plus lisible à curl
  ghostty             # Terminal moderne
  eza                 # Meilleur `ls` pour un affichage enrichi avec icônes et couleurs
  bat                 # Meilleur `cat` avec coloration syntaxique et meilleure lisibilité des fichiers
  fd                  # Recherche rapide et efficace de fichiers, alternative à `find`
  ripgrep             # Recherche de texte ultra-rapide dans des fichiers, alternative à `grep`
  btop                # Moniteur système avec une interface graphique très claire
  tldr                # Résumés simplifiés des pages man pour une consultation rapide
  atuin               # Historique de commande avancé avec synchronisation optionnelle
  starship            # Invite de commande rapide et hautement personnalisable
  yazi                # Gestionnaire de fichiers en terminal avec interface moderne
  mprocs              # Gestion de plusieurs processus dans le terminal

  # ─────────────────────────────────────────────────────
  # VIRTUALISATION & CONTAINERS
  # ─────────────────────────────────────────────────────
  qemu                # Virtualisation KVM/QEMU
  virt-manager        # Interface graphique pour gérer QEMU et libvirt
  virt-viewer         # Visionneuse VM
  libvirt             # Gestionnaire de virtualisation
  ollama              # Exécution de modèles IA locaux
  docker-compose      # Orchestration de containers Docker
  nvidia-container-toolkit # Support NVIDIA pour containers
  nvidia-docker       # Docker avec GPU NVIDIA
  kubernetes          # Orchestration avancée
  minikube            # Kubernetes en local
  podman              # Alternative à Docker en mode rootless
  stern               # Logs en temps réel pour Kubernetes
  k9s                 # Interface CLI puissante pour gérer Kubernetes

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
  prismlauncher       # Minecraft launcher alternatif

  # ─────────────────────────────────────────────────────
  # OUTILS ANDROID & MOBILE
  # ─────────────────────────────────────────────────────
  android-tools       # ADB & Fastboot pour Android
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
