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

  Trigger_PerfAI_Super_Action_AI_Run:
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
          # OpenAPI Specification/Swagger/Bulk/Zip URLs
          openapi-url: ""
          # Server base path for the API
          base-path: ""
          # API Id generated for the PerfAI
          api-label: ""
          # API Id generated for the API in PerfAI
          api-id: "0123456789"
          # To wait till the tests gets completed, set to `true`
          wait-for-completion: "true"
          # To fail the build on new leaks introduced with this commit, set to `true`.
          fail-on-new-leaks: "false"
  ```         
The PerfAI credentials are read from github secrets.

Warning: Never store your secrets in the repository.

----------------------------------------------------------------------------------------------------------------------------
### Inputs

### `username`
**Required**: PerfAI Username.

### `password`
**Required**: PerfAI Password

### `openapi-url`
**Required**: OpenAPI Specification/Swagger/Bulk/Zip URLs.

| **Default value**   | `"https://petstore.swagger.io/v2/swagger.yaml"` |
|----------------|-------|

### `base-path`
**Required**: Server base path for the API.

| **Default value**   | `"https://petstore.swagger.io/v2"` |
|----------------|-------|

### `api-id`
**Required**: API Id generated for the API in PerfAI.

 1. After login into API Privacy. 

 2. Click on **APIs** on the dashboard.
 
 3. Click on horizontal three dotted lines then Copy the **API Id**.

### `api-label`
**Required**: API label name.

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




