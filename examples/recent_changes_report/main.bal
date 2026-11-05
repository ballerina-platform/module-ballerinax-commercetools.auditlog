// Lists the change history of a commercetools Project for the last few hours,
// following every page, and reports how many changes each user made.

import ballerina/io;
import ballerinax/commercetools.auditlog;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;
configurable decimal hoursBack = 24;
configurable int pageSize = 50;

public function main() returns error? {
    auditlog:Client history = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        }
    }, apiUrl);

    if pageSize <= 0 {
        return error(string `pageSize must be a positive number, but it is ${pageSize}`);
    }

    // Step 1: Read every page of change records in the time window
    map<int> changesByUser = {};
    int total = 0;
    int offset = 0;
    while true {
        auditlog:RecordPagedQueryResponse page = check history->listChangeHistory(projectKey,
            dateFrom = <auditlog:HoursAgoFilterValue>hoursBack,
            'limit = <int:Signed32>pageSize,
            offset = <int:Signed32>offset);

        // Step 2: Count the changes per user
        foreach auditlog:Record entry in page.results {
            string user = entry.modifiedBy.id ?: entry.modifiedBy.clientId ?: "unknown";
            changesByUser[user] = (changesByUser[user] ?: 0) + 1;
            total += 1;
        }
        if page.count < pageSize {
            break;
        }
        offset += page.count;
    }

    io:println(string `${total} changes in the last ${hoursBack} hours`);
    foreach [string, int] [user, count] in changesByUser.entries() {
        io:println(string `  ${user}: ${count}`);
    }
}
