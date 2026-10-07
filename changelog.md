# Change Log

This file contains all the notable changes done to the Ballerina commercetools Audit Log connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- The connector is regenerated from the commercetools Composable Commerce API specification and still exposes the two
  Project settings operations, now as **remote methods**.
- Operations are renamed, so every 1.x call site changes:

| 1.x operation | 2.0.0 remote method |
|---|---|
| `queryRecords` (`GET /{projectKey}`) | `getProject(projectKey)` |
| `updateProjectByProjectKey` (`POST /{projectKey}`) | `updateProject(projectKey, payload)` |

- Generated record types follow the current commercetools schema names, for example `Project` and `ProjectUpdate`.
- Authentication uses the OAuth 2.0 client credentials grant with a configurable `tokenUrl`.

### Added

- Two runnable examples under `examples/`, and mock-server based tests.
