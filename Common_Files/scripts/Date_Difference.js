function days_between(date1, date2, bNotAbs) {

    // The number of milliseconds in one day
    var ONE_DAY = 1000 * 60 * 60 * 24

    // Convert both dates to milliseconds
    var date1_ms = date1.getTime()
    var date2_ms = date2.getTime()

	var lNotAbs = false;
	if(arguments.length >= 3)
	{
		lNotAbs = bNotAbs;
	}
	
	var difference_ms = date1_ms - date2_ms;
	// Calculate the difference in milliseconds
	if(!lNotAbs)
	{    
    	var difference_ms = Math.abs(difference_ms);
	}
    
    // Convert back to days and return
    return Math.round(difference_ms/ONE_DAY)

}

