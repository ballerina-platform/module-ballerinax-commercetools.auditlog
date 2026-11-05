# Resource change trail

This example finds the most recently changed resource of a given type in a commercetools Project and prints its full change trail, showing the version, time, author and kind of each change.

## Prerequisites

### 1. Create a commercetools API client

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret, auth URL, Change History API URL and Project key. The API client needs the `view_audit_log` scope, plus the view scope of the resource type you query, for example `view_products`.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<history-api-url>"
projectKey = "<project-key>"
resourceType = "product"
```

`resourceType` is any resource type supported by the Change History API, for example `product`, `customer` or `order`.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
