# install-mattermost-cloud-cli

This action is used to install the Mattermost cloud CLI.

### Usage

```yaml
jobs:
  install-mattermost-cloud-cli:
    runs-on: <private-runners>
    steps:
      - uses: mattermost/actions/delivery/install-mattermost-cloud@main
        with:
          version: 0.83.0
```

### Inputs

| Input   | Description                                    | Default | Required |
| ------- | ---------------------------------------------- | ------- | -------- |
| version | The version of Mattermost Cloud CLI to install | 0.82.0  | true     |
