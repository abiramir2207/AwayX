<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="dataIntBasicInfo_Include.cfm">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=38>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->

<CFPARAM name="diServer_Name" default="">
<CFPARAM name="File_Location" default="">
<CFPARAM name="Email_Address" default="">
<CFPARAM name="File_Creation_Time" default="">

<!----<CFPARAM name="Commodity_Time" default="">--->
<!----<CFPARAM name="Commodity_Pick_Time" default="">---->


<CFPARAM name="diUserName" default="">
<CFPARAM name="Setting_Date" default="">


<CFSET dbBasicInfoExist = false>
<CFSET Brokers=false>
<CFSET Distributors=false>
<CFSET Products=false>
<CFSET diLogExist = false>




<!-----------------------------------------
Get DataIntegration Basic Information from database
------------------------------------------>
<CFQUERY NAME="q_Data_Integration_Read" datasource="#application.datasource#">
		Select 		di.*,u.Name_First + ' ' + u.Name_Last as uName
		From 		DataInt_Settings di left join _users u
		on 			u.user_id = di.User_ID
		where			di.Dataint_setting_ID =
			(Select 	max(Dataint_setting_ID)
			From 		DataInt_Settings)
</CFQUERY>

<CFIF q_Data_Integration_Read.recordCount GT 0>
	<CFSET diServer_Name=q_Data_Integration_Read.Server_Name>
	<CFSET File_Location=q_Data_Integration_Read.File_Location>
	<CFSET Email_Address=q_Data_Integration_Read.Email_Address>

	<CFSET tempTextTime=q_Data_Integration_Read.File_Creation_Time>		
	<!---<CFSET File_Creation_Time=getAMPMTime("#Left(tempTextTime,2)#:#Mid(tempTextTime,3,2)#:#Mid(tempTextTime,5,2)#","")>--->
	<CFIF Len(tempTextTime) GTE 6>
		<CFSET File_Creation_Time="#Left(tempTextTime,2)#:#Mid(tempTextTime,3,2)#:#Mid(tempTextTime,5,2)#">
	<CFELSE>
		<CFSET File_Creation_Time="">
	</CFIF>
	<!-----------
	<CFSET tempCommodity_Time=Trim(q_Data_Integration_Read.Commodity_Time)>
	<CFIF Len(tempCommodity_Time) GTE 6>
		<CFSET Commodity_Time="#Left(tempCommodity_Time,2)#:#Mid(tempCommodity_Time,3,2)#:#Mid(tempCommodity_Time,5,2)#">
	<CFELSE>
		<CFSET Commodity_Times="">
	</CFIF>
	
	<CFSET tempCommodity_Pick_Time=Trim(q_Data_Integration_Read.Commodity_Pick_Time)>
	<CFIF Len(tempCommodity_Pick_Time) GTE 6>
		<CFSET Commodity_Pick_Time="#Left(tempCommodity_Pick_Time,2)#:#Mid(tempCommodity_Pick_Time,3,2)#:#Mid(tempCommodity_Pick_Time,5,2)#">
	</CFIF>
	--------------->
	
	<CFSET Setting_Date=q_Data_Integration_Read.Setting_Date>
	<CFSET diUserName=q_Data_Integration_Read.uName>
	<CFIF Len(diUserName) GT 0>
		<CFSET dbBasicInfoExist = true>
	</CFIF>
</CFIF>
	
<!-----------------------------------------
End - Get DataIntegration Basic Information from database
------------------------------------------>


