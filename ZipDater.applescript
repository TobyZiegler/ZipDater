#
# ZipDater
#
# Applescript to search the modification dates of files in a compressed archive,
#    then update the archive's modification date to coordinate with the latest.
#
# Created by Toby Ziegler, April 04 2018
# Last updated by Toby on March 29, 2023
#
#
# Designating this script as version 0.9
#
--current version message:
--first fully functional version!
#
--still need drag and drop functionality
--still need compression check
--need error handling
#
#


########## BEGIN MAIN ##########

### need to add drop capability

choose file with prompt "Select compressed archive:"
set selectedFile to result

### confirm compressed here?

confirm(selectedFile)

set theContents to loadContents(selectedFile)
log "theContents: " & linefeed & theContents & linefeed


set rawDates to extractDates(theContents)
log "rawDates: " & linefeed & rawDates & linefeed

set theDateList to parseDateStrings(rawDates)
log "theDateList: " & linefeed & theDateList & linefeed


set latestDate to dateSort(theDateList)
log "latestDate: " & linefeed & latestDate & linefeed

changeDate(selectedFile, latestDate)

confirm(selectedFile)


########### END MAIN ###########




on loadContents(theArchive)
	try --if not zipped, file will cause an error
		
		--use zipinfo terminal command to obtain contents
		--use "-T" to get full decimal time, yyyymmdd.hhmmss
		--quoted form handles spaces and othe characters
		set theScript to "zipinfo -T " & the quoted form of the POSIX path of theArchive
		set theContents to do shell script theScript
		
		return theContents
		
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
		
	end repeat
	return rescueDates
	
end extractDates



on parseDateStrings(myDateStrings)
	--this takes the raw data pulled from each line of information and converts it to a list of dates
	
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
	### sort may not be correct, test soon
	
	set lastDate to false
	
	repeat with z from 1 to the count of theDates
		set thisDate to item z of theDates
		if lastDate is false then
			set lastDate to thisDate
		else if thisDate is greater than lastDate then
			set lastDate to thisDate
		end if
	end repeat
	
	return lastDate
end dateSort


on changeDate(theFile, fixDate)
	
	--arrives as a date: Monday, February 6, 2023 at 11:15:41 AM
	--need converted to yyyymmddhhmm (.ss?)
	
	--start by converting the date
	set {year:theYear, month:mm, day:dd} to fixDate
	set theMonth to text -1 thru -2 of ("0" & (mm * 1))
	set theDay to text -1 thru -2 of ("0" & dd)
	set theDate to theYear & theMonth & theDay
	
	--now load the time, then convert hour, minute, and seconds separately
	set theTime to time of fixDate
	
	set theHourBase to (theTime / 60 / 60) as string
	set theHourOffset to the offset of "." in theHourBase
	set theHour to text 1 thru (theHourOffset - 1) of theHourBase
	set theHour to text -1 thru -2 of ("0" & theHour)
	
	set theMinuteBase to (theTime - (theHour * 3600)) / 60 as string
	set theMinuteOffset to the offset of "." in theMinuteBase
	set theMinute to text 1 thru (theMinuteOffset - 1) of theMinuteBase
	set theMinute to text -1 thru -2 of ("0" & theMinute)
	
	set theSecond to theTime - (theHour * 3600) - (theMinute * 60) as string
	set theSecond to text -1 thru -2 of ("0" & theSecond)
	
	
	--touch -t changes access, modification and creation dates, format:
	--touch -t yyyymmddhhmm [pathtofile][filename]
	set theScript to "touch -t " & theDate & theHour & theMinute & "." & theSecond & " " & the quoted form of the POSIX path of theFile
	do shell script theScript
	
end changeDate


on confirm(theSource)
	
	--run shell command "stat" to confirm final system dates
	set theCheckScript to "stat -f 'Access (atime): %Sa%nModify (mtime): %Sm%nChange (ctime): %Sc%nBirth  (Btime): %SB' " & the quoted form of the POSIX path of theSource
	
	set theConfirmation to do shell script theCheckScript
	log "Confirmation: " & linefeed & theConfirmation
	
	(*
	Note:
	
	for the stat command,
	  atime = Access Time = when file was last opened
	  mtime = Modify Time = when file was last changed
	  ctime = Change Time = when file's meta was last changed, including permissions, etc.
	  btime = Birth Time = when file first created
	
	*)
	
end confirm





(*
References:
using zipinfo: https://www.baeldung.com/linux/zip-list-files-without-decompressing
*)