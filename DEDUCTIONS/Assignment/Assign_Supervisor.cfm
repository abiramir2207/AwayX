



<CFPARAM NAME="FORM.Form_Submit" DEFAULT="">

<CFIF FORM.Form_Submit EQ 1>
	<CFIF isdefined("FORM.Analyst_ID")>
		
		<cfset useLakebaseForGetOldAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseForGetOldAnalyst>
			<cftry>
				<cfset GetOldAnalyst = application.oLakebase.toQuery(
					application.oLakebase.selectRows("dd_analyst", {
						"select" = "analyst_user_id",
						"deleted" = "eq.0",
						"is_supervisor" = "eq.1"
					}),
					"analyst_user_id"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetOldAnalyst = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetOldAnalyst>
		<CFQUERY NAME="GetOldAnalyst" DATASOURCE="#Application.Datasource#">
			SELECT Analyst_User_ID FROM DD_Analyst WHERE Deleted = 0 AND Is_Supervisor = 1
		</CFQUERY>
		</cfif>
		<CFSET OldAnalystList = VALUELIST(GetOldAnalyst.Analyst_User_ID)>
		
		<CFSET RemoveAnalyst = "">
		<CFLOOP LIST="#OldAnalystList#" INDEX="Item">
			<CFSET CheckAnalystExist = 	LISTFIND(#FORM.Analyst_ID#,#Item#,",")>
			<CFIF CheckAnalystExist EQ 0>
				<CFSET RemoveAnalyst = "#RemoveAnalyst##Item#,">
			</CFIF>
		</CFLOOP>
		<!--- <CFSET RemoveAnalyst = ListQualify(RemoveAnalyst,"'")> --->
		
		<CFSET User_List = ListQualify(FORM.Analyst_ID,"'")>
		
		<cfset useLakebaseFordelete_cur1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseFordelete_cur1>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_analyst",
					{ "analyst_user_id" = "not.in.(#User_List#)", "deleted" = "eq.0" },
					{ "is_supervisor" = 0 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseFordelete_cur1 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseFordelete_cur1>
		<CFQUERY NAME="delete_cur" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Analyst 
			
			SET 	Is_Supervisor = 0
			
			WHERE 	Analyst_User_ID not in (#preservesinglequotes(User_List)#)
					AND DELETED = 0
		</CFQUERY>
		</cfif>
		
		<cfset useLakebaseFordelete_cur2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseFordelete_cur2>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_analyst",
					{ "analyst_user_id" = "in.(#User_List#)", "deleted" = "eq.0" },
					{ "is_supervisor" = 1 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseFordelete_cur2 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseFordelete_cur2>
		<CFQUERY NAME="delete_cur" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Analyst 
			
			SET 	Is_Supervisor = 1
			
			WHERE 	Analyst_User_ID in (#preservesinglequotes(User_List)#)
					AND DELETED = 0
		</CFQUERY>
		</cfif>
		<!--- 
		<CFLOOP LIST = "#FORM.Analyst_ID#" INDEX="Item">
					
			<CFQUERY NAME="Check_Et" DATASOURCE="#Application.Datasource#">
				SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#Item#' AND Deleted=0
			</CFQUERY>
			
			<CFIF Check_Et.recordcount EQ 0>
				<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
					INSERT INTO
					
					DD_Analyst 		(	Analyst_User_ID	)
					
					VALUES			(	'#Item#'	)
				</CFQUERY>	
			</CFIF>			
	
		</CFLOOP>
		 --->
		
		<CFIF RemoveAnalyst NEQ "">
		
			<CFLOOP LIST="#RemoveAnalyst#" INDEX="Item">			
				<cfset useLakebaseForGetID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
				<cfif useLakebaseForGetID>
					<cftry>
						<cfset GetID = application.oLakebase.toQuery(
							application.oLakebase.selectRows("dd_analyst", {
								"select" = "analyst_user_id",
								"supervisor_id" = "eq.#Item#",
								"deleted" = "eq.0"
							}),
							"analyst_user_id"
						)>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForGetID = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForGetID>
				<CFQUERY NAME="GetID" DATASOURCE="#Application.Datasource#">
					SELECT Analyst_User_ID FROM DD_Analyst WHERE Supervisor_ID = '#Item#' AND Deleted = 0
				</CFQUERY>
				</cfif>
				
				<CFIF GetID.RecordCount GT 0>					
					<CFSET CurrentLoop = Item>
					
					<cfset useLakebaseForReassignDeductions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
					<cfif useLakebaseForReassignDeductions>
						<cftry>
							<cfset application.oLakebase.updateRows("dd_analyst",
								{ "supervisor_id" = "eq.#Item#" },
								{ "supervisor_id" = FORM.New_Analyst }
							)>
							<cfcatch type="any">
								<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
								<cfset useLakebaseForReassignDeductions = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForReassignDeductions>
					<CFQUERY NAME="ReassignDeductions" DATASOURCE="#Application.Datasource#">
						UPDATE 	DD_Analyst
						
						SET 	Supervisor_ID = '#FORM.New_Analyst#'
						
						WHERE	Supervisor_ID = '#Item#'
					</CFQUERY>					
					</cfif>
				</CFIF>				
			</CFLOOP>	
					
		</CFIF>
	<CFELSE>
		<CFQUERY NAME="Delete_All" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Analyst SET 	Deleted = 1	WHERE Deleted = 0	
		</CFQUERY>
		<CFQUERY NAME="update_Ass" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Assignment
			
			SET 	Deleted = 1
			
			WHERE 	DELETED = 0
		</CFQUERY>
		
		<CFQUERY NAME="ReassignDeductions" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			
			SET 	Analyst_User_ID = NULL
		</CFQUERY>
	</CFIF>
	
	<CFQUERY NAME="Decide_Location" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM DD_Analyst WHERE Deleted=0 AND Is_Default_Supervisor = 1
	</CFQUERY>
	<CFQUERY NAME="Decide_Location2" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM DD_Analyst WHERE Deleted=0 AND Default_Analyst = 1
	</CFQUERY>
	<CFIF Decide_Location.recordcount GT 0 AND Decide_Location2.recordcount GT 0>
		<CFLOCATION URL="index2.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="index2.cfm?Show_Step=6" ADDTOKEN="No">
	</CFIF>	
<CFELSE>
	<CFQUERY NAME="User_Lookup" DATASOURCE="#Application.Datasource#">
		SELECT 		Analyst_User_ID User_ID,
					Name_First,
					Name_Last 

		FROM 		DD_Analyst 

		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID

		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0	AND
					User_ID NOT IN (SELECT Analyst_User_ID FROM DD_Analyst WHERE Deleted = 0 AND Is_Supervisor = 1) 		
		ORDER BY	Name_First
	</CFQUERY>
	<CFQUERY NAME="Analyst_Lookup" DATASOURCE="#Application.Datasource#">
		SELECT 		Analyst_User_ID,
					Default_Analyst,
					Name_First,
					Name_Last 

		FROM 		DD_Analyst 

		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID

		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0 AND Is_Supervisor = 1
		ORDER BY	Name_First
	</CFQUERY>
	
	<SCRIPT SRC="/Deductions/Assignment/main_container.js?v=1.0"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT language="JavaScript">
		function Validate()
		{			
			var Submit_OK = 1;

			if (document.Pk_Analyst.Analyst_ID.options.length == 0)
			{
				alert("Please select at least one supervisor from Analysts list and try again.")
				Submit_OK = 0;
				return;
			}
			
			if (document.all.New_Analyst)
			{
				var objNew = document.all.New_Analyst;
				var objNewOptions = objNew.options;
				var selOpt = Get_Object_Property_Match_Collection(objNewOptions, "value", document.all.New_Analyst.value);				
				if(selOpt)
				{
					var conNew = confirm("Analysts under removed Supervisor (if any) will go to Supervisor " +selOpt.text);
					if (!(conNew))
					{
						Submit_OK = 0;
						return;
					}
				}
			}
			if (Submit_OK == 1)
			{
				select_all("Analyst_ID");
				document.Pk_Analyst.submit();
			}
			/*else
			{
				select_all("Analyst_ID");
				document.Pk_Analyst.submit();
			}*/
		}
		/*function CheckDef()
		{
			
			var	selDef = Get_Select_Index(SelObj, matchVal)
			 
		}*/
	</SCRIPT>
	
<BR>	
	<FORM NAME="Pk_Analyst" ACTION="Assign_Supervisor.cfm" METHOD="Post">
		<INPUT TYPE="Hidden" NAME="Form_Submit" VALUE="1">
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="465">	
			<!--- <TR>
				<TD COLSPAN="100%" ALIGN="Center"><B><FONT SIZE="3" COLOR="NAVY">Pick Analyst </FONT></B><FONT SIZE="2" COLOR="NAVY">( including default analyst )</FONT></TD>
			</TR>
			<TR>
				<TD COLSPAN="100%">&nbsp;</TD>
			</TR> --->
			<CFOUTPUT QUERY="Analyst_Lookup">
				<CFIF Default_Analyst EQ 1>					
					<INPUT TYPE="Hidden" NAME="Def_Analyst_ID" VALUE="#Analyst_User_ID#">
					<INPUT TYPE="Hidden" NAME="Def_User_Name" VALUE="#Name_First# #Name_Last#">
				</CFIF>
			</CFOUTPUT>
			<TR  HEIGHT="4">
				<TD VALIGN="Top" BGCOLOR="Navy">&nbsp;<FONT COLOR="WHITE"><B>Supervisor List</B></FONT><BR>
					<SELECT NAME="Analyst_ID" SIZE="22" STYLE="WIDTH:200px" MULTIPLE>
						<CFOUTPUT QUERY="Analyst_Lookup">
							<OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION> 
						</CFOUTPUT>
					</SELECT>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top"><BR><BR><BR>					
					<INPUT TYPE="BUTTON" NAME="Add_Analyst" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('User_ID','Analyst_ID')" STYLE="WIDTH:25px"><BR><BR>
					<INPUT TYPE="BUTTON" NAME="Remove_Analyst" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Analyst_ID','User_ID')" STYLE="WIDTH:25px"><BR><BR>
					<INPUT TYPE="BUTTON" NAME="Remove_All" VALUE=">>" ONCLICK="Javascript: remove_all('Analyst_ID','User_ID')" STYLE="WIDTH:25px"><BR><BR>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top" BGCOLOR="Navy">&nbsp;<FONT COLOR="White"><B>Analyst List</B></FONT><BR>
					<SELECT NAME="User_ID" SIZE="22" STYLE="WIDTH:200px" MULTIPLE>
						<CFOUTPUT QUERY="User_Lookup">
							<OPTION VALUE="#User_ID#">#Name_First# #Name_Last#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>	
		</TABLE>
		<BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="465">	
			<CFIF Analyst_Lookup.Recordcount GT 0>
			<TR>
				<TD><B>Any analysts previously under the removed superviser (if any) will be automatically reassigned to:</B></TD>				
				<TD>
					<SELECT NAME="New_Analyst" STYLE="WIDTH:200px">
						<CFOUTPUT QUERY="Analyst_Lookup">						
							<OPTION VALUE="#Analyst_User_ID#" <CFIF Default_Analyst EQ 1>SELECTED</CFIF>>#Name_First# #Name_Last#&nbsp;&nbsp;<CFIF Default_Analyst EQ 1>(Default)</CFIF></OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			</CFIF>
			<!--- <TR>				
				<TD>					
					<SELECT NAME="New_Analyst">
						<CFOUTPUT QUERY="Analyst_Lookup">						
							<OPTION VALUE="#Analyst_User_ID#" <CFIF Default_Analyst EQ 1>SELECTED</CFIF>>#Name_First# #Name_Last#&nbsp;&nbsp;<CFIF Default_Analyst EQ 1>(Default)</CFIF></OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR> --->
			<TR>
				<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
						<CF_button
							button_name	=	""
							button_caption	=	"save selection"
							button_action	=	"Validate()"
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
</CFIF>



