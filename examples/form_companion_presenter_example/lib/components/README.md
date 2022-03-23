# About this directory

This directory contains "piece of examples" and should be built to `exmaples/lib` with `tools/grind.dart` task.

// note

## Design

1. setup
2. merge header (comment and import)
3. interpret macros
4. rename ids

### Components

account.dart
booking.dart

### Macro

```shell
^(?<Indent>\s*)//!\s*(?<ID>\w+)(\s+(?<ARG>\S+))*\s*$
```

//!macro headerNote
//!macro pageDocument
//!macro fieldInit {name}
//!macro validateMode
//!macro doSubmitPrologue

### ID

AccountPageTemplate
_AccountPaneTeamplate
AccountPresenterTemplate
BookingPageTemplate
_BookingPaneTeamplate
BokingPresenterTemplate
