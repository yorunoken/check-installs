# check-installs

**check-installs** is a simple Bash script that shows you apps you've installed using your `~/.bash_history`.

### Usage

```bash
video-cutter [managers]
```

* `managers` (optional) - A comma-separated list of package managers you want to check.
  Examples: `pacman`, `yay`, `paru`
  If no managers are specified, the script checks all supported managers.

To customize where the script will look for the logs, set an environment variable named `BASH_HISTORY_PATH`

### Supported package managers

* pacman
* yay
* paru
* apt
* dnf
* zypper
* brew
* snap

### Customizing bash history path

You can customize the bash history file path by setting the environment variable `BASH_HISTORY_PATH`.

Example:

```bash
BASH_HISTORY_PATH=/path/to/your/history_file ./check-installs.sh
```
