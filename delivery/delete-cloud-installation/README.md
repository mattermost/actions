# delete-cloud-installation

This action is used to delete a Mattermost cloud installation from Github Actions.

### Usage

```yaml
jobs:
  create-cloud-installation:
    runs-on: <private-runners>
    steps:
      - uses: mattermost/actions/delivery/install-mattermost-cloud@main
        with:
          version: 0.83.0
          
      - uses: mattermost/actions/delivery/delete-cloud-installation@main
        with:
          server: https://delivery-provisioner.test.mattermost.com
          installation-id: <my-installation-id> 
          headers: |-
            x-api-key=MY_TOKEN
```

### Inputs

| Input           | Description                                                                                        | Default | Required |
| --------------- | -------------------------------------------------------------------------------------------------- | ------- | -------- |
| server          | The provisioning server whose API will be queried.                                                 |         | true     |
| headers         | The headers to add in every API call towards the provisioning server. Accepts new line list format |         | false    |
| installation-id | The installation id of Mattermost Cloud instance                                                   |         | true     |
