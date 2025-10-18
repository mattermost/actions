# anchore-scan

This action scans Docker images with Anchore for security vulnerabilities. It supports optional Tailscale connectivity for private network access.

### Usage

#### With Tailscale (default)

```yaml
jobs:
  scan:
    runs-on: ubuntu-22.04
    steps:
      - uses: mattermost/actions/delivery/anchore-scan@main
        with:
          image_name: '<MATTERMOST_IMAGE>'
          dockerfile_path: '<RELATIVE_PATH_TO_DOCKERFILE>'
          anchorectl_url: ${{ secrets.ANCHORECTL_URL }}
          anchorectl_username: ${{ secrets.ANCHORECTL_USERNAME }}
          anchorectl_password: ${{ secrets.ANCHORECTL_PASSWORD }}
          ts_oauth_client_id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          ts_oauth_secret: ${{ secrets.TS_OAUTH_SECRET }}
```

#### Without Tailscale

```yaml
jobs:
  scan:
    runs-on: ubuntu-22.04
    steps:
      - uses: mattermost/actions/delivery/anchore-scan@main
        with:
          image_name: '<MATTERMOST_IMAGE>'
          dockerfile_path: '<RELATIVE_PATH_TO_DOCKERFILE>'
          anchorectl_url: ${{ secrets.ANCHORECTL_URL }}
          anchorectl_username: ${{ secrets.ANCHORECTL_USERNAME }}
          anchorectl_password: ${{ secrets.ANCHORECTL_PASSWORD }}
          use_tailscale: 'false'
```

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `image_name` | Docker image name to scan (with tag) | Yes | - |
| `dockerfile_path` | Path to Dockerfile for context | No | `./Dockerfile` |
| `show_vulnerabilities` | Whether to retrieve and display vulnerabilities after adding image | No | `true` |
| `anchorectl_url` | Anchore URL | Yes | - |
| `anchorectl_username` | Anchore username | Yes | - |
| `anchorectl_password` | Anchore password | Yes | - |
| `use_tailscale` | Whether to use Tailscale for network connectivity | No | `true` |
| `ts_oauth_client_id` | Tailscale OAuth client ID | No* | - |
| `ts_oauth_secret` | Tailscale OAuth secret | No* | - |

\* Required when `use_tailscale` is `true` (default)

### Outputs

| Output | Description |
|--------|-------------|
| `vulnerabilities_file` | Path to vulnerabilities text file |
| `image_added` | Whether image was successfully added |
