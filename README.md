# untrack

untrack is a command line utility that removes tracking information from URLs.
It can remove tracking information in the form of query parameters and redirects.

Removal is handled locally, and the URL is never visited. As such, the tool is
limited to reversing URLs that contain all the necessary information to navigate
to the true URL. In other words, if a series of redirects must be followed to
resolve the true URL, and the redirect info is not contained in the URL itself,
this tool won't be of much help.

## Installation

You can install untrack using [Mint](https://github.com/yonaskolb/Mint):

```
mint install klanchman/untrack
```

Alternatively, you can clone/download the repository and build it from source manually:

```
swift build -c release
```

## Usage

Simply run untrack with the URL to remove trackers from:

```
untrack <url>
```

untrack will output a URL with known trackers removed.

Use the `--help` option to see other available options.

## Supported Query Parameters

- Google Analytics
- Twitter share links

## Supported Redirect Reversals

- [Outlook Safe Links](https://support.microsoft.com/en-us/office/advanced-outlook-com-security-for-office-365-subscribers-882d2243-eab9-4545-a58a-b36fee4a46e2) (useful if you have an Outlook account managed by an organization where you cannot turn off this feature)
- [Gmail click-time URL protection](https://support.google.com/mail/answer/10173182?hl=en)
- [Mandrill click tracking](https://mailchimp.com/developer/transactional/docs/activity-reports/#click-tracking) (Mailchimp Transactional emails)
