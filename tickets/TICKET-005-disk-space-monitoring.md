# TICKET-005: Disk-Space Incident Response and Automated Monitoring

## Ticket Summary

| Field | Details |
|---|---|
| Status | Resolved |
| Severity | High |
| System | Ubuntu Server |
| Affected filesystem | `/mnt/helpdesk-data` |
| Initial usage | 93% |
| Recovered usage | 1% |
| Root cause | Oversized `application.log` file |
| Monitoring threshold | 80% |

## Reported Problem

The application data filesystem was approaching full capacity. If left unresolved, this could prevent applications from writing logs or data and could cause service failures.

## Safety and Lab Scope

A separate 300 MB loopback filesystem was created and mounted at `/mnt/helpdesk-data`. This isolated the disk-exhaustion simulation from the operating system's root filesystem and prevented the exercise from affecting Ubuntu system files.

## Investigation

Filesystem capacity was checked with:

```bash
df -h /mnt/helpdesk-data