<CFSET noAction=false>
<CFIF isDefined("action")>
	<CFIF action EQ "showError">		
		<CFSET Email_Address=Form.Email_Address>
		
		<CFSET tempTextTime=Form.textFileTime>
		<CFIF Len(tempTextTime) GTE 6>
			<CFSET File_Creation_Time="#Left(tempTextTime,2)#:#Mid(tempTextTime,3,2)#:#Mid(tempTextTime,5,2)#">	
		<CFELSE>
			<CFSET File_Creation_Time="">
		</CFIF>
		
		<!------------
		<CFSET tempCommodity_Time=Form.Commodity_Pick_Time>
		<CFIF Len(tempCommodity_Time) GTE 6>
			<CFSET Commodity_Pick_Time="#Left(tempCommodity_Time,2)#:#Mid(tempCommodity_Time,3,2)#:#Mid(tempCommodity_Time,5,2)#">
		<CFELSE>
			<CFSET Commodity_Pick_Time="">
		</CFIF>
		---------->
	</CFIF>
</CFIF>





<!-----------------------------------------
Check whether there is entry for brokers, distributors and products
------------------------------------------>


<CFQUERY NAME="q_Data_Integration_Exists" datasource="#application.datasource#">
		select distinct Integration_Type
		From Data_Integration
	</CFQUERY>
	
	<cfloop query="q_Data_Integration_Exists">
		<cfswitch expression="#Integration_Type#">
				<cfcase value="Brokers">
					<CFSET Brokers=true>
				</cfcase>
				<cfcase value="Distributors">
					<CFSET Distributors=true>
				</cfcase>
				<cfcase value="Products">
					<CFSET Products=true>
				</cfcase>
		</cfswitch>
	</cfloop>
<!-----------------------------------------
End - Check whether there is entry for brokers, distributors and products
------------------------------------------>

<!--------------------------------------
Get DILogExist from database
--------------------------------------->

