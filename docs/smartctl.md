[Self-Monitoring, Analysis, and Reporting Technology (S.M.A.R.T. or SMART)](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology) is a monitoring system included in computer hard disk drives (HDDs) and solid-state drives (SSDs). Its primary function is to detect and report various indicators of drive reliability, or how long a drive can function while anticipating imminent hardware failures.

When S.M.A.R.T. data indicates a possible imminent drive failure, software running on the host system may notify the user so action can be taken to prevent data loss, and the failing drive can be replaced and no data is lost.

# General information

## [Accuracy](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology#Accuracy)

A field study at Google covering over 100,000 consumer-grade drives from December 2005 to August 2006 found correlations between certain S.M.A.R.T. information and annualized failure rates:

- In the 60 days following the first uncorrectable error on a drive (S.M.A.R.T. attribute 0xC6 or 198) detected as a result of an offline scan, the drive was, on average, 39 times more likely to fail than a similar drive for which no such error occurred.
- First errors in reallocations, offline reallocations (S.M.A.R.T. attributes 0xC4 and 0x05 or 196 and 5) and probational counts (S.M.A.R.T. attribute 0xC5 or 197) were also strongly correlated to higher probabilities of failure.
- Conversely, little correlation was found for increased temperature and no correlation for usage level. However, the research showed that a large proportion (56%) of the failed drives failed without recording any count in the "four strong S.M.A.R.T. warnings" identified as scan errors, reallocation count, offline reallocation, and probational count.
- Further, 36% of failed drives did so without recording any S.M.A.R.T. error at all, except the temperature, meaning that S.M.A.R.T. data alone was of limited usefulness in anticipating failures.

# [Installation](https://blog.shadypixel.com/monitoring-hard-drive-health-on-linux-with-smartmontools/)

On Debian systems:

```bash
sudo apt-get install smartmontools
```

By default when you install it all your drives are checked periodically with the `smartd` daemon under the `smartmontools` systemd service.

# Usage

## Running the tests

### [Test types](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology#Self-tests)

S.M.A.R.T. drives may offer a number of self-tests:

- Short: Checks the electrical and mechanical performance as well as the read performance of the disk. Electrical tests might include a test of buffer RAM, a read/write circuitry test, or a test of the read/write head elements. Mechanical test includes seeking and servo on data tracks. Scans small parts of the drive's surface (area is vendor-specific and there is a time limit on the test). Checks the list of pending sectors that may have read errors, and it usually takes under two minutes.
- Long/extended: A longer and more thorough version of the short self-test, scanning the entire disk surface with no time limit. This test usually takes several hours, depending on the read/write speed of the drive and its size. It is possible for the long test to pass even if the short test fails.
- Conveyance: Intended as a quick test to identify damage incurred during transporting of the device from the drive manufacturer to the computer manufacturer. Only available on ATA drives, and it usually takes several minutes.

Drives remain operable during self-test, unless a "captive" option (ATA only) is requested.

#### Long test

Start with a long self test with `smartctl`. Assuming the disk to test is
`/dev/sdd`:

```bash
smartctl -t long /dev/sdd
```

The command will respond with an estimate of how long it thinks the test will
take to complete.

To check progress use:

```bash
smartctl -A /dev/sdd | grep remaining
# or
smartctl -c /dev/sdd | grep remaining
```

Don't check too often because it can abort the test with some drives. If you
receive an empty output, examine the reported status with:

```bash
smartctl -l selftest /dev/sdd
```

If errors are shown, check the `dmesg` as there are usually useful traces of the error.

## Understanding the tests

The output of a `smartctl` command is difficult to read:

