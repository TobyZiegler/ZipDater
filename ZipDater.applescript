#
# ZipDater
#
# Applescript to search the modification dates of files in a compressed archive,
#    then update the archive's modification date to coordinate with the latest.
#
# Created by Toby Ziegler, April 04 2018
# Last updated by Toby on March 27, 2023
#
#
# Designating this script as version 0.6
#
--current version message:
--parsing re-done for zipinfo to -T command
--work in progress still, but improving
#
#


########## BEGIN MAIN ##########

### need to add drop capability

choose file with prompt "Select compressed archive:"
set selectedFile to result

### confirm compressed here?

set theList to loadContents(selectedFile)
log "theList: " & linefeed & theList & linefeed

set latestDate to dateSort(theList)
log "latestDate: " & linefeed & latestDate & linefeed

changeDate(selectedFile, latestDate)

########### END MAIN ###########




on loadContents(theArchive)
	try --if not zipped, file will cause an error
		
		--use zipinfo terminal command to obtain contents
		--use "-T" to get full decimal time, yyyymmdd.hhmmss
		set theScript to "zipinfo -T " & POSIX path of theArchive
		set theContents to do shell script theScript
		log "Contents: " & linefeed & theContents & linefeed
		
		set rawDates to extractDates(theContents)
		
		set theDateList to parseDateStrings(rawDates)
		
		return theDateList
		
	end try ### try activation cascades the failure for the rest of the script! need fix
end loadContents

on extractDates(rawList)
	
	--specify return and linefeed delimiters to separate items from raw input:
	set theDelimiters to AppleScript's text item delimiters --save the originals
	
	set AppleScript's text item delimiters to {character id 10, character id 13} --ascii return and linefeed
	
	set cutList to text items of rawList --pull everything between each delimiter as an item in an array
	
	set AppleScript's text item delimiters to theDelimiters --reset delimiters, no longer needed
	
	
	set permFlags to {"-", "r", "w"} --if another line begins r or w, error?
	
	set rescueDates to {}
	
	repeat with x from 1 to the count of cutList
		
		set listItem to item x of cutList
		
		set lineFound to false --resets the search each loop
		
		repeat with y from 1 to count of permFlags
			try --necessary for unusual characters
				if character 1 of listItem is item x of targetLine then
					set lineFound to true
					exit repeat --no need to look further
				end if
			end try
		end repeat
		
		
		
		if lineFound then
			
			--only works because data is always in the same position
			set founDate to text 38 thru 52 of myMatch
			
			set end of rescueDates to founDate
		end if
	end repeat
	return rescueDates
	
end extractDates


on parseDateStrings(myDateStrings)
	--this takes the raw data and converts it to a list of dates
	
	log "myDateStrings: " & linefeed & myDateStrings & linefeed
	
	set myDates to {}
	
	repeat with i from 1 to the count of myDateStrings
		
		set thisDate to item i of myDateStrings
		
		--since the format is known, specifying positions obtains the data
		set theYear to text 1 thru 4 of thisDate
		set theMonth to text 5 thru 6 of thisDate
		set theDay to text 7 thru 8 of thisDate
		set theHour to text 10 thru 11 of thisDate
		set theMinute to text 12 thru 13 of thisDate
		set theSecond to text 14 thru 15 of thisDate
		
		set dateString to theMonth & "/" & theDay & "/" & theYear
		
		set myDate to date dateString --unable to add date and time together
		
		--quirky thing doesn't work if multiply by seconds, just add them raw
		set time of myDate to (theHour * hours + theMinute * minutes + theSecond)
		
		set end of myDates to myDate
		
	end repeat
	
	return myDates
	
end parseDateStrings




on dateSort(theDates)
	--sort out latest date
	--return date
	
	set theLastTime to "Insert function here."
	
	--set theLastTime to item 1 of theDates
	return theLastTime
end dateSort



on changeDate(theFile, theDate)
	--update theFile to theDate
end changeDate



(*
References:
using zipinfo: https://www.baeldung.com/linux/zip-list-files-without-decompressing
*)