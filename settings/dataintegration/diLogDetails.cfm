<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=38>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFPARAM name="URL.logitem" default="">
<CFPARAM name="URL.logID" default="">
<CFPARAM name="Form.logitem" default="">
<CFPARAM name="Form.logID" default="">


<SCRIPT LANGUAGE="Javascript">

function verifyData()
{
	var thisForm = document.diLogDetailsForm;
	var bErr = false;
	var sErr= "";
	
	if(bErr)
	{
		showMessageWindow();
	}
	else
	{
		thisForm.submit();	
	}
}
</SCRIPT>
	

<CFSET diThisPage="#diLogDetailsPage#">
<CFINCLUDE template="diHeader.cfm">


	<CFOUTPUT>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#diLogListPage#?logitem=#URL.logitem#&thisPage=#URL.thisPage#">
					back to #URL.logitem#
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFOUTPUT>

<TABLE ALIGN="center" BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="100%">
<TR>
<TD>
<cfoutput>
<CFIF (ListLen(logTables,",") EQ ListLen(logItems,",")) AND (ListLen(logTables,",") EQ ListLen(originalDB,","))>
		<cfset bErr=false>
		<cfset sErr="">		
		<CFIF isDefined("fromAction")>
			<CFSET logItemName=Form.logitem>
			<cfset thisLogID=Form.logID>
			<CFIF isDefined("sActionErr")>
			<CFSET sPageErr=true>
			 <TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
			<TD>		
			<FONT SIZE="2"><B>
			Update failed. Some of the fields are either missing or invalid.
			</B></FONT>
			</TD>
			</TD>
			</TR>
			</TABLE>
			 </CFIF>
		<CFELSE>
			<CFSET logItemName=URL.logitem>
			<cfset thisLogID=URL.logID>
		</CFIF>
		
		<!---<cfset thisLogtableIndex=ListFindNoCase(logTables, thisLogtable,",")>--->
		
		<cfset thisLogtableIndex=ListFindNoCase(logItems, logItemName,",")>
		<cfif NOT thisLogtableIndex>
			<cfset bErr=true>
			<CFSET sPageErr=true>
			<cfset sErr="#sErr#Log Item name not found in the available list. ">
			<cfset writeToErrorMessage("Log Item name not found in the available list","error_logDetails")>
		</cfif>
		
		<cfif NOT isNumeric(thisLogID)>
			<CFSET sPageErr=true>
			<CFSET bErr=true>
			<cfset sErr="#sErr#<br>Invalid Log ID. ">
			<cfset writeToErrorMessage("Invalid Log ID","error_logDetails2")>
		<cfelse>
			<cfset thisLogID=Val(thisLogID)>
		</cfif>
		<span id="error_logDetails"></span>&nbsp;	<span id="error_logDetails2"></span>&nbsp;	
		<cfif NOT bErr>			
			<CFSET thisLogtable=ListGetAt(logTables,thisLogtableIndex,",")>
			<cfset idName="Log_#logItemName#_id">
			
			<CFQUERY NAME="q_diLogFields" datasource="#application.datasource#">
			SELECT lower(column_name) as column_name,data_type,character_maximum_length
		    FROM information_schema.columns 
		    WHERE table_name='#thisLogtable#'
			</CFQUERY>
			
			<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
				SELECT *
			    FROM #thisLogtable#
				where #idName#=#thisLogID#
			</CFQUERY>
			<CFIF q_diLogData.recordCount GT 0>
			
				<CFSET Err_Number=q_diLogData.Err_Number>
				<CFSET Err_Message=q_diLogData.Err_Message>
				<CFSET Err_Column=q_diLogData.Err_Column>
				<TABLE WIDTH="60%" ALIGN="CENTER" CELLSPACING=0 CELLPADDING=0 BORDER=0>
				<TR>
					<TD BGCOLOR="red">&nbsp;</TD>
					<TD>&nbsp;&nbsp;Columns that caused the error</TD>
				</TR>
				<TR>
					<TD COLSPAN=2>&nbsp;</TD>
				</TR>
				<TR>
					<TD COLSPAN=2><font class="fc_red"><b>#Err_Message#</b></font></TD>
				</TR>
				</TABLE>
				<CF_DI_CUST_SETTING_NAME 
					DI_keyword="#logItemName#" 
					ReturnField="Cust_Setting_Item_Name">
				<TABLE WIDTH="80%" ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="0">
				<caption><b>#Cust_Setting_Item_Name#</b></caption>				
				
				<!-----<CFQUERY NAME="q_diDBData" datasource="#application.datasource#">
					SELECT #Evaluate("DB#logItemName#Fields")#
					FROM #ListGetAt(originalDB,thisLogtableIndex,",")#
					WHERE #ListGetAt(originalDBIDFields,thisLogtableIndex,",")#='#Evaluate("q_diLogData.#ListGetAt(logTableIDFields,thisLogtableIndex,",")#")#'
				</CFQUERY>------->
				
				<CFSET logIDVal=ListGetAt(logTableIDFields,thisLogtableIndex,",")>
				<CFSET sSql=ReplaceNoCase(Evaluate("DB#logItemName#SQL"),"--id--",Evaluate("q_diLogData.#ListGetAt(logIDVal,1,":")#"))>
				<CFIF ListLen(logIDVal,":") GT 1>
					<CFSET sSql=ReplaceNoCase(sSql,"--id1--",Evaluate("q_diLogData.#ListGetAt(logIDVal,2,":")#"))>
				</CFIF>
				
				<CFIF ListLen(logIDVal,":") GT 2>
					<CFSET sSql=ReplaceNoCase(sSql,"--id2--",Evaluate("q_diLogData.#ListGetAt(logIDVal,3,":")#"))>
				</CFIF>				
				
				<CFQUERY NAME="q_diDBData" datasource="#application.datasource#">
					#PreserveSingleQuotes(sSql)#
				</CFQUERY>	
				<!-----<HR>
				#sSql#
				<HR>------->
								
				<TR BGCOLOR="##FFCE84">
				<TD></TD>
				<TD COLSPAN=2 ALIGN="CENTER"><B>Log Data</B></TD>
				<cfif q_diDBData.recordCount GT 0>
					<TD COLSPAN="2" ALIGN="CENTER"><B>Existing Data</B></TD>
				<cfelse>
					<TD ROWSPAN="100%" VALIGN="TOP" BGCOLOR="Whitesmoke"><B>No Existing data found</B></TD>
				</cfif>
				</TR>
				<TR>
				<TD CLASS="labelStyle"></TD>
				<TD ROWSPAN="100%" BGCOLOR="Navy" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
				<TD></TD>
				<cfif q_diDBData.recordCount GT 0>
					<TD ROWSPAN="100%" BGCOLOR="Navy" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
					<TD></TD>
				</cfif>
				</TR>				
					<!-----<cfloop index="field" list="#q_diLogData.columnList#" delimiters=",">---->
					<cfloop query="q_diLogFields">
					<cfset field=UCase(column_name)>
					
					<cfif isDefined("q_diLogData.#field#")>					
						<cfset thisFieldValue=Evaluate("q_diLogData.#field#")>
						<CFSET formattedThisValue = thisFieldValue>
						<CFSET formattedThisValue = ReplaceNoCase(formattedThisValue, "0", "", "All")>
						<CFSET formattedThisValue = Trim(formattedThisValue)>
						<CFSET formattedThisValue = REReplaceNoCase(formattedThisValue, "^.$", "", "All")>
						<!----
						<CFIF ListFindNoCase(Err_Column, field,", ") AND ((ListLen(Err_Column,", ") LTE 1) OR ((ListLen(Err_Column,", ") GT 1) AND ((Len(Trim(ReplaceNoCase(thisFieldValue,"0","","All"))) EQ 0) OR (1 EQ 2))))>
						----->
						<CFIF ListFindNoCase(Err_Column, field,", ") AND ((ListLen(Err_Column,", ") LTE 1) OR ((ListLen(Err_Column,", ") GT 1) AND (Len(formattedThisValue) EQ 0)))>
							<TR BGCOLOR="red">
						<CFELSE>
							<TR>
						</CFIF>					
							<cfif (NOT FindNoCase("#idName#", field)) AND (LCase(Left(field,4)) NEQ "err_")>
								<!-----<cfset colSize=25>					
								<CFQUERY dbtype="query" name="q_fieldLen">
								SELECT character_maximum_length as maxLen
								FROM q_diLogFields
								WHERE column_name='#LCase("#field#")#'
								</CFQUERY>
								<cfif q_fieldLen.recordCount GT 0>
									<cfset colSize=q_fieldLen.maxLen>
								</cfif>			------->
								<TD CLASS="labelStyle"><b><cfif UCase(field) EQ "FILLER">UPDATEINDICATOR<cfelse>#field#</cfif></b></TD>
								<TD>								
								<!---<input type="textbox" name="#field#" class="input_textbox_input" value="#Trim(Evaluate("q_diLogData.#field#"))#" MAXLENGTH="#colSize#" SIZE="#colSize#">--->
								<font class="comment">
									<b>#Replace(thisFieldValue, " ", "&nbsp;","All")#</b>
									</font>
								</TD>								
								<cfif q_diDBData.recordCount GT 0>
								<TD BGCOLOR="WhiteSmoke">
								<cfset logFieldIndex=ListFindNoCase(Evaluate("Log#logItemName#Fields"), field,",")>									
									<cfif logFieldIndex>
									<font class="comment">
									<!-----<b>#Replace(Evaluate("q_diDBData.#ListGetAt(Evaluate("DB#logItemName#Fields"),logFieldIndex,",")#"), " ", "&nbsp;","All")#</b>------->
									<cfset dbFldName=ListGetAt(Evaluate("DB#logItemName#Fields"),logFieldIndex,",")>
									<cfif ListLen(dbFldName,".") GT 1>
										<cfset dbFldName=ListGetAt(dbFldName,2,".")>
									</cfif>
									<b>#Replace(Evaluate("q_diDBData.#dbFldName#"), " ", "&nbsp;","All")#</b>
									<!---<input type="textbox" class="input_textbox_input" disabled value="#Evaluate("q_diDBData.#ListGetAt(Evaluate("DB#logItemName#Fields"),logFieldIndex,",")#")#">--->
									</font>
									<cfelse>&nbsp;
									</cfif>
									</TD>
								</cfif>											
							</cfif>
						</TR>
					</cfif>
					
					</cfloop>
					<!----
				</cfloop>
				--->
				</TABLE>
				<BR>
				
			</CFIF>
		<cfelse>
			<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
			<TD>		
			<FONT SIZE="2"><B>
			#sErr#
			</B></FONT>
			</TD>
			</TD>
			</TR>
			</TABLE>
		</cfif>
		
</CFIF>
</cfoutput>
	
</TD>
</TR>
</TABLE>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_MessageWindow>
<CFIF isDefined("sPageErr")>
	<SCRIPT LANGUAGE="JavaScript">
		showError();		
	</SCRIPT>
</CFIF>
</BODY>
</HTML>
