#
# ZipDater
#
# Applescript to search the modification dates of files in a compressed archive,
#    then update the archive's modification date to coordinate with the latest.
#
# Created by Toby Ziegler, April 04 2018
# Last updated by Toby on March 25, 2023
#
#
# Designating this script as version 0.2
#
--current version message:
--added zipinfo with POSIX

#
#


########## BEGIN MAIN ##########

choose file with prompt "Select compressed archive:"
set selectedFile to result

set lastModified to latestDate(selectedFile)

changeDate(selectedFile, lastModified)

########### END MAIN ###########

on latestDate(theArchive)
	--confirm compressed
	--use zipinfo terminal command to obtain contents
	set theScript to "zipinfo " & POSIX path of theArchive
	set theContents to do shell script theScript
	log "Contents: " & linefeed & theContents & linefeed
	--parse dates
	--sort out latest date
	--return date
end latestDate

on changeDate(theFile, theDate)
	--update theFile to theDate
end changeDate



(* Inspiration script:
-- Thanks to Bruce Phillips, https://macscripter.net/profile.php?id=5342
choose folder with prompt "Find newest file in this folder:"
set sourceFolder to result

tell application "Finder"
	sort (get files of sourceFolder) by creation date
	-- This raises an error if the folder doesn't contain any files
	set theFile to (item 1 of result) as alias
end tell
*)

(*
References:
using zipinfo: https://www.baeldung.com/linux/zip-list-files-without-decompressing
*)



