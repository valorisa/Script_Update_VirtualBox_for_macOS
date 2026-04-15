# 🔄 Script de Mise à Jour VirtualBox pour macOS (CLI) — v2

> **Un script Bash robuste et sécurisé pour automatiser l'installation et la mise à jour de VirtualBox 7.x sur macOS.**  
> Conçu pour la production : gestion d'erreurs stricte, validation des entrées, mode `--dry-run`, journalisation et compatibilité Apple Silicon.

![macOS 12+](https://img.shields.io/badge/macOS-12%2B-blue?style=flat-square&logo=apple)
![VirtualBox 7.x](https://img.shields.io/badge/VirtualBox-7.x-orange?style=flat-square&logo=virtualbox)
![Bash 5.2+](https://img.shields.io/badge/Bash-5.2%2B-green?style=flat-square&logo=gnu-bash&logoColor=white)
![ShellCheck](https://img.shields.io/badge/ShellCheck-validated-brightgreen?style=flat-square)
![License MIT](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)

![367247962_310921638381166_5778974277649585141_n](https://github.com/valorisa/Script_Update_VirtualBox_for_macOS/assets/13067566/c8dd0322-6dba-45e2-b73e-8fd58881159e)

---

## 📋 Table des Matières

1. [✨ Fonctionnalités](#-fonctionnalités)
2. [⚠️ Prérequis](#-prérequis)
3. [🚀 Installation](#-installation)
4. [🎮 Utilisation](#-utilisation)
5. [🛡 Sécurité & Bonnes Pratiques](#-sécurité--bonnes-pratiques)
6. [📝 Journalisation & Debug](#-journalisation--debug)
7. [🐛 Dépannage](#-dépannage)
8. [📌 Changelog](#-changelog)
9. [🤝 Contribuer](#-contribuer)
10. [📜 Licence](#-licence)

---

## ✨ Fonctionnalités

- ✅ **Mise à jour automatisée** de VirtualBox 7.x depuis les serveurs officiels Oracle
- 🔐 **Sécurité renforcée** : `set -euo pipefail`, validation regex des entrées, `umask 077`
- 🎛 **Interface CLI flexible** : mode interactif, arguments nommés, `--dry-run`, `--verbose`
- 🍎 **Détection d'architecture** : avertissements contextuels pour Apple Silicon (ARM64)
- 🧹 **Nettoyage automatique** : `trap` de sortie, démontage DMG, suppression des fichiers temporaires
- 📝 **Journalisation** : logs horodatés dans `~/Library/Logs/vbox-update.log`
- 🌐 **Téléchargements fiables** : `curl` avec retry, vérification de taille, chemins sécurisés
- ⚡ **Modulaire** : fonctions dédiées pour chaque étape, facilement testable et maintenable

---

## ⚠️ Prérequis

| Catégorie | Requis | Vérification |
|-----------|--------|--------------|
| **Système** | macOS 12+ (Monterey) | `sw_vers -productVersion` |
| **Architecture** | Intel ou Apple Silicon (M1/M2/M3) | `uname -m` |
| **Espace disque** | ~2 Go libres dans `~/Downloads` | `df -h ~/Downloads` |
| **Permissions** | Droits administrateur (`sudo`) | Requis pour l'installation système |
| **État VirtualBox** | Application **fermée** | Quittez via `Cmd+Q` ou `killall VirtualBox` |

> ⚠️ **Note Apple Silicon** : VirtualBox 7.1+ supporte nativement les VM **ARM64**. L'émulation x86_64 reste expérimentale et peut présenter des limitations (USB 3.0, OpenGL, performances). Consultez la [documentation officielle macOS](https://www.virtualbox.org/wiki/MacOS_host_support).

---

## 🚀 Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/valorisa/Script_Update_VirtualBox_for_macOS.git
cd Script_Update_VirtualBox_for_macOS

# 2. Rendre le script exécutable
chmod +x Script_MAJ_VBox_v2.sh

# 3. (Optionnel mais recommandé) Valider la syntaxe
brew install shellcheck
shellcheck Script_MAJ_VBox_v2.sh  # Doit retourner 0 warning

# 4. Lancer le script
./Script_MAJ_VBox_v2.sh
```

💡 *Astuce* : Ajoutez-le à votre `PATH` pour un accès global :
```bash
ln -s "$PWD/Script_MAJ_VBox_v2.sh" /usr/local/bin/vbox-update
# Puis utilisez simplement : vbox-update
```

---

## 🎮 Utilisation

### 🟢 Mode Interactif (par défaut)
```bash
$ ./Script_MAJ_VBox_v2.sh
╔══════════════════════════════════════════════════════════════╗
║  🔄 VirtualBox Updater for macOS — Version 2.0               ║
║  Automatisation sécurisée de l'installation VirtualBox 7.x   ║
╚══════════════════════════════════════════════════════════════╝
ℹ️  [INFO] Architecture détectée: Apple Silicon (arm64)
⚠️  [WARNING] VirtualBox sur Apple Silicon : seules les VM ARM64 sont pleinement supportées
✅ [SUCCESS] Prérequis vérifiés
📦 Version de VirtualBox à installer (ex: 7.0.12): 7.0.12
🔢 Numéro de build Oracle (ex: 150234): 150234
ℹ️  [INFO] 🎯 Cible: VirtualBox v7.0.12 build 150234
ℹ️  [INFO] Téléchargement: VirtualBox Installer
✅ [SUCCESS] VirtualBox Installer téléchargé
...
🎉 [SUCCESS] Mise à jour VirtualBox terminée avec succès !
```

### 🔵 Mode CLI Non-Interactif
```bash
# Installation ciblée
./Script_MAJ_VBox_v2.sh --version 7.0.12 --build 150234

# Détection automatique de la dernière version
./Script_MAJ_VBox_v2.sh --auto-version

# Simulation sans exécution (idéal pour tester/CI)
./Script_MAJ_VBox_v2.sh --version 7.0.12 --build 150234 --dry-run --verbose

# Installation silencieuse + nettoyage post-install
./Script_MAJ_VBox_v2.sh --version 7.0.12 --build 150234 --skip-extpack --cleanup

# Dossier de téléchargement personnalisé
./Script_MAJ_VBox_v2.sh --version 7.0.12 --build 150234 --download-dir "$HOME/Installers"
```

### 📊 Options Disponibles

| Option | Description | Valeur par défaut |
|--------|-------------|-------------------|
| `--version <X.Y.Z>` | Version cible de VirtualBox | *Interactive* |
| `--build <NUM>` | Numéro de build Oracle | *Interactive* |
| `--auto-version` | Récupère la dernière version depuis Oracle | `false` |
| `--skip-extpack` | Ignore l'installation de l'Extension Pack | `false` |
| `--dry-run` | Affiche les commandes sans les exécuter | `false` |
| `--verbose` | Active la sortie détaillée (debug) | `false` |
| `--cleanup` | Supprime les fichiers téléchargés après succès | `false` |
| `--download-dir <PATH>` | Dossier de téléchargement personnalisé | `~/Downloads` |
| `--help` | Affiche l'aide et quitte | - |

---

## 🛡 Sécurité & Bonnes Pratiques

### ✅ Ce que fait le script
- Télécharge **uniquement** depuis `https://download.virtualbox.org` (HTTPS)
- Valide strictement le format des entrées (`X.Y.Z` pour la version, chiffres pour le build)
- Utilise `set -euo pipefail` pour arrêter l'exécution à la première erreur
- Échappe correctement les variables et chemins contenant des espaces
- Crée un dossier temporaire isolé et le nettoie automatiquement (`trap EXIT`)
- Vérifie que les fichiers téléchargés ne sont pas vides avant poursuite

### ❌ Ce que le script NE fait PAS
- Ne collecte aucune donnée, télémétrie ou identifiant
- Ne modifie pas vos machines virtuelles (`~/VirtualBox VMs/`)
- Ne désactive pas SIP, Gatekeeper ou les vérifications de signature macOS
- Ne force pas l'installation en cas d'échec réseau ou de checksum invalide
- N'exécute jamais de code non vérifié depuis des sources tierces

### 🔍 Audit avant exécution (recommandé)
```bash
# Lire le script
less Script_MAJ_VBox_v2.sh

# Vérifier la syntaxe
bash -n Script_MAJ_VBox_v2.sh && echo "✅ Syntaxe valide"

# Analyser les bonnes pratiques
shellcheck Script_MAJ_VBox_v2.sh
```

---

## 📝 Journalisation & Debug

Le script enregistre automatiquement les actions dans :
```
~/Library/Logs/vbox-update.log
```

### Activer le mode verbeux
```bash
./Script_MAJ_VBox_v2.sh --version 7.0.12 --build 150234 --verbose
```

### Consulter les logs en temps réel
```bash
# Suivre les logs du script
tail -f ~/Library/Logs/vbox-update.log

# Consulter les logs système d'installation
log show --predicate 'process == "installer"' --last 15m
```

### Exemple de sortie log
```
[2026-04-15 18:45:12] [INFO] Starting VirtualBox update process
[2026-04-15 18:45:13] [INFO] Architecture detected: arm64
[2026-04-15 18:45:14] [SUCCESS] Prerequisites verified
[2026-04-15 18:45:15] [INFO] Downloading: VirtualBox Installer
[2026-04-15 18:45:42] [SUCCESS] VirtualBox Installer downloaded
...
```

---

## 🐛 Dépannage

| Symptôme | Cause Probable | Solution |
|----------|----------------|----------|
| `curl: command not found` | Outils CLI manquants | `xcode-select --install` |
| `hdiutil: mount failed` | Fichier `.dmg` corrompu ou incomplet | Supprimez `~/Downloads/VirtualBox_*` et relancez |
| `VBoxManage: command not found` | PATH non rechargé | Redémarrez le terminal ou `source ~/.zshrc` |
| Échec sur Apple Silicon | VM x86_64 non supportée nativement | Utilisez une image **ARM64** (ex: Oracle Linux for Arm) |
| Extension Pack bloque | VirtualBox encore ouvert ou licence non acceptée | Quittez complètement l'app, relancez avec `--verbose` |
| `Permission denied` sur l'installation | Droits sudo insuffisants | Vérifiez que votre utilisateur est dans le groupe `admin` |

### 🔄 Réinitialisation propre
```bash
# Nettoyage complet des fichiers temporaires
rm -rf ~/Downloads/VirtualBox_*
rm -rf /tmp/vbox-update-*

# Arrêt forcé de VirtualBox si nécessaire
killall VirtualBox 2>/dev/null || true

# Réinstallation via Homebrew si le script échoue
brew uninstall --cask virtualbox
brew install --cask virtualbox
```

### 📞 Obtenir de l'aide
```bash
# Afficher l'aide complète
./Script_MAJ_VBox_v2.sh --help

# Mode debug maximal
./Script_MAJ_VBox_v2.sh --version 7.0.12 --build 150234 --verbose --dry-run 2>&1 | tee debug.log
```

---

## 📌 Changelog

### v2.0.0 (2026) — Réécriture complète production-ready
```
✨ NOUVEAUTÉS :
• Interface CLI complète : --version, --build, --auto-version, --dry-run, --verbose...
• Détection automatique d'architecture avec avertissements Apple Silicon
• Journalisation horodatée dans ~/Library/Logs/vbox-update.log
• Fonction fetch_latest_version() via LATEST.TXT d'Oracle
• Option --cleanup pour supprimer les fichiers après installation
• Option --download-dir pour personnaliser le dossier de téléchargement

🔐 SÉCURITÉ :
• set -euo pipefail + umask 077 + IFS sécurisé
• Validation regex stricte des entrées version/build
• Vérification que les fichiers téléchargés ne sont pas vides
• Trap cleanup pour démontage auto et suppression des temporaires

🛠 TECHNIQUE :
• Remplacement wget → curl avec --retry et vérification HTTPS
• Fonctions modulaires : download_, install_, validate_, log_
• Sortie colorée avec emojis et niveaux de log (INFO/SUCCESS/ERROR)
• Gestion robuste des chemins avec espaces et variables d'environnement

🧪 TESTING :
• Mode --dry-run pour simulation sans exécution réelle
• Messages d'erreur explicites avec codes de retour
• Compatibilité testée Intel + Apple Silicon (M1/M2/M3)
```

### v1.x (Legacy)
```
• Script interactif basique
• Téléchargement via wget
• Aucune validation d'entrées
• Pas de gestion d'erreurs structurée
→ Conservé en Script_MAJ_VBox_v1_legacy.sh pour référence
```

---

## 🤝 Contribuer

Les contributions sont les bienvenues ! 🙌

### 📬 Processus de contribution
1. Forkez le dépôt
2. Créez une branche : `git checkout -b feat/ma-fonctionnalite`
3. Testez avec `shellcheck` et `bash -n`
4. Committez : `git commit -m "feat: description claire et concise"`
5. Poussez et ouvrez une Pull Request

### 🧪 Tests Requis avant PR
- [ ] Fonctionne sur macOS 12+ (Intel & Apple Silicon)
- [ ] `shellcheck Script_MAJ_VBox_v2.sh` retourne `0` erreur/warning
- [ ] Le mode `--dry-run` affiche exactement les commandes attendues
- [ ] Gestion d'erreur testée (réseau coupé, espace disque insuffisant, VirtualBox ouvert)
- [ ] Les logs sont correctement écrits dans `~/Library/Logs/vbox-update.log`

### 💡 Idées d'Amélioration Futures
- [ ] Vérification SHA256 des téléchargements depuis Oracle
- [ ] Support de la mise à jour via Homebrew Cask en alternative
- [ ] Notification macOS post-installation via `osascript`
- [ ] Backup automatique des VMs avant mise à jour
- [ ] Workflow GitHub Actions pour validation CI/CD

---

## 📜 Licence

Ce projet est distribué sous licence **MIT**.  
Voir le fichier [`LICENSE`](LICENSE) pour plus de détails.

```
MIT License

Copyright (c) 2026 valorisa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

> **⚠️ Disclaimer** : VirtualBox est une marque déposée d'Oracle Corporation. Ce script n'est pas affilié, approuvé ou sponsorisé par Oracle. Il est fourni "tel quel" à des fins d'automatisation et d'apprentissage. L'utilisateur est responsable de l'utilisation du script et de la conformité avec les licences logicielles.

---

*Made with 🍎 & ☕ by [valorisa](https://github.com/valorisa) — Optimisé pour macOS Sequoia & Apple Silicon*
