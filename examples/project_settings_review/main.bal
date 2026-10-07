// Reads the commercetools Project settings and reports the configuration that
// other systems depend on: currencies, countries, languages and the cart and message settings.

import ballerina/io;
import ballerina/lang.regexp;
import ballerinax/commercetools.auditlog;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;
configurable string requiredCurrencies = ?;

public function main() returns error? {
    auditlog:Client commercetools = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        }
    }, apiUrl);

    // Step 1: Read the Project settings
    auditlog:Project project = check commercetools->getProject(projectKey);
    io:println(string `Project: ${project.name} (${project.'key}), version ${project.version}`);
    io:println(string `Created at: ${project.createdAt}`);

    // Step 2: Report the locale, country and currency configuration
    string languages = string:'join(", ", ...project.languages);
    string countries = string:'join(", ", ...project.countries);
    string currencies = string:'join(", ", ...project.currencies);
    io:println(string `Languages: ${languages}`);
    io:println(string `Countries: ${countries}`);
    io:println(string `Currencies: ${currencies}`);

    // Step 3: Report the cart and message settings
    io:println(string `New Carts are deleted by default ${project.carts.deleteDaysAfterLastModification} days after their last modification`);
    string messageState = project.messages.enabled ? "enabled" : "disabled";
    io:println(string `Messages are ${messageState}`);

    // Step 4: Fail loudly when a required currency is not configured
    string[] required = regexp:split(re `,`, requiredCurrencies).map(c => c.trim()).filter(c => c.length() > 0);
    string[] missing = required.filter(c => project.currencies.indexOf(c) is ());
    if missing.length() > 0 {
        return error(string `Project ${project.'key} is missing required currencies: ${string:'join(", ", ...missing)}`);
    }
    io:println("All required currencies are configured.");
}
