
// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/http;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? os:getEnv("COMMERCETOOLS_SERVICE_URL") : "http://localhost:9090";
final string tokenUrl = isLiveServer ? os:getEnv("COMMERCETOOLS_TOKEN_URL") : "http://localhost:9444/oauth/token";
final string clientId = isLiveServer ? os:getEnv("COMMERCETOOLS_CLIENT_ID") : "test-client-id";
final string clientSecret = isLiveServer ? os:getEnv("COMMERCETOOLS_CLIENT_SECRET") : "test-client-secret";
final string projectKey = isLiveServer ? os:getEnv("COMMERCETOOLS_PROJECT_KEY") : "test-project";

// The mock token endpoint starts after module initialisation, so the client is created before the suite.
isolated Client? commercetoolsClient = ();

@test:BeforeSuite
function initClient() returns error? {
    Client c = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        },
        httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
    }, serviceUrl);
    lock {
        commercetoolsClient = c;
    }
}

isolated function getClient() returns Client|error {
    lock {
        Client? c = commercetoolsClient;
        if c is Client {
            return c;
        }
    }
    return error("The client is not initialised");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetProject() returns error? {
    Client commercetools = check getClient();
    Project project = check commercetools->getProject(projectKey);
    test:assertEquals(project.'key, projectKey);
    test:assertTrue(project.name.length() > 0);
    test:assertTrue(project.currencies.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testUpdateProject() returns error? {
    Client commercetools = check getClient();
    Project current = check commercetools->getProject(projectKey);
    // Live runs keep the current name so the real Project is not renamed.
    string newName = isLiveServer ? current.name : "Test Project Renamed";
    Project updated = check commercetools->updateProject(projectKey, {
        version: current.version,
        actions: [{action: "changeName", "name": newName}]
    });
    test:assertEquals(updated.'key, projectKey);
    test:assertEquals(updated.name, newName);
    if isLiveServer {
        test:assertTrue(updated.version >= current.version);
    } else {
        test:assertTrue(updated.version > current.version);
    }
}
