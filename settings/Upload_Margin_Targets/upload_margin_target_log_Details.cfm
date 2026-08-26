<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFIF isdefined("url.Generic_Files_Upload_Log_ID")>
<cfset qGetLogDetails = uploadmargintargetManager.GetLogDetails(Generic_Files_Upload_Log_ID)>
</CFIF>

<CFIF isdefined("url.Margin_Target_Temp_Valid_Id")>
<cfset qGetLogDetails = uploadmargintargetManager.GetItemNotfoundDetails(Margin_Target_Temp_Valid_Id,filetype)>
</CFIF>


<BR>
<CFOUTPUT query="qGetLogDetails">
<CFIF url.Show_Tab EQ 5>
	<CFSET querycolumnlist = "GDWL4_ID,GDWL4_DESCRIPTION,GDW4_OI_TARGET">
	<cfset formatlist= "">
<CFELSEIF url.Show_Tab EQ 6>
	<CFIF isdefined("url.Margin_Target_Temp_Valid_Id")>
		<CFSET querycolumnlist = "ITEM_NUMBER,ITEM_FOB_BASE_PRICE,ITEM_FOB_CASH_DISCOUNT,ITEM_FOB_BASE_AFTER_DISCOUNT,ITEM_DEL_BASE_PRICE,ITEM_DEL_CASH_DISCOUNT,ITEM_DEL_BASE_AFTER_DISCOUNT,ITEM_DEFAULT_TYPE,FOB_ITEM_OI_TARGET,DEL_ITEM_OI_TARGET">
		<cfset formatlist = "ITEM_FOB_BASE_PRICE,ITEM_FOB_CASH_DISCOUNT,ITEM_FOB_BASE_AFTER_DISCOUNT,ITEM_DEL_BASE_PRICE,ITEM_DEL_CASH_DISCOUNT,ITEM_DEL_BASE_AFTER_DISCOUNT,FOB_ITEM_OI_TARGET,DEL_ITEM_OI_TARGET">
	<cfelse>
		<CFSET querycolumnlist = "ITEM_NUMBER,ITEM_BASE_PRICE,ITEM_CASH_DISCOUNT,ITEM_BASE_AFTER_DISCOUNT,ITEM_FOB_DEL,ITEM_DEFAULT_TYPE,ITEM_OI_TARGET">
		<cfset formatlist = "ITEM_BASE_PRICE,ITEM_CASH_DISCOUNT,ITEM_BASE_AFTER_DISCOUNT,ITEM_OI_TARGET">
	</cfif>
	
</CFIF>


<B><FONT COLOR="red" SIZE="2">[ </FONT><A Href="index.cfm?show_tab=#URL.Show_Tab#">back to log list</A><FONT COLOR="red" SIZE="2"> ]</FONT></B>

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>
	<TR>		
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<FONT COLOR="Red"><B>Invalid Reason:</B></FONT></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
		<FONT COLOR="Red"><B><CFIF isdefined("url.Margin_Target_Temp_Valid_Id")>
		Item Not Found In DB.
<CFELSE>#qGetLogDetails.InvalidReason#</CFIF></B>&nbsp;&nbsp;</FONT></TD>		
	</TR>
	<cfloop list="#querycolumnlist#" index="colname">
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>#colname#:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><CFIF #evaluate("qGetLogDetails.#colname#")# EQ "">NULL<CFELSE>
<cfif LISTFINDNOCASE(formatlist,colname,"," )>
	<cfif isnumeric(#evaluate("qGetLogDetails.#colname#")#)>
	#trim(numberformat(evaluate("qGetLogDetails.#colname#"),'_-___,___,___,___,___.____'))#
	<cfelse>
		#evaluate("qGetLogDetails.#colname#")#
	</cfif>
<cfelse>
#evaluate("qGetLogDetails.#colname#")#
</cfif>
</CFIF>&nbsp;&nbsp;</TD>
	</TR>
	</cfloop>
<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>
</TABLE>
</CFOUTPUT>