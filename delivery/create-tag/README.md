# create-tag

This actions is used to create annotated tags from Github Actions.

> **Warning**  
> This action needs content write permissions on the workflow

### Usage

```yaml
jobs:
  tag-version:
    permissions:
      contents: write
    runs-on: ubuntu-22.04
    steps:
      - uses: mattermost/actions/delivery/create-tag@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag: v0.0.1
          message: So much changed in this version
          commit_sha: ${{ github.sha }}
```