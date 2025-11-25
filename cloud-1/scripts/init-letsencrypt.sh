#!/usr/bin/env bash

# ===================================
# Script pour obtenir des certificats Let's Encrypt
# Usage: ./init-letsencrypt.sh domaine email [--staging] [--force]
# ===================================

set -euo pipefail

usage() {
    echo "Usage: $0 <domaine> <email> [--staging] [--force]"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

DOMAIN=$1
EMAIL=$2
shift 2

USE_STAGING=false
FORCE_RENEWAL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --staging)
            USE_STAGING=true
            ;;
        --force)
            FORCE_RENEWAL=true
            ;;
        *)
            echo "Option inconnue: $1"
            usage
            ;;
    esac
    shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_NAME="$(basename "${PROJECT_DIR}")"
CERT_ROOT="/var/lib/docker/volumes/${PROJECT_NAME}_certbot_certs/_data"
CERT_PATH="${CERT_ROOT}/live/${DOMAIN}/fullchain.pem"

cd "${PROJECT_DIR}"

if [[ -f "${CERT_PATH}" && "${FORCE_RENEWAL}" == false ]]; then
    echo "✅ Certificat déjà présent pour ${DOMAIN}, aucune action nécessaire."
    exit 0
fi

echo "🔒 Initialisation Let's Encrypt pour ${DOMAIN}"
echo "================================================"

ORIGINAL_CONF="${PROJECT_DIR}/nginx/nginx.conf"
BACKUP_CONF="${PROJECT_DIR}/nginx/nginx-full.conf"
TEMP_CONF="${PROJECT_DIR}/nginx/nginx-temp.conf"
CONFIG_SWITCHED=false

cleanup() {
    if [[ "${CONFIG_SWITCHED}" == true && -f "${BACKUP_CONF}" ]]; then
        mv -f "${BACKUP_CONF}" "${ORIGINAL_CONF}"
        CONFIG_SWITCHED=false
    fi
    rm -f "${TEMP_CONF}" 2>/dev/null || true
}
trap cleanup EXIT

echo "📝 Étape 1 : Création d'une configuration HTTP temporaire"
cat > "${TEMP_CONF}" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://wordpress:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

mv "${ORIGINAL_CONF}" "${BACKUP_CONF}"
mv "${TEMP_CONF}" "${ORIGINAL_CONF}"
CONFIG_SWITCHED=true

echo "🚀 Étape 2 : Démarrage de Nginx (HTTP uniquement)"
docker compose up -d --no-deps --force-recreate nginx
sleep 5

echo "⏳ Vérification que Nginx écoute sur le port 80"
NGINX_READY=false
for attempt in {1..15}; do
    if curl -s http://127.0.0.1/.well-known/acme-challenge/health >/dev/null 2>&1; then
        NGINX_READY=true
        break
    fi
    sleep 2
done

if [[ "${NGINX_READY}" == false ]]; then
    echo "❌ Nginx ne répond pas sur le port 80 après 30s"
    docker compose logs nginx || true
    exit 1
fi

echo "🔐 Étape 3 : Obtention des certificats Let's Encrypt"
CERTBOT_FLAGS=(
    certonly
    --webroot
    --webroot-path=/var/www/certbot
    --email "${EMAIL}"
    --agree-tos
    --no-eff-email
    -d "${DOMAIN}"
)

if [[ "${USE_STAGING}" == true ]]; then
    CERTBOT_FLAGS+=(--staging)
fi

if [[ "${FORCE_RENEWAL}" == true ]]; then
    CERTBOT_FLAGS+=(--force-renewal)
fi

docker compose run --rm --entrypoint certbot certbot "${CERTBOT_FLAGS[@]}"

echo "✅ Certificats obtenus avec succès"
cleanup
trap - EXIT

echo "🔄 Étape 4 : Restauration de la configuration HTTPS"
docker compose restart nginx

echo ""
echo "================================================"
echo "📁 Certificats : ${CERT_ROOT}/live/${DOMAIN}/"
echo "🌐 Vérifie https://${DOMAIN}/ et https://${DOMAIN}/phpmyadmin"
echo ""
