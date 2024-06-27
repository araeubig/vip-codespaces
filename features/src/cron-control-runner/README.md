
# Cron Control Runner (cron-control-runner)

Installs Cron Control Runner into the Dev Environment

## Example Usage

```json
"features": {
    "ghcr.io/Automattic/vip-codespaces/cron-control-runner:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| enabled | Whether to install Cron Control Runner | boolean | true |
| fpm-socket | Address of the PHP-FPM socket. If not set, WP CLI will be used to run the cron jobs (slower). | string | tcp://127.0.0.1:9000 |
| wordpress-path | Path to the WordPress installation | string | /wp |
| wp-cli-path | Path to the WP CLI binary; required if `fpm-socket` is not set | string | /usr/local/bin/wp |
| install-runit-service | Whether to install a runit service for the Cron Control Runner | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Automattic/vip-codespaces/blob/main/features/src/cron-control-runner/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
