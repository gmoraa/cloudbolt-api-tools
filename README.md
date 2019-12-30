# CLOUDBOLT-API-TOOLS

## Usage

```
Usage: These tools have been created to automate CloudBolt tasks. The scripts are very generic, mots of them just require the server and credentials:

<http(s)://example.cloudbolt.com> </credentials/path/file.json>

1. Where the first argument is the CloudBolt server URL.
2. Where the second argument is the credentials file in json format.
```

# cloudbolt_list.sh
```
Return all your servers flagged as POWERON.
```

# cloudbolt_off.sh
```
Return all your servers flagged as POWEROFF.
```

# cloudbolt_snapshots.sh
```
This script take a snaphot for every server.
```

# cloudbolt_ssh.sh
```
Check all the ssh connections via telnet(POWERON only).
```