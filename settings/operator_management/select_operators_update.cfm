<!---
1) If Selected = 1, only update selected values (SelectedItems)
2) If Selected = 0, update values in AllReturnedOperators.
3) If Delete_This = 1 Set deleted = 1
4) If Delete_This = 0, set deleted = 0
--->

<cfparam name="form.updateStatus" 	default="0">
<cfparam name="form.SelectedItems" default="">
<cfparam name="form.lOpsInvalidLegacyIds" default="">
<cfparam name="form.lDisplay" default="1">
<!---72360 :: Add customer label for BSA ID START --->
<cfset CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels() />
<!---72360 :: Add customer label for BSA ID END --->
<blockquote>
<Font size="+2" color="Navy">Manage <Cfoutput>#application.returned_customer_setting.operator_label_plural#</CFOUTPUT></FONT>
<hr width="100%" color="navy">
</blockquote>
<cfoutput>
<script language="JavaScript">
function activateOperators()
{
	if(window.confirm("Do you want to activate these #application.returned_customer_setting.operator_label_plural#?"))
	{
		document.frmUpdateLegacyIDForm.submit();
	}
	return false;
}
</script>
</cfoutput>
<cfif 	(form.Selected IS 1 AND len(trim(form.SelectedItems)) GT 0) OR
		(form.Selected IS 0 AND len(trim(form.AllReturnedOperators)) GT 0)
