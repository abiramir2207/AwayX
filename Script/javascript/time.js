// JavaScript Document
function IsValidTime(timeStr) 
{
	// Checks if time is in HH:MM:SS AM/PM format.
	// The seconds and AM/PM are optional.

	var timePat = /^(\d{1,2}):(\d{2})(:(\d{2}))?(\s?(AM|am|PM|pm))?$/;

	var matchArray = timeStr.match(timePat);
	if (matchArray == null)
	{
		//alert("Time is not in a valid format.");
		return false;
	}

	hour = matchArray[1];
	minute = matchArray[2];
	second = matchArray[4];
	ampm = matchArray[6];

	if (second=="") { second = null; }
	if (ampm=="") { ampm = null }

	if (hour < 1  || hour > 12)
	{
		//alert("Hour must be between 1 and 12.");
		return false;
	}

	if (ampm == null) 
	{
		//alert("You must specify AM or PM.");
		return false;
	}

	if (minute<0 || minute > 59)
	{
		//alert ("Minute must be between 0 and 59.");
		return false;
	}

	if (second != null && (second < 0 || second > 59))
	{
		//alert ("Second must be between 0 and 59.");
		return false;
	}
	return true;
}
//  End -->