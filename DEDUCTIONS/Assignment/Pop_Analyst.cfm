

<CFPARAM NAME="FORM.Submit_Form" DEFAULT="">

<SCRIPT language="JavaScript">
function Validate()
{
	var submit_ok = 1;
	
	if (document.all.Cust_Analyst.selectedIndex == -1)
	{	
		submit_ok = 0;
		<CFIF not isdefined("URL.FromCust")>
		alert("Please select an Analyst and try again.");
		<CFELSE>
		alert("Please select Analysts and try again.");
		</CFIF>
		return false;
	}
	if (document.all.Default_Supervisor.selectedIndex == -1)
	{
		submit_ok = 0;		
		alert("Please select a default supervisor and try again.");		
		return false;
	}
	
	if (submit_ok == 1)
	{		
		document.pk_Ana.submit();
	}	
}

function close_window()
{
	if (window.opener)
	{
		window.opener.location.reload();
	}
	window.close();
}
</SCRIPT>
<CFIF FORM.Submit_Form EQ 1>

	<CFIF isdefined("FORM.Default_Analyst") OR IsDefined(FORM.Default_Supervisor)>
		<cfset useLakebaseForSet_Back1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseForSet_Back1>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_analyst",
					{ "deleted" = "eq.0" },
					{ "default_analyst" = 0, "is_default_supervisor" = 0 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForSet_Back1 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForSet_Back1>
		<CFQUERY NAME="Set_Back" DATASOURCE="#Application.Datasource#">
			UPDATE 		DD_Analyst
			
			SET 		Default_Analyst = 0,
						Is_Default_Supervisor = 0
			
			WHERE 		Deleted = 0
		</CFQUERY>
		</cfif>
		
		<cfset useLakebaseForUpdate_Default = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseForUpdate_Default>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_analyst",
					{ "dd_analyst_id" = "eq.#FORM.Cust_Analyst#", "deleted" = "eq.0" },
					{ "default_analyst" = 1 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdate_Default = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdate_Default>
		<CFQUERY NAME="Update_Default" DATASOURCE="#Application.Datasource#">
				UPDATE 	DD_Analyst
				
				SET		Default_Analyst = 1
				
				WHERE	DD_Analyst_ID	=	'#FORM.Cust_Analyst#' AND Deleted=0
		</CFQUERY>
		</cfif>
		
		<cfset useLakebaseForUpdate_Default_Supervisor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseForUpdate_Default_Supervisor>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_analyst",
					{ "dd_analyst_id" = "eq.#FORM.Default_Supervisor#", "deleted" = "eq.0" },
					{ "is_default_supervisor" = 1 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdate_Default_Supervisor = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdate_Default_Supervisor>
		<CFQUERY NAME="Update_Default_Supervisor" DATASOURCE="#Application.Datasource#">
				UPDATE 	DD_Analyst
				
				SET		Is_Default_Supervisor = 1
				
				WHERE	DD_Analyst_ID	=	'#FORM.Default_Supervisor#' AND Deleted=0
		</CFQUERY>
		</cfif>
		
		<!--- <CFLOCATION URL="Index2.cfm" ADDTOKEN="No"> --->
	<CFELSE>
	
		<cfset useLakebaseForSet_Back2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
		<cfif useLakebaseForSet_Back2>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_analyst",
					{ "deleted" = "eq.0" },
					{ "ass_customer" = 0 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForSet_Back2 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForSet_Back2>
		<CFQUERY NAME="Set_Back" DATASOURCE="#Application.Datasource#">
			UPDATE 		DD_Analyst
			
			SET 		Ass_Customer = 0
			
			WHERE 		Deleted = 0
		</CFQUERY>
		</cfif>
		
		<CFLOOP LIST="#FORM.Cust_Analyst#" INDEX="Item">
			<CFQUERY NAME="Update_Cust" DATASOURCE="#Application.Datasource#">
				UPDATE 	DD_Analyst
				
				SET		Ass_Customer = 1
				
				WHERE	DD_Analyst_ID	=	'#Item#' AND Deleted=0
			</CFQUERY>
		</CFLOOP>
		
		<SCRIPT language="JavaScript">
			close_window()
		</SCRIPT>
		
	</CFIF>
	<CFQUERY NAME="Decide_Location" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM DD_Analyst WHERE Deleted=0 AND Supervisor_ID IS NOT NULL
	</CFQUERY>

	<CFIF Decide_Location.recordcount GT 0>
		<CFLOCATION URL="index2.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="index2.cfm?Show_Step=7" ADDTOKEN="No">
	</CFIF>	
<CFELSE>
	
	<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Analyst_ID,
					Analyst_User_ID,
					Name_First,
					Name_Last 
	
		FROM 		DD_Analyst 
	
		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID
	
		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0
		ORDER BY	Name_First
	</CFQUERY>
	
	<CFQUERY NAME="Get_Supervisor" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Analyst_ID,
					Analyst_User_ID,
					Name_First,
					Name_Last 
	
		FROM 		DD_Analyst 
	
		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID
	
		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0 AND Is_Supervisor = 1
		ORDER BY	Name_First
	</CFQUERY>
	
	<CFQUERY NAME="Default_Supervisor" DATASOURCE="#Application.Datasource#">
		SELECT 	DD_Analyst_ID 
		FROM 	DD_Analyst
		WHERE	Is_Default_Supervisor = 1 AND Deleted=0
	</CFQUERY>
	
	<CFIF not isdefined("URL.FromCust")>
		<CFQUERY NAME="Default_Ana" DATASOURCE="#Application.Datasource#">
			SELECT 	DD_Analyst_ID 
			FROM 	DD_Analyst
			WHERE	Default_Analyst = 1 AND Deleted=0
		</CFQUERY>
		<CFSET Sel_List = VALUELIST(Default_Ana.DD_Analyst_ID)>
	<CFELSE>
		<CFQUERY NAME="Assigned_with_Cust" DATASOURCE="#Application.Datasource#">
			SELECT 	DD_Analyst_ID		
			FROM 	DD_Analyst
			WHERE	Ass_Customer = 1 AND Deleted=0
		</CFQUERY>
		<CFSET Sel_List = VALUELIST(Assigned_with_Cust.DD_Analyst_ID)>
	</CFIF>
	
	
	<BR>
	<FORM NAME="pk_Ana" ACTION="Pop_Analyst.cfm" METHOD="Post">
	<INPUT TYPE="Hidden" NAME="Submit_Form" VALUE="1">
	<CFIF not isdefined("URL.FromCust")>
	<INPUT TYPE="Hidden" NAME="Default_Analyst" VALUE="1">
	</CFIF>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center">	
		<TR  HEIGHT="23">
			<TD BGCOLOR="Navy">&nbsp;<FONT COLOR="WHITE"><B><CFIF not isdefined("URL.FromCust")>Select default analyst<CFELSE>Select analysts to assign customers:</CFIF></B></FONT></TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD BGCOLOR="Navy">&nbsp;<FONT COLOR="WHITE"><B>Select default Supervisor</B></FONT></TD>
		</TR>	
		
		<TR>		
			<TD ALIGN="Center">				
				<SELECT NAME="Cust_Analyst" SIZE="18" STYLE="WIDTH:200px">										
					<CFOUTPUT QUERY="Get_Analyst">
						<OPTION VALUE="#DD_Analyst_ID#"<CFLOOP LIST="#Sel_List#" INDEX="Item"><CFIF DD_Analyst_ID EQ Item>SELECTED</CFIF></CFLOOP> >#Name_First# #Name_Last#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD ALIGN="Center">				
				<SELECT NAME="Default_Supervisor" SIZE="18" STYLE="WIDTH:200px">										
					<CFOUTPUT QUERY="Get_Supervisor">
						<OPTION VALUE="#DD_Analyst_ID#"<CFIF DD_Analyst_ID EQ Default_Supervisor.DD_Analyst_ID>SELECTED</CFIF>>#Name_First# #Name_Last#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
			<CF_button
				button_name		=	""
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