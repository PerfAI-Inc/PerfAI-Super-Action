# PerfAI Super GitHub Action

A [GitHub Action](https://github.com/features/actions) for using [PerfAI API Privacy](https://app.apiprivacy.com/) to test for data leaks in your APIs. Tests include classification of sensitive and non-sensitive data and documenting it, Generating comprehensive test plan against [API Privacy Top-10 List](https://docsend.com/view/96jygz72tsfpq4kv), Executing these tests against the target environment. This action can be configured to automatically block risks introduced into the codebase as part of your pipeline.
If you want to learn more, contact us at <support@perfai.ai>.

# Example usage
```
# This is a starter workflow to help you get with API-Privacy Super Action

name: API Privacy Super Action

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  # schedule:
  #  - cron: '21 19 * * 4'

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:


permissions:
  contents: read

jobs:

  Trigger_Privacy_AI_Run:
    permissions:
    runs-on: ubuntu-latest

    steps:
       - name: PerfAI Privacy Super Action
         uses: PerfAI-Inc/perfai-api-privacy@v0.0.1
         with:
          # The API Privacy username with which the AI Running will be executed
          username: ${{ secrets.username }}
          # The API Privacy Password with which the AI Running will be executed
          password: ${{ secrets.password}}
          # API name/label
          api-name: "demo"
          # API Id generated for the API in API Privacy
          api-id: "66ebcabcc737e29472660cfe"
          # To wait till the tests gets completed, set to `true` 
          wait-for-completion: "true"
          # To fail the build on new leaks introduced with this commit, set to `true`.
          fail-on-new-leaks: "false"
  ```         
The API Privacy credentials are read from github secrets.

Warning: Never store your secrets in the repository.

----------------------------------------------------------------------------------------------------------------------------
### Inputs

### `username`
**Required**: API Privacy Username.

### `password`
**Required**: API Privacy Password

### `api-id`
**Required**: API Id generated for the API in API Privacy.

 1. After login into API Privacy. 

 2. Click on **APIs** on the dashboard.
 
 3. Click on horizontal three dotted lines then Copy the **API Id**.

### `api-name`
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
