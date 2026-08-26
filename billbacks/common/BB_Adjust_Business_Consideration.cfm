<!---
Name: 			BillbackDAO.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	08/18/2011
Created By:    	Tim Ford
Description:	File that gets called from Billback Edit to add Business Considerations on Billback Adjust. Created a seperate Bisiness Considerations file for Adjust to maintain sanity.
Parameters:		N/A
Usage:			Log Billback Considerations on Billback Adjust.
--->

<!--- 
Modes: URL.Mode Sets the Eval Action of the Form. For this file it will always be 11
11 = Adjust Billback
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--- Dev Note: Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="">
<cfif isDefined("URL.FlexAppName")>
	<cfset structInsert(FORM,"FlexAppName",URL.FlexAppName,true) />		
</cfif>
<cfparam name="ParentFormName" default="">
<cfparam name="mode" default="0">
<cfparam name="edit" default="1">
<cfparam name="Action" default="">
<cfparam name="PAGE_TITLE" default="Billback Adjust Business Consideration">
<cfparam name="frmWidth" default="750px">
<cfparam name="ProgramAgree" default="0">
<CFPARAM NAME="FORM.BBID" DEFAULT = "">
<CFPARAM NAME="FORM.FormSubmit" DEFAULT = "0">
 
<CFIF ISDefined("URL.BBID")>
	<CFSET FORM.BBID = URL.BBID>
</CFIF>

<cfif isdefined("form.mode")>
	<cfset mode = form.mode >
</cfif>

<cfif isdefined("URL.FormName") and URL.FormName NEQ "">
	<cfset ParentFormName = URL.FormName>
</cfif>

<CFSWITCH expression="#mode#">
	<CFCASE value="11">
		<cfset evalAction = 'ADJUST'>
		<cfset Action = 'ADJUST' />
	</CFCASE>
	<cfdefaultcase>
		<!--- Mode Not Passed to Template --->
	</cfdefaultcase>
</CFSWITCH>

<cfif mode EQ "0">
	<cfset evalAction = ''>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!--- Get Business Considerations Reminder Data --->
<cfinvoke component="components.settings.BusinessConsiderationsReminderBB" method="get" returnvariable="qBizConRemindersBB">

<!--- Get Billback Programs --->
<cfinvoke component="components.Billback.Programs.BillbackProgramsManager" method="getBillbackPrograms" returnvariable="qBillbackPrograms" billbackId="#FORM.BBID#">

