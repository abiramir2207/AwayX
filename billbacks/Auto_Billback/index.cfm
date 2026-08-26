<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!--- <CFIF Get_Profile_Settings.BB_Create EQ 1><A HREF="/billbacks/Auto_Billback/index.cfm">Create Auto billback</A><CFELSE><font class="no_access">Create Auto billback</font></CFIF><BR> --->


<CFPARAM NAME="URL.BBID" DEFAULT="">
<CFIF URL.BBID EQ 0>	
	<CFSET URL.BBID = "">
</CFIF>
<CFPARAM NAME="FORM.BB_Code" DEFAULT="">
<CFPARAM NAME="FORM.BB_Reference" DEFAULT="">
<CFPARAM NAME="FORM.BB_Title" DEFAULT="">
<CFPARAM NAME="FORM.BB_Date" DEFAULT="#Now()#">
<CFPARAM NAME="FORM.BB_Start_Date" DEFAULT="#Now()#">
<CFPARAM NAME="FORM.BB_End_Date" DEFAULT="#Now()#">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<CFPARAM NAME="FORM.BB_Creator_Notes" DEFAULT="">
<CFPARAM NAME="FORM.comments" DEFAULT="">


<CFIF URL.BBID NEQ "">
	<CFQUERY NAME="GetAutoBB_BasicInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		* 
		FROM 		Billback
		
		WHERE 		Billback.Billback_ID = <cfqueryparam value="#URL.BBID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	
	
	<CFSET FORM.BB_Code = GetAutoBB_BasicInfo.BB_Code>
	<CFSET FORM.BB_Reference = GetAutoBB_BasicInfo.BB_Reference>
	<CFSET FORM.BB_Title = GetAutoBB_BasicInfo.BB_Title>
	<CFSET FORM.BB_Date = GetAutoBB_BasicInfo.BB_Date>
	<CFSET FORM.BB_Start_Date = GetAutoBB_BasicInfo.BB_Start_Date>
	<CFSET FORM.BB_End_Date = GetAutoBB_BasicInfo.BB_End_Date>	
	<CFSET FORM.BB_Creator_Notes = GetAutoBB_BasicInfo.BB_Creator_Notes>
	<CFSET FORM.comments = GetAutoBB_BasicInfo.Comments>	
</CFIF>

<CFIF FORM.BB_Code EQ "">
	<cfinclude template="/billbacks/capture/billback_number_generator.cfm">
	<CFSET FORM.BB_Code = generator_billback_number>
</CFIF>

<CFSET InfoBar_BBID = URL.BBID>
<cfinclude template="/billbacks/capture/billback_load_infobar.cfm">
		
<STYLE TYPE="text/css">
.DataTitleCell {
	text-align : right;
	font-weight : bold;
	vertical-align : top;
}
TABLE.UnderLined TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>




<CFOUTPUT>

