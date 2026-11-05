// Finds the most recently changed resource of a given type and prints its full
// change trail: who changed it, when, and which change was made.

import ballerina/io;
import ballerinax/commercetools.auditlog;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;
configurable auditlog:ChangeHistoryResourceType resourceType = "product";

public function main() returns error? {
    auditlog:Client history = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        }
    }, apiUrl);

    // Step 1: Find the latest change record of the resource type
    auditlog:RecordPagedQueryResponse latest = check history->listResourceTypeChangeHistory(projectKey, resourceType, 'limit = 1);
    if latest.results.length() == 0 {
        return error(string `No change history found for resource type ${resourceType}`);
    }
    string? resourceId = latest.results[0].'resource.id;
    if resourceId is () {
        return error("The latest change record has no resource ID");
    }

    // Step 2: Read the full history of that resource
    auditlog:RecordPagedQueryResponse trail = check history->getResourceChangeHistory(projectKey, resourceType, resourceId);
    io:println(string `Change trail of ${resourceType} ${resourceId}`);
    foreach auditlog:Record entry in trail.results {
        string changed = string:'join(", ", ...from auditlog:Change c in entry.changes
            select c.change);
        io:println(string `  v${entry.version} at ${entry.modifiedAt} by ${entry.modifiedBy.id ?: entry.modifiedBy.clientId ?: "unknown"}: ${changed}`);
    }
}
