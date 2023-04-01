#
# ZipDater
#
# Applescript to search the modification dates of files in a compressed archive,
#    then update the archive's modification date to coordinate with the latest.
#
# Created by Toby Ziegler, April 04 2018
# Last updated by Toby on March 26, 2023
#
#
# Designating this script as version 0.3
#
--current version message:
--added logs to better follow the data and processes
--moved zipinfo to loadContents handler
--added parseDates to pull dates from the data
--dummy data in dateSort
#
#


########## BEGIN MAIN ##########

choose file with prompt "Select compressed archive:"
set selectedFile to result
--confirm compressed here

set theList to loadContents(selectedFile)
log "theList: " & linefeed & theList & linefeed

set latestDate to dateSort(theList)
log "latestDate: " & linefeed & latestDate & linefeed

changeDate(selectedFile, latestDate)

########### END MAIN ###########




on loadContents(theArchive)
	try --if not zipped, file will cause an error
		--use zipinfo terminal command to obtain contents
		set theScript to "zipinfo " & POSIX path of theArchive
		set theContents to do shell script theScript
		log "Contents: " & linefeed & theContents & linefeed
		
		set theDateList to parseDates(theContents)
		
		return theDateList
	end try --try activation cascades the failure for the rest of the script
end loadContents


on parseDates(myText)
	
	set AppleScript's text item delimiters to {character id 10, character id 13} --ascii return and linefeed
	
	set myItems to text items of myText --pull everything between each delimiter as an item in an array
	
	set AppleScript's text item delimiters to "" --reset delimiters, no longer needed
	
	set myDates to {}
	
	repeat with i from 1 to the count of myItems
		
		set myMatch to item i of myItems
		
		set targetLine to {"-", "r", "w"} --only the file lines begin with permission characters
		
		repeat with x from 1 to count of targetLine
			
			try --necessary for unusual characters
				if character 1 of myMatch is item x of targetLine then
					
					--using a colon and grabbing the text around it is the part making this only work for the kind of data supplied
					set colonPosition to offset of ":" in myMatch
					
					set thisDate to {text (colonPosition - 12) thru (colonPosition + 2) of myMatch}
					
					set end of myDates to thisDate
				end if
			end try
		end repeat
	end repeat
	
	return myDates
	
end parseDates


on dateSort(theDates)
	--parse dates
	--sort out latest date
	--return date
	set theLastTime to item 1 of theDates
	return theLastTime
end dateSort



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

