# Debugging Network Performance Issues: SSH Disconnections and Packet Loss

A comprehensive guide to diagnosing and solving CPU-bound network packet processing bottlenecks using RPS (Receive Packet Steering), with complete monitoring setup.

## The Problem

Intermittent network issues manifesting as:

- SSH connections dropping with "Broken pipe" errors
- NFS file streaming experiencing stutters and interruptions
- Problems occurring during network traffic bursts
- No obvious hardware failures or errors

These symptoms suggest packet loss at the network processing layer rather than physical network problems.

## Understanding the Linux Network Stack

Before diving into debugging, it's crucial to understand how Linux processes network packets:

```
Physical Network
       ↓
Network Interface Card (NIC)
       ↓
Ring Buffer (hardware queue)
       ↓
Hardware Interrupt → CPU Assignment
       ↓
Softnet Processing (per-CPU queues)
       ↓
Application
```

Each stage has limited capacity and can become a bottleneck.

## Initial Diagnostic Steps

### 1. Check for Hardware Issues

```bash
# Verify no hardware errors
ethtool -S <interface> | grep -E "(drop|error|fifo|overrun|collision)"

# Check ring buffer size
ethtool -g <interface>
```

**What to look for:**

- All error counters should be 0
- Ring buffer should not be at minimum size

### 2. Examine Softnet Statistics

The `/proc/net/softnet_stat` file contains critical information about packet processing per CPU:

```bash
cat /proc/net/softnet_stat
```

**Output format (hexadecimal):**

```
/proc/net/softnet_stat output:

0006a7ac 00000000 00000000 00000000 00000000 ...
    │        │        │        └─────────────── Reserved
    │        │        └──────────────────────── Time squeeze count
    │        └───────────────────────────────── Dropped packet count
    └────────────────────────────────────────── Total packets processed
```

