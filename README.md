# PerfAI Super GitHub Action

A GitHub Action for using [PerfAI Super Action](https://app.apiprivacy.com/) to test for data leaks in your APIs. Tests include classification of sensitive and non-sensitive data, documenting it, generating a comprehensive test plan against the [PerfAI Action Top-10 List](https://docsend.com/view/96jygz72tsfpq4kv) and executing these tests against the target environment. This action can be configured to automatically block risks introduced into the codebase as part of your CI/CD pipeline. For assistance, please contact us at support@perfai.ai.

🚀 Example usage

Below is a starter workflow example for using the PerfAI Super GitHub Action:
```
name: PerfAI Super GitHub Action

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  Trigger-PerfAI-Super-Action-Run:
    runs-on: ubuntu-latest

    steps:
      - name: PerfAI Super GitHub Action
        uses: PerfAI-Inc/PerfAI-Super-Action@v0.0.1
        with:
          username: ${{ secrets.PERFAI_USERNAME }}
          password: ${{ secrets.PERFAI_PASSWORD }}
          openApiUrl: "https://petstore.swagger.io/v2/swagger.yaml"
          basePath: "https://petstore.swagger.io/v2"
          label: "My API Name"
          appId: "0123456789"
          wait-for-completion: "true"
          fail-on-new-leaks: "false"
          authenticationUrl: "https://example.com/auth"
          authenticationBody1: "{\"username\": \"user\", \"password\": \"pass\"}"
          authorizationHeaders1: "Authorization: Bearer token"
          authenticationUr2: "https://example.com/auth"
          authenticationBod2: "{\"username\": \"user\", \"password\": \"pass\"}"
          authorizationHeaders2: "Authorization: Bearer token"
  ```         
The PerfAI credentials are read from github secrets.

⚠️ Warning: Store your secrets in GitHub Secrets. Never store sensitive information directly in your repository

----------------------------------------------------------------------------------------------------------------------------
### 🔧 Inputs

| Input                 | Required | Description                                                    | Default Value                               |
|-----------------------|----------|----------------------------------------------------------------|---------------------------------------------|
| username              | Yes      | PerfAI Username                                                | " "                                         |
| password              | Yes      | PerfAI Password                                                | " "                                         |
| openApiUrl            | Yes      | URL to your OpenAPI Specification (Swagger, Bulk, Zip)         | https://petstore.swagger.io/v2/swagger.yaml |
| basePath              | Yes      | Server base path for the API                                   | https://petstore.swagger.io/v2"             |
| appId                 | Yes      | It can be any app id                                           | 0123456789                                  |
| label                 | Yes      | It can be any name                                             | " "                                         |
| wait-for-completion   | Yes      | To wait till the tests gets completed, set to `true            | true                                        |
| fail-on-new-leaks     | Yes      | Fail build if new leaks are detected. Set to "true" or "false" | false                                       |
| authenticationUrl1    | Optional | Authentication URL for test account 1                          |  " "                                        |
| authenticationBody1   | Optional | Authentication body for test account 1                         | " "                                         |
| authorizationHeaders1 | Optional | Authorization headers for authentication                       | " "                                         |
| authenticationUrl1    | Optional | Authentication URL for test account 2                          | " "                                         |
| authenticationBody2   | Optional | Authentication body for test account 2                         |  " "                                        |
| authorizationHeaders2 | Optional | Authorization headers for authentication                       | " "                                         |

📘 Instructions for Obtaining api-id

1. Log in to [API Privacy](https://app.apiprivacy.com/).
2. Navigate to the APIs section on the dashboard.
3. Locate your API, click on the three-dot menu, and select Copy API ID.
