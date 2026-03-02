# mcp-auth-proxy-secrets

A Docker image that wraps [`ghcr.io/sigbit/mcp-auth-proxy`](https://github.com/sigbit/mcp-auth-proxy) with [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/) support.

The upstream image reads all configuration from environment variables. This wrapper adds the `_FILE` convention: set `<VAR>_FILE=/path/to/secret` instead of `<VAR>=value` and the entrypoint will read the file and populate the variable. This enables secure secret injection via Docker Secrets, Kubernetes Secrets, or any file-based secret manager without embedding sensitive values in environment variables.

## Usage

### Docker Compose with Docker Secrets

```yaml
secrets:
  google_client_secret:
    file: ./secrets/google_client_secret.txt

services:
  mcp-auth-proxy:
    image: ghcr.io/danschultz/mcp-auth-proxy:latest
    environment:
      EXTERNAL_URL: https://proxy.example.com
      GOOGLE_CLIENT_ID: your-client-id
      GOOGLE_CLIENT_SECRET_FILE: /run/secrets/google_client_secret
    secrets:
      - google_client_secret
    ports:
      - "80:80"
```

### Docker Swarm

```bash
echo "your-secret-value" | docker secret create google_client_secret -

docker service create \
  --name mcp-auth-proxy \
  --secret google_client_secret \
  --env EXTERNAL_URL=https://proxy.example.com \
  --env GOOGLE_CLIENT_ID=your-client-id \
  --env GOOGLE_CLIENT_SECRET_FILE=/run/secrets/google_client_secret \
  ghcr.io/danschultz/mcp-auth-proxy:latest
```

### Plain Docker (file-based secrets)

```bash
docker run \
  -v /path/to/secret.txt:/run/secrets/google_secret:ro \
  -e EXTERNAL_URL=https://proxy.example.com \
  -e GOOGLE_CLIENT_ID=your-client-id \
  -e GOOGLE_CLIENT_SECRET_FILE=/run/secrets/google_secret \
  ghcr.io/danschultz/mcp-auth-proxy:latest
```

## Supported `_FILE` Variables

Any environment variable accepted by mcp-auth-proxy can use the `_FILE` convention. Common examples:

| `_FILE` Variable | Populates | Description |
|---|---|---|
| `EXTERNAL_URL_FILE` | `EXTERNAL_URL` | External URL for the proxy |
| `PASSWORD_FILE` | `PASSWORD` | Plain text password |
| `PASSWORD_HASH_FILE` | `PASSWORD_HASH` | Bcrypt hash of password |
| `GOOGLE_CLIENT_ID_FILE` | `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET_FILE` | `GOOGLE_CLIENT_SECRET` | Google OAuth client secret |
| `GOOGLE_ALLOWED_USERS_FILE` | `GOOGLE_ALLOWED_USERS` | Comma-separated allowed emails |
| `GOOGLE_ALLOWED_WORKSPACES_FILE` | `GOOGLE_ALLOWED_WORKSPACES` | Comma-separated allowed workspaces |
| `GITHUB_CLIENT_ID_FILE` | `GITHUB_CLIENT_ID` | GitHub OAuth client ID |
| `GITHUB_CLIENT_SECRET_FILE` | `GITHUB_CLIENT_SECRET` | GitHub OAuth client secret |
| `GITHUB_ALLOWED_USERS_FILE` | `GITHUB_ALLOWED_USERS` | Comma-separated allowed GitHub usernames |
| `GITHUB_ALLOWED_ORGS_FILE` | `GITHUB_ALLOWED_ORGS` | Comma-separated allowed GitHub orgs/teams |
| `OIDC_CONFIGURATION_URL_FILE` | `OIDC_CONFIGURATION_URL` | OIDC configuration endpoint URL |
| `OIDC_CLIENT_ID_FILE` | `OIDC_CLIENT_ID` | OIDC client ID |
| `OIDC_CLIENT_SECRET_FILE` | `OIDC_CLIENT_SECRET` | OIDC client secret |
| `OIDC_ALLOWED_USERS_FILE` | `OIDC_ALLOWED_USERS` | Exact match user list |
| `OIDC_ALLOWED_USERS_GLOB_FILE` | `OIDC_ALLOWED_USERS_GLOB` | Glob pattern user list |
| `PROXY_BEARER_TOKEN_FILE` | `PROXY_BEARER_TOKEN` | Bearer token for proxied requests |
| `REPOSITORY_DSN_FILE` | `REPOSITORY_DSN` | Database connection string |

For the full list of environment variables, see the [upstream configuration docs](https://sigbit.github.io/mcp-auth-proxy/docs/configuration).

**Precedence:** If both `FOO` and `FOO_FILE` are set, `FOO` takes precedence and `FOO_FILE` is ignored.

## Building Locally

```bash
docker build -t mcp-auth-proxy-secrets .
```

To pin to a specific upstream version:

```bash
docker build \
  --build-arg BASE_IMAGE=ghcr.io/sigbit/mcp-auth-proxy:v1.2.3 \
  -t mcp-auth-proxy-secrets .
```

## Release Process

Images are published to GitHub Container Registry at `ghcr.io/danschultz/mcp-auth-proxy`.

### Pull Request Builds

Every pull request targeting `main` automatically builds and pushes a test image:

```
ghcr.io/danschultz/mcp-auth-proxy:pr-42
```

### Versioned Releases

To publish a release, go to **Actions → Release → Run workflow** and enter the version number (e.g. `1.0.0`). The workflow will:

1. Create and push the `v1.0.0` git tag
2. Build and push multi-platform images (`linux/amd64`, `linux/arm64`)
3. Create a GitHub Release with auto-generated release notes

The following image tags are published:

| Tag | Example |
|---|---|
| Exact version | `v1.0.0` |
| Minor alias | `1.0` |
| Major alias | `1` |
| Latest | `latest` |
