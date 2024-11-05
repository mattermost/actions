# create-check-run

This action creates a new check run of the declared commit sha with the desired state

| Input                  | Description                                                                                           |
| ---------------------- | ----------------------------------------------------------------------------------------------------- |
| *repository_full_name* | The full name of the repository `<org>/<repo>`                                                        |
| *commit_sha*           | The originating commit sha of the event                                                               |
| *name*                 | The name of the check                                                                                 |
| *summary*              | The summary of the check                                                                              |
| *title*                | The title of the check                                                                                |
| *status*               | The status of the status check. Can be one of `queued`, `in_progress` or `completed`                  |
| *details_url*          | The target url of the status check. By default returns the current running workflow URL               |




