<!-----------------------------------------------------------------------------

FILE NAME:		autoRenewalHelp.cfm
DESCRIPTION:	Help text display page called from contract_crate_1_form.cfm file
				from the Auto Renewal section.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	15-Apr-2015	

------------------------------------------------------------------------------> 

<html>
<head>
	<title>Auto Renewal - Help</title>
</head>

<body>
<strong><u>Auto Renewal - Help:</u></strong><br>
<br>
If you select <strong>'Renew Annually'</strong>, the application will create a new program with a start and end date that are both one year after the dates of the original program. <br>
 For example, a program with dates of 7/1/2015 to 7/31/2015 will Renew Annually as 7/1/2016 to 7/31/2016.  Each Auto Renew execution will carry the program into the following year for the same start and end points.
<br><br><br>

If you select <strong>'Renew Concurrently'</strong>, the new program will begin the day after the current program ends and will have a duration equal to the current program.  <br>
For example, a program with dates of 8/1/2015 to 8/31/2015 will Renew Concurrently as 9/1/2015 to 10/1/2015.  As the original program was 31 days long, the new date range will mirror that duration starting the first day after the original expires.
<br>
<br>
<div align="center">
	<input type="button" value="Close Help Window" OnClick="javascript:window.close();">
</div>
</body>
</html>
