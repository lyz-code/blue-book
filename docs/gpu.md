[GPU](https://en.wikipedia.org/wiki/Graphics_processing_unit) or Graphic Processing Unit is a specialized electronic circuit initially designed to accelerate computer graphics and image processing (either on a video card or embedded on motherboards, mobile phones, personal computers, workstations, and game consoles). 

For years I've wanted to buy a graphic card but I've been stuck in the problem that I don't have a desktop. I have a X280 lenovo laptop used to work and personal use with an integrated card that has let me so far to play old games such as [King Arthur Gold](kag.md) or [Age of Empires II](age_of_empires.md), but has hard times playing "newer" games such as It takes two. Last year I also bought a [NAS](nas.md) with awesome hardware. So it makes no sense to buy a desktop just for playing. 

Now that I host [Jellyfin](jellyfin.md) on the NAS and that machine learning is on the hype with a lot of interesting solutions that can be self-hosted (whisper, chatgpt similar solutions...), it starts to make sense to add a GPU to the server. What made me give the step is that you can also self-host a gaming server to stream to any device! It makes so much sense to have all the big guns inside the NAS and stream the content to the less powerful devices. 

That way if you host services, you make the most use of the hardware.

# [Install cuda](https://developer.nvidia.com/cuda-downloads)
[CUDA](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html) is a parallel computing platform and programming model invented by NVIDIA®. It enables dramatic increases in computing performance by harnessing the power of the graphics processing unit (GPU).
If you're not using Debian 11 follow [these instructions](https://developer.nvidia.com/cuda-downloads)

## Base Installer

**Installation Instructions:**

```sh
wget https://developer.download.nvidia.com/compute/cuda/12.5.1/local_installers/cuda-repo-debian11-12-5-local_12.5.1-555.42.06-1_amd64.deb
sudo dpkg -i cuda-repo-debian11-12-5-local_12.5.1-555.42.06-1_amd64.deb
sudo cp /var/cuda-repo-debian11-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo add-apt-repository contrib
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-5
```

Additional installation options are detailed [here](https://developer.nvidia.com/cuda-downloads).

## Driver Installer

To install the open kernel module flavor:

```sh
sudo apt-get install -y nvidia-kernel-open-dkms
sudo apt-get install -y cuda-drivers
```
## Install cuda
```bash
apt-get install cuda
reboot
```
# Install nvidia card
Check if your card is supported in the [releases supported by your OS](https://wiki.debian.org/NvidiaGraphicsDrivers)
## [If it's supported](https://wiki.debian.org/NvidiaGraphicsDrivers)
## [If it's not supported](https://docs.kinetica.com/7.1/install/nvidia_deb/)

### Ensure the GPUs are Installed

#### Install `pciutils`
Ensure that the `lspci` command is installed (which lists the PCI devices connected to the server):

```sh
sudo apt-get -y install pciutils
```

#### Check Installed Nvidia Cards
Perform a quick check to determine what Nvidia cards have been installed:

```sh
lspci | grep VGA
```

The output of the `lspci` command above should be something similar to:

```
00:02.0 VGA compatible controller: Intel Corporation 4th Gen ...
01:00.0 VGA compatible controller: Nvidia Corporation ...
```

If you do not see a line that includes Nvidia, then the GPU is not properly installed. Otherwise, you should see the make and model of the GPU devices that are installed.

## Disable Nouveau

### Blacklist Nouveau in Modprobe
The `nouveau` driver is an alternative to the Nvidia drivers generally installed on the server. It does not work with CUDA and must be disabled. The first step is to edit the file at `/etc/modprobe.d/blacklist-nouveau.conf`. 

Create the file with the following content:

```sh
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF
```

Then, run the following commands:

```sh
echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
sudo update-initramfs -u
```

### Update Grub to Blacklist Nouveau
Backup your grub config template:

```sh
sudo cp /etc/default/grub /etc/default/grub.bak
```

Then, update your grub config template at `/etc/default/grub`. Add `rd.driver.blacklist=nouveau` and `rcutree.rcu_idle_gp_delay=1` to the `GRUB_CMDLINE_LINUX` variable. For example, change:

```sh
GRUB_CMDLINE_LINUX="quiet"
```

to:

```sh
GRUB_CMDLINE_LINUX="quiet rd.driver.blacklist=nouveau rcutree.rcu_idle_gp_delay=1"
```

Then, rebuild your grub config:

```sh
sudo grub2-mkconfig -o /boot/grub/grub.cfg
```

## Install prerequisites
The following prerequisites should be installed before installing the Nvidia drivers:

```sh
sudo apt-get -y install linux-headers-$(uname -r) make gcc-4.8
sudo apt-get -y install acpid dkms
```

## Close X Server
Before running the install, you should exit out of any X environment, such as Gnome, KDE, or XFCE. To exit the X session, switch to a TTY console using `Ctrl-Alt-F1` and then determine whether you are running `lightdm` or `gdm` by running:

```sh
sudo ps aux | grep "lightdm|gdm|kdm"
```

Depending on which is running, stop the service, running the following commands (substitute `gdm` or `kdm` for `lightdm` as appropriate):

```sh
sudo service lightdm stop
sudo init 3
```

## Install Drivers Only

**Important**

To accommodate GL-accelerated rendering, OpenGL and GL Vendor Neutral Dispatch (GLVND) are now required and should be installed with the Nvidia drivers. OpenGL is an installation option in the `*.run` type of drivers. In other types of the drivers, OpenGL is enabled by default in most modern versions (dated 2016 and later). GLVND can be installed using the installer menus or via the `--glvnd-glx-client` command line flag.

This section deals with installing the drivers via the `*.run` executables provided by Nvidia.

To download only the drivers, navigate to [http://www.nvidia.com/object/unix.html](http://www.nvidia.com/object/unix.html) and click the Latest Long Lived Branch version under the appropriate CPU architecture. On the ensuing page, click Download and then click Agree and Download on the page that follows.

**Note**

The Unix drivers found in the link above are also compatible with all Nvidia Tesla models.

If you'd prefer to download the full driver repository, Nvidia provides a tool to recommend the most recent available driver for your graphics card at [http://www.Nvidia.com/Download/index.aspx?lang=en-us](http://www.Nvidia.com/Download/index.aspx?lang=en-us).

If you are unsure which Nvidia devices are installed, the `lspci` command should give you that information:

```sh
lspci | grep -i "nvidia"
```

Download the recommended driver executable. Change the file permissions to allow execution:

```sh
chmod +x ./NVIDIA-Linux-$(uname -m)-*.run
```

Run the install.

## Check that it's installed
To check that the GPU is well installed and functioning properly, you can use the `nvidia-smi` command. This command provides detailed information about the installed Nvidia GPUs, including their status, utilization, and driver version. 

First, ensure the Nvidia drivers are installed. Then, run:

```sh
nvidia-smi
```

If the GPU is properly installed, you should see an output that includes information about the GPU, such as its model, memory usage, and driver version. The output will look something like this:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 450.66       Driver Version: 450.66       CUDA Version: 11.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla K80           Off  | 00000000:00:1E.0 Off |                    0 |
| N/A   38C    P8    29W / 149W |      0MiB / 11441MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

If you encounter any errors or the GPU is not listed, there may be an issue with the installation or configuration of the GPU drivers.

# [Measure usage](https://askubuntu.com/questions/387594/how-to-measure-gpu-usage)
For Nvidia GPUs there is a tool [nvidia-smi](https://developer.nvidia.com/system-management-interface) that can show memory usage, GPU utilization and temperature of GPU.

# [Load test the gpu](https://github.com/wilicc/gpu-burn)

First make sure you have [CUDA](#install-cuda) installed, then install the `gpu_burn` tool
```bash
git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make
```

To run a test for 60 seconds run:
```bash
./gpu_burn 60
```

# [Monitor it with Prometheus](https://developer.nvidia.com/blog/monitoring-gpus-in-kubernetes-with-dcgm/)

[NVIDIA DCGM](https://developer.nvidia.com/dcgm) is a set of tools for managing and monitoring NVIDIA GPUs in large-scale, Linux-based cluster environments. It’s a low overhead tool that can perform a variety of functions including active health monitoring, diagnostics, system validation, policies, power and clock management, group configuration, and accounting. For more information, see the [DCGM User Guide](https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-user-guide/overview.html).

You can use DCGM to expose GPU metrics to Prometheus using `dcgm-exporter`.

## [Install NVIDIA Container Kit](https://github.com/NVIDIA/nvidia-container-toolkit)
The NVIDIA Container Toolkit allows users to build and run GPU accelerated containers. The toolkit includes a container runtime library and utilities to automatically configure containers to leverage NVIDIA GPUs.

```bash
sudo apt-get install -y nvidia-container-toolkit
```

Configure the container runtime by using the nvidia-ctk command:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
```
Restart the Docker daemon:

```bash
sudo systemctl restart docker
```

## Install NVIDIA DCGM

Follow the [Getting Started Guide](https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html).

Determine the distribution name:

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
```

Download the meta-package to set up the CUDA network repository:

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-keyring_1.1-1_all.deb
```

Install the repository meta-data and the CUDA GPG key:

```bash
sudo dpkg -i cuda-keyring_1.1-1_all.deb
```

Update the Apt repository cache:

```bash
sudo apt-get update
```

Now, install DCGM:

```bash
sudo apt-get install -y datacenter-gpu-manager
```

Enable the DCGM systemd service (on reboot) and start it now:

```bash
sudo systemctl --now enable nvidia-dcgm
```

You should see output similar to this:

```
● dcgm.service - DCGM service
  Loaded: loaded (/usr/lib/systemd/system/dcgm.service; disabled; vendor preset: enabled)
  Active: active (running) since Mon 2020-10-12 12:18:57 PDT; 14s ago
Main PID: 32847 (nv-hostengine)
    Tasks: 7 (limit: 39321)
  CGroup: /system.slice/dcgm.service
          └─32847 /usr/bin/nv-hostengine -n

Oct 12 12:18:57 ubuntu1804 systemd[1]: Started DCGM service.
Oct 12 12:18:58 ubuntu1804 nv-hostengine[32847]: DCGM initialized
Oct 12 12:18:58 ubuntu1804 nv-hostengine[32847]: Host Engine Listener Started
```

To verify installation, use `dcgmi` to query the system. You should see a listing of all supported GPUs (and any NVSwitches) found in the system:

```bash
dcgmi discovery -l
```

Output:

```
8 GPUs found.
+--------+----------------------------------------------------------------------+
| GPU ID | Device Information                                                   |
+--------+----------------------------------------------------------------------+
| 0      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:07:00.0                                         |
|        | Device UUID: GPU-1d82f4df-3cf9-150d-088b-52f18f8654e1                |
+--------+----------------------------------------------------------------------+
| 1      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:0F:00.0                                         |
|        | Device UUID: GPU-94168100-c5d5-1c05-9005-26953dd598e7                |
+--------+----------------------------------------------------------------------+
| 2      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:47:00.0                                         |
|        | Device UUID: GPU-9387e4b3-3640-0064-6b80-5ace1ee535f6                |
+--------+----------------------------------------------------------------------+
| 3      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:4E:00.0                                         |
|        | Device UUID: GPU-cefd0e59-c486-c12f-418c-84ccd7a12bb2                |
+--------+----------------------------------------------------------------------+
| 4      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:87:00.0                                         |
|        | Device UUID: GPU-1501b26d-f3e4-8501-421d-5a444b17eda8                |
+--------+----------------------------------------------------------------------+
| 5      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:90:00.0                                         |
|        | Device UUID: GPU-f4180a63-1978-6c56-9903-ca5aac8af020                |
+--------+----------------------------------------------------------------------+
| 6      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:B7:00.0                                         |
|        | Device UUID: GPU-8b354e3e-0145-6cfc-aec6-db2c28dae134                |
+--------+----------------------------------------------------------------------+
| 7      | Name: A100-SXM4-40GB                                                 |
|        | PCI Bus ID: 00000000:BD:00.0                                         |
|        | Device UUID: GPU-a16e3b98-8be2-6a0c-7fac-9cb024dbc2df                |
+--------+----------------------------------------------------------------------+
6 NvSwitches found.
+-----------+
| Switch ID |
+-----------+
| 11        |
| 10        |
| 13        |
| 9         |
| 12        |
| 8         |
+-----------+
```

## [Install the dcgm-exporter](https://github.com/NVIDIA/dcgm-exporter)
As it doesn't need any persistence I've added it to the prometheus docker compose:

```
  dcgm-exporter:
    # latest didn't work
    image: nvcr.io/nvidia/k8s/dcgm-exporter:3.3.6-3.4.2-ubuntu22.04
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
    restart: unless-stopped
    container_name: dcgm-exporter
```

And added the next scraping config in `prometheus.yml`

```yaml
  - job_name: dcgm-exporter
    metrics_path: /metrics
    static_configs:
    - targets:
      - dcgm-exporter:9400
```
## Adding alerts

Tweak the next alerts for your use case.

```yaml
---
groups:
- name: dcgm-alerts
  rules:
  - alert: GPUHighTemperature
    expr: DCGM_FI_DEV_GPU_TEMP > 80
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "GPU High Temperature (instance {{ $labels.instance }})"
      description: "The GPU temperature is above 80°C for more than 5 minutes.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

  - alert: GPUMemoryUtilizationHigh
    expr: DCGM_FI_DEV_MEM_COPY_UTIL > 90
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "GPU Memory Utilization High (instance {{ $labels.instance }})"
      description: "The GPU memory utilization is above 90% for more than 10 minutes.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

  - alert: GPUComputeUtilizationHigh
    expr: DCGM_FI_DEV_GPU_UTIL > 90
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "GPU Compute Utilization High (instance {{ $labels.instance }})"
      description: "The GPU compute utilization is above 90% for more than 10 minutes.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

  - alert: GPUPowerUsageHigh
    expr: DCGM_FI_DEV_POWER_USAGE > 160
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "GPU Power Usage High (instance {{ $labels.instance }})"
      description: "The GPU power usage is above 160W for more than 5 minutes.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

  - alert: GPUUnavailable
    expr: up{job="dcgm-exporter"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "GPU Unavailable (instance {{ $labels.instance }})"
      description: "The DCGM Exporter instance is down or unreachable for more than 5 minutes.\n  LABELS: {{ $labels }}"
```
## Adding a dashboard

I've [tweaked this dashboard](https://grafana.com/grafana/dashboards/12239-nvidia-dcgm-exporter-dashboard/) to simplify it:

```json
{
  "annotations": {
    "list": [
      {
        "$$hashKey": "object:192",
        "builtIn": 1,
        "datasource": {
          "type": "datasource",
          "uid": "grafana"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "description": "This dashboard is to display the metrics from DCGM Exporter on a Kubernetes (1.13+) cluster",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "gnetId": 12239,
  "graphTooltip": 0,
  "links": [],
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "celsius"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 18,
        "x": 0,
        "y": 0
      },
      "id": 12,
      "options": {
        "legend": {
          "calcs": [
            "mean",
            "lastNotNull",
            "max"
          ],
          "displayMode": "table",
          "placement": "right",
          "showLegend": true
        },
        "tooltip": {
          "maxHeight": 600,
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "DCGM_FI_DEV_GPU_TEMP",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "GPU Temperature",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "max": 100,
          "min": 0,
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "#EAB839",
                "value": 83
              },
              {
                "color": "red",
                "value": 87
              }
            ]
          },
          "unit": "celsius"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 6,
        "x": 18,
        "y": 0
      },
      "id": 14,
      "options": {
        "minVizHeight": 75,
        "minVizWidth": 75,
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true,
        "sizing": "auto"
      },
      "pluginVersion": "11.0.1",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "avg(DCGM_FI_DEV_GPU_TEMP)",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "GPU Avg. Temp",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "watt"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 18,
        "x": 0,
        "y": 8
      },
      "id": 10,
      "options": {
        "legend": {
          "calcs": [
            "mean",
            "lastNotNull",
            "max"
          ],
          "displayMode": "table",
          "placement": "right",
          "showLegend": true
        },
        "tooltip": {
          "maxHeight": 600,
          "mode": "multi",
          "sort": "none"
        }
      },
      "pluginVersion": "6.5.2",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "DCGM_FI_DEV_POWER_USAGE",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "GPU Power Usage",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "max": 2400,
          "min": 0,
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "#EAB839",
                "value": 1800
              },
              {
                "color": "red",
                "value": 2200
              }
            ]
          },
          "unit": "watt"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 6,
        "x": 18,
        "y": 8
      },
      "id": 16,
      "options": {
        "minVizHeight": 75,
        "minVizWidth": 75,
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "sum"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true,
        "sizing": "auto"
      },
      "pluginVersion": "11.0.1",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "sum(DCGM_FI_DEV_POWER_USAGE)",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "GPU Power Total",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 2,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "hertz"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 16
      },
      "id": 2,
      "interval": "",
      "options": {
        "legend": {
          "calcs": [
            "mean",
            "lastNotNull",
            "max"
          ],
          "displayMode": "table",
          "placement": "right",
          "showLegend": true
        },
        "tooltip": {
          "maxHeight": 600,
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "DCGM_FI_DEV_SM_CLOCK * 1000000",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "GPU SM Clocks",
      "type": "timeseries"
    },
    {
      "aliasColors": {},
      "autoMigrateFrom": "graph",
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "uid": "${DS_PROMETHEUS}"
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 24
      },
      "hiddenSeries": false,
      "id": 6,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "max": true,
        "min": false,
        "rightSide": true,
        "show": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "DCGM_FI_DEV_GPU_UTIL{instance=~\"${instance}\", gpu=~\"${gpu}\"}",
          "interval": "",
          "legendFormat": "GPU {{gpu}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "GPU Utilization",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "cumulative"
      },
      "type": "timeseries",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percent",
          "logBase": 1,
          "max": "100",
          "min": "0",
          "show": true
        },
        {
          "format": "short",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {},
      "autoMigrateFrom": "graph",
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "uid": "${DS_PROMETHEUS}"
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 32
      },
      "hiddenSeries": false,
      "id": 4,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "max": true,
        "min": false,
        "rightSide": true,
        "show": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "DCGM_FI_PROF_PIPE_TENSOR_ACTIVE{instance=~\"${instance}\", gpu=~\"${gpu}\"}",
          "interval": "",
          "legendFormat": "GPU {{gpu}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Tensor Core Utilization",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "cumulative"
      },
      "type": "timeseries",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percentunit",
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        },
        {
          "format": "short",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {},
      "autoMigrateFrom": "graph",
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "uid": "${DS_PROMETHEUS}"
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 40
      },
      "hiddenSeries": false,
      "id": 18,
      "legend": {
        "avg": true,
        "current": false,
        "max": true,
        "min": false,
        "rightSide": true,
        "show": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "uid": "${DS_PROMETHEUS}"
          },
          "expr": "DCGM_FI_DEV_FB_USED{instance=~\"${instance}\", gpu=~\"${gpu}\"}",
          "interval": "",
          "legendFormat": "GPU {{gpu}}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "GPU Framebuffer Mem Used",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "timeseries",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "decmbytes",
          "logBase": 1,
          "show": true
        },
        {
          "format": "short",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    }
  ],
  "refresh": false,
  "schemaVersion": 39,
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timeRangeUpdatedDuringEditOrView": false,
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ]
  },
  "timezone": "",
  "title": "NVIDIA DCGM Exporter Dashboard",
  "uid": "Oxed_c6Wz",
  "version": 1,
  "weekStart": ""
}
```

# Market analysis

Done on January of 2024 taking into account the next requirements:

- Price under 600$
- Able to perform the next actions for at least 5 years:
  - [Jellyfin](jellyfin.md) transcoding
  - Videogame streaming from a headless server.
  - Machine learning operations.
- 

Using these sources:

- [PCGamer 2024 review](https://www.pcgamer.com/the-best-graphics-cards/)
- [Gamesradar 2024 review](https://www.gamesradar.com/best-pc-graphics-cards/)

## Overview of the market analysis

The best graphics card is objectively Nvidia's RTX 4090 but it's too expensive. Then there's the RTX 4080, which is a bit too pricey for us, and the RTX 4070 Ti. The RTX 4070 Ti also costs a heap more cash than we'd like, but at least it's more reasonable than Nvidia's finest for a perfectly 4K capable card.

On the other end of the market, Nvidia has a rather uninspired upgrade in the RTX 4060. We also met the release of AMD's RX 7600 with a shrug, but at least it's cheap enough now to feel more competitive. And Intel still has a dog in the budget game: the Arc A750. When this card drops down to around $200, it's a steal, though the drivers aren't always up to the standard we'd like to see. That leaves AMD's RX 7600 as the best budget graphics card today, mostly for being a boringly safe pick.

[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
