## Overview

[commercetools](https://commercetools.com/) is a composable commerce platform that provides API-first building blocks for storefronts, carts, orders, customers and catalogs. Its Change History API records every change made to the resources of a Project, including who changed what and when.

The commercetools Audit Log connector lets applications query this change history with REST requests or GraphQL queries. It supports version 1 of the commercetools Change History API.

### Key features

- List the change history across the resources of a Project
- Read the full change trail of a single resource of a given type
- Query the change history with GraphQL for exactly the fields you need
- Authenticate with the OAuth 2.0 client credentials grant using a commercetools API client

## Setup guide

To use the commercetools Audit Log connector, you need a commercetools Project and an API client that can read its change history. If you do not have a commercetools account, you can sign up for a trial [here](https://commercetools.com/free-trial).

### Step 1: Create an API client

1. Open the [Merchant Center](https://mc.commercetools.com/) and select your Project.

2. Go to **Settings** → **Developer settings** and select **Create new API client**.

3. Give the client a name and select the scope **View audit log** (`view_audit_log`). To read the history of a resource type, also grant the view scope of that type, for example `view_products` for products.

### Step 2: Note down the credentials

After the client is created, copy the following values. The client secret is shown only once.

* Project key
* Client ID
* Client secret
* Auth URL, for example `https://auth.us-central1.gcp.commercetools.com`
* Change History API URL, for example `https://history.us-central1.gcp.commercetools.com`

The token URL is the auth URL followed by `/oauth/token`.

## Quickstart

To use the commercetools Audit Log connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `commercetools.auditlog` module.

```ballerina
import ballerinax/commercetools.auditlog;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the credentials obtained in the steps above:

```toml
clientId = "<Client ID>"
clientSecret = "<Client Secret>"
tokenUrl = "<Auth URL>/oauth/token"
apiUrl = "<Change History API URL>"
projectKey = "<Project key>"
```

2. Create an `auditlog:ConnectionConfig` with the OAuth 2.0 client credentials and initialize the connector with it.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;

final auditlog:Client commercetools = check new ({
    auth: {
        tokenUrl,
        clientId,
        clientSecret
    }
}, apiUrl);
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### List the change history of a Project

```ballerina
public function main() returns error? {
    auditlog:RecordPagedQueryResponse _ = check commercetools->listChangeHistory(projectKey);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The commercetools Audit Log connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/), covering the following use cases:

1. [Recent changes report](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/recent_changes_report) - Read the Project's change history for a recent time window, follow every page, and report how many changes each user made.

2. [Resource change trail](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/resource_change_trail) - Find the most recently changed resource of a type and print its full change trail.