<!--- Decrypt Contract ID, Retrieve Contract_Number, and Get Evaluation Notes --->
<cfif isDefined("FORM.BBID")>

	<cfif FORM.FormSubmit EQ 1>
		<cfif trim(form.notes) neq "">
			<cfquery name="postEvaluationNotes" datasource="#application.datasource#">
				IF NOT EXISTS (select * from BB_Business_Consideration where Created_By = '#request.AccessStructure.User_ID#' AND Action = '#form.Action#' AND Notes = '#REReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#' AND Billback_ID = '#form.BBID#')
				BEGIN
					INSERT INTO BB_Business_Consideration(Billback_ID,Action,Notes,Created_By)
					VALUES('#form.BBID#','#form.Action#','#REReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#','#request.AccessStructure.User_ID#')
				END
			</cfquery>
			<cfoutput>
				<script>
					function getFlexApp(appName)
					{
				  		if (navigator.appName.indexOf ("Microsoft") !=-1)
				  		{
				    		return opener.window[appName];
				  		} 
				  		else 
				  		{
				    		return opener.document[appName];
				  		}
					}
					
					function showAdjustProgramSearch()
					{
				  		getFlexApp('#FORM.FlexAppName#').showAdjustProgramSearch('#Form.programId#');
					}
					showAdjustProgramSearch();
					window.close();
				</script>
			</cfoutput>
		</cfif>
	</cfif>	
	
	<!--- 
	22910/Anand Rao/29-Mar-10:
	Business Consideration sorting:
	1) Moved the code for the table to be at the bottom of the page
	2) Most recent one will be at the top by default
	3) Added the below code for doing the sorting on all columns 
	--->
	<cfset sortByField          = "Created_Date" />
	<cfset orderBy              = "DESC" />
	<cfset sortOrderParam       = "" />
	<cfset sortOrderParamDate   = "DA"   />
	<cfset sortOrderParamUser   = "UD"   />
	<cfset sortOrderParamAction = "AD"   />
	<cfset sortOrderParamNotes  = "ND"   />
	<cfset imgDate              = ""/>
	<cfset imgUser              = "" />
	<cfset imgAction            = "" />
	<cfset imgNotes             = "" />
	
	<cfif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "DA">
		<cfset sortByField = "Created_Date"/>
		<cfset orderBy = "ASC" />
		<cfset sortOrderParamDate = "DD" />
		<cfset imgDate = "<img src='/Images/up_1.gif' border='0' />" />
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "DD">
		<cfset sortByField = "Created_Date"/>
		<cfset orderBy = "DESC" />
		<cfset sortOrderParamDate = "DA" />
		<cfset imgDate = "<img src='/Images/down_1.gif' border='0' />" />
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "UA">  
		<cfset sortByField = "_Users.Name_First"/>
		<cfset orderBy = "ASC" />
		<cfset sortOrderParamUser = "UD" />
		<cfset imgUser = "<img src='/Images/up_1.gif' border='0' />" />
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "UD">  
		<cfset sortByField = "_Users.Name_First"/>
		<cfset orderBy = "DESC" />
		<cfset sortOrderParamUser = "UA" />
		<cfset imgUser = "<img src='/Images/down_1.gif' border='0' />" />
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "AA">  
		<cfset sortByField = "Action"/>
		<cfset orderBy = "ASC" />
		<cfset sortOrderParamAction = "AD" />  
		<cfset imgAction = "<img src='/Images/up_1.gif' border='0' />" />      
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "AD">  
		<cfset sortByField = "Action"/>
		<cfset orderBy = "DESC" />
		<cfset sortOrderParamAction = "AA" />        
		<cfset imgAction = "<img src='/Images/down_1.gif' border='0' />" />    
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "NA">  
		<cfset sortByField = "Notes"/>
		<cfset orderBy = "ASC" />
		<cfset sortOrderParamNotes = "ND" />    
		<cfset imgNotes = "<img src='/Images/up_1.gif' border='0' />" />        
	<cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "ND">  
		<cfset sortByField = "Notes"/>
		<cfset orderBy = "DESC" />
		<cfset sortOrderParamNotes = "NA" />    
		<cfset imgNotes = "<img src='/Images/down_1.gif' border='0' />" />        
	</cfif>
	
	<cfset sortURL = application.HTTPVar & CGI.SERVER_NAME & CGI.SCRIPT_NAME & "?" />   
	
	<cfif isdefined("URL.MODE") and URL.MODE NEQ "">
		<cfset sortURL = sortURL & "MODE="& URL.MODE & "&" /> 
	</cfif>
	<cfif isdefined("URL.EDIT") and URL.EDIT NEQ "">
		<cfset sortURL = sortURL & "EDIT="& URL.EDIT & "&" /> 
	</cfif>
	<cfif isdefined("URL.Action") and URL.Action NEQ "">
		<cfset sortURL = sortURL & "Action="& URL.Action & "&" /> 
	</cfif> 
	<cfif isdefined("URL.FormName") and URL.FormName NEQ "">
		<cfset sortURL = sortURL & "FormName="& URL.FormName & "&" /> 
	</cfif>
	
	<cfif isDefined("URL.BBID")>
		<cfset sortURL = sortURL & "BBID=" & URL.BBID /> 
	<cfelseif isDefined("FORM.BBID")>
		<cfset sortURL = sortURL & "BBID=" & FORM.BBID />  
	</cfif>
	
	<cfquery name="GetBB_BusiConsi" datasource="#application.datasource#">
		SELECT 	Billback_ID,Notes,_Users.Name_First,_Users.Name_Last,Created_Date, Action
		FROM 	BB_Business_Consideration
				INNER JOIN _Users ON _Users.User_ID = BB_Business_Consideration.Created_By
		WHERE 	Billback_ID = '#FORM.BBID#'
		ORDER BY #sortByField# #orderBy#
	</cfquery>
	
</cfif>

<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>

	<style type="text/css">
		table {
				margin-right:10px;
				border-collapse:collapse;
				width:<cfoutput>#frmwidth#</cfoutput>
				}
		th 	  { font-size:9pt;
				color:#000000;
				font-weight:550;
				font-family:verdana;
				text-align:left;
				padding-left:5px;
				background-color:#FFCE84;
				}
		td 	  {	font-size:8pt;
				color:#000000;
				padding-left:5px;
				font-family:verdana;
				vertical-align:top;
				}
		pre	  {
				font-size:8pt;
				color:#000000;
				font-family:verdana;
			  }
		td.norecords  {	font-size:8pt;
						color:#770022;
						font-family:verdana;
						padding-left:5px;
						text-align:center;
						}
		.header { font-size:11pt;
				  font-weight:bold;
				  color:#000000;
				  font-family:verdana;
				  text-align:left;
				  width:<cfoutput>#frmWidth#</cfoutput>;
				  }
		textarea { width:725px;
				   height:75;
				   margin-top:5px;
				   margin-bottom:5px;
				   margin-right:10px;
				   margin-left:10px;
				   font-family:verdana;
				   }
		p.bodyheader 	{ font-size:10pt;
						  color:#22006F;
						  font-family:verdana;
						  font-weight:bold;
						  }
		/* Reminders */
		div.heading {font-size:12pt;font-family:verdana;}
		div.heading p {font-size:8pt;font-style:italic;font-family:verdana;margin:1px;margin-left:10px;padding:1px;font-weight:500;}
		div.heading ol {font-size:8pt;font-style:italic;font-family:verdana;font-weight:500;}
		div.heading ul {font-size:8pt;font-style:italic;font-family:verdana;font-weight:500;}
		div.heading span {font-weight:bold;font-size:10pt;}			  
						  
		a	{ font-family:verdana;
			  font-size:10pt;
			  font-weight:700;
			  color:dark blue;
			  }
		.likelink	{ font-family:verdana;
					  font-size:9pt;
					  font-weight:700;
					  color:blue;
					  background-color:white;
					  }
	</style>
	<cfoutput>
	<script type="text/javascript" language="JavaScript">
		function ValidateForm()
		{
			//Notes = document.all.notes.value;
			Notes = document.getElementById("Notes").value;   /// CrhomeFix D57213
			if (Notes.length == 0)
			{
				alert("The submitted note is blank. Please enter a valid note.");
				return false;
			}
			else if (Notes.length > 4000)
			{
				alert("The submitted note exceeds the size limit. Please revise the note.");
				return false;
			}
			//else if (document.all.programId.checked == false)
			else if (document.getElementById("programId").checked == false)  /// CrhomeFix D57213
			{
				alert("Please select a program to adjust.");
				return false;
			}
			else
				document.all.BBBusiConsiForm.submit();
				return true;
		}
	
		function fnSortSubmit(actionURL)
		{
			document.all.BBBusiConsiForm.action = actionURL;
			document.all.BBBusiConsiForm.submit();
		}
	
	</script>
	</cfoutput>
