# ZipDater
An AppleScript to update a zip archive to match the dates of the files within.

After a compressed zip archive is selected, the script uses [zipinfo](https://manpages.ubuntu.com/manpages/focal/man1/zipinfo.1.html) to extract the information on every file in the archive.

The information is parsed to locate and extract the date data. The data is then converted to dates and sorted to find the latest date.

The dates are then sorted to produce the last modification date of the files. Finally, this last date is applied to the selected archive.

On a personal note, this simple task proved to need many more steps and more complications than I had supposed.