<CFOUTPUT>
<CFQUERY NAME="q_DILog_Exists" datasource="#application.datasource#">
select (select count(*) from #ListChangeDelims(logTables, " ) + ( select count(*) from ",",")#) as cnt
</CFQUERY>
</CFOUTPUT>
<CFIF q_DILog_Exists.recordCount GT 0>
	<CFIF q_DILog_Exists.cnt>
		<CFSET diLogExist=true>
	</CFIF>
</CFIF>
<!--------------------------------------
End Get DILogExist from database
--------------------------------------->


<SCRIPT language="JavaScript" SRC="commonFunctions.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript">

<CFOUTPUT>
var diStartTime = "#diMinStartTime#";
var diMaxStartTime = "#diMaxStartTime#";
<!--------------
var commMinTime = "#Commodity_Time#";
var commMaxTime = "#commMaxTime#";
------------->
</CFOUTPUT>



function verifyData() 
{
	var isClear = true;
	var thisForm = document.dataIntegrationBasicInfoForm;
	//thisForm.textFileTime.value = thisForm.textFileTime1.value;
	//thisForm.Commodity_Pick_Time.value = thisForm.Commodity_Pick_Time1.value;
	
	
	//thisForm.submit();
	//return true;
	/////////////////////////////////
	///////validate Email Address
	
	var validEmailAdd = checkMultipleEmail(thisForm.Email_Address);
	if(validEmailAdd!=true)
	{
		queueMessage("Invalid Email Address '" + validEmailAdd + "'", document.all.error_Email_Address);
		isClear = false;
	}
	else if(thisForm.Email_Address.value.length >= 4000)
	{
		queueMessage("Email Address exceeds available size limit", document.all.error_Email_Address);
		isClear = false;
	}
	else
	{
		clearQueue(document.all.error_Email_Address);
	}
	
	/////////////////Validate Text File Creation Time
	//textFileTime
	//if()
	var sfileTimeErr = "";
	var bfileTimeErr = false;
	var tFileTime = thisForm.textFileTime.value;
	var txtFileTime = getMilitaryTime(tFileTime);
	if(txtFileTime!=false)
	{	
		var txtTime = txtFileTime.split(":");	
		var diSTime = diStartTime.split(":");
		var diMTime = diMaxStartTime.split(":");		
		
		if(!((checkTimelessThan(txtTime,diSTime) || checkTimelessThan(diMTime,txtTime))) && checkTimelessThan(diSTime,diMTime))
		{
			bfileTimeErr = true;
			sfileTimeErr = "Text File should be Created before the Data Integration Start Time '<CFOUTPUT>#getAMPMTime(diMinStartTime,"")#</CFOUTPUT>' and after Data Integration End Time '<CFOUTPUT>#getAMPMTime(diMaxStartTime,"")#</CFOUTPUT>'";
		}
		else if(!((checkTimelessThan(txtTime,diSTime) && checkTimelessThan(diMTime,txtTime))) && checkTimelessThan(diMTime,diSTime))
		{
			bfileTimeErr = true;
			sfileTimeErr = "Text File should be Created before the Data Integration Start Time '<CFOUTPUT>#getAMPMTime(diMinStartTime,"")#</CFOUTPUT>' and after Data Integration End Time '<CFOUTPUT>#getAMPMTime(diMaxStartTime,"")#</CFOUTPUT>'";
		}
		/*
		if(checkTimelessThan(diSTime,txtTime))
		{
			bfileTimeErr = true;
			sfileTimeErr = "Text File should be Created before the Data Integration Start Time '<CFOUTPUT>#getAMPMTime(diMinStartTime,"")#</CFOUTPUT>'";
		}
		*/
	}
	else
	{
		bfileTimeErr = true;
		sfileTimeErr = "Invalid Text File Creation Time '" + tFileTime + "'";
	}
	if(bfileTimeErr)
	{
		isClear = false;		
		queueMessage(sfileTimeErr, document.all.error_TextFile_Time);
	}
	else
	{
		clearQueue(document.all.error_TextFile_Time);		
	}
	
	/*
	var sCommTimeErr = "";
	var bCommTimeErr = false;
	var tCommTime = thisForm.Commodity_Pick_Time1.value;
	txtFileTime = getMilitaryTime(tCommTime);

	
	if(txtFileTime!=false)
	{	
		var txtTime = txtFileTime.split(":");	
		var diSTime = commMinTime.split(":");
		var diMTime = commMaxTime.split(":");		
	
		
		/////////
		///problem here	
		//if(!((checkTimelessThan(txtTime,diSTime) || checkTimelessThan(diMTime,txtTime))) && checkTimelessThan(diSTime,diMTime))
		if(!(checkTimelessThan(txtTime,diMTime) && checkTimelessThan(diSTime,txtTime)) && checkTimelessThan(diSTime,diMTime))
		{
			bCommTimeErr = true;
			<!---
			sCommTimeErr = "Commodity Time should be in the interval '<CFOUTPUT>#getAMPMTime(Commodity_Time,"")#</CFOUTPUT>' to '<CFOUTPUT>#getAMPMTime(commMaxTime,"")#</CFOUTPUT>'";
			---->
		}
		else if(!(checkTimelessThan(txtTime,diMTime) || checkTimelessThan(diSTime,txtTime)) && (checkTimelessThan(diMTime,diSTime)))
		{			
			bCommTimeErr = true;
			<!--------
			sCommTimeErr = "Commodity Time should be in the interval '<CFOUTPUT>#getAMPMTime(Commodity_Time,"")#</CFOUTPUT>' to '<CFOUTPUT>#getAMPMTime(commMaxTime,"")#</CFOUTPUT>'";
			----->
		}
	}
	else
	{
		bCommTimeErr = true;
		sCommTimeErr = "Invalid Commodity Time '" + tCommTime + "'";
		alert("1");
	}
	
	
	if(bCommTimeErr)
	{
		isClear = false;		
		queueMessage(sCommTimeErr, document.all.error_CommFile_Time);
	}
	else
	{
		clearQueue(document.all.error_CommFile_Time);
	}
	
	*/
	
	if(!isClear)
	{
		showMessageWindow();
	}
	else
	{
		thisForm.submit();
		//showMessageWindow();
		//alert("submit");
	}
}

function checkEmail(email) {
  if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)){
    return (true)
  }
  return (false)
}


