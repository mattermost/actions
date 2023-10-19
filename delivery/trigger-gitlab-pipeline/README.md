# trigger-gitlab-pipeline

This action can be used to trigger Gitlab Pipelines through the [pipeline trigger](https://docs.gitlab.com/ee/ci/triggers/#create-a-pipeline-trigger-token) functionality.

This environment variable is **mandatory** to be declared.

### Environment Variables

| Environment Variable     | Description                                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| *PIPELINE_TRIGGER_TOKEN* | The token generated from the Gitlab Project [user interface](https://docs.gitlab.com/ee/ci/triggers/#create-a-pipeline-trigger-token) |

### Action Variables

| Action Variables     | Description                                   | Default                             |
| -------------------- | --------------------------------------------- | ----------------------------------- |
| *GITLAB_URL*         | The URL of the Gitlab Server                  | https://git.internal.mattermost.com |
| *GITLAB_PROJECT_ID*  | The ID of the Gitlab Project                  | -                                   |
| *GITLAB_PROJECT_REF* | The reference of the Pipeline to trigger from | main                                |
| *PIPELINE_VARIABLES* | The variables we need to pass to the pipeline | -                                   |

### Action Outputs

| Outputs               | Description                                   |
| --------------------- | --------------------------------------------- |
| *GITLAB_PIPELINE_URL* | The URL of the Gitlab Server                  |
| *GITLAB_PIPELINE_ID*  | The ID of the Gitlab Project                  |
| *GITLAB_PIPELINE_IID* | The reference of the Pipeline to trigger from |
| *GITLAB_PIPELINE_SHA* | The variables we need to pass to the pipeline |


### Example usage

```yaml
steps:
  - name: ci/trigger-gitlab-pipeline
    uses: mattermost/actions/delivery/trigger-gitlab-pipeline@main
    env:
      PIPELINE_TRIGGER_TOKEN: ${{ secrets.PIPELINE_TRIGGER_TOKEN }}
    with:
      GITLAB_PROJECT_ID: 33
      GITLAB_PROJECT_REF: master
      PIPELINE_VARIABLES: |
        BRANCH=master
        DEPLOY_MASTER=true
```