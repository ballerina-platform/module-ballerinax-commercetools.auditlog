# Running Tests

## Prerequisites

By default the tests run against a mock commercetools server and a mock OAuth 2.0 token endpoint that start with `bal test`, so no credentials are needed.

To run the tests against a real commercetools Project, create an API client with the `view_project_settings` and `manage_project_settings` scopes (see the [Setup guide](../README.md#setup-guide)) and set these environment variables:

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to use the real service |
| `COMMERCETOOLS_SERVICE_URL` | API URL, for example `https://api.europe-west1.gcp.commercetools.com` |
| `COMMERCETOOLS_TOKEN_URL` | Token URL, the auth URL followed by `/oauth/token` |
| `COMMERCETOOLS_CLIENT_ID` | API client ID |
| `COMMERCETOOLS_CLIENT_SECRET` | API client secret |
| `COMMERCETOOLS_PROJECT_KEY` | Key of the Project to read and update |

## Test approach

- `testGetProject` reads the Project settings with `getProject` and checks the key, name and currencies.
- `testUpdateProject` reads the Project, applies a `changeName` update action with `updateProject` using the current version, and checks the returned Project. The mock run renames the Project and checks the new name and a higher version; the live run re-applies the current name.

Both tests belong to the `mock_tests` and `live_tests` groups. On a live Project the update test leaves the name unchanged and only bumps the version.

## Running the tests

```bash
# Mock server (default)
bal test --groups mock_tests

# Live service
IS_LIVE_SERVER=true bal test --groups live_tests
```
