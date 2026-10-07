_Author_:  @DimuthuMadushan \
_Created_: 2026/10/06 \
_Updated_: 2026/10/06 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Commercetools.
The OpenAPI specification is obtained from [https://github.com/wso2/api-specs/blob/main/openapi/commercetools/auditlog/v1/openapi.yaml](https://github.com/wso2/api-specs/blob/main/openapi/commercetools/auditlog/v1/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Subset the spec to the Audit Log connector's previous scope.** The source spec is the full commercetools Composable Commerce API (299 paths). Only `GET /{projectKey}` (`ByProjectKeyGet`) and `POST /{projectKey}` (`ByProjectKeyPost`) were kept. `HEAD /{projectKey}` (`ByProjectKeyHead`) and every other path were dropped to match the previous scope of the connector. `components` was pruned to the transitive closure of the schemas and responses those two operations reference, plus the `oauth_2_0` security scheme (52 schemas, 8 responses). The spec remains self-contained (see item 5 for the discriminator mappings that pointed at pruned schemas).

   `docs/resources/script.py` performs this subset, together with item 5, from the full source spec. It takes no arguments; paths resolve relative to the script, so it runs from anywhere, and it writes `openapi.yaml` beside itself:

   ```bash
   python3 docs/resources/script.py
   ```

   The source is downloaded on first run and cached beside the script as `commercetools-api-openapi.yaml` (~3 MB, untracked); delete that file to pick up a newer upstream. The kept operations are listed in the script's `KEEP` constant. Its output is the input to items 2, 3, 4 and 6, which are applied on top of it in `docs/spec/openapi.yaml`.

2. **Add missing operation summaries and descriptions.** `GET /{projectKey}` is summarised as "Get project settings" and `POST /{projectKey}` as "Update project settings". Both operations also gained a description, the `200` responses replaced the bare `'200'` description, and the `POST` request body got a description and `required: true`, since `version` and `actions` are required.

3. **Remove a bogus required property from `ErrorObject`.** The `required` list of `ErrorObject` contained `//`, which is not a property of the schema (it comes from a comment in the vendor's source definition). It was removed so the schema only requires `code` and `message`.

4. **Replace the templated server URL with a concrete one.** The `https://api.{region}.commercetools.com` server variable was replaced by the default region host `https://api.us-central1.gcp.commercetools.com`, so the generated client has a matching default `serviceUrl`. Connectors for other regions pass their own `serviceUrl`.

5. **Prune dangling discriminator mappings.** After the subset, the `discriminator.mapping` entries of several schemas still pointed at schemas that no longer exist. Only mappings whose target schema still exists were kept: `Reference` keeps `customer-group`, `customer` and `type`, and `KeyReference` keeps `associate-role` and `store`. The `discriminator` was removed from `ErrorObject`, `FieldType`, `ProjectUpdateAction` and `ShippingRateInputType`, because none of their targets survive. `docs/resources/script.py` (item 1) applies this pruning.

6. **Match the token URL region to the server.** `securitySchemes.oauth_2_0.flows.clientCredentials.tokenUrl` was changed from `https://auth.europe-west1.gcp.commercetools.com/oauth/token` to `https://auth.us-central1.gcp.commercetools.com/oauth/token`, the auth host of the default `us-central1.gcp` server.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --client-methods remote --license docs/license.txt
```

Note: The license year is hardcoded to 2026, change if necessary.
