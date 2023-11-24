# Publish Anaconda Package Action

A Github Action to publish your software package to an Anaconda repository.

## Example workflow

```yaml
name: Publish

on:
  # Run manually the action
  workflow_dispatch:
    branches: [main]
  # Run automatically in case of new release
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:

    - name: Checkout
      - uses: actions/checkout@v4.1.0

    - name: Publish to Anaconda
      uses: crabisoft/publish-conda@v1.0.0
      with:
        # Specifies a sub directory within the repository containing your meta.yml or conda_build_config files.
        # Defaults to 'conda'
        # Optional
        sub-directory: 'conda'
        # Space separated string of conda channels to use during the build.
        # Defaults to 'conda-forge'
        # Optional
        build-channels: 'conda-forge' 
        # Conda channel where the package will be uploaded.
        # Defaults to 'conda-forge'
        # Optional
        upload-channel: 'conda-forge'
        # Space separated string of platforms to build.
        # Defaults to "win-64 osx-64 linux-64"
        platforms: 'win-64 osx-64 linux-64'
        # true for stable release, else false to indicate a beta version.
        # Defaults to true
        # Optional
        stable : true
        # Anaconda access token with read and write API permissions.
        # Required
        token: ${{ secrets.ANACONDA_TOKEN }}
```

* Configure **ANACONDA_TOKEN** secret on your settings repository
