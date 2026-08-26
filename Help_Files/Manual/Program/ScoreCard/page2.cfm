<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Scorecard</title>
	<script language="JavaScript">
<!--
function change(html){
  description.innerHTML=html
  description2.innerHTML=html
}
//-->
</script>
</head>

<body>
<strong><div id="description">&nbsp; </div></strong>
<cfinclude template="scorecard_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Program Scorecard -- Scorecard Detail</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/program_scorecard.gif"></td></tr>
<tr><td colspan="2"><p>&nbsp; </p></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
You can navigate between different status pages for scorecards by clicking on the tabs at the top. The exact information shown in the scorecard varies depending on the status.  For example, an active, expiring or expired program will display the name of the approver and the date approved, where a request for approval program will display the name of the person asking approval. 

</p>
You can search for words or numbers entered in the "Find what" area.  You can search by the entire word (for example, if you were to enter "an", clicking on whole word only would return only examples of "an".  "And" "anteater" "transportation" and "can" would not be returned.  They would be returned if "Match whole word only" is not checked.) You can also match by case, so that if you type "String Cheese" and check "match case" you will not find "string cheese".  Be sure you check for a word both "up" and "down".
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
You can reorder the way the scorecard is displayed by clicking on the links in blue at the top. 
</td></tr>
 <tr><td valign="top"> <img src="../../images/3.gif"></td><td>
A variety of information about each program is displayed.  The status is indicated by a color coded circle as below:  

<p align="center">
<img src="../../images/program_scorecard_legend.gif">
</p>

<ul>
<li><em>Work in Progress:</em>  A work in progress is a program that is in the process of being edited, but that has not been submitted for approval.</li>
<li><em>Ready for Approval:</em> Indicates that a program has been completed by its creator, and is ready for approval.</li>
<li><em>Pre Active:</em> When a program is pre active, it has been approved, but the start date is after the current date.</li>
<li><em>Active:</em> An active program is currently in force.</li>
<li><em>Expiring:</em> A set amount of time before the end date of a program, the program is shown as expiring.  If you are an administrator, you can establish the number of weeks before the end date a program is shown as expiring by going to Settings -&lt; Administrative -&lt; Programs -&lt; Expiring Age.</li>
<li><em>Expired:</em> Programs whose end date has passed are marked as expired.</li>
<br><br>
Also displayed are the program number, type, title, reference number, start and end dates, and volume.
</ul>

</td></tr>
 <tr><td valign="top"> <img src="../../images/4.gif"></td><td>
You see more programs in a particular status by clicking on the page numbers listed in the bottom right of the screen. You can also see how many programs are in a status in the lower right hand corner of the screen.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="scorecard_toc.cfm">
<cfinclude template="scorecard_updated.cfm">
</body>
</html>