>
	<cfif Selected IS 1>
		<cfset ListofOpsToUpdate = form.SelectedItems>
	<cfelse>
		<cfset ListofOpsToUpdate = form.AllReturnedOperators>
	</cfif>
	
	<!------ If the action is deleted, there is nothing to be collected form the user, so no need to display the form ----->
	<cfif Delete_This EQ 1 AND form.updateStatus EQ 0>
		<cfset form.updateStatus  = 1 />
	</cfif>
	
	<form name="frmUpdateLegacyIDForm" method="post">
	<input type="Hidden" name="updateStatus" value="2" />
	<input type="Hidden" name="Selected" value="1" />
	<input type="Hidden" name="Delete_This" value="0" />
	<cfoutput>
	<input type="Hidden" name="SelectedItems" value="#ListofOpsToUpdate#" />
	<input type="Hidden" name="sort_by" value="#form.sort_by#" />
	</cfoutput>
	<cfif form.updateStatus EQ 0>
	
		<!------ Display the form when updateStatus = 0 ----->
		<cfoutput>
		<cfsavecontent variable="tableCaption">
		Please provide the #application.returned_customer_setting.Operator_Legacy_Id_label# and click save to activate the following <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>
		</cfsavecontent>
		</cfoutput>
	<cfelseif form.updateStatus EQ 1><!------ If updateStatus = 1 ----->

		<!------ update the operators when updateStatus = 1 ----->
		
		<cfquery name="GetOperatorNames" datasource="#application.datasource#">
			select Operator_Name
			from
			BSA_Operator
			WHERE BSA_Operator_ID IN (#ListofOpsToUpdate#)
		</cfquery>
		
		<cfset operatornamelist = "#ValueList(GetOperatorNames.Operator_Name)#">
		
		<cfloop list="#operatornamelist#" index="opr_name">
		<cfquery name="UpdateOperator" datasource="#application.datasource#">
			UPDATE BSA_Operator
			SET 	display_code = 'N',
				User_Date_Edited	= 	getdate(),
				Edited_By		= 	'#request.AccessStructure.User_ID#'
			WHERE Operator_Name = '#REReplace(opr_name, "'", "''", "ALL")#'
			and deleted = 1
		</cfquery>
		</cfloop>
		<cfquery name="UpdateOperator" datasource="#application.datasource#">
			UPDATE BSA_Operator
			SET 	Deleted = #Delete_This#,
				display_code = 'A',
				User_Date_Edited	= 	getdate(),
				Edited_By		= 	'#request.AccessStructure.User_ID#'
			WHERE BSA_Operator_ID IN (#ListofOpsToUpdate#)
		</cfquery>
		
		<cfoutput>
		<cfsavecontent variable="tableCaption">
		You <cfif Delete_This IS 1>de</cfif>activated the following <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>:
		</cfsavecontent>
		</cfoutput>
		
	<cfelse><!------ If updateStatus = 2 ----->

		<!------ go on a loop and update the operators when updateStatus = 2 ----->
		
		<cfloop list="#ListofOpsToUpdate#" index="currentOperator">
			<cfset legacyOperatorID = Form["legacyId_#currentOperator#"] />
			
			<!---check to see if the operator Legacy ID already exists--->
			<cfquery name="qCheckLegacyId" datasource="#application.datasource#">
				SELECT	Legacy_ID
				FROM 	BSA_Operator
				WHERE 	Deleted = 0
				AND		Legacy_ID = <cfqueryparam value="#trim(legacyOperatorID)#" cfsqltype="CF_SQL_VARCHAR">
				AND		BSA_Operator_ID != <cfqueryparam value="#trim(currentOperator)#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfif qCheckLegacyId.RecordCount>
				<cfset form.lOpsInvalidLegacyIds = ListAppend(form.lOpsInvalidLegacyIds, currentOperator) />
			<cfelse>
				<cfquery name="UpdateOperator" datasource="#application.datasource#">
					UPDATE 	BSA_Operator
					SET 	Deleted = 0,
						User_Date_Edited	= 	getdate(),
						Edited_By		= 	'#request.AccessStructure.User_ID#',
							Legacy_ID = <cfqueryparam value="#legacyOperatorID#" cfsqltype="CF_SQL_VARCHAR">
					WHERE 	BSA_Operator_ID = <cfqueryparam value="#currentOperator#" cfsqltype="CF_SQL_INTEGER">				
				</cfquery>
			</cfif>
		</cfloop>
		
		<cfoutput>
		<cfsavecontent variable="tableCaption">
		You <cfif Delete_This IS 1>de</cfif>activated the following <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>:
		</cfsavecontent>
		<cfsavecontent variable="invalidTableCaption">
		The <cfoutput>#application.returned_customer_setting.Operator_Legacy_Id_label#</cfoutput> you have entered for the following <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> already exist:
		</cfsavecontent>
		</cfoutput>
		
	</cfif><!------ If updateStatus = 2 ----->
	
	<cfquery name="GetOperatorInfo" datasource="#application.datasource#">
		SELECT 	* 
		FROM 	BSA_Operator 
		WHERE 	BSA_Operator_ID IN (#ListofOpsToUpdate#)
		<cfif Len(trim(form.lOpsInvalidLegacyIds))>
		AND		BSA_Operator_ID NOT IN (#form.lOpsInvalidLegacyIds#)	
		</cfif>
	</cfquery>	
	
	<!---if we have invalid operator entries then query those operators--->
	<cfif Len(trim(form.lOpsInvalidLegacyIds))>
			<cfquery name="GetInvlaidOperatorInfo" datasource="#application.datasource#">
				SELECT 	* 
				FROM 	BSA_Operator 
				WHERE 	BSA_Operator_ID IN (#form.lOpsInvalidLegacyIds#)
			</cfquery>
		<cfset form.lDisplay = ListAppend(form.lDisplay, "2") />
	</cfif>
	
	<!---loop over the display tables. one for valid entries, the other for invalid--->
	<cfloop index="tblIndx" list="#form.lDisplay#">
		<!---set variables according to valid or invalid operators--->
		<cfif tblIndx eq 1>
			<cfset tmpTableCaption = tableCaption />
			<cfset tmpGetOperatorInfo = GetOperatorInfo />
		<cfelse>
			<cfset tmpTableCaption = invalidTableCaption />
			<cfset tmpGetOperatorInfo = GetInvlaidOperatorInfo />
		</cfif>
		<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="800">
			<tr><td colspan="100%" bgcolor="lightsteelblue"><font size="2"><strong><cfoutput>#tmpTableCaption#</cfoutput></strong></font></td></tr>
			<TR ID="header" BGCOLOR="#ffce84" VALIGN="top">
				<TD align="center">&nbsp;</TD>
				<CFSET Header_Display_List = "#application.returned_customer_setting.operator_label_singular#">
				<CFSET Header_Value_List = "Operator Name">
				
				<CFSET Header_Display_List = ListAppend(Header_Display_List, "Location<BR>Type,City:State,Doing Business As,#CustomerSettingsLabels.BSA_ID_label#,#application.returned_customer_setting.Operator_Legacy_Id_label#,Active", ",")>
				<CFSET Header_Value_List = ListAppend(Header_Value_List, "Location Type,City:State,Doing Business As,BSA ID,Legacy ID,Active", ",")>
				
				<CFSET Counter = 1>
				<CFOUTPUT>
				<CFLOOP LIST="#Header_Display_List#" INDEX="This_Header" DELIMITERS=",">
					<CFSET This_Value = ListGetAt(Header_Value_List, Counter, ",")>
					<TD ID="header"><B>
					<CFSET Counter_1 = 1>
					<CFLOOP LIST="#This_Header#" INDEX="Each_Token" DELIMITERS=":">
						<CFSET This_Value_Token = ListGetAt(This_Value, Counter_1, ":")>
						<CFIF Counter_1 GT 1>
						<BR>/
						</CFIF>
						<CFSET Next_Sort_Item = This_Value_Token>
						<CFSET Next_Sort_Order = "ASC">
						<CFSET Img_String = "">
						<CFIF CompareNoCase(This_Value_Token, FORM.sort_by) EQ 0><!--- current sort --->
							<CFIF FORM.sort_Order EQ "ASC"><!--- current sort --->
								<CFSET Next_Sort_Order = "DESC">
								<CFSET Img_String = "<IMG SRC=""/Images/down_1.gif"">">
							<CFELSE>
								<CFSET Img_String = "<IMG SRC=""/Images/up_1.gif"">">
							</CFIF>
						</CFIF>
						<CFIF Trim(Next_Sort_Item) NEQ "">
					
						</CFIF>
						#Each_Token#
						<CFIF Trim(Next_Sort_Item) NEQ "">
						 #Img_String#
						</CFIF>
						<CFSET Counter_1 = Counter_1 + 1>
					</CFLOOP>
					</B></TD>
					<CFSET Counter = Counter + 1>
				</CFLOOP>
				</CFOUTPUT>
			</TR>
	
		<CFOUTPUT QUERY="tmpGetOperatorInfo">
		
			<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
				<TD align="center">&nbsp;
				 
				</TD>
				<TD NOWRAP>#tmpGetOperatorInfo.operator_name#<CFIF trim(tmpGetOperatorInfo.legacy_id) EQ ""> [#tmpGetOperatorInfo.BSA_Operator_Id#]</cfif></TD>
				<TD NOWRAP>#tmpGetOperatorInfo.Operator_Location_Type#&nbsp;</TD>
				<TD NOWRAP>#tmpGetOperatorInfo.Operator_City#<BR>#tmpGetOperatorInfo.Operator_State#&nbsp;#tmpGetOperatorInfo.Operator_Zip#<!--- &nbsp;#Ucase(GetOperatorInfo.Operator_Country_Code)# ---><br>#tmpGetOperatorInfo.Operator_Phone#</TD>			
				<TD>#tmpGetOperatorInfo.Operator_DBA#&nbsp;</TD>
				<TD NOWRAP>#tmpGetOperatorInfo.BSA_Operator_ID#&nbsp;</TD>
				<TD NOWRAP>
				<cfif form.updateStatus EQ 0>
				<input type="Text" name="legacyId_#tmpGetOperatorInfo.BSA_Operator_ID#" value="#tmpGetOperatorInfo.Legacy_ID#" size="10" >
				<cfelse>#tmpGetOperatorInfo.Legacy_ID#&nbsp;</cfif>
				</TD>
				<td><Cfif Deleted IS 1>Inactive<cfelse>Active</CFIF></td>
			</TR>
			<cfflush>
		</CFOUTPUT>
				
		</TABLE>
		<br><br>
	</cfloop>
	</form>
	
	<cfif form.updateStatus EQ 0>
		<p></p>
		<div align="center">
		<CF_smallLink 
		title = "activate #lcase(application.returned_customer_setting.operator_label_plural)#" 
		url = "##"
		parameters = "onClick=""javascript: return activateOperators();"""
		></div>
	<cfelse>
		<p></p>
		<div align="center">
		<CF_smallLink 
		title = "return to manage #lcase(application.returned_customer_setting.operator_label_plural)#" 
		url = "select_operators.cfm"
		parameters = ""
		></div>
	</cfif>
	
<cfelse><!------ If no operators selected ----->

You did not select any <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> to update.
<p></p>
<div align="center"><CF_smallLink 
	title = "return to manage #lcase(application.returned_customer_setting.operator_label_plural)#" 
	url = "select_operators.cfm"
	parameters = ""
	></div>
</cfif>