</head>
<body>

<p align="left" class="header" style="display:inline"><cfoutput>#PAGE_TITLE#</cfoutput>:</p>
	<CFIF qBizConRemindersBB.RecordCount GT 0>
		<cfif qBizConRemindersBB.business_considerations_reminders_on>
			<HR>
			<div class="heading" align="left">
			 <cfoutput>
			 	<span style="font-size:10pt;font-style:italic;"><b>Reminders:<b></span>
				#qBizConRemindersBB.business_considerations_reminders_txt#
			</cfoutput>
			</div>
		</cfif>
	</CFIF>
<HR>

<cfif edit EQ 1>
<cfoutput>
	<form name="BBBusiConsiForm" method="Post" action="BB_Adjust_Business_Consideration.cfm?BBID=#FORM.BBID#">
	<table width="#frmWidth#" align="center" border=1>
		<tr>
			<th width="700px">ADD NOTE</th>
		</tr>
		<tr>
			<td width="700px"><b>ACTION:</b> #UCASE(Action)#</td>
		</tr>
		<tr>
			<td width="700px"><b>NOTES:</b><br>
			<textarea id="Notes" name="notes" width="#frmWidth#"></textarea>
			</td>
		</tr>
		<tr>
			<td width="700px"><b>Select Program To Adjust:</b><br>
			<cfloop query="qBillbackPrograms">
				<input name="programId" type="radio" value="#Program_ID#"> #Contract_Number# <br>
			</cfloop>
			</td>
		</tr>
		<tr>
			<td width="700px" align="center">
	
				<table width="680px" align="Center">
					<tr>
						<td width="50%" align="center">
							&nbsp;&nbsp;&nbsp;&nbsp;
							<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:window.close()">close window</a><span style="font-weight:bold;color:red"> ] </span>
						</td>
						<td  width="50%" align="center">
							&nbsp;&nbsp;&nbsp;&nbsp;
							<span style="font-weight:bold;color:red"> [ </span><a href="##" OnClick="javascript:ValidateForm();">save/continue</a><span style="font-weight:bold;color:red"> ] </span>
						</td>
					</tr>
				</table>
				<input type="hidden" name="FormSubmit" value="1">
				<input type="hidden" name="Action" value="#evalaction#">
				<input type="hidden" name="mode" value="#mode#">
				<input type="hidden" name="ParentFormName" value="#ParentFormName#">
				<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="#FORM.FlexAppName#">
			</td>
		
		</tr>
	</table>
	</form>
</cfoutput>
</cfif>

<table width="#frmWidth#" align="center" border="1">
	<tr>
	<cfoutput>
		<th width="90px">
			<a href="#sortURL#&sortOrderParam=#sortOrderParamDate#">DATE #imgDate#</a>
		</th>
		<th width="120px">
			<a href="#sortURL#&sortOrderParam=#sortOrderParamUser#">USERNAME #imgUser#</a>
		</th>
		<th width="90px">
			<a href="#sortURL#&sortOrderParam=#sortOrderParamAction#">ACTION #imgAction#</a>
		</th>
		<th width="450px">
			<a href="#sortURL#&sortOrderParam=#sortOrderParamNotes#">NOTES #imgNotes#</a>
		</th>
	</cfoutput>  
	</tr>
	<cfif GetBB_BusiConsi.RecordCount GT 0>
		<cfoutput query="GetBB_BusiConsi">
		<tr><td width="90px">#DateFormat(GetBB_BusiConsi.Created_Date,'MM/DD/YYYY')#</td>
		<td width="120px">#GetBB_BusiConsi.Name_First# #GetBB_BusiConsi.Name_Last#</td>
		<td width="90px">#GetBB_BusiConsi.Action#</td>
		<td width="450px">#trim(GetBB_BusiConsi.Notes)#</td></tr>
		</cfoutput>
	<cfelse>
		<tr><td colspan="4" class="norecords" align="center">No Matching Records Found</td></tr>
	</cfif>
	
</table>

</body>
</html>

