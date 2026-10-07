// Renames a commercetools Project with an optimistic-concurrency update and
// verifies the change by reading the Project again.

import ballerina/io;
import ballerinax/commercetools.auditlog;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;
configurable string newProjectName = ?;
configurable boolean applyChange = false;

public function main() returns error? {
    auditlog:Client commercetools = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        }
    }, apiUrl);

    // Step 1: Read the current Project and its version
    auditlog:Project current = check commercetools->getProject(projectKey);
    io:println(string `Current name: ${current.name} (version ${current.version})`);

    if current.name == newProjectName {
        io:println("The Project already has this name, nothing to do.");
        return;
    }
    if !applyChange {
        io:println(string `Dry run: would rename the Project to "${newProjectName}". Set applyChange = true to apply.`);
        return;
    }

    // Step 2: Apply the change against the version that was just read
    auditlog:Project updated = check commercetools->updateProject(projectKey, {
        version: current.version,
        actions: [{action: "changeName", "name": newProjectName}]
    });
    io:println(string `Updated to version ${updated.version}`);

    // Step 3: Read the Project again and verify the new name
    auditlog:Project verified = check commercetools->getProject(projectKey);
    if verified.name != newProjectName {
        return error(string `Expected name "${newProjectName}" but found "${verified.name}"`);
    }
    io:println(string `Verified name: ${verified.name}`);
}
