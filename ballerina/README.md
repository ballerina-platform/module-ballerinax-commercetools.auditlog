## Overview

[commercetools](https://commercetools.com/) is a composable commerce platform that provides API-first building blocks for online storefronts, carts, orders, customers and catalogs. Each commercetools Project has settings that control its currencies, countries, languages, cart and message behaviour, and search indexing.

The commercetools Audit Log connector lets Ballerina applications read and update the settings of a commercetools Project. It supports version 1 of the commercetools HTTP API.

### Key features

- Read the settings and configuration of a Project, including currencies, countries, languages and cart rules
- Update Project settings with versioned update actions that protect against concurrent modification
- Authenticate with the OAuth 2.0 client credentials grant using a commercetools API client

## Setup guide

To use the commercetools Audit Log connector, you need a commercetools Project and an API client that can access its settings. If you do not have a commercetools account, you can sign up for a trial [here](https://commercetools.com/free-trial).

### Step 1: Create an API client

1. Open the [Merchant Center](https://mc.commercetools.com/) and select your Project.

2. Go to **Settings** → **Developer settings** and select **Create new API client**.

3. Give the client a name and select the scopes **View project settings** (`view_project_settings`) and **Manage project settings** (`manage_project_settings`).

### Step 2: Note down the credentials

After the client is created, copy the following values. The client secret is shown only once.

* Project key
* Client ID
* Client secret
* Auth URL, for example `https://auth.europe-west1.gcp.commercetools.com`
* API URL, for example `https://api.europe-west1.gcp.commercetools.com`

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
apiUrl = "<API URL>"
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

#### Get the Project settings

```ballerina
public function main() returns error? {
    auditlog:Project _ = check commercetools->getProject(projectKey);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The commercetools Audit Log connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/), covering the following use cases:

1. [Project settings review](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/project_settings_review) - Read the Project settings, report the currency, country, language, cart and message configuration, and fail when a required currency is missing.

2. [Project name update](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/project_name_update) - Rename the Project with a versioned update action and verify the change by reading the Project again.
