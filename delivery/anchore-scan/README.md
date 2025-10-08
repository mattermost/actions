# anchore-scan

This action scans Docker images with Anchore for security vulnerabilities using Tailscale connectivity.

### Usage

```yaml
jobs:
  scan:
    runs-on: ubuntu-22.04
    steps:
      - uses: mattermost/actions/delivery/anchore-scan@main
        with:
          image_name: '<MATTERMOST_IMAGE>'
          dockerfile_path: '<RELATIVE_PATH_TO_DOCKERFILE>'
          anchorectl_url: ${{ secrets.ANCHORE_URL }}
          anchorectl_username: ${{ secrets.ANCHORE_USERNAME }}
          anchorectl_password: ${{ secrets.ANCHORE_PASSWORD }}
          ts_oauth_client_id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          ts_oauth_secret: ${{ secrets.TS_OAUTH_SECRET }}
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
| `ts_oauth_client_id` | Tailscale OAuth client ID | Yes | - |
| `ts_oauth_secret` | Tailscale OAuth secret | Yes | - |

### Outputs

| Output | Description |
|--------|-------------|
| `vulnerabilities_file` | Path to vulnerabilities text file |
| `image_added` | Whether image was successfully added |