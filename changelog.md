# Change Log

This file contains all the notable changes done to the Ballerina commercetools Audit Log connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed

- `getProject` and `updateProject` (Project settings operations) and their related types.

### Changed

- The connector is now generated from the commercetools Change History API, matching its Audit Log name, and uses the
  `history` service URL and the `view_audit_log` scope.
- All operations are **remote methods**. Authentication uses the OAuth 2.0 client credentials grant with a configurable
  `tokenUrl`.

### Added

- Change history operations: `listChangeHistory`, `listResourceTypeChangeHistory`, `getResourceChangeHistory` and
  `queryChangeHistory` (GraphQL).
- Two runnable examples under `examples/`, and mock-server based tests.
