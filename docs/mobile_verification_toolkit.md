[Mobile Verification Toolkit](https://github.com/mvt-project/mvt) (MVT) is a collection of utilities to simplify and automate the process of gathering forensic traces helpful to identify a potential compromise of Android and iOS devices.

MVT's capabilities are continuously evolving, but some of its key features include:

- Decrypt encrypted iOS backups.
- Process and parse records from numerous iOS system and apps databases, logs and system analytics.
- Extract installed applications from Android devices.
- Extract diagnostic information from Android devices through the adb protocol.
- Compare extracted records to a provided list of malicious indicators in STIX2 format.
- Generate JSON logs of extracted records, and separate JSON logs of all detected malicious traces.
- Generate a unified chronological timeline of extracted records, along with a timeline all detected malicious traces.

MVT is a forensic research tool intended for technologists and investigators. Using it requires understanding the basics of forensic analysis and using command-line tools. MVT is not intended for end-user self-assessment. If you are concerned with the security of your device please seek expert assistance.

It has been developed and released by the Amnesty International Security Lab in July 2021 in the context of the Pegasus Project along with a technical forensic methodology. It continues to be maintained by Amnesty International and other contributors.

MVT supports using public indicators of compromise (IOCs) to scan mobile devices for potential traces of targeting or infection by known spyware campaigns. 

**Warning** Public indicators of compromise are insufficient to determine that a device is "clean", and not targeted with a particular spyware tool. Reliance on public indicators alone can miss recent forensic traces and give a false sense of security.

Reliable and comprehensive digital forensic support and triage requires access to non-public indicators, research and threat intelligence.

Such support is available to civil society through [Amnesty International's Security Lab](https://securitylab.amnesty.org/get-help/?c=mvt_docs) or through their forensic partnership with [Access Now’s Digital Security Helpline](https://www.accessnow.org/help/).

## How it works

### [Indicators of compromise](https://docs.mvt.re/en/latest/iocs/)

MVT uses [Structured Threat Information Expression (STIX)](https://oasis-open.github.io/cti-documentation/stix/intro.html) files to identify potential traces of compromise.

These indicators of compromise are contained in a file with a particular structure of [JSON](https://en.wikipedia.org/wiki/JSON) with the `.stix2` or `.json` extensions.

#### STIX2 Support

So far MVT implements only a subset of [STIX2 specifications](https://docs.oasis-open.org/cti/stix/v2.1/csprd01/stix-v2.1-csprd01.html):

* It only supports checks for one value (such as `[domain-name:value='DOMAIN']`) and not boolean expressions over multiple comparisons
* It only supports the following types: `domain-name:value`, `process:name`, `email-addr:value`, `file:name`, `file:path`, `file:hashes.md5`, `file:hashes.sha1`, `file:hashes.sha256`, `app:id`, `configuration-profile:id`, `android-property:name`, `url:value` (but each type will only be checked by a module if it is relevant to the type of data obtained)

#### Known repositories of STIX2 IOCs

- The [Amnesty International investigations repository](https://github.com/AmnestyTech/investigations) contains STIX-formatted IOCs for:
    - [Pegasus](https://en.wikipedia.org/wiki/Pegasus_(spyware)) ([STIX2](https://raw.githubusercontent.com/AmnestyTech/investigations/master/2021-07-18_nso/pegasus.stix2))
    - [Predator from Cytrox](https://citizenlab.ca/2021/12/pegasus-vs-predator-dissidents-doubly-infected-iphone-reveals-cytrox-mercenary-spyware/) ([STIX2](https://raw.githubusercontent.com/AmnestyTech/investigations/master/2021-12-16_cytrox/cytrox.stix2))
    - [An Android Spyware Campaign Linked to a Mercenary Company](https://github.com/AmnestyTech/investigations/tree/master/2023-03-29_android_campaign) ([STIX2](https://github.com/AmnestyTech/investigations/blob/master/2023-03-29_android_campaign/malware.stix2))
- [This repository](https://github.com/Te-k/stalkerware-indicators) contains IOCs for Android stalkerware including [a STIX MVT-compatible file](https://raw.githubusercontent.com/Te-k/stalkerware-indicators/master/generated/stalkerware.stix2).
- They are also maintaining [a list of IOCs](https://github.com/mvt-project/mvt-indicators) in STIX format from public spyware campaigns.

You can automatically download the latest public indicator files with the command `mvt-ios download-iocs` or `mvt-android download-iocs`. These commands download the list of indicators from the [mvt-indicators](https://github.com/mvt-project/mvt-indicators/blob/main/indicators.yaml) repository and store them in the [appdir](https://pypi.org/project/appdirs/) folder. They are then loaded automatically by MVT.

Please [open an issue](https://github.com/mvt-project/mvt/issues/) to suggest new sources of STIX-formatted IOCs.

### [Consensual Forensics](https://docs.mvt.re/en/latest/introduction/)

While MVT is capable of extracting and processing various types of very personal records typically found on a mobile phone (such as calls history, SMS and WhatsApp messages, etc.), this is intended to help identify potential attack vectors such as malicious SMS messages leading to exploitation.

MVT's purpose is not to facilitate adversarial forensics of non-consenting individuals' devices. The use of MVT and derivative products to extract and/or analyse data originating from devices used by individuals not consenting to the procedure is explicitly prohibited in the [license](license.md).

# [Installation](https://docs.mvt.re/en/latest/install/)

## [Using docker](https://docs.mvt.re/en/latest/docker/)

## Not using docker

Before proceeding, please note that MVT requires Python 3.6+ to run. While it should be available on most operating systems, please make sure of that before proceeding.

### Dependencies on Linux

First install some basic dependencies that will be necessary to build all required tools:

```bash
sudo apt install python3 python3-venv python3-pip sqlite3 libusb-1.0-0
```

`libusb-1.0-0` is not required if you intend to only use `mvt-ios` and not `mvt-android`.

(Recommended) Set up `pipx`

For Ubuntu 23.04 or above:
```bash
sudo apt install pipx
pipx ensurepath
```

For Ubuntu 22.04 or below:
```
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

Other distributions: check for a `pipx` or `python-pipx` via your package manager.

When working with Android devices you should additionally install [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools). If you prefer to install a package made available by your distribution of choice, please make sure the version is recent to ensure compatibility with modern Android devices.

### Installing ADB

Follow the steps of [android_sdk.md#installation].

### Installing MVT

1. Install `pipx` following the instructions above for your OS/distribution. Make sure to run `pipx ensurepath` and open a new terminal window.
2. ```bash
   pipx install mvt
   ```

You now should have the `mvt-ios` and `mvt-android` utilities installed. If you run into problems with these commands not being found, ensure you have run `pipx ensurepath` and opened a new terminal window.

# Usage

## Download the indicators 

If you want to check android:
```bash 
mvt-android download-iocs
```
If you want to check ios:
```bash 
mvt-ios download-iocs
```

## [Checking an Android mobile](https://docs.mvt.re/en/latest/android/methodology/)

Unfortunately Android devices provide much less observability than their iOS cousins. Android stores very little diagnostic information useful to triage potential compromises, and because of this `mvt-android` capabilities are limited as well.

However, not all is lost.

First [make sure `adb` works fine](android_sdk.md#connecting-over-usb).

Then you can run:

```bash
mvt-android check-adb --output .
```

### Check installed Apps

Because malware attacks over Android typically take the form of malicious or backdoored apps, the very first thing you might want to do is to extract and verify all installed Android packages and triage quickly if there are any which stand out as malicious or which might be atypical.

While it is out of the scope of this documentation to dwell into details on how to analyze Android apps, MVT does allow to easily and automatically extract information about installed apps, download copies of them, and quickly look them up on services such as [VirusTotal](https://www.virustotal.com).

You can [download all the apks](https://docs.mvt.re/en/latest/android/download_apks/) with the next command:

```bash
mvt-android download-apks --output /path/to/folder
```

MVT will likely warn you it was unable to download certain installed packages. There is no reason to be alarmed: this is typically expected behavior when MVT attempts to download a system package it has no privileges to access.
#### Upload apks to VirusTotal

Be warned thought that each apk you upload to VirusTotal can be downloaded by any VirusTotal user, so if you have private apps that may have confidential information stored in the apk you should not use the upload to VirusTotal feature.

!!! info "Using VirusTotal"
	Please note that in order to use VirusTotal lookups you are required to provide your own API key through the `MVT_VT_API_KEY` environment variable. You should also note that VirusTotal enforces strict API usage. Be mindful that MVT might consume your hourly search quota.

##### Register in VirusTotal
You can register a new account [here](https://www.virustotal.com/gui/join-us). Then get your key from [here](https://www.virustotal.com/gui/my-apikey).

The standard free end-user account. It is not tied to any corporate group and so it does not have access to Premium services. You are subjected to the following limitations:

- Request rate:	4 lookups / min
- Daily quota:500 lookups / day
- Monthly quota:	15.5 K lookups / month

I've tried to find the [pricing](https://docs.virustotal.com/docs/difference-public-private#price) but got nowhere. Maybe the default limits are enough

### Check the device over Android Debug Bridge

Some additional diagnostic information can be extracted from the phone using the [Android Debug Bridge (adb)](https://developer.android.com/studio/command-line/adb). `mvt-android` allows to automatically extract information including [dumpsys](https://developer.android.com/studio/command-line/dumpsys) results, details on installed packages (without download), running processes, presence of root binaries and packages, and more.

## [Work with the indicators of compromise](https://docs.mvt.re/en/latest/iocs/)

You can indicate a path to a STIX2 indicators file when checking iPhone backups or filesystem dumps. For example:

```bash
mvt-ios check-backup --iocs ~/ios/malware.stix2 --output /path/to/iphone/output /path/to/backup
```

Or, with data from an Android backup:

```bash
mvt-android check-backup --iocs ~/iocs/malware.stix2 /path/to/android/backup/
```

After extracting forensics data from a device, you are also able to compare it with any STIX2 file you indicate:

```bash
mvt-ios check-iocs --iocs ~/iocs/malware.stix2 /path/to/iphone/output/
```

The `--iocs` option can be invoked multiple times to let MVT import multiple STIX2 files at once. For example:

```bash
mvt-ios check-backup --iocs ~/iocs/malware1.stix --iocs ~/iocs/malware2.stix2 /path/to/backup
```

It is also possible to load STIX2 files automatically from the environment variable `MVT_STIX2`:

```bash
export MVT_STIX2="/home/user/IOC1.stix2:/home/user/IOC2.stix2"
```
# Troubleshooting

## Suspicious org.thoughtcrime.securesms in trace logs
It's the signal app.

## Seeing applications of other profiles
`adb` is able to extract the applications of other profiles, so it's able to analyse them. That's why you may see receivers (monitoring telephony state/incoming calls or to intercept incoming SMS messages) in the logs, as the program checks signatures on those apps.

# References

- [Source](https://github.com/mvt-project/mvt)
- [Docs](https://docs.mvt.re/en/latest/)
- [38C3 talk: From Pegasus to Predator - The evolution of Commercial Spyware on iOS](https://media.ccc.de/v/38c3-from-pegasus-to-predator-the-evolution-of-commercial-spyware-on-ios)
