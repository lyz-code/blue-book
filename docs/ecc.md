[Error Correction Code](https://www.memtest86.com/ecc.htm) (ECC) is a mechanism used to detect and correct errors in memory data due to environmental interference and physical defects. ECC memory is used in high-reliability applications that cannot tolerate failure due to corrupted data.

# Installation
 Due to additional circuitry required for ECC protection, specialized ECC hardware support is required by the CPU chipset, motherboard and DRAM module. This includes the following:

- Server-grade CPU chipset with ECC support (Intel Xeon, AMD Ryzen)
- Motherboard supporting ECC operation
- ECC RAM

Consult the motherboard and/or CPU documentation for the specific model to verify whether the hardware supports ECC. Use vendor-supplied list of certified ECC RAM, if provided. 

Most ECC-supported motherboards allow you to configure ECC settings from the BIOS setup. They are usually on the Advanced tab. The specific option depends on the motherboard vendor or model such as the following:

- DRAM ECC Enable (American Megatrends, ASUS, ASRock, MSI)
- ECC Mode (ASUS)

# Monitorization

The mechanism for how ECC errors are logged and reported to the end-user depends on the BIOS and operating system. In most cases, corrected ECC errors are written to system/event logs. Uncorrected ECC errors may result in kernel panic or blue screen.

The Linux kernel supports reporting ECC errors for ECC memory via the EDAC (Error Detection And Correction) driver subsystem. Depending on the Linux distribution, ECC errors may be reported by the following:

- [`rasdaemon`](rasdaemon.md): monitor ECC memory and report both correctable and uncorrectable memory errors on recent Linux kernels.
- `mcelog` (Deprecated): collects and decodes MCA error events on x86.
- `edac-utils` (Deprecated): fills DIMM labels data and summarizes memory errors.

To configure rasdaemon follow [this article](rasdaemon.md)

# Confusion on boards supporting ECC

I've read that even if some motherboards say that they "Support ECC" some of them don't do anything with it.

On [this post](https://forums.servethehome.com/index.php?threads/has-anyone-gotten-ecc-logging-rasdaemon-edac-whea-etc-to-work-on-xeon-w-1200-or-w-1300-or-core-12-or-13-gen-processors.39257/) and the [kernel docs](https://www.kernel.org/doc/html/latest/firmware-guide/acpi/apei/einj.html) show that you should see references to ACPI/WHEA in the specs manual. Ideally ACPI5 support.

From the )  EINJ provides a hardware error injection mechanism. It is very useful for debugging and testing APEI and RAS features in general.

You need to check whether your BIOS supports EINJ first. For that, look for early boot messages similar to this one:

```
ACPI: EINJ 0x000000007370A000 000150 (v01 INTEL           00000001 INTL 00000001)
```

Which shows that the BIOS is exposing an EINJ table - it is the mechanism through which the injection is done.

Alternatively, look in `/sys/firmware/acpi/tables` for an "EINJ" file, which is a different representation of the same thing.

It doesn't necessarily mean that EINJ is not supported if those above don't exist: before you give up, go into BIOS setup to see if the BIOS has an option to enable error injection. Look for something called `WHEA` or similar. Often, you need to enable an `ACPI5` support option prior, in order to see the `APEI`,`EINJ`,... functionality supported and exposed by the BIOS menu.

To use `EINJ`, make sure the following are options enabled in your kernel configuration:

```
CONFIG_DEBUG_FS
CONFIG_ACPI_APEI
CONFIG_ACPI_APEI_EINJ
```

One way to test it can be to run [memtest](memtest.md) as it sometimes [shows ECC errors](https://forum.level1techs.com/t/asrock-taichi-x570-ecc-options-no-longer-in-bios/178045) such as `** Warning** ECC injection may be disabled for AMD Ryzen (70h-7fh)`.

Other people ([1](https://www.memtest86.com/ecc.htm), [2](https://www.reddit.com/r/ASRock/comments/jlsw5z/x570_pro4_correctable_ecc_errors_no_response_from/) say that there are a lot of motherboards that NEVER report any corrected errors to the OS. In order to see corrected errors, PFEH (Platform First Error Handling) has to be disabled. On some motherboards and FW versions this setting is hidden from the user and always enabled, thus resulting in zero correctable errors getting reported. 

[They also suggest](https://www.memtest86.com/ecc.htm) to disable "Quick Boot". In order to initialize ECC, memory has to be written before it can be used. Usually this is done by BIOS, but with some motherboards this step is skipped if "Quick Boot" is enabled. 

The people behind [memtest](memtest.md) have a [paid tool to test ECC](https://www.passmark.com/products/ecc-tester/index.php)

Another way is to run `dmidecode`. For ECC support you'll see:
```bash
$: dmidecode -t memory | grep ECC
  Error Correction Type: Single-bit ECC
  # or
  Error Correction Type: Multi-bit ECC
```

No ECC:

```bash
$: dmidecode -t memory | grep ECC
  Error Correction Type: None
```

You can also test it with [`rasdaemon`](rasdaemon.md)
\n\n[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
