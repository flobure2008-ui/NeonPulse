# ⚡ Neon Pulse : Cyber Strike (iOS)

[![Build iOS IPA](https://github.com/USER/NeonPulse-iOS/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/USER/NeonPulse-iOS/actions)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![Engine](https://img.shields.io/badge/Engine-SpriteKit%20%2B%20SwiftUI-purple.svg)](https://developer.apple.com)

> **Un jeu d'arcade néon cyberpunk ultra-rapide, addictif et fluide à 120 FPS sur iPhone et iPad, avec pipeline CI/CD GitHub Actions pour convertir et exporter automatiquement le jeu en fichier `.ipa` prêt à installer.**

---

## 🎮 Concept & Gameplay : Pourquoi ce jeu est impossible à lâcher

*Neon Pulse* est pensé selon les mécaniques de rétention et de **« Flow State »** les plus puissantes du jeu mobile moderne (*Geometry Dash*, *Color Switch*, *Helix Jump*) :

1. **Prise en main instantanée à un doigt** : Faites glisser votre doigt sur l'écran pour diriger votre noyau quantique à travers un couloir cybernétique à haute vitesse avec physique dynamique d'inclinaison.
2. **Mécanique "Near-Miss" (Frôlement / Graze)** : Frôlez les obstacles mortels au millimètre près pour déclencher un ralenti cinématographique (*Slow-Motion Time Dilation*), des gerbes d'étincelles dorées, un retour haptique percutant et des bonus de score massifs !
3. **Mode HYPERDRIVE (Fever Mode)** : Récoltez les cristaux néon (*Cyber Bits*) pour charger votre jauge Overdrive. À 100 %, déchaînez l'**Hyperdrive** : devenez une comète invincible à travers l'hyper-espace qui pulvérise tous les obstacles sur son passage !
4. **Moteur Sonore Procédural 80s Synthwave** : Synthétiseur audio en temps réel intégré via `AVAudioEngine` (arpèges synth, basse résonante, carillons pentatoniques lors des combos, zaps laser). 0 fichier MP3 externe requis, 0 latence !
5. **Retours Haptiques Taptic Engine** : Vibrations fines sur les frôlements, impacts puissants sur les destructions et tremblements d'écran lors des crashes.
6. **Boutique Cyber Core & Quêtes Quotidiennes** : Débloquez 6 skins cybernétiques avec traînées de particules exclusives (*Cyber Pulse*, *Solar Flare*, *Void Phantom*, *Matrix Glitch*, *Inferno Core*, *Prismatic Apex*) et validez vos missions quotidiennes.
7. **Rejeu Instantané (0.2s)** : Crash ? Un simple tap vous replonge immédiatement dans l'action sans aucun écran de chargement fastidieux.

---

## 🚀 Pipeline GitHub Actions : Conversion Automatique en `.ipa`

Le projet inclut un workflow GitHub Actions automatisé (`.github/workflows/build-ipa.yml`) qui s'exécute sur les machines virtuelles macOS d'Apple (`macos-14` avec Apple Silicon).

### Comment obtenir votre fichier `.ipa` en 3 étapes :

1. **Créez un dépôt sur GitHub** et poussez ce dossier :
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Neon Pulse iOS Game"
   git branch -M main
   git remote add origin https://github.com/VOTRE_PSEUDO/NeonPulse-iOS.git
   git push -u origin main
   ```

2. **GitHub Actions compile automatiquement l'IPA** :
   - Rendez-vous sur votre dépôt GitHub, dans l'onglet **Actions**.
   - Vous verrez le job **Build iOS IPA** se lancer.
   - En moins de 3 minutes, le jeu est compilé et converti en fichier `NeonPulse.ipa`.

3. **Téléchargez l'IPA** :
   - Cliquez sur le run terminé dans l'onglet **Actions**.
   - Dans la section **Artifacts**, téléchargez **NeonPulse-iOS-IPA**.
   - Vous pouvez également créer un Tag Git (ex: `git tag v1.0.0 && git push origin v1.0.0`) pour générer automatiquement une **GitHub Release** avec le `.ipa` attaché !

---

## 📲 Comment installer le fichier `.ipa` sur votre iPhone / iPad

L'IPA généré par GitHub Actions est non-signé / ad-hoc, ce qui signifie que vous pouvez l'installer **gratuitement sans payer les 99$/an du compte développeur Apple**, via les outils de sideloading standard :

### Méthode 1 : AltStore (Recommandé - Directement depuis l'iPhone)
1. Installez **[AltStore](https://altstore.io)** sur votre iPhone.
2. Téléchargez `NeonPulse.ipa` sur Safari depuis GitHub.
3. Ouvrez AltStore > onglet **My Apps** > bouton **+** > sélectionnez `NeonPulse.ipa`.
4. AltStore signe l'application avec votre identifiant Apple et l'installe sur votre écran d'accueil !

### Méthode 2 : Sideloadly (PC Windows ou Mac)
1. Téléchargez **[Sideloadly](https://sideloadly.io)** sur votre ordinateur.
2. Branchez votre iPhone via câble USB ou WiFi.
3. Glissez-déposez le fichier `NeonPulse.ipa` dans Sideloadly.
4. Renseignez votre Apple ID (gratuit) et cliquez sur **Start**.

### Méthode 3 : TrollStore / Scarlet / LiveContainer
Si vous possédez TrollStore, Scarlet ou LiveContainer sur votre appareil iOS, ouvrez directement le fichier `.ipa` pour l'installer en un tap !

> **Note iOS** : Lors du premier lancement, rendez-vous dans *Réglages > Général > VPN et gestion des appareils*, puis faites *Faire confiance* à votre certificat personnel.

---

## 📂 Architecture du Projet

```
NeonPulse-iOS/
├── .github/
│   └── workflows/
│       └── build-ipa.yml             # Workflow GitHub Actions CI/CD (Générateur IPA)
├── NeonPulse.xcodeproj/
│   ├── project.pbxproj               # Projet Xcode 15/16 configuré
│   └── xcshareddata/
│       └── xcschemes/
│           └── NeonPulse.xcscheme    # Scheme partagé pour xcodebuild
├── NeonPulse/
│   ├── App/
│   │   ├── NeonPulseApp.swift        # Point d'entrée @main SwiftUI
│   │   └── Info.plist                # Permissions, orientations, 120Hz ProMotion
│   ├── Game/
│   │   ├── GameView.swift            # Vue conteneur SwiftUI SpriteView
│   │   ├── GameScene.swift           # Scène 120 FPS SpriteKit, physique, collisions
│   │   ├── PlayerNode.swift          # Vaisseau avec anneaux rotatifs et inclinaison
│   │   ├── ObstacleNode.swift        # Lasers, mines à pointes, portes de phase, zones Graze
│   │   ├── CollectibleNode.swift     # Bits magnétiques quantiques
│   │   ├── PhysicsCategory.swift     # Masques de collision
│   │   ├── GameState.swift           # State manager partagé (scores, combos, overdrive)
│   │   ├── SoundEngine.swift         # Synthétiseur temps réel PCM (AVAudioEngine)
│   │   ├── HapticManager.swift       # Retours haptiques Taptic Engine
│   │   └── ParticleManager.swift     # Générateur d'étincelles, traînées et explosions
│   ├── Managers/
│   │   ├── ScoreManager.swift        # Missions quotidiennes et stats persistantes
│   │   └── SkinManager.swift         # Gestionnaire de skins déblocables
│   ├── UI/
│   │   ├── HUDView.swift             # HUD néon, jauge overdrive, combo banner
│   │   ├── GameOverView.swift        # Écran de crash, retry 1-tap, records
│   │   ├── ShopView.swift            # Boutique de noyaux cybernétiques
│   │   └── MissionsView.swift        # Cartes des défis quotidiens
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/       # Icône HD 1024x1024 néon générée
│       └── AccentColor.colorset/
├── scripts/
│   ├── build_ipa.sh                  # Script de compilation local pour macOS
│   └── generate_pbxproj.py           # Générateur du fichier de projet Xcode
├── exportOptions.plist
├── .gitignore
└── README.md
```

---

## 💻 Développement Local sur Mac (Xcode)

Si vous disposez d'un Mac avec Xcode installé :
1. Clonez le dépôt :
   ```bash
   git clone https://github.com/VOTRE_PSEUDO/NeonPulse-iOS.git
   cd NeonPulse-iOS
   ```
2. Ouvrez le projet dans Xcode :
   ```bash
   open NeonPulse.xcodeproj
   ```
3. Sélectionnez votre iPhone ou le Simulateur iOS en haut, puis appuyez sur **Cmd + R** pour lancer le jeu !

---

## ⚡ Spécifications Techniques

- **iOS Target** : iOS 15.0 ou version ultérieure (compatible iPhone 6s jusqu'à iPhone 16 Pro Max, et iPad).
- **Framerate** : Compatible 60 FPS et **120 FPS ProMotion** (`CADisableMinimumFrameDurationOnPhone`).
- **Taille de l'IPA** : Ultra-léger (~5 à 8 Mo), rapide à télécharger et installer.
- **Zéro Dépendance Tierce** : Construit à 100% avec les frameworks natifs Apple (`SpriteKit`, `SwiftUI`, `AVFoundation`, `UIKit`).

---

*Développé avec passion pour une expérience arcade néon addictive et sans compromis.*