function checkMultipleEmail(emailTextBox) 
{
  var separator = ";";
  var emails2 = emailTextBox.value.split(separator);
  var anyEmail = false;
	for(var i=0; i<emails2.length; i++) 
	{
		//emails2[i] = emails2[i].replace(/(^ )|( $)/g, ""); //trim spaces
		//alert((/(^ )|( $)|(\r\n)/.test(emails2[i])));
		
		//emails2[i] = emails2[i].replace(/(^ )|( $)/g, ""); //trim spaces
		//emails2[i] = emails2[i].replace(/(^\r\n)|(\r\n$)/g, ""); //trim \r\n
		
		emails2[i] = emails2[i].replace(/(^ *(\r\n)* *)|( *(\r\n)* *$)/g, ""); //trim spaces and enters
		
		tempEmail = checkEmail(emails2[i])
		if(!tempEmail) 
		{
		return emails2[i];
		} 		
	}
	return true;
 }
 
</SCRIPT>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--------------------------------
Show Tabs
----------------------------------->
<!----------------------------------------
<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
	<TR>
		<TD><IMG SRC="/images/fill.gif" WIDTH="20" HEIGHT="1"></TD>
		<TD><IMG SRC="/images/tabs/left.gif"></TD>
		<TD>
		<CFIF dbBasicInfoExist>
			<IMG SRC="/images/tabs/gi_1_1.gif" BORDER="0">
		<CFELSE>
			<IMG SRC="/images/tabs/gi_1_0.gif" BORDER="0">
		</CFIF>
		
		</TD>
		<TD>			
		<CFIF Brokers>
			<CFSET imgPart="_1">			
		<CFELSE>
			<CFSET imgPart="_0">			
		</CFIF>		
		
			<CFSET imgPart="_0#imgPart#">
			<CFOUTPUT>
			<A HREF="#diPage#?diType=Brokers"><IMG SRC="/images/tabs/br#imgPart#.gif" BORDER="0"></A>
			</CFOUTPUT>
		
		</TD>
		<TD>		
		<CFIF Distributors>
			<CFSET imgPart="_1">
		<CFELSE>
			<CFSET imgPart="_0">
		</CFIF>
		
			<CFSET imgPart="_0#imgPart#">
			<CFOUTPUT>
			<A HREF="#diPage#?diType=Distributors"><IMG SRC="/images/tabs/di#imgPart#.gif" BORDER="0"></A>
		</CFOUTPUT>
		
		</TD>
		<TD>		
		<CFIF Products>
			<CFSET imgPart="_1">
		<CFELSE>
			<CFSET imgPart="_0">
		</CFIF>
		
			<CFSET imgPart="_0#imgPart#">
			<CFOUTPUT>
			<A HREF="#diPage#?diType=Products"><IMG SRC="/images/tabs/pr#imgPart#.gif" BORDER="0"></A>
			</CFOUTPUT>
		
		</TD> 		
		<TD><IMG SRC="/images/tabs/right.gif"></TD>
	</TR>
</TABLE>
---------------------------------------->

<!------------------------------
<!---------------new tabs------------------------------->
<STYLE TYPE="text/css">
TD.foreground
	{
		border-left :		1px solid #31009C;
		border-right :		1px solid #31009C;
		border-top :		1px solid #31009C;
	}
TD.background
	{
		border-left:		1px solid #FFFFFF;
		border-right:		1px solid #FFFFFF;
	}
