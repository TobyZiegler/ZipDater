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
# Designating this script as version 0.5
#
--current version message:
--changed zipinfo to -T command and started to re-do parsing
--work in progress lots of scratching, needs a cleanup
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
		##use "-T" to get full decimal time, rewrite all the parsing!
		set theScript to "zipinfo -T " & POSIX path of theArchive
		set theContents to do shell script theScript
		log "Contents: " & linefeed & theContents & linefeed
		
		set theDateList to parseDates(theContents)
		
		return theDateList
		
	end try ##try activation cascades the failure for the rest of the script! need fix
end loadContents


on parseDates(myText)
	
	--specify return and linefeed delimiters to separate items from raw input:
	set theDelimiters to AppleScript's text item delimiters --save the originals
	
	set AppleScript's text item delimiters to {character id 10, character id 13} --ascii return and linefeed
	
	set myItems to text items of myText --pull everything between each delimiter as an item in an array
	
	set AppleScript's text item delimiters to theDelimiters --reset delimiters, no longer needed
	
	
	set myDates to {} --ready the array for data
	set targetLine to {"-", "r", "w"} --only the file lines begin with permission characters
	
	repeat with i from 1 to the count of myItems
		
		set myMatch to item i of myItems
		
		set targetFound to false --resets the search for each loop
		
		repeat with x from 1 to count of targetLine --look for each permission character
			try --necessary for unusual characters
				if character 1 of myMatch is item x of targetLine then
					set targetFound to true
					exit repeat
				end if
			end try
		end repeat
		
		
		if targetFound then
			
			--only works because data is always in the same position
			set thisDateString to text 38 thru 52 of myMatch
			
			--set thisDate to parseDateString(thisDateString)
			--set dateStamp to short date string of (current date)
			--log "dateStamp: " & dateStamp
			
			(*
					set thisYearString to {text (colonPosition - 12) thru (colonPosition - 11) of myMatch}
					set thisMonthString to {text (colonPosition - 9) thru (colonPosition - 7) of myMatch}
					set thisDayString to {text (colonPosition - 5) thru (colonPosition - 4) of myMatch}
					
					set thisHourString to {text (colonPosition - 2) thru (colonPosition - 1) of myMatch}
					set thisMinuteString to {text (colonPosition + 1) thru (colonPosition + 2) of myMatch}
					
					set thisDate to date {thisYearString, thisMonthString, thisDayString, thisHourString, thisMinuteString}
					log "thisDate: " & thisDate
					*)
			
			--probably better to coerce string to date & time here instead
			
			--log "thisDateString: " & thisDateString
			--log "thisTimeString: " & thisTimeString
			
			--set thisDate to date thisDateString
			--set thisTime to date thisTimeString
			
			--log "thisDate: " & thisDate
			--log "thisTime: " & thisTime
			
			set end of myDates to thisDateString
		end if
	end repeat
	
	return myDates
	
end parseDates


-- Parse date and time from the string given in the email.
on parseDateString(datestring)
	set theDate to current date
	--set dateWords to words of datestring
	--log "dateWords: " & dateWords
	
	
	set year of theDate to text 1 thru 2 of datestring
	log "add year: " & theDate
	
	set month of theDate to text 4 thru 6 of datestring
	log "add month: " & theDate
	
	set day of theDate to text 8 thru 9 of datestring
	log "add day: " & theDate
	
	set time of theDate to (text 11 thru 12 of datestring) * hours + (text 14 thru 15 of datestring) * minutes
	log "add time: " & theDate
	
	
	(*
    set monthList to {January, February, March, April, May, June, July, August, September, October, November, December}
    repeat with i from 1 to 12
        if item 3 of dateWords = ((item i of monthList) as string) then
            set monthNumber to (text -2 thru -1 of ("0" & i))
            exit repeat
        end if
    end repeat
    set month of theDate to monthNumber
	
	*)
	return theDate
end parseDateString




on dateSort(theDates)
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
