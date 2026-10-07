# Project settings review

This example reads the settings of a commercetools Project and prints its currencies, countries, languages, cart retention and message settings. It then checks that every currency listed in the comma-separated `requiredCurrencies` value is configured and fails if one is missing.

## Prerequisites

### 1. Create a commercetools API client

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret, auth URL, API URL and Project key. The API client needs the `view_project_settings` scope.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<api-url>"
projectKey = "<project-key>"
requiredCurrencies = "<comma-separated-currency-codes, e.g. EUR,USD>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
