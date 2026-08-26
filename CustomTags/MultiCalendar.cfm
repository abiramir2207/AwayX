<!--- Set default attributes. --->
<cfparam name="attributes.siteid" default="1">
<cfparam name="attributes.MultiCalDSN" default="MultiCalendar_v15">
<cfparam name="attributes.Categories" default="0">
<cfparam name="attributes.MonthChange" default="None">
<cfparam name="attributes.LastDate" default="None">
<cfparam name="attributes.NoSHow" default="1">
<cfparam name="attributes.cellcolor" default="WHITE">
<cfparam name="attributes.celltext" default="NAVY">
<cfparam name="attributes.todaycolor" default="YELLOW">
<cfparam name="attributes.todaytext" default="BLACK">
<cfparam name="attributes.headercolor" default="STEELBLUE">
<cfparam name="attributes.headertext" default="ALICEBLUE">
<cfparam name="attributes.nodatecolor" default="LIGHTSTEELBLUE">
<cfparam name="attributes.greetingtext" default="BLACK">
<cfparam name="attributes.cellcolorhex" default="##FFFFFF">
<cfparam name="attributes.celltexthex" default="##000080">
<cfparam name="attributes.todaycolorhex" default="##FFFF00">
<cfparam name="attributes.todaytexthex" default="##000000">
<cfparam name="attributes.headercolorhex" default="##4682B4">
<cfparam name="attributes.headertexthex" default="##F0F8FF">
<cfparam name="attributes.nodatecolorhex" default="##B0C4DE">
<cfparam name="attributes.greetingtext" default="##000000">


<script language="javascript">
<!--
function makeremote(url) {
daydisplay = window.open("","daywindow","toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizeable=0,width=500,height=400");
daydisplay.location.href = url;
if (daydisplay.opener == null) daydisplay.opener = window;
daydisplay.opener.name = "CalendarDisplay";
}
// -->
</script>

<CFIF isdefined('attributes.showremote')>

