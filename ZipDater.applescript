#
# ZipDater
#
# Applescript to search the modification dates of files in a compressed archive,
#    then update the archive's modification date to coordinate with the latest.
#
# Created by Toby Ziegler, April 04 2018
# Last updated by Toby on March 28, 2023
#
#
# Designating this script as version 0.7
#
--current version message:
--works through to sorting, sort next
#
#


########## BEGIN MAIN ##########

### need to add drop capability

choose file with prompt "Select compressed archive:"
set selectedFile to result

### confirm compressed here?

set theContents to loadContents(selectedFile)
log "theContents: " & linefeed & theContents & linefeed


set rawDates to extractDates(theContents)
log "rawDates: " & linefeed & rawDates & linefeed

set theDateList to parseDateStrings(rawDates)
log "theDateList: " & linefeed & theDateList & linefeed


set latestDate to dateSort(theDateList)
log "latestDate: " & linefeed & latestDate & linefeed

changeDate(selectedFile, latestDate)

########### END MAIN ###########




on loadContents(theArchive)
	try --if not zipped, file will cause an error
		
		--use zipinfo terminal command to obtain contents
		--use "-T" to get full decimal time, yyyymmdd.hhmmss
		set theScript to "zipinfo -T " & POSIX path of theArchive
		set theContents to do shell script theScript
		
		return theContents
		
	end try ### try activation cascades the failure for the rest of the script! need fix
end loadContents



on extractDates(rawList)
	log "rawList: " & linefeed & rawList & linefeed
	
	--specify return and linefeed delimiters to separate items from raw input:
	set theDelimiters to AppleScript's text item delimiters --save the originals
	set AppleScript's text item delimiters to {character id 10, character id 13} --ascii return and linefeed
	set cutList to text items of rawList --pull everything between each delimiter as an item in an array
	set AppleScript's text item delimiters to theDelimiters --reset delimiters, no longer needed
	log "cutList: " & linefeed & cutList & linefeed
	
	
	set permFlags to {"-", "r", "w"} --if another line begins r or w, error?
	set rescueDates to {}
	
	repeat with x from 1 to the count of cutList
		
		set listItem to item x of cutList
		
		set lineFound to false --resets the search each loop
		set founDate to ""
		
		--check whether this item (line) starts with a permission flag
		repeat with y from 1 to count of permFlags
			try --necessary for unusual characters
				if character 1 of listItem is item y of permFlags then
					set lineFound to true
					exit repeat --no need to look further
				end if
			end try
		end repeat
		
		--pull out the information and add it to the array
		if lineFound then
			--only works because data is always in the same position
			set founDate to text 38 thru 52 of listItem
			set end of rescueDates to founDate
		end if
		log "founDate: " & founDate
		log "rescueDates-" & x & ": " & linefeed & rescueDates & linefeed
		
	end repeat
	return rescueDates
	
end extractDates



on parseDateStrings(myDateStrings)
	--this takes the raw data pulled from each line of information and converts it to a list of dates
	
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
		
		set myDate to date dateString --unable to add date and time together, this works for the first half
		
		--quirky thing doesn't work if multiply by seconds like the others, just add seconds raw
		set time of myDate to (theHour * hours + theMinute * minutes + theSecond)
		
		set end of myDates to myDate
		
	end repeat
	return myDates
	
end parseDateStrings




on dateSort(theDates)
	log "theDates: " & theDates
	
	set thisDate to ""
	
	repeat with z from 1 to the (count of theDates) - 1
		set thisDate to item z of theDates
		set nextDate to (item z) + 1
		if thisDate comes after nextDate then
			set thisDate to nextDate
		end if
		log "thisDate-" & z & ": " & thisDate
	end repeat
	log "Final Date: " & thisDate
	
	return thisDate
end dateSort



on changeDate(theFile, theDate)
	--update theFile to theDate
end changeDate



(*
References:
using zipinfo: https://www.baeldung.com/linux/zip-list-files-without-decompressing
*)



