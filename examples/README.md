# Examples

The `ballerinax/commercetools.auditlog` connector provides practical examples illustrating usage in various scenarios.

1. **[Project settings review](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/project_settings_review)** - Read the Project settings, report the currency, country, language, cart and message configuration, and fail when a required currency is missing.

2. **[Project name update](https://github.com/ballerina-platform/module-ballerinax-commercetools.auditlog/tree/main/examples/project_name_update)** - Rename the Project with a versioned update action and verify the change by reading the Project again.

## Prerequisites

1. Create a commercetools API client as described in the [Setup guide](https://central.ballerina.io/ballerinax/commercetools.auditlog/latest#setup-guide).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your Config.toml file should look:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<api-url>"
projectKey = "<project-key>"
```

Each example lists the additional values it needs in its own README.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
