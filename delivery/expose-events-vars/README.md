# expose-events-vars

This action can be used with [Push](https://docs.github.com/webhooks-and-events/webhooks/webhook-events-and-payloads#push), [Workflow Run](https://docs.github.com/webhooks-and-events/webhooks/webhook-events-and-payloads#workflow_run). [Pull Request](https://docs.github.com/webhooks-and-events/webhooks/webhook-events-and-payloads#pull_request) or [Status](https://docs.github.com/en/webhooks-and-events/webhooks/webhook-events-and-payloads#status) payload input.  
It breaks down the payload and extracts the environment variables needed from the event as below:

| Environment Variable       | Description                                                         |
| -------------------------- | ------------------------------------------------------------------- |
| *TRIGGERER_EVENT*          | The event that used in the payload                                  |
| *TRIGGERER_BRANCH*         | The originating branch of the event (not available on status event) |
| *TRIGGERER_COMMIT_SHA*     | The originating commit sha of the event                             |
| *TRIGGERER_REPO_NAME*      | The originating repo of the event                                   |
| *TRIGGERER_REPO_FULL_NAME* | The originating full repo of the event `<org>/<repo>`               |
