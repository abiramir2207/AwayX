
function getMilitaryTime(sTime)
{
	var retVal = false;
	var spTime = sTime.split(":");
	if(spTime.length >= 3)
	{
		var hr = parseInt(spTime[0],10);
		//if(hr.toString() == spTime[0])
		if(makeFixedDigits(2,hr.toString(),"00") == makeFixedDigits(2,spTime[0],"00"))
		{
			var mn = parseInt(spTime[1],10);			
			if(makeFixedDigits(2,mn.toString(),"00") == makeFixedDigits(2,spTime[1],"00"))
			{
				var sc = parseInt(spTime[2],10);
				var ampm = spTime[2].substr(makeFixedDigits(2,sc.toString(),"00").length);
				ampm = ampm.replace(/(^\s*)|(\s*$)/g, "");
				ampm = ampm.toLowerCase();
				if(/^[\s\t]*?[aApP][mM][\s\t]*?$/.test(ampm))
				{
					//////specified ap/pm
					if(hr >= 0 && hr <= 12 && mn >=0 && mn <60 && sc >=0 && sc <60)
					{
						hr = hr + (ampm=="am"?0:12);						
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}
				else
				{
					//////not specified ap/pm
					//if(hr <= 24 && mn <=60 && sc <=60)
					if(hr >= 0 && hr < 24 && mn >=0 && mn <60 && sc >=0 && sc <60)
					{
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}					
			}
		}
	}		
	return retVal;
}

function getHHMMSSTime()
{
	var retVal = "";
	var tmp;
	var args = arguments;
	for(i=0;i<args.length;i++)
	{
		//tmp = "0" + args[i];
		//retVal = retVal + tmp.substring(tmp.length-2,tmp.length) + ":";
		retVal = retVal + makeFixedDigits(2,args[i],"00") + ":";
	}
	return (retVal.substring(0,retVal.length-1));
}

function makeFixedDigits(dig,val,padStr)
{
	var retVal = padStr + val;
	return (retVal.substr(retVal.length-dig));	
}

function checkTimelessThan(sTime,gTime)
{
	var tLen = sTime.length;
	if(sTime[0] < gTime[0])
	{
		return true;
	}
	else if(sTime[0] == gTime[0])
	{
		if(sTime[1] < gTime[1])
		{
			return true;		
		}
		else if(sTime[1] == gTime[1])
		{
			if(sTime[2] <= gTime[2])
			{
				return true;
			}
		}
	}
	return false;
}

function isSpace(sStr)
{
	var re = /^[\s\t]*$/ig;
	if (re.test(sStr))
		return true;
	else
		return false;
}

function disableDiv(divName,bDis,bHide)
{
	oDiv = document.all.item(divName);	
	oDiv.disabled = bDis;
	//oDiv.onmousedown=new Function ("return false");
	var i,itemLen = oDiv.all.length;
	for(i=0;i<itemLen;i++)
	{
		oDiv.all[i].disabled = bDis;
	}
	var args = arguments;
	var argLen = args.length;
	if(argLen <3)
	{
		return;
	}
	if(args[2])
	{
		oDiv.style.display = "none";
	}
	else
	{
		oDiv.style.display = "";
	}
	if(argLen <4)
	{
		return;
	}
	var parObj = document.all.item(args[3]);
	
	if(args[2])
	{
		parObj.style.display = "none";
	}
	else
	{
		parObj.style.display = "";
	}
}



function days_less(date1, date2) {

    // The number of milliseconds in one day
    var ONE_DAY = 1000 * 60 * 60 * 24

    // Convert both dates to milliseconds
    var date1_ms = date1.getTime()
    var date2_ms = date2.getTime()

    // Calculate the difference in milliseconds
    //var difference_ms = Math.abs(date1_ms - date2_ms)
	var difference_ms = date1_ms - date2_ms;
    
    // Convert back to days and return
    return Math.round(difference_ms/ONE_DAY)

}


function makeDate(dVal)
{
	var nDate = new Date();
	var ar_s_date = dVal.split("/");	
	if(ar_s_date.length >= 3)
	{
		nDate = new Date(ar_s_date[2],ar_s_date[0]-1,ar_s_date[1]);
	}	
	return nDate;
}

function days_between(date1, date2) {

    // The number of milliseconds in one day
    var ONE_DAY = 1000 * 60 * 60 * 24

    // Convert both dates to milliseconds
    var date1_ms = date1.getTime()
    var date2_ms = date2.getTime()

    // Calculate the difference in milliseconds
    var difference_ms = Math.abs(date1_ms - date2_ms)
    
    // Convert back to days and return
    return Math.round(difference_ms/ONE_DAY)

}
