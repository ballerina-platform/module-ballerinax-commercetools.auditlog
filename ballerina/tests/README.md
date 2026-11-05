# Running Tests

## Prerequisites

By default the tests run against a mock Change History server and a mock OAuth 2.0 token endpoint that start with `bal test`, so no credentials are needed.

To run the tests against a real commercetools Project, create an API client with the `view_audit_log` scope (see the [Setup guide](../README.md#setup-guide)) and set these environment variables:

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to use the real service |
| `COMMERCETOOLS_SERVICE_URL` | Change History API URL, for example `https://history.us-central1.gcp.commercetools.com` |
| `COMMERCETOOLS_TOKEN_URL` | Token URL, the auth URL followed by `/oauth/token` |
| `COMMERCETOOLS_CLIENT_ID` | API client ID |
| `COMMERCETOOLS_CLIENT_SECRET` | API client secret |
| `COMMERCETOOLS_PROJECT_KEY` | Key of the Project whose change history is read |

## Test approach

- `testListChangeHistory` lists change records across resource types with `listChangeHistory` and checks the page counts.
- `testListResourceTypeChangeHistory` lists the change records of one resource type with `listResourceTypeChangeHistory`.
- `testGetResourceChangeHistory` takes the first product record and reads that resource's history with `getResourceChangeHistory`.
- `testQueryChangeHistory` runs a GraphQL query with `queryChangeHistory` and checks for data and no errors.

All tests only read data and belong to the `mock_tests` and `live_tests` groups.

## Running the tests

```bash
# Mock server (default)
bal test --groups mock_tests

# Live service
IS_LIVE_SERVER=true bal test --groups live_tests
```
