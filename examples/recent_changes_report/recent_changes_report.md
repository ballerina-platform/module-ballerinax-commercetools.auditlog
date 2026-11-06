# Recent changes report

This example reads the change history of a commercetools Project for a recent time window, follows every page of results, and prints how many changes each user or API client made.

## Prerequisites

### 1. Create a commercetools API client

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret, auth URL, Change History API URL and Project key. The API client needs the `view_audit_log` scope.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<history-api-url>"
projectKey = "<project-key>"
hoursBack = 24.0
pageSize = 50
```

`hoursBack` sets how far back the report looks, and `pageSize` sets how many records are read per request.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