<FORM NAME="AutoBB_BasicInfo" ACTION="index.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="BBID" VALUE="#URL.BBID#">
<INPUT TYPE="Hidden" NAME="BB_Code" VALUE="#FORM.BB_Code#">
<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="10" ALIGN="Center">
	<TR>
		<TD CLASS="DataTitleCell">Payable Number:</TD>
		<TD ROWSPAN="100%" BGCOLOR="0000CC" WIDTH="2px"></TD>
		<TD STYLE="font-size: 20px; font-weight: bold;">#FORM.BB_Code#</TD>
	</TR>	
	<TR>
		<TD CLASS="DataTitleCell"><span id="error_BB_Reference"></span>&nbsp;Billback Number:</TD>
		<TD><input name="BB_Reference" type="Text" value="#FORM.BB_Reference#" size="55" maxlength="64"></TD>
	</TR>
	<TR>
		<TD CLASS="DataTitleCell"><span id="error_BB_Title"></span>&nbsp;Billback Title:</TD>
		<TD><input name="BB_Title" type="Text" value="#FORM.BB_Title#" size="55"  maxlength="64"></TD>
	</TR>
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Date"></span>&nbsp;Billback Date:</TD>
		<TD><CF_EASYDATE FORMNAME="AutoBB_BasicInfo" FIELDNAME="BB_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.BB_Date#"></TD>
	</TR>
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Start_Date"></span>&nbsp;<span id="error_BB_End_Date"></span>&nbsp;Delivery Period Start\End:</TD>
		<TD>
			<TABLE>
				<TR>
					<TD><CF_EASYDATE FORMNAME="AutoBB_BasicInfo" FIELDNAME="BB_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.BB_Start_Date#"></TD>
					<TD>&nbsp;&nbsp;to&nbsp;&nbsp;</TD>
					<TD><CF_EASYDATE FORMNAME="AutoBB_BasicInfo" FIELDNAME="BB_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.BB_End_Date#"></TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
		
	
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Notes"></span>&nbsp;Notes:</TD>
		<TD><CF_SCALABLETEXTAREA 
				NAME="BB_Creator_Notes" 
				ID="BB_Creator_Notes"
				COLS="57" 
				ROWS="5" 
				incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">" 
				decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">">#Form.BB_Creator_Notes#</CF_SCALABLETEXTAREA>
			</TD>
	</TR>
	<TR>
		<TD class="DataTitleCell"><span id="error_Comments"></span>&nbsp;<B>Comments:</B><BR><span style="color:red;font-size:10px;">only visible internally</span></TD>
		<TD>
			<CF_SCALABLETEXTAREA 
				NAME="comments" 
				ID="comments"
				COLS="57" 
				ROWS="5" 
				incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">" 
				decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">"><CFOUTPUT>#Form.Comments#</CFOUTPUT></CF_SCALABLETEXTAREA>	
		<!--- <cf_scalabletextarea NAME="notes"><CFOUTPUT>#Form.Notes#</CFOUTPUT></cf_scalabletextarea> --->
		</TD>
	</TR>	
	<TR>
		<TD COLSPAN="2"></TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"CheckForErrors();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>			
		</TD>
	</TR>
</TABLE>
</FORM>
</CFOUTPUT>



<SCRIPT LANGUAGE="JavaScript">


function CheckForErrors() 
{
	todaysDate = new Date();
	
	ErrorCount = 0;
	
	error_text 		= "Please enter a billback number.";
	error_oSpan 	= document.all.error_BB_Reference;
	<!---  Reference Number (Text Length) --->
	if(document.all.BB_Reference.value.length == 0) 
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);
	}			
	
	
	error_text 		= "Please enter a billback title";
	error_oSpan 	= document.all.error_BB_Title;
	<!--- Billback Title (Text Length) --->
	if(document.all.BB_Title.value.length == 0) 
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);
	}					
	
	error_text 		= "The delivery period end date must be after the delivery period start date";
	error_oSpan 	= document.all.error_BB_Start_Date;
	if(checkDate(document.all.BB_Start_Date.value, document.all.BB_End_Date.value) <= 0)			
	{
		clearQueue(error_oSpan);
	}
	else
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	
	
	if(ErrorCount == 0) 
	{
		document.AutoBB_BasicInfo.action = "Save_AutoBB_BasicInfo.cfm";	
		document.AutoBB_BasicInfo.submit()
	}
	else 
	{
		showMessageWindow()
	}		
}	
</SCRIPT>
<CF_MessageWindow>

<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
 
<SCRIPT>
function checkDate(dateStr1,dateStr2)
{
 var dateSplit; 
 var retVal = null;
 dateSplit = dateStr1.split("/"); 
 if(dateSplit.length > 2)
 {
  var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
  dateSplit = dateStr2.split("/");
  if(dateSplit.length > 2)
  {
   var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
   retVal = days_between(date1, date2, true);
  }
 }
 return retVal;
}
</SCRIPT>




</body>
</html>
