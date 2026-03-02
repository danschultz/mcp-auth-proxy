#!/bin/bash
set -euo pipefail

# Supported _FILE variables for Docker Secrets.
# For each entry, if FOO_FILE is set, reads the file and exports FOO=<content>.
# If both FOO and FOO_FILE are set, FOO takes precedence.
FILE_VARS=(
    PASSWORD_FILE:PASSWORD
    GOOGLE_CLIENT_SECRET_FILE:GOOGLE_CLIENT_SECRET
    GITHUB_CLIENT_SECRET_FILE:GITHUB_CLIENT_SECRET
    OIDC_CLIENT_SECRET_FILE:OIDC_CLIENT_SECRET
    PROXY_BEARER_TOKEN_FILE:PROXY_BEARER_TOKEN
    REPOSITORY_DSN_FILE:REPOSITORY_DSN
)

for entry in "${FILE_VARS[@]}"; do
    file_var="${entry%%:*}"
    target="${entry##*:}"
    file_path="${!file_var:-}"

    [[ -z "$file_path" ]] && continue

    if [[ -n "${!target:-}" ]]; then
        echo >&2 "[entrypoint] ${target} already set; ignoring ${file_var}"
        continue
    fi

    if [[ -f "$file_path" ]]; then
        export "${target}=$(< "$file_path")"
        unset "$file_var"
        echo >&2 "[entrypoint] Loaded Docker Secret: ${target}"
    else
        echo >&2 "[entrypoint] Warning: Secret file not found: ${file_path} (for ${file_var})"
    fi
done

exec /usr/local/bin/mcp-auth-proxy "$@"