```
smartctl 5.40 2010-03-16 r3077 [x86_64-unknown-linux-gnu] (local build)
Copyright (C) 2002-10 by Bruce Allen, http://smartmontools.sourceforge.net

=== START OF INFORMATION SECTION ===
Model Family:     SAMSUNG SpinPoint F2 EG series
Device Model:     SAMSUNG HD502HI
Serial Number:    S1VZJ9CS712490
Firmware Version: 1AG01118
User Capacity:    500,107,862,016 bytes
Device is:        In smartctl database [for details use: -P show]
ATA Version is:   8
ATA Standard is:  ATA-8-ACS revision 3b
Local Time is:    Wed Feb  9 15:30:42 2011 CET
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x00)    Offline data collection activity
                    was never started.
                    Auto Offline Data Collection: Disabled.
Self-test execution status:      (   0)    The previous self-test routine completed
                    without error or no self-test has ever
                    been run.
Total time to complete Offline
data collection:          (6312) seconds.
Offline data collection
capabilities:              (0x7b) SMART execute Offline immediate.
                    Auto Offline data collection on/off support.
                    Suspend Offline collection upon new
                    command.
                    Offline surface scan supported.
                    Self-test supported.
                    Conveyance Self-test supported.
                    Selective Self-test supported.
SMART capabilities:            (0x0003)    Saves SMART data before entering
                    power-saving mode.
                    Supports SMART auto save timer.
Error logging capability:        (0x01)    Error logging supported.
                    General Purpose Logging supported.
Short self-test routine
recommended polling time:      (   2) minutes.
Extended self-test routine
recommended polling time:      ( 106) minutes.
Conveyance self-test routine
recommended polling time:      (  12) minutes.
SCT capabilities:            (0x003f)    SCT Status supported.
                    SCT Error Recovery Control supported.
                    SCT Feature Control supported.
                    SCT Data Table supported.

SMART Attributes Data Structure revision number: 16
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   099   099   051    Pre-fail  Always       -       2376
  3 Spin_Up_Time            0x0007   091   091   011    Pre-fail  Always       -       3620
  4 Start_Stop_Count        0x0032   100   100   000    Old_age   Always       -       405
  5 Reallocated_Sector_Ct   0x0033   100   100   010    Pre-fail  Always       -       0
  7 Seek_Error_Rate         0x000f   253   253   051    Pre-fail  Always       -       0
  8 Seek_Time_Performance   0x0025   100   100   015    Pre-fail  Offline      -       0
  9 Power_On_Hours          0x0032   100   100   000    Old_age   Always       -       717
 10 Spin_Retry_Count        0x0033   100   100   051    Pre-fail  Always       -       0
 11 Calibration_Retry_Count 0x0012   100   100   000    Old_age   Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       405
 13 Read_Soft_Error_Rate    0x000e   099   099   000    Old_age   Always       -       2375
183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
184 End-to-End_Error        0x0033   100   100   000    Pre-fail  Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       2375
188 Command_Timeout         0x0032   100   100   000    Old_age   Always       -       0
190 Airflow_Temperature_Cel 0x0022   084   074   000    Old_age   Always       -       16 (Lifetime Min/Max 16/16)
194 Temperature_Celsius     0x0022   084   071   000    Old_age   Always       -       16 (Lifetime Min/Max 16/16)
195 Hardware_ECC_Recovered  0x001a   100   100   000    Old_age   Always       -       3558
196 Reallocated_Event_Count 0x0032   100   100   000    Old_age   Always       -       0
197 Current_Pending_Sector  0x0012   098   098   000    Old_age   Always       -       81
198 Offline_Uncorrectable   0x0030   100   100   000    Old_age   Offline      -       0
199 UDMA_CRC_Error_Count    0x003e   100   100   000    Old_age   Always       -       1
200 Multi_Zone_Error_Rate   0x000a   100   100   000    Old_age   Always       -       0
201 Soft_Read_Error_Rate    0x000a   253   253   000    Old_age   Always       -       0

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
No self-tests have been logged.  [To run self-tests, use: smartctl -t]


SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.
```

### Checking overall health

Somewhere in your report you'll see something like:

```
=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED
```

If it doesn’t return PASSED, you should immediately backup all your data. Your hard drive is probably failing.

That message can also be shown with `smartctl -H /dev/sda`

### [Checking the SMART attributes](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology#Known_ATA_S.M.A.R.T._attributes)

Each drive manufacturer defines a set of attributes, and sets threshold values beyond which attributes should not pass under normal operation. But they do not agree on precise attribute definitions and measurement units, the following list of attributes is a general guide only.

If one or more attribute have the "prefailure" flag, and the "current value" of such prefailure attribute is smaller than or equal to its "threshold value" (unless the "threshold value" is 0), that will be reported as a "drive failure". In addition, a utility software can send SMART RETURN STATUS command to the ATA drive, it may report three status: "drive OK", "drive warning" or "drive failure".