- Each line is one CPU core
- Column 1: Total packets processed by this CPU
- Column 2: Packets dropped (netdev_max_backlog exceeded)
- Column 3: Time squeeze (CPU couldn't finish processing)
- Columns 4-9: Various other counters
- Last column: CPU number

**Example output:**

```
0006a7ac 00000000 00000000 ...  (CPU 0: 6,949,804 packets)
0005f333 00000000 00000000 ...  (CPU 1: 6,169,395 packets)
000cd69c 00000000 00000000 ...  (CPU 10: 842,396 packets)
```

### 3. Decode Hexadecimal Values

```bash
# Convert hex to decimal using Python
cat /proc/net/softnet_stat | python3 -c "
import sys
for i, line in enumerate(sys.stdin):
    cols = line.split()
    packets = int(cols[0], 16)
    drops = int(cols[1], 16) if len(cols) > 1 else 0
    print(f'CPU {i:2d}: {packets:10,d} packets, {drops:3d} drops')
"
```

## The Root Cause: Uneven Packet Distribution

```
Incoming Traffic Burst (10,000 packets/sec)
                │
                ▼
        ┌───────────────┐
        │   NIC Queue   │  ← Ring buffer: 4096 packets
        │   (RX-0)      │
        └───────┬───────┘
                │ Hardware IRQ
                ▼
        ┌───────────────┐
        │    CPU 0      │  ← Handles ALL packets
        │   ┌─────────┐ │
        │   │ Softnet │ │  ← Backlog: 1000 packets
        │   │  Queue  │ │
        │   └─────────┘ │
        │     [FULL]    │  ← Queue overflows!
        └───────┬───────┘
                │
                ▼
        Packets DROPPED
        SSH keepalive lost → "Broken pipe"
        NFS data delayed  → Stuttering


Meanwhile:
┌─────────┐  ┌─────────┐  ┌─────────┐
│  CPU 1  │  │  CPU 2  │  │  CPU 3  │
│  [IDLE] │  │  [IDLE] │  │  [IDLE] │
│   5%    │  │   3%    │  │   4%    │
└─────────┘  └─────────┘  └─────────┘
```

### Identifying the Problem

Calculate the packet distribution ratio:

```python
counts = [int(line.split()[0], 16) for line in open('/proc/net/softnet_stat')]
ratio = max(counts) / min(counts)
print(f"Distribution ratio: {ratio:.2f}x")
```

**Interpretation:**

- **Ratio < 3**: Good distribution, packets spread across CPUs
- **Ratio 3-5**: Moderate imbalance, potential issues under load
- **Ratio > 5**: Severe imbalance, CPU bottleneck likely

```
Network Packet Processing per CPU:

CPU 0:  ████████████████████████ 100% ← OVERLOADED
CPU 1:  ██████████████████████   95% ← OVERLOADED
CPU 2:  ██                        8%
CPU 3:  █                         5%
CPU 4:  █                         4%
CPU 5:  █                         3%
CPU 6:  █                         6%
CPU 7:  █                         4%
CPU 8:  ████████████████████     88% ← OVERLOADED
CPU 9:  ████                     15%
CPU 10: ██                        9%
CPU 11: █                         6%
CPU 12: █                         7%
CPU 13: ██                        8%
CPU 14: █                         6%
CPU 15: █                         5%

Ratio: 100% / 3% = 33x ❌ CRITICAL

Problem: 2-3 CPUs doing all the work
```

### Why This Matters

Without proper packet distribution:

1. **Hardware interrupts** go to only 2-3 CPUs (based on NIC queue count)
2. Those CPUs become **bottlenecked** processing all network traffic
3. Their **softnet backlog queues** fill up (default: 1000 packets)
4. New packets get **dropped** even though the ring buffer has space
5. Critical packets (SSH keepalives, NFS data) get lost
6. Connections fail or stutter

**The key insight:** The problem isn't network bandwidth—it's CPU processing capacity for network packets.

## The Solution: Receive Packet Steering (RPS)

```
Incoming Traffic Burst (10,000 packets/sec)
                │
                ▼
        ┌───────────────┐
        │   NIC Queue   │
        │   (RX-0)      │
        └───────┬───────┘
                │ Hardware IRQ
                ▼
        ┌───────────────┐
        │    CPU 0      │  ← Initial handler
        └───────┬───────┘
                │
                │  RPS distributes packets
                │  based on packet hash
                │
    ┌───────────┼───────────┬───────────┐
    ▼           ▼           ▼           ▼
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│ CPU 0  │  │ CPU 1  │  │ CPU 2  │  │ CPU 3  │
│┌──────┐│  │┌──────┐│  │┌──────┐│  │┌──────┐│
││Queue ││  ││Queue ││  ││Queue ││  ││Queue ││
││ 250  ││  ││ 250  ││  ││ 250  ││  ││ 250  ││
│└──────┘│  │└──────┘│  │└──────┘│  │└──────┘│
│  [OK]  │  │  [OK]  │  │  [OK]  │  │  [OK]  │
└────────┘  └────────┘  └────────┘  └────────┘
    │           │           │           │
    └───────────┴───────────┴───────────┘
                    │
                    ▼
            All packets processed
            No drops, no delays
            SSH stable, NFS smooth
```

### What is RPS?

RPS (Receive Packet Steering) is a software mechanism that distributes packet processing across all CPUs after hardware interrupt handling. It's essentially software-based load balancing for network packet processing.

### How RPS Works

```
Without RPS:
NIC → Hardware IRQ → CPU 0, 1 → All packets processed by 2 CPUs

With RPS:
NIC → Hardware IRQ → CPU 0, 1 → Distribute to CPUs 0-15 via RPS

┌─────────────────────────────────────────────────────────────┐
│                     Physical Network                        │
│                    (Ethernet cables)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Network Interface Card (NIC)                   │
│                  Hardware Processing                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Ring Buffer                              │
│         (Hardware queue: 256-4096 packets)                  │
│    ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐          │
│    │Pkt│Pkt│Pkt│Pkt│Pkt│   │   │   │   │   │   │          │
│    └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Hardware Interrupt (IRQ)                       │
│            Assigned to specific CPU(s)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                ┌────────┴────────┐
                │   Without RPS   │
                └────────┬────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
    ┌───────┐       ┌───────┐       ┌───────┐
    │ CPU 0 │       │ CPU 1 │       │ CPU 2 │
    │ 100%  │       │ 100%  │       │  5%   │
    │  !!!  │       │  !!!  │       │       │
    └───────┘       └───────┘       └───────┘
                         ⋮

    Problem: CPUs 0-1 overwhelmed, others idle

                         │
                ┌────────┴────────┐
                │    With RPS     │
                └────────┬────────┘
                         │
        ┌────┬────┬────┬─┴─┬────┬────┬────┐
        ▼    ▼    ▼    ▼   ▼    ▼    ▼    ▼
    ┌────┐┌────┐┌────┐┌────┐┌────┐┌────┐┌────┐
    │CPU0││CPU1││CPU2││CPU3││CPU4││CPU5││...│
    │ 45%││ 42%││ 48%││ 43%││ 46%││ 44%││   │
    │ ✓  ││ ✓  ││ ✓  ││ ✓  ││ ✓  ││ ✓  ││   │
    └────┘└────┘└────┘└────┘└────┘└────┘└────┘

    Solution: Load distributed evenly
```

### Implementing RPS

#### 1. Determine CPU Count

```bash
nproc
# Output: 16 (for example)
```

#### 2. Calculate CPU Mask

Create a hexadecimal bitmask representing which CPUs should process packets:

- 8 CPUs: `ff` (binary: 11111111)
- 16 CPUs: `ffff` (binary: 1111111111111111)
- 32 CPUs: `ffffffff`

```
┌─────────────────────────────────────────────────────────┐
│  /sys/class/net/eth0/queues/                           │
│                                                         │
│    rx-0/                                               │
│      rps_cpus ───→ 0000ffff  (binary: 1111111111111111)│
│                              └─────────────────────────┘│
│                              CPU:  │││││││││││││││││  │
│                              15 14 13...5 4 3 2 1 0    │
│                              All CPUs enabled!         │
│                                                         │
│    rx-1/                                               │
│      rps_cpus ───→ 0000ffff                            │
│                                                         │
└─────────────────────────────────────────────────────────┘

CPU Mask Calculation:

 8 CPUs:        11111111 = 0xFF       = ff
16 CPUs: 1111111111111111 = 0xFFFF     = ffff
32 CPUs: (32 ones)        = 0xFFFFFFFF = ffffffff

Formula: 2^(num_cpus) - 1 in hexadecimal
```

#### 3. Apply RPS Configuration

```bash
# For each RX queue, set the CPU mask
for rx in /sys/class/net/<interface>/queues/rx-*/rps_cpus; do
    echo "ffff" > "$rx"  # For 16 CPUs
done
```

#### 4. Verify Configuration

```bash
cat /sys/class/net/<interface>/queues/rx-*/rps_cpus
# Should show: 0000ffff (not 00000000)
```

### Making RPS Persistent

Create a systemd service to apply on boot:

```bash
cat > /etc/systemd/system/network-rps.service << 'EOF'
[Unit]
Description=Configure RPS for network interface
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for rx in /sys/class/net/<interface>/queues/rx-*/rps_cpus; do echo "ffff" > "$rx"; done'
ExecStart=/sbin/sysctl -w net.core.netdev_max_backlog=5000
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable network-rps.service
systemctl start network-rps.service
```

## Additional Tuning

### Increase Network Backlog

The default `netdev_max_backlog` (1000 packets) may be too small:

```bash
# Increase to 5000 packets
sysctl -w net.core.netdev_max_backlog=5000

# Make permanent in /etc/sysctl.conf
echo "net.core.netdev_max_backlog=5000" >> /etc/sysctl.conf
```

### Optimize Ring Buffers

If hardware supports larger buffers:

```bash
# Check maximum supported size
ethtool -g <interface>

# Increase to maximum
ethtool -G <interface> rx 4096 tx 4096
```

## Monitoring the Solution

### Key Metrics to Track

1. **Packet distribution ratio**: Should remain < 3
2. **Softnet drops**: Should stay at 0
3. **RPS configuration**: Should remain enabled
4. **Network errors**: Should stay at 0

### Building a Monitoring Script

Create a metrics collector for Prometheus Node Exporter:

```python
#!/usr/bin/env python3
"""
Network statistics collector for Prometheus
Exposes metrics via textfile collector
"""

import os
from pathlib import Path

OUTPUT_DIR = "/var/lib/node_exporter/textfile_collector"
OUTPUT_FILE = f"{OUTPUT_DIR}/network_stats.prom"
INTERFACE = "eth0"  # Adjust to your interface

def read_softnet_stat():
    """Parse /proc/net/softnet_stat"""
    metrics = []
    with open('/proc/net/softnet_stat', 'r') as f:
        for cpu, line in enumerate(f):
            cols = line.split()
            metrics.append({
                'cpu': cpu,
                'processed': int(cols[0], 16),
                'dropped': int(cols[1], 16) if len(cols) > 1 else 0,
            })
    return metrics

def calculate_distribution_ratio(metrics):
    """Calculate max/min ratio across CPUs"""
    counts = [m['processed'] for m in metrics]
    min_count = min(counts)
    max_count = max(counts)
    return max_count / min_count if min_count > 0 else 0

def check_rps_configured(interface):
    """Check if RPS is enabled"""
    queue_path = f"/sys/class/net/{interface}/queues"
    for rx_queue in Path(queue_path).glob("rx-*/rps_cpus"):
        rps_value = rx_queue.read_text().strip()
        if rps_value not in ("00000000", "0", ""):
            return 1
    return 0

def generate_metrics():
    """Generate Prometheus metrics"""
    lines = []

    # Softnet stats
    softnet_metrics = read_softnet_stat()
    for m in softnet_metrics:
        lines.append(f'node_network_softnet_processed_total{{cpu="{m["cpu"]}"}} {m["processed"]}')
        lines.append(f'node_network_softnet_dropped_total{{cpu="{m["cpu"]}"}} {m["dropped"]}')

    # Distribution ratio
    ratio = calculate_distribution_ratio(softnet_metrics)
    lines.append(f'node_network_packet_distribution_ratio {ratio:.2f}')

    # RPS status
    rps_configured = check_rps_configured(INTERFACE)
    lines.append(f'node_network_rps_configured{{device="{INTERFACE}"}} {rps_configured}')

    return '\n'.join(lines) + '\n'

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    metrics = generate_metrics()

    # Write atomically
    temp_file = f"{OUTPUT_FILE}.{os.getpid()}"
    with open(temp_file, 'w') as f:
        f.write(metrics)
    os.rename(temp_file, OUTPUT_FILE)

if __name__ == '__main__':
    main()
```

### Systemd Timer Setup

**Service file** (`/etc/systemd/system/network-stats.service`):

```ini
[Unit]
Description=Network Statistics Collector
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/network_stats.py
User=root
StandardOutput=journal
StandardError=journal
```

**Timer file** (`/etc/systemd/system/network-stats.timer`):

```ini
[Unit]
Description=Network Statistics Collector Timer
Requires=network-stats.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min

[Install]
WantedBy=timers.target
```

**Enable and start:**

```bash
systemctl daemon-reload
systemctl enable network-stats.timer
systemctl start network-stats.timer
```

### Prometheus Alert Rules

```yaml
groups:
  - name: network_health
    rules:
      # Alert when packet distribution is uneven
      - alert: NetworkPacketDistributionUneven
        expr: node_network_packet_distribution_ratio > 3
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Uneven packet distribution detected"
          description: "Ratio: {{ $value }}x. RPS may not be working properly."

      # Alert when RPS is disabled
      - alert: NetworkRPSNotConfigured
        expr: node_network_rps_configured == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "RPS is not configured"
          description: "Network packet steering is disabled."

      # Alert on packet drops
      - alert: NetworkSoftnetPacketDrops
        expr: rate(node_network_softnet_dropped_total[5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Network packets being dropped"
          description: "CPU {{ $labels.cpu }} dropping {{ $value }} packets/sec"
```

## Verification and Testing

### Test Packet Distribution

```bash
# Take snapshot before generating traffic
cat /proc/net/softnet_stat > /tmp/before.txt

# Generate network load (e.g., large file transfer)
# ... traffic generation ...

# Take snapshot after
cat /proc/net/softnet_stat > /tmp/after.txt

# Calculate difference per CPU
paste /tmp/before.txt /tmp/after.txt | python3 -c "
import sys
for i, line in enumerate(sys.stdin):
    cols = line.split()
    before = int(cols[0], 16)
    after = int(cols[13], 16)  # After hex value position
    diff = after - before
    print(f'CPU {i:2d}: {diff:8,d} packets processed')
"
```

### Expected Results

**Without RPS** (bad):

```
CPU  0: 5,234,123 packets  ← Overloaded
CPU  1: 4,891,234 packets  ← Overloaded
CPU  2:   123,456 packets  ← Idle
CPU  3:    98,234 packets  ← Idle
...
Ratio: 53.4x (BAD)
```

**With RPS** (good):

```
CPU  0:   456,789 packets  ← Balanced
CPU  1:   423,456 packets  ← Balanced
CPU  2:   445,123 packets  ← Balanced
CPU  3:   467,890 packets  ← Balanced
...
Ratio: 1.8x (GOOD)
```

## Common Pitfalls

### 1. RPS Not Persisting After Reboot

**Problem:** RPS settings are lost on reboot.

**Solution:** Use systemd service (shown above) or add to network interface configuration.

### 2. Wrong CPU Mask

**Problem:** Using CPU mask that doesn't match actual CPU count.

**Solution:** Always calculate based on `nproc` output:

- For N CPUs: mask = 2^N - 1 (in hex)

### 3. Monitoring Only Hardware Metrics

**Problem:** Looking only at `ethtool -S` which shows hardware-level stats.

**Solution:** Also monitor `/proc/net/softnet_stat` for CPU-level packet processing.

### 4. Ignoring Softnet Backlog

**Problem:** Ring buffer is large but netdev_max_backlog is default (1000).

**Solution:** Increase `net.core.netdev_max_backlog` to 5000+.
