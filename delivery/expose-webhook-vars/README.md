# expose-webhook-vars

This action can be used with [Push](https://docs.github.com/webhooks-and-events/webhooks/webhook-events-and-payloads#push) or [Workflow Run](https://docs.github.com/webhooks-and-events/webhooks/webhook-events-and-payloads#workflow_run) payload input.  
It breaks down the payload and extracts the environment variables needed from the event as below:

| Environment Variable       | Description                                                         |
| -------------------------- | ------------------------------------------------------------------- |
| *TRIGGERER_EVENT*          | The event that used in the payload. Can be `push` or `workflow_run` |
| *TRIGGERER_BRANCH*         | The originating branch of the event                                 |
| *TRIGGERER_COMMIT_SHA*     | The originating commit sha of the event                             |
| *TRIGGERER_REPO_NAME*      | The originating repo of the event                                   |
| *TRIGGERER_REPO_FULL_NAME* | The originating full repo of the event `<org>/<repo>`               |