#### [SMART attributes columns](https://ma.juii.net/blog/interpret-smart-attributes)

Every of the SMART attributes has several columns as shown by “smartctl -a <device>”:

- ID: The ID number of the attribute, good for comparing with other lists like [Wikipedia: S.M.A.R.T.: Known ATA S.M.A.R.T. attributes](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology#Known_ATA_S.M.A.R.T._attributes) because the attribute names sometimes differ.
- Name: The name of the SMART attribute.
- Value: The current, normalized value of the attribute. Higher values are always better (except for temperature for hard disks of some manufacturers). The range is normally 0-100, for some attributes 0-255 (so that 100 resp. 255 is best, 0 is worst). There is no standard on how manufacturers convert their raw value to this normalized one: when the normalized value approaches threshold, it can do linearily, exponentially, logarithmically or any other way, meaning that a doubled normalized value does not necessarily mean “twice as good”.
- Worst: The worst (normalized) value that this attribute had at any point of time where SMART was enabled. There seems to be no mechanism to reset current SMART attribute values, but this still makes sense as some SMART attributes, for some manufacturers, fluctuate over time so that keeping the worst one ever is meaningful.
- Threshold: The threshold below which the normalized value will be considered “exceeding specifications”. If the attribute type is “Pre-fail”, this means that SMART thinks the hard disk is just before failure. This will “trigger” SMART: setting it from “SMART test passed” to “SMART impending failure” or similar status.
- Type: The type of the attribute. Either “Pre-fail” for attributes that are said to indicate impending failure, or “Old_age” for attributes that just indicate wear and tear. Note that one and the same attribute can be classified as “Pre-fail” by one manufacturer or for one model and as “Old_age” by another or for another model. This is the case for example for attribute Seek_Error_Rate (ID 7), which is a widespread phenomenon on many disks and not considered critical by some manufacturers, but Seagate has it as “Pre-fail”.
- Raw value: The current raw value that was converted to the normalized value above. smartctl shows all as decimal values, but some attribute values of some manufacturers cannot be reasonably interpreted that way

#### [Reacting to SMART Values](https://ma.juii.net/blog/interpret-smart-attributes)

It is said that a drive that starts getting bad sectors (attribute ID 5) or “pending” bad sectors (attribute ID 197; they most likely are bad, too) will usually be trash in 6 months or less. The only exception would be if this does not happen: that is, bad sector count increases, but then stays stable for a long time, like a year or more. For that reason, one normally needs a diagramming / journaling tool for SMART. Many admins will exchange the hard drive if it gets reallocated sectors (ID 5) or sectors “under investigation” (ID 197)

#### [Critical SMART attributes](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology#Known_ATA_S.M.A.R.T._attributes)

Of all the attributes I'm going to analyse only the critical ones

##### Read Error Rate

ID: 01 (0x01)
Ideal: Low
Correlation with probability of failure: not clear

(Vendor specific raw value.) Stores data related to the rate of hardware read errors that occurred when reading data from a disk surface. The raw value has different structure for different vendors and is often not meaningful as a decimal number. For some drives, this number may increase during normal operation without necessarily signifying errors.

##### Reallocated Sectors Count

ID: 05 (0x05)
Ideal: Low
Correlation with probability of failure: Strong

Count of reallocated sectors. The raw value represents a count of the bad sectors that have been found and remapped. Thus, the higher the attribute value, the more sectors the drive has had to reallocate. This value is primarily used as a metric of the life expectancy of the drive; a drive which has had any reallocations at all is significantly more likely to fail in the immediate months. If Raw value of 0x05 attribute is higher than its Threshold value, that will reported as "drive warning".

##### Spin Retry Count

ID: 10 (0x0A)
Ideal: Low
Correlation with probability of failure: Strong

Count of retry of spin start attempts. This attribute stores a total count of the spin start attempts to reach the fully operational speed (under the condition that the first attempt was unsuccessful). An increase of this attribute value is a sign of problems in the hard disk mechanical subsystem.

##### Current Pending Sector Count

ID: 197 (0xC5)
Ideal: Low
Correlation with probability of failure: Strong

Count of "unstable" sectors (waiting to be remapped, because of unrecoverable read errors). If an unstable sector is subsequently read successfully, the sector is remapped and this value is decreased. Read errors on a sector will not remap the sector immediately (since the correct value cannot be read and so the value to remap is not known, and also it might become readable later); instead, the drive firmware remembers that the sector needs to be remapped, and will remap it the next time it has been successfully read.[76]

However, some drives will not immediately remap such sectors when successfully read; instead the drive will first attempt to write to the problem sector, and if the write operation is successful the sector will then be marked as good (in this case, the "Reallocation Event Count" (0xC4) will not be increased). This is a serious shortcoming, for if such a drive contains marginal sectors that consistently fail only after some time has passed following a successful write operation, then the drive will never remap these problem sectors. If Raw value of 0xC5 attribute is higher than its Threshold value, that will reported as "drive warning"

##### (Offline) Uncorrectable Sector Count

ID: 198 (0xC6)
Ideal: Low
Correlation with probability of failure: Strong

The total count of uncorrectable errors when reading/writing a sector. A rise in the value of this attribute indicates defects of the disk surface and/or problems in the mechanical subsystem.

In the 60 days following the first uncorrectable error on a drive (S.M.A.R.T. attribute 0xC6 or 198) detected as a result of an offline scan, the drive was, on average, 39 times more likely to fail than a similar drive for which no such error occurred.

#### [Non critical SMART attributes](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology#Known_ATA_S.M.A.R.T._attributes)

The next attributes appear to change in the logs but that doesn't mean that there is anything going wrong

##### Hardware ECC Recovered

ID: 195 (0xC3)
Ideal: Varies
Correlation with probability of failure: Low

(Vendor-specific raw value.) The raw value has different structure for different vendors and is often not meaningful as a decimal number. For some drives, this number may increase during normal operation without necessarily signifying errors.

# Monitorization

To monitor your drive health you can use [prometheus](prometheus.md) with [alertmanager](alertmanager.md) for alerts and [grafana](grafana.md) for dashboards.

## Installing the exporter

The prometheus community has it's own [smartctl exporter](https://github.com/prometheus-community/smartctl_exporter)

### Using the binary

You can download the latest binary from the repository [releases](https://github.com/prometheus-community/smartctl_exporter/releases) and configure the [systemd service](https://github.com/prometheus-community/smartctl_exporter/blob/master/systemd/smartctl_exporter.service)

```bash
unp smartctl_exporter-0.13.0.linux-amd64.tar.gz
sudo mv smartctl_exporter-0.13.0.linux-amd64/smartctl_exporter /usr/bin
```

Add the [service](https://github.com/prometheus-community/smartctl_exporter/blob/master/systemd/smartctl_exporter.service) to `/etc/systemd/system/smartctl-exporter.service`

```ini
[Unit]
Description=smartctl exporter service
After=network-online.target

[Service]
Type=simple
PIDFile=/run/smartctl_exporter.pid
ExecStart=/usr/bin/smartctl_exporter
User=root
Group=root
SyslogIdentifier=smartctl_exporter
Restart=on-failure
RemainAfterExit=no
RestartSec=100ms
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Then enable it:

```bash
sudo systemctl enable smartctl-exporter
sudo service smartctl-exporter start
```

### [Using docker](https://github.com/prometheus-community/smartctl_exporter?tab=readme-ov-file#example-of-running-in-docker)

```yaml
---
services:
  smartctl-exporter:
    container_name: smartctl-exporter
    image: prometheuscommunity/smartctl-exporter
    privileged: true
    user: root
    ports:
      - "9633:9633"
```

### Configuring prometheus

Add the next scraping metrics:

```yaml
- job_name: smartctl_exporter
  metrics_path: /metrics
  scrape_timeout: 60s
  static_configs:
    - targets: [smartctl-exporter:9633]
      labels:
        hostname: "your-hostname"
```

### Configuring the alerts

Taking as a reference the [awesome prometheus rules](https://samber.github.io/awesome-prometheus-alerts/rules#s.m.a.r.t-device-monitoring) and [this wired post](https://www.wirewd.com/hacks/blog/monitoring_a_mixed_fleet_of_flash_hdd_and_nvme_devices_with_node_exporter_and_prometheus) I'm using the next rules:

```yaml
---
groups:
  - name: smartctl exporter
    rules:
      - alert: SmartDeviceTemperatureWarning
        expr: smartctl_device_temperature > 60
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: Smart device temperature warning (instance {{ $labels.hostname }})
          description: "Device temperature  warning (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: SmartDeviceTemperatureCritical
        expr: smartctl_device_temperature > 80
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: Smart device temperature critical (instance {{ $labels.hostname }})
          description: "Device temperature critical  (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: SmartCriticalWarning
        expr: smartctl_device_critical_warning > 0
        for: 15m
        labels:
          severity: critical
        annotations:
          summary: Smart critical warning (instance {{ $labels.hostname }})
          description: "device has critical warning (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: SmartNvmeWearoutIndicator
        expr: smartctl_device_available_spare{device=~"nvme.*"} < smartctl_device_available_spare_threshold{device=~"nvme.*"}
        for: 15m
        labels:
          severity: critical
        annotations:
          summary: Smart NVME Wearout Indicator (instance {{ $labels.hostname }})
          description: "NVMe device is wearing out (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: SmartNvmeMediaError
        expr: smartctl_device_media_errors > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: Smart NVME Media errors (instance {{ $labels.hostname }})
          description: "Contains the number of occurrences where the controller detected an unrecovered data integrity error. Errors such as uncorrectable ECC, CRC checksum failure, or LBA tag mismatch are included in this field (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: SmartSmartStatusError
        expr: smartctl_device_smart_status < 1
        for: 15m
        labels:
          severity: critical
        annotations:
          summary: Smart general status error (instance {{ $labels.hostname }})
          description: " (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: DiskReallocatedSectorsIncreased
        expr: smartctl_device_attribute{attribute_id="5", attribute_value_type="raw"} > max_over_time(smartctl_device_attribute{attribute_id="5", attribute_value_type="raw"}[1h])
        labels:
          severity: warning
        annotations:
          summary: "SMART Attribute Reallocated Sectors Count Increased"
          description: "The SMART attribute 5 (Reallocated Sectors Count) has increased on {{ $labels.device }} (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: DiskSpinRetryCountIncreased
        expr: smartctl_device_attribute{attribute_id="10", attribute_value_type="raw"} > max_over_time(smartctl_device_attribute{attribute_id="10", attribute_value_type="raw"}[1h])
        labels:
          severity: warning
        annotations:
          summary: "SMART Attribute Spin Retry Count Increased"
          description: "The SMART attribute 10 (Spin Retry Count) has increased on {{ $labels.device }} (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: DiskCurrentPendingSectorCountIncreased
        expr: smartctl_device_attribute{attribute_id="197", attribute_value_type="raw"} > max_over_time(smartctl_device_attribute{attribute_id="197", attribute_value_type="raw"}[1h])
        labels:
          severity: warning
        annotations:
          summary: "SMART Attribute Current Pending Sector Count Increased"
          description: "The SMART attribute 197 (Current Pending Sector Count) has increased on {{ $labels.device }} (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

      - alert: DiskUncorrectableSectorCountIncreased
        expr: smartctl_device_attribute{attribute_id="198", attribute_value_type="raw"} > max_over_time(smartctl_device_attribute{attribute_id="198", attribute_value_type="raw"}[1h])
        labels:
          severity: warning
        annotations:
          summary: "SMART Attribute Uncorrectable Sector Count Increased"
          description: "The SMART attribute 198 (Uncorrectable Sector Count) has increased on {{ $labels.device }} (instance {{ $labels.hostname }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### Configuring the grafana dashboards

Of the different grafana dashboards ([1](https://grafana.com/grafana/dashboards/22604-smartctl-exporter-dashboard/), [2](https://grafana.com/grafana/dashboards/20204-smart-hdd/), [3](https://grafana.com/grafana/dashboards/22381-smartctl-exporter/)) I went for the first one.

Import it with the UI of grafana, make it work and then export the json to store it in your infra as code respository.

# References

- [Wikipedia](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology)
- [Home](https://sourceforge.net/projects/smartmontools/)
- [Documentation](https://www.smartmontools.org/wiki/TocDoc)
