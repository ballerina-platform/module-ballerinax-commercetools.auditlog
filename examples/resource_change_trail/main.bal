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
// How far back to look, in hours. The API defaults to the last 24 hours.
configurable decimal hoursBack = 720;
configurable int pageSize = 50;

public function main() returns error? {
    if pageSize <= 0 {
        return error(string `pageSize must be a positive number, but it is ${pageSize}`);
    }

    auditlog:Client history = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        }
    }, apiUrl);

    // Step 1: Find the latest change record of the resource type
    auditlog:RecordPagedQueryResponse latest = check history->listResourceTypeChangeHistory(projectKey, resourceType,
        dateFrom = <auditlog:HoursAgoFilterValue>hoursBack, 'limit = 1);
    if latest.results.length() == 0 {
        return error(string `No change history found for resource type ${resourceType}`);
    }
    string? resourceId = latest.results[0].'resource.id;
    if resourceId is () {
        return error("The latest change record has no resource ID");
    }

    // Step 2: Read every page of that resource's history in the time window
    auditlog:Record[] trail = [];
    int offset = 0;
    while true {
        auditlog:RecordPagedQueryResponse page = check history->getResourceChangeHistory(projectKey, resourceType,
            resourceId, dateFrom = <auditlog:HoursAgoFilterValue>hoursBack, 'limit = <int:Signed32>pageSize,
            offset = <int:Signed32>offset);
        trail.push(...page.results);
        offset += page.count;
        int? total = page.total;
        if page.count == 0 || page.count < page.'limit || (total is int && offset >= total) {
            break;
        }
    }
    io:println(string `Change trail of ${resourceType} ${resourceId}`);
    foreach auditlog:Record entry in trail {
        string changed = string:'join(", ", ...from auditlog:Change c in entry.changes
            select c.change);
        io:println(string `  v${entry.version} at ${entry.modifiedAt} by ${entry.modifiedBy.id ?: entry.modifiedBy.clientId ?: "unknown"}: ${changed}`);
    }
}
