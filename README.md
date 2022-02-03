# ssh.sh

This is a small script that adds the -h/--hostname flag to ssh

By passing said flag, the ssh connection details are saved to .ssh/config
before connecting to the desired host

Example:

```bash
ssh.sh --hostname some-alias user@example.com
```
