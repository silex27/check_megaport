# Megaport Centreon Check

A simple script that retrieves the **provisioning status** of Megaport Ports and VXCs, then reports to Centreon (or Nagios-compatible systems) whether all resources are in a **LIVE** state. It also provides performance data so you can graph port and VXC counts over time.

## Features

- **OAuth2 Client Credentials**: Authenticates against the Megaport M2M OAuth2 endpoint.
- **Lists Megaport Products**: Checks top-level **MEGAPORT** Ports plus their **associated VXCs**.
- **Monitoring Logic**:
  - If _any_ Ports or VXCs are not `LIVE`, returns **CRITICAL**.
  - Otherwise, returns **OK**.
- **Performance Data**: Exposes metrics (`total_ports`, `live_ports`, `bad_ports`, `total_vxcs`, `live_vxcs`, `bad_vxcs`) for Centreon graphs.

# Megaport Integration Guide

## Initial Setup

 **Edit the script** to set your Megaport **Client ID** and **Client Secret**:

```bash
CLIENT_ID="YOUR_CLIENT_ID" CLIENT_SECRET="YOUR_CLIENT_SECRET"
```


## Example Output

**All good**:

```sql
OK - All 2 ports, 3 VXCs, and 3 VXCs (up attribute) are LIVE. | total_ports=2;;;0; live_ports=2;;;0; bad_ports=0;;;0; total_vxcs=3;;;0; live_vxcs=3;;;0; bad_vxcs=0;;;0; up_vxcs=3;;;0; down_vxcs=0;;;0;
```

**Some non-live**:

```scss
CRITICAL - 1 port(s) and 2 VXC(s) NOT LIVE out of 2 / 3. | total_ports=2;;;0; ...
```
