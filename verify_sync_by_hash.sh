# 📢 Afficher le contexte
echo '🔍 Vérification de synchronisation entre local et GitHub...'
echo

# 1. Hash local
echo '📦 Calcul du hash SHA256 du fichier local : Script_MAJ_VBox_v2.sh'
LOCAL_HASH=$(sha256sum Script_MAJ_VBox_v2.sh | awk '{print $1}')
echo "   → Hash local : $LOCAL_HASH"
echo

# 2. Hash distant (GitHub)
echo '🌐 Récupération et calcul du hash SHA256 depuis GitHub...'
REMOTE_HASH=$(curl -sL https://raw.githubusercontent.com/valorisa/Script_Update_VirtualBox_for_macOS/main/Script_MAJ_VBox_v2.sh | sha256sum | awk '{print $1}')
echo "   → Hash distant : $REMOTE_HASH"
echo

# 3. Comparaison
echo '⚖️  Comparaison des hashes...'
if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
    echo '✅ SUCCESS : Les fichiers sont IDENTIQUES — ta v2 locale est synchronisée avec GitHub !'
else
    echo '❌ WARNING : Les hashes DIFFÈRENT — vérifie que tu as bien poussé la dernière version.'
fi
