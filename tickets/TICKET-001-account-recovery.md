# TICKET-001: Recovering Linux Account Access

## Status

Resolved

## Environment

- Oracle VirtualBox
- Ubuntu Server 26.04.1 LTS
- VirtualBox NAT networking
- OpenSSH Server installed

## Problem

The administrator could not remember the local Linux username and was unable to log in after restarting the server.

## Symptoms

- The system displayed `Login incorrect`.
- Attempts using the expected usernames failed.
- Reinstalling the operating system would have caused unnecessary work.

## Investigation

The server was started in Ubuntu recovery mode to obtain a root maintenance shell. The local account database was then searched for accounts with home directories.

```bash
grep /home/ /etc/passwd
```

The command identified the original account:

```text
ourney:x:1000:1000:...:/home/ourney:/bin/bash
```

The username had accidentally been created as `ourney` instead of `journey`.

## Resolution

The root filesystem was remounted with write access:

```bash
mount -o remount,rw /
```

The password for the original account was reset:

```bash
passwd ourney
```

After confirming access, a correctly named account was created:

```bash
sudo adduser journey
sudo usermod -aG sudo journey
```

## Verification

The replacement account was verified with:

```bash
whoami
groups
sudo -v
```

Expected results:

- `whoami` returned `journey`.
- `groups` included the `sudo` group.
- `sudo -v` completed without an authorization error.

## Root Cause

The original username was entered incorrectly during Ubuntu installation. Linux usernames are case-sensitive, and the missing first character caused subsequent login attempts to fail.

## Security Considerations

- Passwords were never displayed or recorded.
- Recovery mode requires direct access to the virtual machine console.
- The original account was retained until the replacement administrator account was tested successfully.
- The obsolete account should only be removed after confirming that no required files depend on it.

## Lessons Learned

- Verify usernames carefully during system installation.
- Local Linux accounts can be identified through `/etc/passwd`.
- Recovery mode can restore access without reinstalling the operating system.
- A replacement administrator account must be tested before removing the original account.
