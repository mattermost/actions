# create-cloud-installation

This action is used to create a Mattermost cloud installation from Github Actions.

### Usage

```yaml
jobs:
  create-cloud-installation:
    runs-on: <private-runners>
    steps:
      - uses: mattermost/actions/delivery/install-mattermost-cloud-@main
        with:
          version: 0.83.0
          
      - uses: mattermost/actions/delivery/create-cloud-installation@main
        with:
          name: my-first-instance
          server: https://delivery-provisioner.test.mattermost.com
          mattermost-version: 9.5.0
          mattermost-env: |-
            KEY_NAME=VALUE
            KEY_NAME2=VALUE2
          headers: |-
            x-api-key=${{ secrets.MY_TOKEN }}
```

### Inputs

| Input                       | Description                                                                                                                                                                                     | Default                                  | Required |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | -------- |
| name                        | Subdomain at which the Mattermost server will be available. `${name}.test.mattermost.cloud`                                                                                                     |                                          | true     |
| server                      | The provisioning server whose API will be queried.                                                                                                                                              |                                          | true     |
| headers                     | The headers to add in every api call towards the provisioning server. Accepts new line list format                                                                                              |                                          | false    |
| mattermost-version          | The Mattermost version to install.                                                                                                                                                              | latest                                   | true     |
| licence                     | The Mattermost License to use in the server.                                                                                                                                                    |                                          | false    |
| size                        | The size of the installation. Accepts 100users, 1000users, 5000users, 10000users, 25000users, miniSingleton, or miniHA. Defaults to 100users.                                                   | 100users                                 | false    |
| image                       | The Mattermost container image to use. (default "mattermost/mattermost-enterprise-edition")                                                                                                     | mattermost/mattermost-enterprise-edition | false    |
| owner                       | An opaque identifier describing the owner of the installation.                                                                                                                                  | DeliveryTeam                             | false    |
| mattermost-env              | Env vars to add to the Mattermost App. Accepts new line list format                                                                                                                             |                                          | false    |
| priority-env                | Env vars to add to the Mattermost App that take priority over group config. Accepts new line list format                                                                                        |                                          | false    |
| affinity                    | How other installations may be co-located in the same cluster. (default "multitenant")                                                                                                          | multitenant                              | false    |
| annotations                 | Additional annotations for the installation. Accepts multiple values comma separated                                                                                                            | multi-tenant                             | false    |
| database                    | The Mattermost server database type. Accepts mysql-operator, aws-rds, aws-rds-postgres, aws-multitenant-rds, or aws-multitenant-rds-postgres (default "aws-multitenant-rds-postgres-pgbouncer") | aws-multitenant-rds-postgres-pgbouncer   | false    |
| filestore                   | The Mattermost server filestore type. Accepts minio-operator, aws-s3, bifrost, or aws-multitenant-s3 (default "bifrost")                                                                        | bifrost                                  | false    |
| group                       | The id of the group to join                                                                                                                                                                     |                                          | false    |
| group-selection-annotations | Annotations for automatic group selection. Accepts multiple values comma separated                                                                                                              |                                          | false    |

### Outputs

| Output                  | Description                                  |
| ----------------------- | -------------------------------------------- |
| installation-id         | The installation id that was created         |
| cluster-installation-id | The cluster installation id that was created |
| group                   | The group id that the installation joined    |
| owner                   | The owner of the installation                |
| dns                     | The installation DNS                         |
| url                     | The installation URL                         |
| username                | The installation system admin username       |
| password                | The installation system admin password       |
