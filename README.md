# PerfAI Super GitHub Action

A GitHub Action for using [PerfAI Super Action](https://app.apiprivacy.com/) to test for data leaks in your APIs. Tests include classification of sensitive and non-sensitive data, documenting it, generating a comprehensive test plan against the [PerfAI Action Top-10 List](https://docsend.com/view/96jygz72tsfpq4kv) and executing these tests against the target environment. This action can be configured to automatically block risks introduced into the codebase as part of your pipeline. For more information, contact us at support@perfai.ai.

# Example usage
```
# This is a starter workflow to help you get with PerfAI Super Action

name: PerfAI Super Github Action

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:


permissions:
  contents: read

jobs:

  Trigger_Privacy_AI_Run:
    permissions:
    runs-on: ubuntu-latest

    steps:
       - name: PerfAI Super Github Action
         uses: PerfAI-Inc/PerfAI-Super-Action@v0.0.1
         with:
          # The PerfAI username with which the AI Running will be executed
          username: ${{ secrets.username }}
          # The PerfAI Password with which the AI Running will be executed
          password: ${{ secrets.password}}
          # open-spec url
          openapi-url: ""
          # base-path url
          base-path: ""
          # services
          services: ""
          # API name/label
          api-name: "demo"
          # API Id generated for the API in PerfAI
          api-id: "66ebcabcc737e29472660cfe"
          # To wait till the tests gets completed, set to `true`
          api-label: ""
          wait-for-completion: "true"
          # To fail the build on new leaks introduced with this commit, set to `true`.
          fail-on-new-leaks: "false"
          # Test Account Details
          test-account-1-token:
          test-account-2-token:
          test-account-1-auth-url:
          test-account-1-auth-body:
          test-account-2-auth-url:
          test-account-2-auth-body:
  ```         
The PerfAI credentials are read from github secrets.

Warning: Never store your secrets in the repository.

----------------------------------------------------------------------------------------------------------------------------
### Inputs

### `username`
**Required**: PerfAI Username.

### `password`
**Required**: PerfAI Password

### `api-id`
**Required**: API Id generated for the API in PerfAI.

 1. After login into API Privacy. 

 2. Click on **APIs** on the dashboard.
 
 3. Click on horizontal three dotted lines then Copy the **API Id**.

### `api-label`
**Required**: API Name / Label.

| **Default value**   | `""` |
|----------------|-------|

### `wait-for-completion`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"true"` |
|----------------|-------|

### `fail-on-new-leaks`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"false"` |
|----------------|-------|

### `openapi-url`
**Required**: API Privacy openapi-url.

### `base-path`
**Required**: API Privacy base-path.

### `test-account-1-token`
**Required**: API Privacy test-account-1-token.

### `test-account-2-token`
**Required**: API Privacy test-account-2-token.

### `test-account-1-auth-url`
**Required**: API Privacy test-account-1-auth-url.

### `test-account-1-auth-body`
**Required**: API Privacy test-account-1-auth-body.

### `test-account-2-auth-url`
**Required**: API Privacy test-account-2-auth-url.

### `test-account-2-auth-body`
**Required**: API Privacy test-account-2-auth-body.