<cfset useLakebaseForGETSITE = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("site_table")>
<cfif useLakebaseForGETSITE>
	<cftry>
		<cfset GETSITE = application.oLakebase.toQuery(
			application.oLakebase.selectRows("site_table", {
				"siteid" = "eq.#attributes.siteid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGETSITE = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGETSITE>
<CFQUERY name="GETSITE" datasource="#attributes.MultiCalDSN#">
SELECT * from SITE_TABLE
WHERE SITEID = #attributes.siteid#
</cfquery>
</cfif>

<CFIF #attributes.showremote# eq 'showallevents'>

<CFQUERY name="GetEvent" DATASOURCE="#attributes.MultiCalDSN#">
SELECT 		* 
FROM 		MULTICALENDAR_TABLE, CATEGORY_TABLE
WHERE 		startdate <= #createodbcdate(attributes.DateList)# 
AND 		enddate >= #createodbcdate(attributes.DateList)# 
AND			MULTICALENDAR_TABLE.Category = CATEGORY_TABLE.id 
AND 		active ='Y' 
AND			RECUR = 'N'
<CFIF #attributes.categories# neq 0>
AND			CATEGORY_TABLE.id = #attributes.categories#
</cfif>
AND 		MULTICALENDAR_TABLE.siteid = #attributes.siteid#
</CFQUERY>

<CFQUERY name="GetRecur" DATASOURCE="#attributes.MultiCalDSN#">
SELECT 		* 
FROM 		MULTICALENDAR_TABLE, CATEGORY_TABLE, RECUR_TABLE, RECURTYPE_TABLE
WHERE 		RECUR_TABLE.startdate = #createodbcdate(attributes.DateList)# 
AND			MULTICALENDAR_TABLE.Category = CATEGORY_TABLE.id 
AND 		active ='Y' 
<CFIF 		#attributes.categories# neq 0>
AND			CATEGORY_TABLE.id = #attributes.categories#
</cfif>
AND 		MULTICALENDAR_TABLE.siteid = #attributes.siteid#
AND			RECUR_TABLE.EventID = MULTICALENDAR_TABLE.EventID
AND			RECUR_TABLE.RECURTYPEID = RECURTYPE_TABLE.RECURTYPEID
</CFQUERY>

<CENTER>
<br>
<CFIF #GetEvent.recordcount# lte 0 AND #GetRecur.recordcount# lte 0>
<CFIF #attributes.categories# neq 0>
<cfset useLakebaseForGetCat = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("category_table")>
<cfif useLakebaseForGetCat>
	<cftry>
		<cfset GetCat = application.oLakebase.toQuery(
			application.oLakebase.selectRows("category_table", {
				"id" = "eq.#attributes.categories#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCat = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCat>
<CFQUERY name="GetCat" DATASOURCE="#attributes.MultiCalDSN#">
SELECT 		* 
FROM 		CATEGORY_TABLE
WHERE		CATEGORY_TABLE.id = #attributes.categories#
</CFQUERY>
</cfif>
</cfif>
<b><font>Sorry, there are no <CFIF #attributes.categories# neq 0><cfoutput><font color="#GetCat.Textcolor#">"#GetCat.title#"</cfoutput></font><cfelse>events</cfif> listed for today.</font></b><br><br>
<CFELSE>
<CFIF #attributes.categories# neq 0><cfoutput><font size="+1" color="#GetEvent.Textcolor#"><b><i>#GetEvent.title#</i></b></font></cfoutput></cfif>
<table border=0 cellpadding="2" cellspacing="5">
<CFOUTPUT query="GetEvent">
<tr><td align="center" bgcolor="#textcolor#">
<table width="100%" cellspacing="0" cellpadding="2">
<tr>
<td colspan="2">
<A HREF="#attributes.pagename#?showremote=showevent&eventID=#eventID#&curntdate=#urlencodedformat(attributes.CurntDate)#&DateList=#urlencodedformat(attributes.DateList)#&siteid=#attributes.siteid#&recur=0&MonthChange1=#monthchange1#&categories=#attributes.categories#"><font size="+1" color="WHITE"><b>#LONGTITLE#</b></font></A>
</td>
</tr>
<tr bgcolor="WHITE">
<td><font color="black"><b>From:</b></font></td><td><font color="black"><b>#dateformat(startdate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(starttime, 'hh:mm TT')#</b></font></td></tr>
<tr bgcolor="WHITE"><td>
<font color="black"><b>To:</b></font></td><td><font color="black"><b>#dateformat(enddate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(endtime, 'hh:mm TT')#</b></font>
</td></tr>
</table>
</td></tr>
</CFOUTPUT>
<CFOUTPUT query="GetRecur">
<tr><td align="center" bgcolor="#textcolor#">
<table width="100%" cellspacing="0" cellpadding="2">
<tr>
<td colspan="2">
<A HREF="#attributes.pagename#?showremote=showevent&eventID=#eventID#&curntdate=#urlencodedformat(attributes.CurntDate)#&DateList=#urlencodedformat(attributes.DateList)#&siteid=#attributes.siteid#&recur=#RecurID#&monthchange1=#monthchange1#&categories=#attributes.categories#"><font size="+1" color="WHITE"><b>#LONGTITLE#</b></font></A> <font size="+1" color="WHITE">[<i>#RecurType# Event</i>]</font>
</td>
</tr>
<tr bgcolor="WHITE">
<td><font color="black"><b>From:</b></font></td><td><font color="black"><b>#dateformat(startdate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(starttime, 'hh:mm TT')#</b></font></td></tr>
<tr bgcolor="WHITE"><td>
<font color="black"><b>To:</b></font></td><td><font color="black"><b>#dateformat(startdate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(endtime, 'hh:mm TT')#</b></font>
</td></tr>
</table>
</td></tr>
</CFOUTPUT>
</table>
</CFIF>
<CFOUTPUT>
<cfif #GetSite.Allowsubmit# eq 'Y'>
<font size="-1"><a HREF="#attributes.pagename#?newevent=newevent&DateList=#urlencodedformat(attributes.DateList)#&curntdate=#urlencodedformat(attributes.CurntDate)#&siteid=#attributes.siteid#&categories=#attributes.categories#" <cfif #GetSite.AllowJava# eq 'Y'>target="CalendarDisplay"</cfif>>Submit an Event!</a></font></cfif>
<br><br>
<font size="-1"><cfif #GetSite.AllowJava# eq 'Y'><a href="##" onclick="window.close()">Close Window</a><cfelse><a HREF="#attributes.pagename#?curntdate=#urlencodedformat(attributes.CurntDate)#&lastdate=#urlencodedformat(attributes.CurntDate)#&monthchange=#monthchange1#&siteid=#attributes.siteid#&categories=#attributes.categories#">Back to Calendar</a></cfif></font></cfoutput>
</CENTER>
<cfelse>
<CFIF #attributes.recur# neq 0>
<CFQUERY name="GetRecur" DATASOURCE="#attributes.MultiCalDSN#">
SELECT * FROM RECUR_TABLE r, RECURTYPE_TABLE t
WHERE   r.recurid = #attributes.recur#
AND		r.recurtypeid = t.recurtypeid
</CFQUERY>
</cfif>
<CFQUERY name="GetEvent" DATASOURCE="#attributes.MultiCalDSN#">
SELECT * FROM MULTICALENDAR_TABLE e, CATEGORY_TABLE c
WHERE eventid = #attributes.eventid#
AND		e.Category = c.id
</CFQUERY>
<CENTER>
<br>
<CFOUTPUT query="GetEvent">
<table width="100%" border="0" cellspacing="2" cellpadding="2" align="CENTER" valign="MIDDLE" nowrap bgcolor="#textcolor#"><tr><td>
<table width="100%" cellspacing="0" cellpadding="5" align="CENTER" valign="MIDDLE" nowrap bgcolor="White" border="0">
<tr><td colspan="2"><font size="+2" color="#textcolor#"><center><b>#LONGTITLE#</b><CFIF #attributes.recur# neq 0><br>[<i>#GetRecur.RecurType# Event</i>]</cfif></center></font></td></tr>
<tr><td valign="Top"><font color="#textcolor#"><b>Start Date & Time: </b></font></td>
<td valign="Top"><font><CFIF #attributes.recur# eq 0>#dateformat(startdate, 'mmm. dd, yyyy')#<cfelse>#dateformat(GetRecur.startdate, 'mmm. dd, yyyy')#</cfif>&nbsp;&nbsp;#timeformat(starttime, 'HH:mm TT')#</font></td></tr>
<tr><td valign="Top"><font color="#textcolor#"><b>End Date & Time: </b></font></td>
<td valign="Top"><font><CFIF #attributes.recur# eq 0>#dateformat(enddate, 'mmm. dd, yyyy')#<cfelse>#dateformat(GetRecur.startdate, 'mmm. dd, yyyy')#</cfif>&nbsp;&nbsp;#timeformat(endtime, 'HH:mm TT')#</font></td></tr>
<tr><td valign="Top"><font color="#textcolor#"><b>Contact(s): </b></font></td>
<td valign="Top"><font>#eventfirst# #eventlast#<br>
<a href="mailto:#eventemail#">#eventemail#</a><br>
#eventphone#
<CFIF #eventfirst2# neq ""><br><br>#eventfirst2#</cfif>
<CFIF #eventlast2# neq "">#eventlast2# <br></cfif>
<CFIF #eventemail2# neq ""><a href="mailto:#eventemail2#">#eventemail2#</a></cfif>
<CFIF #eventphone2# neq ""><br>#eventphone2#</cfif></font></td></tr>
<tr><td valign="Top" colspan="2"><font color="#textcolor#"><b>Location: </b></font></td></tr>
<tr><td valign="Top" colspan="2">
<CFIF #location# eq ""><font color="silver">None Listed</font><cfelse><pre><font size="+1">#location#</font></pre></cfif></td></tr>
<tr><td valign="Top" colspan="2"><font color="#textcolor#"><b>Event Description: </b></font></td></tr>
<tr><td valign="Top" colspan="2"><pre><font size="+1">#LONGDESC#</font></pre>
</td></tr></table></td></tr></table><br>

<font size="-1"><cfif #GetSite.AllowJava# eq 'Y'><a href="##" onclick="window.close()">Close Window</a><cfelse><a HREF="#attributes.pagename#?curntdate=#urlencodedformat(attributes.CurntDate)#&lastdate=#urlencodedformat(attributes.CurntDate)#&monthchange=#monthchange1#&siteid=#attributes.siteid#&categories=#attributes.categories#">Back to Calendar</a></cfif></font></CFOUTPUT>
</CENTER>


</cfif>
<cfelse>

<CFIF #isdefined('attributes.newevent')#>
<cfif #attributes.newevent# eq 'newevent'>

<CFSET attributes.NOSHOW = 0>

	<CFSET FIRSTNAME = "">
	<CFSET LASTNAME = "">
	<CFSET email = "">
	<CFSET phone11 = "">
	<CFSET phone12 = "">
	<CFSET phone13 = "">
	
<cfset useLakebaseForGetCalColors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("site_table")>
<cfif useLakebaseForGetCalColors>
	<cftry>
		<cfset GetCalColors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("site_table", {
				"siteid" = "eq.#attributes.siteid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCalColors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCalColors>
<CFQUERY name="GetCalColors" datasource="#attributes.MultiCalDSN#">
SELECT  *
FROM    SITE_TABLE
WHERE   SiteID = #attributes.siteid#
</cfquery>
</cfif>

<cfset useLakebaseForGetcategories = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("category_table")>
<cfif useLakebaseForGetcategories>
	<cftry>
		<cfset Getcategories = application.oLakebase.toQuery(
			application.oLakebase.selectRows("category_table", {
				"siteid" = "eq.#attributes.siteid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetcategories = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetcategories>
<CFQUERY name="Getcategories" datasource="#attributes.MultiCalDSN#">
SELECT * 
FROM 	CATEGORY_TABLE
WHERE	siteid = #attributes.siteid#
</CFQUERY>
</cfif>

<CFFORM action="#attributes.pagename#" Method="POST" name="addeventform">
<cfoutput>
<input type="hidden" name="siteid" value="#attributes.siteid#">
<input type="hidden" name="DateList" value="#attributes.DateList#">
<input type="hidden" name="CurntDate" value="#attributes.CurntDate#">
<input type="hidden" name="categories" value="#attributes.categories#">
</cfoutput>
<input type="hidden" name="newevent" value="insertevent">
<table border="0" cellspacing="0" cellpadding="5" align="CENTER" valign="TOP" nowrap width="750">
<tr><td colspan="2"><center><font color="<cfoutput>#GetCalColors.headercolor#" size="+1"><b>Submit An Event</b></font></center><br>
<div align="center"><font size="-1" color="#GetCalColors.headercolor#</cfoutput>">
Anyone may submit an event to be entered in the Events Calendar. Simply complete<br>
the form below and press "SUBMIT EVENT". All submissions will be reviewed for<br>
completeness and will then be posted or denied as appropriate.<br>
<br>
Please note that times should be entered using the 24 hour clock or military time.<br>
(1:00 PM = 13:00) If want help on completing an entry, click on the entry title.</font></div><br><br>
<hr></td></tr>
<tr><td width="50%" align="center" colspan="2"><font color="<cfoutput>#GetCalColors.headercolor#"><b>Event Date: #dateformat(attributes.datelist, 'mmmm dd, yyyy')#</b><br>
<center><font color="RED" size="-1"><b>All fields marked with an asterisk [ * ] are required!</b></font></center><br></cfoutput></font></td></tr>
<tr>
<td width="50%" align="right" valign="top"><font>First Name: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="eventfirst1" message="You must enter your first name." required="Yes" size="30" tabindex="1" value="#FIRSTNAME#"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Last Name: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="eventlast1" message="You must enter your last name." required="Yes" size="30" tabindex="2" value="#LASTNAME#"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Email Address: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="eventemail1" message="You must enter your email address." required="Yes" size="30" tabindex="3" value="#EMAIL#"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Phone Number: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="eventphone11" message="You must enter your Area Code." validate="integer" required="Yes" size="3" maxlength="3" tabindex="4" value="#PHONE11#">-<cfinput type="Text" name="eventphone12" message="You must enter your Phone Number Prefix." validate="integer" required="Yes" size="3" maxlength="3" tabindex="5" value="#PHONE12#">-
<cfinput type="Text" name="eventphone13" message="You must enter your complete Phone Number." validate="integer" required="Yes" size="4" maxlength="4" tabindex="6" value="#PHONE13#"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top">&nbsp;</td>
<td width="50%">&nbsp;</td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Start Date: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="startdate" value="#dateformat(attributes.datelist, 'mm/dd/yyyy')#" message="You must enter a starting date." validate="date" required="Yes" size="30" tabindex="13"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Start Time: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="starttime" value="#timeformat(now(), 'HH:mm')#" message="You must enter a starting time." validate="time" required="Yes" size="30" tabindex="14"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top" valign="top"><font>End Date: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="enddate" value="#dateformat(attributes.datelist, 'mm/dd/yyyy')#" message="You must enter a starting date." validate="date" required="Yes" size="30" tabindex="15"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>End Time: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="endtime" value="#timeformat(now(), 'HH:mm')#" message="You must enter an ending time." validate="time" required="Yes" size="30" tabindex="16"></td>
</tr>
<cfset useLakebaseForGetRecurType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("recurtype_table")>
<cfif useLakebaseForGetRecurType>
	<cftry>
		<cfset GetRecurType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("recurtype_table", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetRecurType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetRecurType>
<CFQUERY name="GetRecurType" datasource="#attributes.MultiCalDSN#">
SELECT * FROM RECURTYPE_TABLE
</cfquery>
</cfif>
<tr>
<td width="50%" align="right" valign="top"><font>Recurring Events: </font></td>
<td width="50%"><font><cfselect name="RecurType" query="GetRecurType" value="RecurTypeID" display="RecurType">
<option value="0" selected>Not Recurring
</cfselect> occurs <input type="Text" name="RecurAmount" value="0" size="2" maxlength="3"> times.</font></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Event Type: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfselect name="category" size="1" message="Select the type of event" query="Getcategories" value="id" display="title" required="Yes" tabindex="17" selected="#attributes.categories#">
</cfselect></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Long Title: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="longtitle" message="Enter a long Title here" required="Yes" size="30" tabindex="18"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Short Display Title: </font><font color="red"><b>*</b></font></td>
<td width="50%"><cfinput type="Text" name="shorttitle" message="Enter a title for the calendar here." required="Yes" size="30" tabindex="19"></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Location: </font><font color="red"><b>*</b></font></td>
<td width="50%"><textarea cols=60 rows=6 name="location" wrap="hard" tabindex="20"></textarea></td>
</tr>
<tr>
<td width="50%" align="right" valign="top"><font>Event Description: </font><font color="red"><b>*</b></font></td>
<td width="50%"><TEXTAREA name="longdesc" wrap="hard" rows="6" cols="60" tabindex="21"></textarea></td>
</tr>
<tr>
<td colspan="2" align="center"><INPUT name="insertevent" type="submit" value="SUBMIT EVENT" tabindex="22"></CFFORM></td>
</tr>
</table>


<cfelseif #attributes.newevent# eq 'insertevent'>
<CFSET attributes.NOSHOW = 1>
<CFSET eventphone1 = "#eventphone11#"&"-"&"#eventphone12#"&"-"&"#eventphone13#">

<CFQUERY name="checkdupe" datasource="#attributes.MultiCalDSN#">
SELECT * FROM MULTICALENDAR_TABLE
WHERE  category  = #category#
AND     longdesc = '#longdesc#'
AND     longtitle = '#longtitle#'
AND     shorttitle = '#shorttitle#'
AND     startdate = #createodbcdate(startdate)#
AND     starttime = #createodbctime(starttime)#
AND     enddate = #createodbcdate(enddate)#
AND     endtime = #createodbctime(endtime)#
AND     eventemail = '#eventemail1#'
</CFQUERY>

<cfif #checkdupe.recordcount# lte 0>
<cfquery name="insertevent" DATASOURCE="#attributes.MultiCalDSN#">
INSERT INTO MULTICALENDAR_TABLE (category , longdesc, longtitle, shorttitle, startdate, starttime, enddate, endtime, location, active, eventfirst, eventlast, eventemail, eventphone, siteid, RECUR)
VALUES (#category#, '#longdesc#', '#longtitle#', '#shorttitle#', #createodbcdate(startdate)#, #createodbctime(starttime)#, #createodbcdate(enddate)#, #createodbctime(endtime)#, '#location#', 'I', '#eventfirst1#', '#eventlast1#', '#eventemail1#', '#eventphone1#', #attributes.siteid#, <cfif #RecurType# neq 0 AND #RecurAmount# neq 0>'Y'<cfelse>'N'</cfif>)
</CFQUERY>

<cfquery name="getmax" DATASOURCE="#attributes.MultiCalDSN#">
SELECT MAX(EVENTID) AS MAXID FROM MULTICALENDAR_TABLE
</CFQUERY>

<cfif #RecurType# neq 0 AND #RecurAmount# neq 0>
<CFQUERY name="GetRecurTypes" datasource="#attributes.MultiCalDSN#">
SELECT * FROM RECURTYPE_TABLE
WHERE	RECURTYPEID = #RECURTYPE#
</cfquery>
<CFSET RecurDate = #createodbcdate(startdate)#>
<CFQUERY name="InsertRecurrance" datasource="#attributes.MultiCalDSN#">
INSERT INTO RECUR_TABLE (eventID, StartDate, RecurTypeID)
VALUES (#GETMAX.MAXID#, #RecurDate#, #RecurType#)
</cfquery>
<cfloop index="RecurNum" FROM="2" TO="#RecurAmount#">
<CFIF #RECURTYPE# eq 3>
<CFSET RecurDate = #DateAdd(GetRecurTypes.dtepart, GetRecurTypes.dtenum, RecurDate)#>
<cfloop condition="DayOfWeek(RECURDATE) eq 1 OR DayOfWeek(RECURDATE) EQ 7">
<CFSET RecurDate = #DateAdd(GetRecurTypes.dtepart, GetRecurTypes.dtenum, RecurDate)#>
</cfloop>
<cfelseif #RECURTYPE# eq 4>
<CFSET RecurDate = #DateAdd(GetRecurTypes.dtepart, GetRecurTypes.dtenum, RecurDate)#>
<cfloop condition="DayOfWeek(RECURDATE) GTE 2 AND DayOfWeek(RECURDATE) LTE 6">
<CFSET RecurDate = #DateAdd(GetRecurTypes.dtepart, GetRecurTypes.dtenum, RecurDate)#>
</cfloop>
<cfelse>
<CFSET RecurDate = #DateAdd(GetRecurTypes.dtepart, GetRecurTypes.dtenum, RecurDate)#>
</cfif>
<CFQUERY name="InsertRecurrance" datasource="#attributes.MultiCalDSN#">
INSERT INTO RECUR_TABLE (eventID, StartDate, RecurTypeID)
VALUES (#GETMAX.MAXID#, #RecurDate#, #RecurType#)
</cfquery>
</cfloop>
</cfif> 

<cfquery name="getevent" DATASOURCE="#attributes.MultiCalDSN#">
SELECT * FROM MULTICALENDAR_TABLE 
WHERE EVENTID = #GETMAX.MAXID#
</CFQUERY>

<cfquery name="GetAdmin" DATASOURCE="#attributes.MultiCalDSN#">
SELECT 	* 
FROM 	ADMIN_TABLE a, USER_TABLE u 
WHERE 	a.SITEID = #attributes.siteid#
AND		a.USERID = u.USERID
</CFQUERY>

<CFSET attributes.ent = "SUB">

<cfmail query="GetEvent" to="#GetAdmin.email#" from="#GetEvent.eventemail#" subject="Proposed Event Calendar Entry" cc="#GetEvent.eventemail#" type="HTML">
<table width="500" border="0" cellspacing="0" cellpadding="3" valign="TOP" nowrap bgcolor="Black"><tr><td><table width="494" border="0" cellspacing="0" cellpadding="5" align="CENTER" valign="MIDDLE" nowrap bgcolor="White"><tr><td align="CENTER" valign="MIDDLE">
<font size="-1">Calendar Administrator,<br>
<br>
#Eventfirst# #eventlast# has requested the below event be added to the Event Calendar:<br>
<br>
Event Starting Date/Time: #dateformat(startdate, 'mmmm dd, yyyy')# #timeformat(starttime, 'HH:mm tt')#<br>
Event Ending Date/Time: #dateformat(enddate, 'mmmm dd, yyyy')# #timeformat(endtime, 'HH:mm tt')#<br>
Event Title: #Longtitle#<br>
Event Location: #location#<br>
Event Description: #longdesc#<br>
</font>
</td></tr></table></td></tr></table>
</cfmail>
<cfelse>
<CFSET attributes.ent = "DUP">
</cfif>

</cfif>
</cfif>

<cfif Attributes.noshow eq 1>
<CFQUERY name="GetCalColors" datasource="#attributes.MultiCalDSN#">
SELECT  *
FROM    SITE_TABLE
WHERE   SiteID = #attributes.siteid#
</cfquery>

    <CFIF #attributes.categories# neq 0>
    <CFQUERY name="Getcategories" datasource="#attributes.MultiCalDSN#">
    SELECT  *
    FROM    CATEGORY_TABLE
    WHERE   siteid = #attributes.siteid#
    AND     id <> #attributes.categories#
    ORDER BY TITLE
    </CFQUERY>
    <cfset useLakebaseForGetSelectedType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("category_table")>
<cfif useLakebaseForGetSelectedType>
	<cftry>
		<cfset GetSelectedType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("category_table", {
				"id" = "eq.#attributes.categories#",
				"siteid" = "eq.#attributes.siteid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSelectedType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSelectedType>
<CFQUERY name="GetSelectedType" datasource="#attributes.MultiCalDSN#">
    SELECT  *
    FROM    CATEGORY_TABLE
    WHERE   id = #attributes.categories#
    AND     siteid = #attributes.siteid#
    </CFQUERY>
</cfif>
    <cfelse>
        <CFQUERY name="Getcategories" datasource="#attributes.MultiCalDSN#">
        SELECT  *
        FROM    CATEGORY_TABLE
        WHERE   siteid = #attributes.siteid#
    ORDER BY TITLE
        </CFQUERY>
    </cfif>

<CFIF #isdefined('attributes.ent')#>
	<CFIF #attributes.ent# eq "SUB">
		<CFSET attributes.ent = 0>
		<script language="javascript">
			alert('THANK YOU!\nYour event has been submitted and the Calendar Administrator has been notified.')
		</script>
	</CFIF>
	<CFIF #attributes.ent# eq "DUP">
		<CFSET attributes.ent = 0>
		<script language="javascript">
			alert('It appears that this event has already been submitted.\nPlease review your entry and submit it again.')
		</script>
	</CFIF>
</cfif>

<cfif #parameterexists(CurntDate)# is 'YES'>
<CFSET YearSet = #year(CurntDate)#>
<CFSET MonthSet = #month(CurntDate)#>
	<cfif isdefined('attributes.MonthChange')>
		<cfif attributes.MonthChange eq 'weekview'>
			<cfset CurntDate = attributes.LastDate>	
			<cfset weektest = 1>
		</cfif>
	</cfif>
<cfelse>

<CFIF parameterexists(newdate) is 'YES'> 
<CFSET CurntDate = #CreateODBCDate(newdate)#>
<CFSET MinDate = CreateODBCDate(DateAdd("m", -1, now()))>
<CFIF #MinDate# lte #CurntDate#>
<CFSET CurntDate = #CurntDate#>
<CFELSE>
<CFSET CurntDate = #MinDate#>
</cfif>
<CFELSE>
<CFSET CurntDate = #now()#>
</cfif>

	<cfif attributes.MonthChange is 'Forward'>
			<cfset CurntDate = CreateODBCDate(DateAdd("m", 1, LastDate))>		
	<cfelseif attributes.MonthChange is 'Backward'>
		<cfset CurntDate = CreateODBCDate(DateAdd("m", -1,LastDate))>
			<CFSET MinDate = CreateODBCDate(DateAdd("m", #GetCalColors.firstmonth#, now()))>
			<CFIF #MinDate# lte #CurntDate#>
			<CFSET CurntDate = #CurntDate#>
			<CFELSE>
			<CFSET CurntDate = #MinDate#>
			</cfif>	
	<cfelseif attributes.MonthChange is 'weekview'>
			<cfset CurntDate = LastDate>	
			<cfset weektest = 1>
	</CFIF>

<CFSET YearSet = #year(CurntDate)#>
<CFSET MonthSet = #month(CurntDate)#>

</CFIF>

<CFSET PREVMonth = #CreateODBCDate(DateAdd("m", -1,CurntDate))#>
<CFSET NEXTMonth = #CreateODBCDate(DateAdd("m", 1,CurntDate))#>

<!--- Create the date variables to search the Database by. --->
<cfset MonthStart = CreateDate("#YearSet#", "#MonthSet#", "1")>
<!--- <cfset MonthEnd = dateformat(CreateDateTime(#YearSet#, #MonthSet#, #DaysInMonth(MonthStart)#, 23, 59, 59), 'mm/d/yyyy')> --->
<CFQUERY NAME="getMonthsEvents" DATASOURCE="#attributes.MultiCalDSN#">
	SELECT	*
	FROM    MULTICALENDAR_TABLE, CATEGORY_TABLE
	WHERE	CATEGORY_TABLE.ID = MULTICALENDAR_TABLE.Category
    AND     active = 'Y'
	AND		RECUR = 'N'
    AND     MULTICALENDAR_TABLE.siteid = #attributes.siteid#
    AND     CATEGORY_TABLE.siteid = MULTICALENDAR_TABLE.siteid
    <CFIF #attributes.categories# neq 0>
    AND     CATEGORY_TABLE.ID = #attributes.categories#
    </cfif>
	ORDER BY	startdate
</CFQUERY>
	<CFQUERY name="GetNoGreet" datasource="#attributes.MultiCalDSN#">
				SELECT * FROM Greeting
				WHERE greeting_date = '00/00'
				AND siteid =#attributes.siteid#
	</CFQUERY>
<CFSET OffSet = #DayOfWeek("#MonthStart#")#>
<CFSET LastSlot = #OffSet# + #DaysInMonth("#MonthStart#")#-1>
<CFSET CalDays = (#Ceiling(LastSlot/7)#)*7>
<CFSET DayNumeral = 1>
<CFOUTPUT>
<table bgcolor="#GetCalColors.Headercolor#" align="center"><tr><td>
<table border="0" cellspacing="2">
	<TR>
		
		<td <cfif isdefined('weektest')>colspan="2"<cfelse>colspan="7"</cfif> align="center" valign="BOTTOM" bgcolor="#GetCalColors.Headercolor#"> <A HREF="#attributes.pagename#?MonthChange=Backward&LastDate=#urlencodedformat(CurntDate)#&siteid=#attributes.siteid#&categories=#attributes.categories#"><FONT SIZE="1" color="#GetCalColors.HeaderText#"><B>#DateFormat(prevmonth,"MMMM yyyy")#</A></B></FONT> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<FONT SIZE="5" color="#GetCalColors.HeaderText#"><B>#DateFormat(CurntDate,"MMMM yyyy")#</B></FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 <A HREF="#attributes.pagename#?MonthChange=Forward&LastDate=#urlencodedformat(CurntDate)#&siteid=#attributes.siteid#&categories=#attributes.categories#"><FONT SIZE="1" color="#GetCalColors.HeaderText#"><B>#DateFormat(nextmonth,"MMMM yyyy")#</B></FONT></A> 
    </td>
	</TR></CFOUTPUT>
	
<cfif isdefined('weektest')>
<cfoutput><TR>
		<Td width="595" colspan="2" bgcolor="#GetCalColors.HeaderText#" align="center">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="CENTER" valign="MIDDLE" nowrap bgcolor="#GetCalColors.HeaderText#"><tr><td align="left"><font size="1" COLOR="#GetCalColors.HeaderColor#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#attributes.pagename#?MonthChange=weekview&LastDate=#urlencodedformat(dateadd("d",-7,LastDate))#&siteid=#attributes.siteid#&categories=#attributes.categories#" class="weeklink"><font color="#GetCalColors.headercolor#">LAST WEEK</a></font></td><td align="right"><font size="1" COLOR="#GetCalColors.HeaderColor#"><A HREF="#attributes.pagename#?MonthChange=weekview&LastDate=#urlencodedformat(dateadd("d",-7,LastDate))#&siteid=#attributes.siteid#&categories=#attributes.categories#" class="weeklink"><font color="#GetCalColors.headercolor#">NEXT WEEK</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td></tr></table>
		</TD>
</TR></cfoutput>
<cfloop index="weeklyloop" from="1" to="7">
<CFQUERY name="GetWeekRecur" datasource="#attributes.MultiCalDSN#">
	SELECT * FROM RECUR_TABLE, MULTICALENDAR_TABLE, CATEGORY_TABLE, RECURTYPE_TABLE
	WHERE 	RECUR_TABLE.STARTDATE = #dateadd("d", (weeklyloop-1),LastDate)#
	AND		RECUR_TABLE.EVENTID = MULTICALENDAR_TABLE.EVENTID
	AND		CATEGORY_TABLE.id = MULTICALENDAR_TABLE.category
	AND		ACTIVE = 'Y'
	AND		MULTICALENDAR_TABLE.SiteID = #attributes.SiteID#
	AND		RECUR_TABLE.recurtypeid = RECURTYPE_TABLE.recurtypeid
    <CFIF #attributes.categories# neq 0>
    AND     CATEGORY_TABLE.ID = #attributes.categories#
    </cfif>
</CFQUERY>
<CFQUERY name="GetGreeting" datasource="#attributes.MultiCalDSN#">
	SELECT * FROM Greeting
	WHERE greeting_date = '#dateformat(dateadd("d", (weeklyloop-1),LastDate), 'mm/dd')#'
	AND siteid =#attributes.siteid#
</CFQUERY>
<cfoutput><TR><Td width="85" bgcolor="#GetCalColors.HeaderText#" align="center" valign="top"><FONT COLOR="#GetCalColors.HeaderColor#">#ucase(left(DayofWeekAsString(weeklyloop),3))#</FONT></TD>
<TD valign="top" width="510" <cfif month(dateadd("d", (weeklyloop-1),LastDate)) neq month(CurntDate)>bgcolor="#GetCalColors.nodatecolor#"<cfelseif #dateformat(now(), 'mm/dd/yy')# eq #dateformat(dateadd("d", (weeklyloop-1),LastDate), 'mm/dd/yy')#>bgcolor="#GetCalColors.TodayColor#"<cfelse>bgcolor="#GetCalColors.cellcolor#"</cfif>>
<table width="100%"><tr><td>
<cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showallevents&siteid=#attributes.siteid#&DateList=#urlencodedformat(dateadd("d", (weeklyloop-1),LastDate))#&curntdate=#urlencodedformat(CurntDate)#&eventid=0&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showallevents&siteid=#attributes.siteid#&DateList=#urlencodedformat(dateadd("d", (weeklyloop-1),LastDate))#&curntdate=#urlencodedformat(CurntDate)#&eventid=0&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><FONT COLOR="#GetCalColors.Celltext#"><b>#dateformat(dateadd("d", (weeklyloop-1),LastDate), 'dd')#</b></FONT></A> <CFIF #Getgreeting.recordcount# eq 1><CFSET greeting = "#Getgreeting.greeting#"><CFELSEIF #dateformat(now(), 'mm/dd/yy')# eq #dateformat(dateadd("d", (weeklyloop-1),LastDate), 'mm/dd/yy')#><CFIF #GetNoGreet.recordcount# gt 0><CFSET greeting = "#GetNoGreet.greeting#"><cfelse><CFSET greeting = ""></cfif><cfelse><CFSET greeting = ""></cfif>
<FONT SIZE="1" COLOR="#GetCalColors.GreetingText#">#Greeting#</font><br></cfoutput>
</td></tr><tr>
<cfset eventloop = 1>
<cfoutput query="getMonthsEvents">
						<CFIF #dateadd("d", (weeklyloop-1),LastDate)# gte #getMonthsEvents.startdate# and #dateadd("d", (weeklyloop-1),LastDate)# LTE #getMonthsEvents.enddate#><td>
<table border=0 cellpadding="2" cellspacing="5">
<tr><td align="center" bgcolor="#textcolor#">
<table width="100%" cellspacing="0" cellpadding="2">
<tr>
<td colspan="2">
<cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showevent&eventID=#eventID#&curntdate=#urlencodedformat(CurntDate)#&DateList=#urlencodedformat(CurntDate)#&siteid=#attributes.siteid#&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showevent&eventID=#eventID#&curntdate=#urlencodedformat(CurntDate)#&DateList=#urlencodedformat(CurntDate)#&siteid=#attributes.siteid#&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><font color="WHITE"><b>#LONGTITLE#</b></font></A>
</td>
</tr>
<tr bgcolor="WHITE">
<td><font color="black" size="-1"><b>From:</b></font></td>
<td><font color="black" size="-1">#dateformat(startdate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(starttime, 'hh:mm TT')#</font></td>
</tr>
<tr bgcolor="WHITE">
<td>
<font color="black" size="-1"><b>To:</b></font></td>
<td><font color="black" size="-1">#dateformat(enddate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(endtime, 'hh:mm TT')#</font>
</td></tr>
</table>	
</td></tr>
</table></td>
<cfif #eventloop# eq 2>
<cfset eventloop = 0>
</tr><tr>
</cfif>
<cfset eventloop = eventloop + 1>
				</cfif>
</cfoutput>


<cfoutput query="GetWeekRecur"><td>
<table border=0 cellpadding="2" cellspacing="5">
<tr><td align="center" bgcolor="#textcolor#">
<table width="100%" cellspacing="0" cellpadding="2">
<tr>
<td colspan="2">
<cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showevent&eventID=#eventID#&curntdate=#urlencodedformat(CurntDate)#&DateList=#urlencodedformat(CurntDate)#&siteid=#attributes.siteid#&recur=#RecurID#&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showevent&eventID=#eventID#&curntdate=#urlencodedformat(CurntDate)#&DateList=#urlencodedformat(CurntDate)#&siteid=#attributes.siteid#&recur=#RecurID#&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><font color="WHITE"><b>#LONGTITLE#</b></font></A><br><font size="-1" color="WHITE">[<i>#RecurType# Event</i>]</font>
</td>
</tr>
<tr bgcolor="WHITE">
<td><font color="black" size="-1"><b>From:</b></font></td><td><font color="black" size="-1">#dateformat(startdate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(starttime, 'hh:mm TT')#</font></td></tr>
<tr bgcolor="WHITE"><td>
<font color="black" size="-1"><b>To:</b></font></td><td><font color="black" size="-1">#dateformat(startdate, 'mmm. dd, yyyy')#&nbsp;&nbsp;#timeformat(endtime, 'hh:mm TT')#</font>
</td></tr>
</table>
</td></tr></table></td>
<cfif #eventloop# eq 2>
<cfset eventloop = 0>
</tr><tr>
</cfif>
<cfset eventloop = eventloop + 1>
</cfoutput>
</tr></table>
</cfloop>
<TR>
<cfelse>
	<cfoutput><TR bgcolor="#GetCalColors.headercolor#">
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">SUN</FONT></TD>
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">MON</FONT></TD>
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">TUE</FONT></TD>
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">WED</FONT></TD>
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">THU</FONT></TD>
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">FRI</FONT></TD>
		<Td width="85" bgcolor="#GetCalColors.headercolor#"><FONT COLOR="#GetCalColors.HeaderText#">SAT</FONT></TD>
	</TR></cfoutput>
<cfif #GetCalColors.AllowWeek# eq 'Y'>
		<cfset weekdate = #DateAdd("d", -(offset - 1),createdate("#yearset#", "#monthset#", "1"))#>
<cfoutput>	<TR>
		<Td colspan="7" bgcolor="#GetCalColors.headertext#"><A HREF="#attributes.pagename#?MonthChange=weekview&LastDate=#urlencodedformat(weekdate)#&siteid=#attributes.siteid#&categories=#attributes.categories#" class="weeklink"><font color="#GetCalColors.headercolor#">View Week of #dateformat(weekdate, 'mm/dd/yy')# - #dateformat(DateAdd("d", 6,weekdate), 'mm/dd/yy')#</font></a></TD>
</TR></cfoutput>
</cfif>
<TR>
		<CFLOOP INDEX="ii" FROM="1" TO="#CalDays#">
			<CFIF #ii# GTE #Offset# and #ii# LTE #LastSlot# >
            <CFSET Testday = createdate("#yearset#", "#monthset#", "#daynumeral#")>
			<CFQUERY name="GetRecur" datasource="#attributes.MultiCalDSN#">
			SELECT * FROM RECUR_TABLE, MULTICALENDAR_TABLE, CATEGORY_TABLE
			WHERE 	RECUR_TABLE.STARTDATE = #TESTDAY#
			AND		RECUR_TABLE.EVENTID = MULTICALENDAR_TABLE.EVENTID
			AND		CATEGORY_TABLE.id = MULTICALENDAR_TABLE.category
			AND		ACTIVE = 'Y'
			AND		MULTICALENDAR_TABLE.SiteID = #attributes.SiteID#
		    <CFIF #attributes.categories# neq 0>
		    AND     CATEGORY_TABLE.ID = #attributes.categories#
		    </cfif>
			</CFQUERY>
            <CFQUERY name="GetGreeting" datasource="#attributes.MultiCalDSN#">
				SELECT * FROM Greeting
				WHERE greeting_date = '#dateformat(Testday, 'mm/dd')#'
				AND siteid =#attributes.siteid#
			</CFQUERY>
            <cfoutput>
<CFIF #dateformat(now(), 'mm/d/yy')# eq #dateformat(Testday, 'mm/d/yy')#>
				<TD valign=top WIDTH="85" height="75" bgcolor="#GetCalColors.TodayColor#">
					<cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showallevents&siteid=#attributes.siteid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&eventid=0&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showallevents&siteid=#attributes.siteid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&eventid=0&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><FONT COLOR="#GetCalColors.Celltext#"><b>#DayNumeral#</b></FONT></A><br>
<CFIF #Getgreeting.recordcount# gt 0>
<CFSET greeting = "#Getgreeting.greeting#">
<CFELSE>
	<CFIF #GetNoGreet.recordcount# gt 0>
<CFSET greeting = "#GetNoGreet.greeting#">
<cfelse>
<CFSET greeting = "">
</cfif>
</CFIF>
<center><FONT SIZE="1" COLOR="#GetCalColors.GreetingText#">#Greeting#</font></center><br>
					
<CFELSE>
				<TD valign=top WIDTH="85" height="75" bgcolor="#GetCalColors.cellcolor#">
					<cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showallevents&siteid=#attributes.siteid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&eventid=0&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showallevents&siteid=#attributes.siteid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&eventid=0&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><FONT SIZE="1" COLOR="#GetCalColors.Celltext#">#DayNumeral#</FONT></A><br><CFIF #GetGreeting.recordcount# gte 1><center><FONT SIZE="1" COLOR="#GetCalColors.Celltext#">#Getgreeting.Greeting#</font></center><br></cfif>

</CFIF>
</cfoutput>
<cfoutput query="getMonthsEvents">
						<CFIF #Testday# gte #getMonthsEvents.startdate# and #Testday# LTE #getMonthsEvents.enddate#>
						<cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showevent&siteid=#attributes.siteid#&eventid=#eventid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showevent&siteid=#attributes.siteid#&eventid=#eventid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&recur=0&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><FONT SIZE="-2" COLOR="#getMonthsEvents.textcolor#">#shorttitle#</FONT></A><br>	
				</cfif>
</cfoutput>
<cfoutput query="GetRecur"><cfif #GetCalColors.AllowJava# eq 'Y'><a href="##" onclick="makeremote('#attributes.pagename#?showremote=showevent&siteid=#attributes.siteid#&eventid=#eventid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&recur=#GetRecur.recurid#&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#&NoDisplay=1')"><cfelse><A HREF="#attributes.pagename#?showremote=showevent&siteid=#attributes.siteid#&eventid=#eventid#&DateList=#urlencodedformat(Testday)#&curntdate=#urlencodedformat(CurntDate)#&recur=#GetRecur.recurid#&MonthChange1=#attributes.monthchange#&categories=#attributes.categories#"></cfif><FONT SIZE="-2" COLOR="#GetRecur.textcolor#">#shorttitle#</FONT></A><br>	
</cfoutput>
				</TD>
				<CFSET DayNumeral = #DayNumeral# + 1>
			<CFELSE>
				<TD width="75" bgcolor="<cfoutput>#GetCalColors.nodatecolor#</cfoutput>">&nbsp;</TD>
			</CFIF>
			
			<CFIF (#ii# mod 7 is 0)>
			</TR>
			<cfif #GetCalColors.AllowWeek# is 'Y'>
			<TR><CFIF #ii# GTE #Offset# and #ii# LT #LastSlot# ><cfoutput>
		<Td colspan="7" bgcolor="#GetCalColors.headertext#"><A HREF="#attributes.pagename#?MonthChange=weekview&LastDate=#urlencodedformat(DateAdd("d", 1,testday))#&siteid=#attributes.siteid#&categories=#attributes.categories#" class="weeklink"><font color="#GetCalColors.headercolor#">View Week of #dateformat(DateAdd("d", 1,testday), 'mm/dd/yy')# - #dateformat(DateAdd("d", 7,testday), 'mm/dd/yy')#</font></a></TD></cfoutput></TR>
</cfif>
			<TR>
			</CFIF>
			</cfif>
		</CFLOOP>
</cfif> 
	<!--- The last TR is created in the loop above --->
	<TD <cfif isdefined('weektest')>colspan="2"<cfelse>colspan="7"</cfif> align="center" bgcolor="<cfoutput>#GetCalColors.headercolor#</cfoutput>">
	<table align="center" border=0 width="100%">
		<tr>
        <td align="center">
    <table align="center" width="100%">
		<tr><CFOUTPUT>
			<FORM action="#attributes.pagename#" method="post">
			<td align="center">
            <input type="hidden" value="#attributes.siteid#" name="siteid">
			<input type="hidden" value="none" name="Monthchange">
            <input type="hidden" value="none" name="LastDate">
            <input type="hidden" value="#attributes.categories#" name="categories">
			<select name="CurntDate">
			<CFLOOP index="moncount" FROM="#GetCalColors.firstmonth#" TO="#GetCalColors.lastmonth#">
			<CFSET LoopDate = CreateODBCDate(DateAdd("m", moncount,now()))>
			<CFIF #dateformat(loopdate, 'mm/yyyy')# eq #dateformat(now(), 'mm/yyyy')#>
			<OPTION VALUE="#LoopDate#" selected>#dateformat(loopdate, 'MMMM yyyy')#
			<cfelse>
			<OPTION VALUE="#LoopDate#">#dateformat(loopdate, 'MMMM yyyy')#
			</cfif>
			</CFLOOP>
			</select>
            </CFOUTPUT>
			<input type="submit" value="Go To Month"> 
			
			</td>
		</tr></form>
	</table>
    </td>
    <td align="center">
	<table align="center" width="100%">
		<tr><CFOUTPUT>
			<FORM action="#attributes.pagename#" method="post">
			<td align="center">
            <input type="hidden" value="#attributes.siteid#" name="siteid">
            <cfif attributes.MonthChange eq 'weekview'>
			<input type="hidden" name="Monthchange" value="weekview">
            <input type="hidden" name="LastDate" value="#Lastdate#">
			<cfelse>
			<input type="hidden" value="none" name="Monthchange">
            <input type="hidden" value="none" name="LastDate">
			</cfif>
            <input type="hidden" name="CurntDate" value="#Curntdate#">
            </CFOUTPUT>
            <select name="categories">
            <CFIF #attributes.categories# neq 0>
            <OPTION VALUE="<cfoutput>#getselectedtype.id#" selected>#GetSelectedtype.title# </cfoutput>
            <OPTION VALUE="0"> All Events
            <CFOUTPUT Query="Getcategories">
			<OPTION VALUE="#id#">#title#
			</CFOUTPUT>
            <cfelse>
			<OPTION VALUE="0" selected> All Events
			<CFOUTPUT Query="Getcategories">
			<OPTION VALUE="#id#">#title#
			</CFOUTPUT>
            </cfif>
			</select>
			<input type="submit" value="View Events">
					</td></form>	</tr></table></td></tr></table></td></tr></TABLE></td></tr></table></cfif></cfif>