#!/usr/bin/env bash
set -euo pipefail

: "${TRAEFIK_DOMAIN_EMAIL:?Задайте TRAEFIK_DOMAIN_EMAIL}"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
docker_dir=$(cd "$script_dir/.." && pwd -P)

cat > "$docker_dir/traefik/config/traefik-prod.yml" <<EOF
log:
  level: INFO

api:
  dashboard: true

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
          permanent: true

  https:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false

certificatesResolvers:
  le:
    acme:
      tlsChallenge: true
      email: "$TRAEFIK_DOMAIN_EMAIL"
      storage: "/letsencrypt/acme.json"
EOF