A.tablink_back
	{
		color: 				#FFFFFF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:VISITED.tablink_back
	{
		color: 				#FFFFFF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:VISITED.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}

</STYLE>
<cfoutput>
<BR><BR>
<TABLE border="0" width="100%" cellspacing="0" cellpadding="2">
<COLGROUP>
<COL SPAN="5" WIDTH="20%">
</COLGROUP>
	<TD CLASS="foreground" BGCOLOR="FFFFFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF dbBasicInfoExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><font CLASS="tablink_fore">basic Info</font></B></TD>
	<TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Brokers>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Brokers" CLASS="tablink_back">brokers</A></B></TD>
	<TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Distributors>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Distributors" CLASS="tablink_back">distributors</A></B></TD>
	<TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Products>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Products" CLASS="tablink_back">products</A></B></TD>
	<TD CLASS="foreground" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF diLogExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diLogPage#" CLASS="tablink_back">Log</A></B></TD>
</TABLE>
<BR>
</cfoutput>

<!--------------------------------
End - Show Tabs
----------------------------------->
---------------------------->


<CFSET diThisPage="#basicInfoPage#">
<CFINCLUDE template="diHeader.cfm">

<CFIF isDefined("sErr")>
	<BR>
	<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Update failed. Some of the fields are either missing or invalid.
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
	</TABLE>
<CFELSE>

<!-------------------------------------------
Show the last update user information
---------------------------------------------->
<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		<CFIF Len(diUserName) GT 0>
		The Data Integration Basic Settings were last updated on #Setting_Date# by #diUserName#
		<CFELSE>
		Previous update information for Data Integration Basic Setting not found
		</CFIF>
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
</TABLE>
<!-------------------------------------------
End - Show the last update user information
---------------------------------------------->
</CFIF>

	<CFOUTPUT>
	<FORM ACTION="#basicInfoActionPage#" METHOD="post" NAME="dataIntegrationBasicInfoForm" ID="dataIntegrationBasicInfoForm">		
		<TABLE CELLSPACING=0 CELLPADDING=1 BORDER=0>
			<TR>
				<TD CLASS="labelStyle"></TD>
				<TD ROWSPAN="100%" BGCOLOR="Navy"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
				<TD></TD>
			</TR>
			<TR>
				<TD CLASS="labelStyle">&nbsp;<b>Server Name</b></TD>
				<TD><input type="textbox" class="input_textbox_input" value="#diServer_Name#" disabled="true"></TD>
			</TR>
			<TR>
				<TD CLASS="labelStyle">&nbsp;<b>Path</b></TD>
				<TD><input type="textbox" class="input_textbox_input" value="#File_Location#" disabled="true"></TD>
			</TR>
			<TR>
				<TD CLASS="labelStyle"><span id="error_Email_Address"></span>&nbsp;<b>Email Addresses</b>
			<br>Separate with <B>( ; )</B> if more then one Email Address</TD>
				<TD><TEXTAREA COLS="60" ROWS="2" NAME="Email_Address">#Email_Address#</TEXTAREA></TD>
			</TR>
			<TR>
				<TD VALIGN="TOP" CLASS="labelStyle"><span id="error_TextFile_Time"></span>&nbsp;<b>Text File creation Time (hh:mm:ss am/pm)</b></TD>
				<TD>
				<!---<input type="textbox" id="textFileTime" name="textFileTime" class="input_textbox_input" value="#File_Creation_Time#">--->
				<cf_restrictedTime name="textFileTime" hhmmss="#File_Creation_Time#" minInterval="#diMaxStartTime#" maxInterval="#diMinStartTime#" mdelta="5" showSeconds="false" Form="dataIntegrationBasicInfoForm" ImagesDir="/images/" width="70">
				<font class="di_warning">
				Select a time in the interval from <b>#getAMPMTime(diMaxStartTime,"")#</b> to <b>#getAMPMTime(diMinStartTime,"")#</b>
				 </font>
				</TD>
			</TR>
		</TABLE>		
	</FORM>	
	</CFOUTPUT>
	<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"save settings"
			BUTTON_ACTION	=	"javascript:verifyData();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_MessageWindow>
<CFIF isDefined("sErr")>
	<SCRIPT LANGUAGE="JavaScript">
		showError();		
	</SCRIPT>
</CFIF>
</BODY>
</HTML>
