_Author_:  @DimuthuMadushan \
_Created_: 2026/10/06 \
_Updated_: 2026/11/05 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the commercetools Change History OpenAPI specification.
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/commercetools/history/v1/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.
All changes below were made in the original `docs/spec/openapi.yaml`.

## Sanitization Details

1. Change the `url` property of the servers object to the `us-central1` region
   - **Original**: `https://history.europe-west1.gcp.commercetools.com`
   - **Updated**: `https://history.us-central1.gcp.commercetools.com`
   - **Reason**: The connector targets the `us-central1` region.

2. Change the `tokenUrl` of the OAuth 2.0 `clientCredentials` flow to the `us-central1` region
   - **Original**: `https://auth.europe-west1.gcp.commercetools.com/oauth/token`
   - **Updated**: `https://auth.us-central1.gcp.commercetools.com/oauth/token`
   - **Reason**: The token endpoint must belong to the same region as the Change History API.

3. Add `info.description`
   - **Updated**: `Query the change history of commercetools project resources, including who changed what and when, using REST or GraphQL requests.`
   - **Reason**: The spec had no description, so the generated `Client` class had no summary.

4. Add operation summaries
   - **Updated**: `GET /{projectKey}` is "List change history of project resources", `GET /{projectKey}/{resourceType}` is "List change history of a resource type", `GET /{projectKey}/{resourceType}/{ID}` is "Get change history of a resource", and `POST /{projectKey}/graphql` is "Query change history with GraphQL". The `POST /{projectKey}/graphql` request body has the description "GraphQL query and variables to run against the change history".
   - **Reason**: The spec had no summaries or request-body description; they drive the operation names and the method documentation (the request body becomes the `payload` parameter's doc).

5. Add descriptions to the query and path parameters
   - **Updated**: Every query parameter (`resourceTypes`, `date.from`, `date.to`, `limit`, `offset`, `userId`, `userIds`, `clientId`, `customerId`, `associateId`, `businessUnit`, `type`, `resourceId`, `resourceIds`, `resourceKey`, `source`, `changes`, `stores`, `excludePlatformInitiatedChanges`, `expand`, `withTotal`) now has a description, on each operation that declares it. The path parameters `projectKey`, `resourceType` and `ID` have a description on every path that declares them.
   - **Reason**: Undocumented query parameters produce `undocumented field` warnings in the generated types, and undocumented path parameters produce `undocumented parameter` warnings on the client methods.

6. Replace the generic `200` response description of `POST /{projectKey}/graphql`
   - **Original**: `200`
   - **Updated**: `Result of the GraphQL query.`
   - **Reason**: The original text carried no information.

7. Share one `DateFilter` schema between the `date.from` and `date.to` parameters
   - **Original**: Each of the six `date.from` and `date.to` parameters (three operations) declared the same inline `oneOf` of `DateStringFilter`, a date-time string and a number.
   - **Updated**: All six reference a new `DateFilter` component schema, which has a description.
   - **Reason**: The inline unions generated eighteen near-identical `Datefrom*`/`Dateto*` types.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --client-methods remote --license docs/license.txt
```

Note: The license year is hardcoded to 2024, change if necessary.
