# upadte-commit-status

This action updates the commit status check of the declared commit sha with the desired state

| Input                  | Description                                                                                           |
| ---------------------- | ----------------------------------------------------------------------------------------------------- |
| *repository_full_name* | The full name of the repository `<org>/<repo>`                                                        |
| *commit_sha*           | The originating commit sha of the event                                                               |
| *context*              | The context name of the status check                                                                  |
| *description*          | The description of the status check                                                                   |
| *status*               | The status of the status check. Can be one of `error`, `failure`, `pending`, `success` or `cancelled` |
| *target_url*           | The target url of the status check. By default returns the current running workflow URL               |




