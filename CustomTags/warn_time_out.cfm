<!---
Id: warn_time_out.cfm, v1.0.2 7/29/00 1:01:18 PM dbabbitt
Description: This custom tag warns the user to refresh 
             the screen before their session variables 
			 expire.
Usage: <CF_WARN_TIME_OUT WarningThreshold="1" TimeOutMinutes="2"> 
--->

<CFPARAM Name="Attributes.TimeOutMinutes" Default="20">
<CFPARAM Name="Attributes.WarningThreshold" Default="5">
<CFPARAM Name="Attributes.WarningMessage" Default="Your session on this server will expire in #Attributes.WarningThreshold# minute(s)!\nPlease save your work now.">

<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript"><CFOUTPUT>
<!--
// Global variables
StartTime = new Date();
StartMils = Date.parse(StartTime.toLocaleString());
TimeOutMils = StartMils + (60000 * #Attributes.TimeOutMinutes#);
ThresholdMils = 60000 * #Attributes.WarningThreshold#;

function CountDown() {
	clearTimeout('timerLoop');
	CurrentTime = new Date();
	CurrentMils = Date.parse(CurrentTime.toLocaleString());
	RemainingMils = TimeOutMils - CurrentMils;
	if(RemainingMils < ThresholdMils) {window.alert('#Attributes.WarningMessage#');}
	else {timerLoop = setTimeout('CountDown()', 10000);}
	}

// run CountDown for the first time
CountDown();
//-->
	</CFOUTPUT></SCRIPT>

<!---
	Log: warn_time_out.cfm
	Revision 1.0 7/29/00 12:26:51 PM dbabbitt
	This custom tag warns the user to 
	refresh the screen before their session 
	variables expire.
	--->