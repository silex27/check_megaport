# Megaport Centreon Check

A simple script that retrieves the **provisioning status** of Megaport Ports and VXCs, then reports to Centreon (or Nagios-compatible systems) whether all resources are in a **LIVE** state. It also provides performance data so you can graph port and VXC counts over time.

## Features

- **OAuth2 Client Credentials**: Authenticates against the Megaport M2M OAuth2 endpoint.
- **Lists Megaport Products**: Checks top-level **MEGAPORT** Ports plus their **associated VXCs**.
- **Monitoring Logic**:
  - If _any_ Ports or VXCs are not `LIVE`, returns **CRITICAL**.
  - Otherwise, returns **OK**.
- **Performance Data**: Exposes metrics (`total_ports`, `live_ports`, `bad_ports`, `total_vxcs`, `live_vxcs`, `bad_vxcs`) for Centreon graphs.

## Requirements

- **bash** (>= 4.0 recommended)
- **curl**
- **jq** (JSON parsing)

## Quick Start

1. **Clone** this repository and place `check_megaport.sh` on your **Centreon poller** or host where checks are executed.
2. **Make it executable**:
   ```bash
   chmod +x check_megaport.sh

# Megaport Integration Guide

## Initial Setup

1. **Edit the script** to set your Megaport **Client ID** and **Client Secret**:

```bash
CLIENT_ID="YOUR_CLIENT_ID" CLIENT_SECRET="YOUR_CLIENT_SECRET"
```

2. **Test** by running manually:

```bash
./check_megaport.sh
```

You should see either:

```sql
OK - All 2 ports and 3 VXCs are LIVE. | total_ports=2 ... bad_vxcs=0
```

or something like:

```scss
CRITICAL - 1 port(s) and 0 VXC(s) NOT LIVE out of 2 / 3. | ...
```

(Depending on your actual Megaport status.)

## Integration with Centreon

1. **Create a new command**:
   * **Command Name**: `check_megaport`
   * **Command Line**: (assuming you put the script in `/usr/lib/centreon/plugins`)

```ruby
$USER1$/check_megaport.sh
```

2. **Create a new service**:
   * **Check Command**: `check_megaport`
   * **Arguments**: (none) or any parameters you might add later
   * Assign it to the relevant host(s).

3. **Reload** Centreon. After a few polling intervals, you can view:
   * **Service Status**: OK / CRITICAL
   * **Graphs**: Centreon stores performance data for `ports` and `vxcs`, which you can visualize over time.

## Example Output

**All good**:

```sql
OK - All 2 ports and 3 VXCs are LIVE. | total_ports=2;;;0; live_ports=2;;;0; bad_ports=0;;;0; total_vxcs=3;;;0; live_vxcs=3;;;0; bad_vxcs=0;;;0;
```

**Some non-live**:

```scss
CRITICAL - 1 port(s) and 2 VXC(s) NOT LIVE out of 2 / 3. | total_ports=2;;;0; ...
```
