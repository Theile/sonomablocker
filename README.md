# Sonoma Blocker

Blocking macOS 14 Sonoma installer

Detect when `Install macOS Sonoma.app` installer application has launched, terminate the process and display an alert.

_This project is totally copied from the original `bigsurblocker` from which I made `montereyblocker`, then `venturablocker`, and now also `sonomablocker`._

_See [hjuutilainen/bigsurblocker](https://github.com/hjuutilainen/bigsurblocker) for the original software for blocking Big Sur and README there._

## Guide available

[HCS Technology Group](https://hcsonline.com) has made a guide available on how to set this up. [Read it here](https://docs.hcsonline.com/SonomaBlocker).

## Why

Apple wants end users to upgrade to the latest macOS as soon as it becomes available. Depending on the software and policies your organization uses, this might be unacceptable. Apple is limiting the options, and now we basically only have this solution left, if users are admins on their computer:

- Use an MDM to push a profile to delay updates for maximum of 90 days. This will however postpone _all_ updates, not just the macOS upgrade.

But this option does not prevent users from downloading the full installer, and run that to upgrade their system, and this is where Sonoma Blocker fits in.

## How

The `sonomablocker` binary is installed in `/usr/local/bin` and is launched for each user through a launch agent. This means that the binary is running in the user session and therefore has the privileges of the current user. It runs silently in the background and listens for app launch notifications. As soon as the user launches the macOS installer application, the binary (forcefully) terminates it and displays a warning message.

By design, it will _not_ block the `startosinstall` command line tool.

__This app only block the app installer, so in order to prevent the users from upgrading through the Software Update mechanisms, a management profile to delay major upgrades has to be deployed to the machines. Remember that is limited to 90 days__

## Requirements

The binary requires at least macOS 11.

## Management profiles

All configuration is optional.

Management profile for making sure [Blocker is not disabled by the user](Management%20profiles/sonomablocker%20profile.mobileconfig) (for MDM systems.)

Profile for [custom Blocker alert settings](Management%20profiles/dk.envo-it.sonomablocker.plist) (deployed as custom settings in a MDM system.)

## Installation

On macOS 11 and later, download a prebuilt package from the [Releases page](releases) and deploy with your favorite method. The package is signed and notarized.

## Uninstall

To fully uninstall `sonomablocker`, run the script `[sonomablocker-remove.sh](sonomablocker-remove.sh)` (as root or with `sudo`) or deploy through MDM.

## License

Sonoma Blocker is licensed under [the MIT License](LICENSE), just as the original software.




The rest of this README is from that original project:

# Original README

This project is heavily inspired by Erik Berglund's [AppBlocker](https://github.com/erikberglund/AppBlocker). It uses the same underlying idea of registering and listening for NSWorkspace notifications when app has started up and then checking the CFBundleIdentifier of the launched app to identify a Big Sur installer launch.

# Why

Apple wants end users to upgrade to the latest macOS as soon as it becomes available. Depending on the software and policies your organization uses, this might be unacceptable. As an administrator, you currently have some options:
- Use an MDM to push a profile to delay updates for maximum of 90 days. This will however postpone _all_ updates, not just the macOS upgrade.
- If your fleet is enrolled in an MDM, you can use `softwareupdate --ignore` to hide certain updates. This will result in a highly broken user experience where the system thinks it has an update pending but it is unable to download and install it. Apple has also decided that only MDM enrolled systems can use the `--ignore` flag.
- If you are already using a binary authorization system such as Googles [Santa](https://github.com/google/santa), you should use it but deploying a system like Santa only for blocking Big Sur might be unfeasible.

# How

The `bigsurblocker` binary is installed in `/usr/local/bin` and is launched for each user through a launch agent. This means that the binary is running in the user session and therefore has the privileges of the current user. It runs silently in the background and listens for app launch notifications. As soon as the user launches the macOS installer application, the binary (forcefully) terminates it and displays a warning message.

By design, it will _not_ block the `startosinstall` command line tool.

# Requirements

The binary requires at least macOS 10.9, however it has been tested only on macOS 10.10, 10.11, 10.12, 10.13, 10.14 and 10.15.

Note. It seems that macOS 10.10 and 10.11 have trouble installing a signed and notarized package. Use the unsigned package available from the releases page if deploying on those. The signed and notarized package can be used on macOS 10.12 and later.

# Configuration

All configuration is optional. If needed, the alert title and text can be set through a configuration profile. Use `com.hjuutilainen.bigsurblocker` as the domain and `AlertTitle` and `AlertText` as the keys.

# Installation

On macOS 10.12 and later, download a prebuilt package from the [Releases page](https://github.com/hjuutilainen/bigsurblocker/releases) and deploy with your favorite method. The package is signed and notarized.

On OS X 10.11 and earlier, download and deploy an unsigned package from the [Releases page](https://github.com/hjuutilainen/bigsurblocker/releases) and deploy with your favorite method

# Uninstall

To fully uninstall `bigsurblocker`, run the following (as root or with sudo):

```
current_user_uid=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/UID :/ && ! /loginwindow/ { print $3 }' )

launchd_item_path="/Library/LaunchAgents/com.hjuutilainen.bigsurblocker.plist"
launchctl bootout gui/${current_user_uid} "${launchd_item_path}"

rm -f /Library/LaunchAgents/com.hjuutilainen.bigsurblocker.plist
rm -f /usr/local/bin/bigsurblocker

pkgutil --forget com.hjuutilainen.bigsurblocker
```

# License

Big Sur Blocker is licensed under [the MIT License](https://github.com/hjuutilainen/bigsurblocker/blob/main/LICENSE).
