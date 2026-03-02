#!/bin/bash
set -euo pipefail

# Process Docker Secret _FILE environment variables
#
# For any variable named FOO_FILE=/path/to/file, reads the file and exports
# FOO=<content>. Trailing newlines are stripped, which is standard for secrets.
#
# If both FOO and FOO_FILE are set, FOO takes precedence and FOO_FILE is ignored.

for var_name in $(compgen -e); do
    # Only process variables ending in _FILE
    [[ "$var_name" == *_FILE ]] || continue

    file_path="${!var_name}"
    [[ -z "$file_path" ]] && continue

    target="${var_name%_FILE}"

    # Skip if the target variable is already set
    if [[ -n "${!target:-}" ]]; then
        echo >&2 "[entrypoint] ${target} already set; ignoring ${var_name}"
        continue
    fi

    if [[ -f "$file_path" ]]; then
        # $(< ...) strips trailing newlines, which is desirable for secrets
        export "${target}=$(< "$file_path")"
        unset "$var_name"
        echo >&2 "[entrypoint] Loaded Docker Secret: ${target}"
    else
        echo >&2 "[entrypoint] Warning: Secret file not found: ${file_path} (for ${var_name})"
    fi
done

exec "$@"
