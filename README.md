# Export things.app database to JSON

This is a complete, but not yet released, Node module that can export the entire contents of your [Things.app by CulturedCode](https://culturedcode.com/things/) database into a JSON file. You can then write external scripts that use that JSON file to some result.

## Requirements

OS X and Things.app installed locally.

## Examples

There are a couple of usage examples:

* `daily_log.rb` generates a Markdown log of items completed by day
* `stale.rb` finds tasks that are too old.

## Current issues

* The time format of the export is system-dependent. I tried to make it system-independent, but that requires serious AppleScript hackery.

* The JSON format replicates the window structure of Things.app, this leads to duplication of items, for example, between the Projects list and the Next list.

## TODO

* DRY up export format
* Add options to not export the entire database, but a selected list, or at least not export the logbook & trash.

(c) 2015 Leonid Shevtsov
