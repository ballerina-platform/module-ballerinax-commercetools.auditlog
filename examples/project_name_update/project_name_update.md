# Project name update

This example reads the current name and version of a commercetools Project, renames it with a versioned `changeName` update action, and reads the Project again to verify the new name.

## Prerequisites

### 1. Create a commercetools API client

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret, auth URL, API URL and Project key. The API client needs the `view_project_settings` and `manage_project_settings` scopes.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<api-url>"
projectKey = "<project-key>"
newProjectName = "<new-project-name>"
applyChange = false
```

Renaming a Project changes it for every user, so the example only applies the change when `applyChange` is `true`. Otherwise it prints the rename it would perform.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
