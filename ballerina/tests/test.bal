
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

import ballerina/http;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? os:getEnv("COMMERCETOOLS_SERVICE_URL") : "http://localhost:9090";
final string tokenUrl = isLiveServer ? os:getEnv("COMMERCETOOLS_TOKEN_URL") : "http://localhost:9444/oauth/token";
final string clientId = isLiveServer ? os:getEnv("COMMERCETOOLS_CLIENT_ID") : "test-client-id";
final string clientSecret = isLiveServer ? os:getEnv("COMMERCETOOLS_CLIENT_SECRET") : "test-client-secret";
final string projectKey = isLiveServer ? os:getEnv("COMMERCETOOLS_PROJECT_KEY") : "test-project";

isolated Client? historyClient = ();

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
        historyClient = c;
    }
}

isolated function getClient() returns Client|error {
    lock {
        Client? c = historyClient;
        if c is Client {
            return c;
        }
    }
    return error("The client is not initialised");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListChangeHistory() returns error? {
    Client history = check getClient();
    RecordPagedQueryResponse response = check history->listChangeHistory(projectKey, resourceTypes = ["product", "customer"], 'limit = 20);
    test:assertEquals(response.count, response.results.length());
    test:assertTrue(response.results.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListResourceTypeChangeHistory() returns error? {
    Client history = check getClient();
    RecordPagedQueryResponse response = check history->listResourceTypeChangeHistory(projectKey, "product", 'limit = 10);
    test:assertEquals(response.count, response.results.length());
    test:assertTrue(response.results.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetResourceChangeHistory() returns error? {
    Client history = check getClient();
    RecordPagedQueryResponse response = check history->listResourceTypeChangeHistory(projectKey, "product", 'limit = 1);
    if response.results.length() == 0 {
        return;
    }
    string? resourceId = response.results[0].'resource.id;
    if resourceId is () {
        return;
    }
    RecordPagedQueryResponse resourceHistory = check history->getResourceChangeHistory(projectKey, "product", resourceId);
    test:assertTrue(resourceHistory.results.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testQueryChangeHistory() returns error? {
    Client history = check getClient();
    GraphQLResponse response = check history->queryChangeHistory(projectKey, {
        query: "query { changes(limit: 1) { total count } }"
    });
    test:assertTrue(response?.errors is ());
    test:assertTrue(response?.data !is ());
}
