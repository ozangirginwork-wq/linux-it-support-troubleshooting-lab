# TICKET-002: Configure Secure Remote SSH Access

## Status

Resolved

## Environment

- Windows host computer
- Oracle VirtualBox
- Ubuntu Server 26.04.1 LTS
- VirtualBox NAT networking
- OpenSSH Server
- Local administrator account: `journey`

## Request

Configure secure remote command-line access from the Windows host to the Ubuntu Server virtual machine.

## Initial Assessment

The virtual machine used NAT networking, so the guest SSH service was not directly accessible from the Windows host. A VirtualBox port-forwarding rule was required.

The SSH service was also installed but inactive.

## Configuration

A VirtualBox NAT port-forwarding rule was created:

| Setting | Value |
|---|---|
| Name | SSH |
| Protocol | TCP |
| Host IP | `127.0.0.1` |
| Host port | `2222` |
| Guest IP | Blank |
| Guest port | `22` |

Using `127.0.0.1` restricted the forwarded port to the local Windows host instead of exposing SSH to other devices on the network.

## Resolution

The SSH service status was checked:

```bash
systemctl is-active ssh
```

The service initially returned:

```text
inactive
```

SSH was enabled and started:

```bash
sudo systemctl enable --now ssh
```

The service was checked again and returned:

```text
active
```

From Windows PowerShell, the remote connection was initiated:

```powershell
ssh -p 2222 journey@127.0.0.1
```

The server fingerprint was reviewed and accepted during the first connection. Authentication completed successfully using the local Linux account.

## Verification

The remote session was verified with:

```bash
whoami
hostname
echo $SSH_CONNECTION
```

Results confirmed:

- Authenticated user: `journey`
- Remote hostname: `ab01`
- SSH connected to guest port `22`
- The session originated from the VirtualBox NAT network

## Evidence

![Successful SSH connection and verification](../evidence/ticket-002-ssh-verification.png)

## Security Considerations

- The forwarded host port was bound to `127.0.0.1`, preventing access from other network devices.
- SSH was configured to start automatically after reboot.
- No passwords or private credentials were recorded.
- The first-connection host-key prompt was acknowledged. In a production environment, the fingerprint should be independently verified before acceptance.
- A non-root administrator account was used for remote access.

## Outcome

Secure SSH administration from Windows to the Ubuntu Server VM was successfully configured, tested, and documented.

## Lessons Learned

- NAT port forwarding can provide controlled access to services inside a virtual machine.
- An installed service may still need to be started and enabled.
- Service status should be verified before troubleshooting network connectivity.
- SSH connection details can be validated through environment variables and system commands.
