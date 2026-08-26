<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody
		{
			border-bottom:solid #93BEE2 1px; 
			font-size : 10px;
		}
	.dropdown
		{
			width: 270px;
		}
	
	INPUT, SELECT, TEXTAREA
		{
			font: 8pt Arial;
		}
</style>



<CFINCLUDE TEMPLATE="../PM_lookup_tables.cfm">

<CFPARAM NAME="FORM.Selected_Projects" DEFAULT="">
<CFPARAM NAME="FORM.From_PM_Far_ID" DEFAULT="">
<CFPARAM NAME="FORM.From_Owner_Position_ID" DEFAULT="">
<CFPARAM NAME="FORM.From_PM_Sponsor_ID" DEFAULT="">
<CFPARAM NAME="FORM.To_PM_Far_ID" DEFAULT="">
<CFPARAM NAME="FORM.To_Owner_Position_ID" DEFAULT="">
<CFPARAM NAME="FORM.To_PM_Sponsor_ID" DEFAULT="">
<CFPARAM NAME="FORM.Update" DEFAULT="">

<CFPARAM NAME="URL.Disable_Far" DEFAULT="#FORM.From_PM_Far_ID#">
<CFPARAM NAME="URL.Disable_Position" DEFAULT="#FORM.From_Owner_Position_ID#">
<CFPARAM NAME="URL.Disable_Sponsor" DEFAULT="#FORM.From_PM_Sponsor_ID#">


<CFPARAM NAME="FORM.PM_Far_ID" DEFAULT="#FORM.From_PM_Far_ID#">
<CFPARAM NAME="FORM.PM_Position_ID" DEFAULT="#FORM.From_Owner_Position_ID#">
<CFPARAM NAME="FORM.PM_Sponsor_ID" DEFAULT="#FORM.From_PM_Sponsor_ID#">
<CFPARAM NAME="FORM.PM_Acct_Project" DEFAULT="">
<CFPARAM NAME="FORM.PM_CER" DEFAULT="">
<CFPARAM NAME="FORM.PM_Priority_ID" DEFAULT="">
<CFPARAM NAME="FORM.PM_Status_ID" DEFAULT="">
<CFPARAM NAME="FORM.PM_Phase_ID" DEFAULT="">
<CFPARAM NAME="FORM.PM_Start_Date" DEFAULT="">
<CFPARAM NAME="FORM.PM_End_Date" DEFAULT="">
<CFPARAM NAME="FORM.PM_Value_Pounds" DEFAULT="">
<CFPARAM NAME="FORM.PM_Value_Pounds_Filter" DEFAULT="">
<CFPARAM NAME="FORM.PM_Value_Dollars" DEFAULT="">
<CFPARAM NAME="FORM.PM_Value_Dollars_Filter" DEFAULT="">
<CFPARAM NAME="FORM.PM_Resources" DEFAULT="">
<CFPARAM NAME="FORM.PM_Ext_Budget" DEFAULT="">
<CFPARAM NAME="FORM.PM_Ext_Budget_Filter" DEFAULT="">
<CFPARAM NAME="FORM.PM_Actual" DEFAULT="">
<CFPARAM NAME="FORM.PM_Actual_Filter" DEFAULT="">
<CFPARAM NAME="FORM.PM_Support" DEFAULT="">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<CFPARAM NAME="FORM.SubmittoPM_reassign" DEFAULT="">
<CFPARAM NAME="FORM.Items_OnThis_Page" DEFAULT="">
<CFPARAM NAME="FORM.PM_Item_Master_ID" DEFAULT="">
<CFPARAM NAME="FORM.Already_Selected_List" DEFAULT="#FORM.Selected_Projects#">
<CFPARAM NAME="FORM.SORT_BY" 		DEFAULT="">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFPARAM NAME="PM_Status_ID_List" DEFAULT="">

<CFIF isdefined("FORM.Undo_Seletion")>
	<CFIF FORM.Undo_Seletion EQ 1>
		<CFSET FORM.Items_OnThis_Page = "">
		<CFSET FORM.Already_Selected_List = "">
		<CFSET FORM.PM_Item_Master_ID = "">
	</CFIF>
</CFIF> 


<CFIF FORM.PM_Status_ID NEQ "0">
<CFSET PM_Status_ID_List = ListQualify(FORM.PM_Status_ID,"'",",")>
</CFIF>



	<CFIF Not Isdefined("FORM.Already_Selected_List")>
		<CFPARAM NAME="FORM.Already_Selected_List" DEFAULT="#FORM.Selected_Projects#">
		<CFSET FORM.Already_Selected_List = FORM.PM_Item_Master_ID>
	<CFELSE>	
		<CFLOOP LIST="#FORM.PM_Item_Master_ID#" INDEX="Item">		
			<CFIF NOT ListFindNoCase(FORM.Already_Selected_List,Item,",")>
				<CFSET FORM.Already_Selected_List = ListAppend(FORM.Already_Selected_List,Item,",")>
			</CFIF>
		</CFLOOP> 
	</CFIF>

	<CFLOOP LIST="#FORM.Items_OnThis_Page#" INDEX="Item">
		<CFIF Not ListFindNoCase(FORM.PM_Item_Master_ID,Item,",")>
			<CFSET DeleteItemPosition = ListFindNoCase(FORM.Already_Selected_List,Item,",")>
			<CFIF DeleteItemPosition GT 0>
				<CFSET FORM.Already_Selected_List = ListDeleteAt(FORM.Already_Selected_List,DeleteItemPosition,",")>
			</CFIF>
		</CFIF>
	</CFLOOP>

	
<SCRIPT language="JavaScript">
function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.PM_reSearch;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}
</SCRIPT>

<CFIF FORM.SubmittoPM_reassign EQ 1>

	<SCRIPT language="JavaScript">	
	function ActualSubmittoPMReassign()
	{
		window.opener.location.href ="PM_Reassign.cfm?<CFOUTPUT>Selected_Projects=#FORM.Already_Selected_List#&PM_Sponsor_ID=#FORM.PM_Sponsor_ID#&Owner_Position_ID=#FORM.PM_Position_ID#&PM_Far_ID=#FORM.PM_Far_ID#&To_PM_Far_ID=#FORM.To_PM_Far_ID#&To_Owner_Position_ID=#FORM.To_Owner_Position_ID#&To_PM_Sponsor_ID=#FORM.To_PM_Sponsor_ID#&Update=#FORM.Update#</CFOUTPUT>";		
		window.close();
	}		
	ActualSubmittoPMReassign();
	</SCRIPT>
</CFIF> 
<!--- <CFDUMP VAR="#URL#">
<CFDUMP VAR="#FORM#"> --->

<CF_openLayer
	Border="yes"
	BorderSize="1"  
	BorderColor="blue"  
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="Hide Project Search Tool:"  
	TitleClosed="Show Project Search Tool:"  
	TitleTooltip="Click to Show/Hide Criteria Used"  
	TitleFont="font"  
	TitleColor="Blue"  
	TitleSize="9"  
	IsClosed="Yes"  
	Width="100%">	

	

	<CFOUTPUT>	
	<FORM NAME="PM_reSearch" ACTION="PM_ReassignSearch.cfm?Disable_Far=#URL.Disable_Far#&Disable_Position=#URL.Disable_Position#&Disable_Sponsor=#URL.Disable_Sponsor#" METHOD="POST">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">

	<INPUT TYPE="Hidden" NAME="To_PM_Far_ID" VALUE="#FORM.To_PM_Far_ID#">
	<INPUT TYPE="Hidden" NAME="To_Owner_Position_ID" VALUE="#FORM.To_Owner_Position_ID#">
	<INPUT TYPE="Hidden" NAME="To_PM_Sponsor_ID" VALUE="#FORM.To_PM_Sponsor_ID#">
	<INPUT TYPE="Hidden" NAME="Update" VALUE="#FORM.Update#">
	</CFOUTPUT>
	
	<CFOUTPUT>	
	<CFIF URL.Disable_Far NEQ ""  >
		<INPUT TYPE="Hidden" NAME="PM_Far_ID" VALUE="#URL.Disable_Far#">
	</CFIF>
	<CFIF URL.Disable_Position NEQ "">
		<INPUT TYPE="Hidden" NAME="PM_Position_ID" VALUE="#URL.Disable_Position#">
	</CFIF>
	<CFIF URL.Disable_Sponsor NEQ "">
		<INPUT TYPE="Hidden" NAME="PM_Sponsor_ID" VALUE="#URL.Disable_Sponsor#">
	</CFIF>
	</CFOUTPUT>
	
	<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="70%" ALIGN="Center">
		<TR>		
			<TD COLSPAN="3">
			<B>Project:</B><BR>
				<INPUT type="text" name="PM_Acct_Project" size="102" VALUE=<CFOUTPUT>"#FORM.PM_Acct_Project#"</CFOUTPUT>>&nbsp;
			</TD>
			<TD><B>CER/Acct Number:</B><BR>
				<INPUT type="text" name="PM_CER" SIZE="48" VALUE=<CFOUTPUT>"#FORM.PM_CER#"</CFOUTPUT>>
			</TD>		
		</TR>
		<TR>
			<TD COLSPAN="2">
				<B>Sponsor:</B><BR>
				<SELECT size="1" name="PM_Sponsor_ID" CLASS="dropdown" <CFIF URL.Disable_Sponsor NEQ "">DISABLED</CFIF>>
					<OPTION VALUE="">All Sponsors</OPTION>
					<CFOUTPUT QUERY="Get_Sponsor"><OPTION VALUE="#PM_Sponsor_ID#" <CFIF URL.Disable_Sponsor EQ PM_Sponsor_ID>SELECTED<CFELSEIF FORM.PM_Sponsor_ID EQ PM_Sponsor_ID>SELECTED</CFIF>>#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</OPTION></CFOUTPUT>
				</SELECT>
	
			</TD>
			<TD>			
				<B>Owner Position:</B><BR>
				<SELECT size="1" name="PM_Position_ID" CLASS="dropdown" <CFIF URL.Disable_Position NEQ "">DISABLED</CFIF>>
					<OPTION VALUE="">All Owners</OPTION>
					<CFOUTPUT QUERY="Get_Positions"><OPTION VALUE="#User_Positions_ID#" <CFIF URL.Disable_Position EQ User_Positions_ID>SELECTED<CFELSEIF FORM.PM_Position_ID EQ User_Positions_ID>SELECTED</CFIF>>#Position_Label#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Functional Area Responsible:</B><BR>
				<SELECT size="1" name="PM_FAR_ID" CLASS="dropdown" <CFIF URL.Disable_Far NEQ "">DISABLED</CFIF>>
					<OPTION VALUE="">All Areas</OPTION>
					<CFOUTPUT QUERY="Get_FAR"><OPTION VALUE="#PM_FAR_ID#" <CFIF URL.Disable_Far EQ PM_Far_ID>SELECTED<CFELSEIF FORM.PM_FAR_ID EQ PM_FAR_ID>SELECTED</CFIF>>#PM_FAR_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2">
				<B>Priority:</B><BR>
				<SELECT size="1" name="PM_Priority_ID"  CLASS="dropdown">
					<OPTION VALUE="">All Priorities</OPTION>
					<CFOUTPUT QUERY="Get_Priority"><OPTION VALUE="#PM_Priority_ID#" <CFIF FORM.PM_Priority_ID EQ PM_Priority_ID>SELECTED</CFIF>>#PM_Priority_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<TD ROWSPAN="2">
				<B>Status:</B><BR>
				<SELECT size="3" name="PM_Status_ID" CLASS="dropdown" MULTIPLE>
					<OPTION VALUE="0">All Status</OPTION>
					<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#PM_Status_ID#" <CFIF ListFind(FORM.PM_Status_ID,PM_Status_ID,",") NEQ 0>SELECTED</CFIF>>#PM_Status_Description#</OPTION></CFOUTPUT>
				</SELECT>
				<BR>
				<FONT COLOR="#FF0000" SIZE="1"><B>* Hold ctrl and click to select multiple status</B></FONT>
			</TD>
			<TD>
				<B>Phase:</B><BR>
				<SELECT size="1" name="PM_Phase_ID" CLASS="dropdown">
					<OPTION VALUE="">All Phases</OPTION>
					<CFOUTPUT QUERY="Get_Phase"><OPTION VALUE="#PM_Phase_ID#" <CFIF FORM.PM_Phase_ID EQ PM_Phase_ID>SELECTED</CFIF> >#PM_Phase_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR VALIGN="top">
			<TD>
				<B>Timeline:</B> (From - To)<BR>
				<CF_EASYDATE FORMNAME="PM_reSearch" FIELDNAME="PM_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.PM_Start_Date#">
			</TD>
			<TD>			
				<BR>	
				<CF_EASYDATE FORMNAME="PM_reSearch" FIELDNAME="PM_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.PM_End_Date#">
			</TD>
			<TD>
				<cfoutput><B>#application.returned_customer_setting.broker_label_singular#:</B><BR></cfoutput>
				<CFQUERY NAME="GetBrokers" DATASOURCE="#application.datasource#">
				SELECT 	BSA_Foodservice_Brokers_ID, Broker_Name
				--FROM 	broker_active
				FROM 	broker_lob_active
				WHERE 	
						len(Broker_Name) > 0
				ORDER BY Broker_Name
				</CFQUERY>
				<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
				<SELECT NAME="Broker_ID" CLASS="dropdown">
					<cfoutput><OPTION VALUE="">**ALL** #application.returned_customer_setting.broker_label_plural#</OPTION></cfoutput>
					<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker_ID) EQ GetBrokers.BSA_Foodservice_Brokers_ID, DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
				</SELECT>			
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2">
				<B>Value lbs:</B><BR>
				<SELECT size="1" name="PM_Value_Pounds_Filter">
					<OPTION VALUE="">Any</OPTION>
					<OPTION VALUE="=" <CFIF FORM.PM_Value_Pounds_Filter EQ "=">SELECTED</CFIF>>=</OPTION>
					<OPTION VALUE=">" <CFIF FORM.PM_Value_Pounds_Filter EQ ">">SELECTED</CFIF>>></OPTION>
					<OPTION VALUE="<" <CFIF FORM.PM_Value_Pounds_Filter EQ "<">SELECTED</CFIF>><</OPTION>
					<OPTION VALUE=">=" <CFIF FORM.PM_Value_Pounds_Filter EQ ">=">SELECTED</CFIF>>>=</OPTION>
					<OPTION VALUE="<=" <CFIF FORM.PM_Value_Pounds_Filter EQ "<=">SELECTED</CFIF>><=</OPTION>
					<OPTION VALUE="<>" <CFIF FORM.PM_Value_Pounds_Filter EQ "<>">SELECTED</CFIF>><></OPTION>
				</SELECT>
				<INPUT TYPE="Text" NAME="PM_Value_Pounds" SIZE="38" onKeyUp="clenseText(this, '0123456789.');" VALUE=<CFOUTPUT>"#FORM.PM_Value_Pounds#"</CFOUTPUT>>
			</TD>
			<TD>
				<B>Value $:</B><BR>
				<SELECT size="1" name="PM_Value_Dollars_Filter">
					<OPTION VALUE="">Any</OPTION>
					<OPTION VALUE="=" <CFIF FORM.PM_Value_Dollars_Filter EQ "=">SELECTED</CFIF>>=</OPTION>
					<OPTION VALUE=">" <CFIF FORM.PM_Value_Dollars_Filter EQ ">">SELECTED</CFIF>>></OPTION>
					<OPTION VALUE="<" <CFIF FORM.PM_Value_Dollars_Filter EQ "<">SELECTED</CFIF>><</OPTION>
					<OPTION VALUE=">=" <CFIF FORM.PM_Value_Dollars_Filter EQ ">=">SELECTED</CFIF>>>=</OPTION>
					<OPTION VALUE="<=" <CFIF FORM.PM_Value_Dollars_Filter EQ "<=">SELECTED</CFIF>><=</OPTION>
					<OPTION VALUE="<>" <CFIF FORM.PM_Value_Dollars_Filter EQ "<>">SELECTED</CFIF>><></OPTION>
				</SELECT>
				<INPUT TYPE="Text" NAME="PM_Value_Dollars" SIZE="38" onKeyUp="clenseText(this, '0123456789.');" VALUE=<CFOUTPUT>"#FORM.PM_Value_Dollars#"</CFOUTPUT>>
			</TD>
			 <TD>
				<B>Resources:</B><BR>
				<INPUT type="text" name="PM_Resources" SIZE="48" VALUE=<CFOUTPUT>"#FORM.PM_Resources#"</CFOUTPUT>>
			</TD> 
		</TR>
		<TR>
			<TD COLSPAN="2">
				<B>Budget $:</B><BR>
				<SELECT size="1" name="PM_Ext_Budget_Filter">
					<OPTION VALUE="">Any</OPTION>
					<OPTION VALUE="=" <CFIF FORM.PM_Ext_Budget_Filter EQ "=">SELECTED</CFIF>>=</OPTION>
					<OPTION VALUE=">" <CFIF FORM.PM_Ext_Budget_Filter EQ ">">SELECTED</CFIF>>></OPTION>
					<OPTION VALUE="<" <CFIF FORM.PM_Ext_Budget_Filter EQ "<">SELECTED</CFIF>><</OPTION>
					<OPTION VALUE=">=" <CFIF FORM.PM_Ext_Budget_Filter EQ ">=">SELECTED</CFIF>>>=</OPTION>
					<OPTION VALUE="<=" <CFIF FORM.PM_Ext_Budget_Filter EQ "<=">SELECTED</CFIF>><=</OPTION>
					<OPTION VALUE="<>" <CFIF FORM.PM_Ext_Budget_Filter EQ "<>">SELECTED</CFIF>><></OPTION>
				</SELECT>
				<INPUT TYPE="Text" NAME="PM_Ext_Budget" SIZE="38" onKeyUp="clenseText(this, '0123456789.');" VALUE=<CFOUTPUT>"#FORM.PM_Ext_Budget#"</CFOUTPUT>>
			</TD> 
			<TD>
				<B>Actual $:</B><BR>
				<SELECT size="1" name="PM_Actual_Filter">
					<OPTION VALUE="">Any</OPTION>
					<OPTION VALUE="=" <CFIF FORM.PM_Actual_Filter EQ "=">SELECTED</CFIF>>=</OPTION>
					<OPTION VALUE=">" <CFIF FORM.PM_Actual_Filter EQ ">">SELECTED</CFIF>>></OPTION>
					<OPTION VALUE="<" <CFIF FORM.PM_Actual_Filter EQ "<">SELECTED</CFIF>><</OPTION>
					<OPTION VALUE=">=" <CFIF FORM.PM_Actual_Filter EQ ">=">SELECTED</CFIF>>>=</OPTION>
					<OPTION VALUE="<=" <CFIF FORM.PM_Actual_Filter EQ "<=">SELECTED</CFIF>><=</OPTION>
					<OPTION VALUE="<>" <CFIF FORM.PM_Actual_Filter EQ "<>">SELECTED</CFIF>><></OPTION>
				</SELECT>
				<INPUT TYPE="Text" NAME="PM_Actual" onKeyUp="clenseText(this, '0123456789.');" SIZE="38" VALUE=<CFOUTPUT>"#FORM.PM_Actual#"</CFOUTPUT>>
			</TD>
			<TD>
				<B>Support:</B><BR>
				<INPUT type="text" name="PM_Support" SIZE="48" VALUE=<CFOUTPUT>"#FORM.PM_Support#"</CFOUTPUT>>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="Right">
				<B><FONT SIZE="2" COLOR="red">[ </FONT><A Href="##" onClick="Javascript: formReset()">reset</A><FONT SIZE="2" COLOR="Red"> ]</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<B><FONT SIZE="2" COLOR="red">[ </FONT><A Href="##" onClick="Javascript: formSubmit()">search projects</A><FONT SIZE="2" COLOR="Red"> ]</FONT></B>&nbsp;&nbsp;
			</TD>
		</TR>
	</TABLE>

</CF_openLayer>

	
	<!---  initial user position--->
	<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
		SELECT User_Positions_ID
		FROM User_Position_Holders
		WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
	</CFQUERY>
	<!--- locate those positions underneath the supplied position --->
	<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
	<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
	<!--- list of positions underneath supplied --->
	<CFSET ListOfPositionsUnderMine = GP_Position_List_From_My_Position_Down>
	
	
	<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
		<CFCASE VALUE="PM_Acct_Project,PM_Priority_Description,PM_Status_Description,PM_Sponsor_Name_First,PM_Far_Description,PM_Position_ID" DELIMITERS=",">
			<CFSET FORM.SORT_BY = FORM.SORT_BY>
		</CFCASE>
		<CFDEFAULTCASE>
			<CFSET FORM.SORT_BY = "PM_Acct_Project">
		</CFDEFAULTCASE>
	</CFSWITCH>
	
	<CFIF FORM.SORT_ORDER NEQ "DESC">
		<CFSET FORM.SORT_ORDER = "ASC">
	</CFIF>
	
	
	
	<CFOUTPUT>
	<cfset FORM.PM_Acct_Project = trim(replace(FORM.PM_Acct_Project, "'", "''", "all"))>
	<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#"> 
		SELECT 		DISTINCT 
					PM_Item_Master.PM_Item_Master_ID,
					PM_Item_Master.PM_Acct_Project,
					PM_Priority.PM_Priority_Description,
					PM_Status.PM_Status_Description,
					PM_Item_Master.PM_Value_Pounds,
					PM_Item_Master.PM_Value_Dollars,
					PM_Sponsor.PM_Sponsor_Name_First,
					PM_Sponsor.PM_Sponsor_Name_Last,										
					PM_Item_Master.PM_Position_ID,
					PM_Far.PM_Far_Description,
					PM_Item_Master.PM_Date_Modified

		FROM 		PM_Item_Master
		INNER JOIN 	PM_Priority ON PM_Priority.PM_Priority_ID=PM_Item_Master.PM_Priority_ID
		INNER JOIN 	PM_Status ON PM_Status.PM_Status_ID=PM_Item_Master.PM_Status_ID
		INNER JOIN 	PM_Sponsor ON PM_Sponsor.PM_Sponsor_ID=PM_Item_Master.PM_Sponsor_ID
		INNER JOIN 	PM_Phase ON PM_Phase.PM_Phase_ID=PM_Item_Master.PM_Phase_ID
		INNER JOIN 	PM_Far ON PM_Far.PM_Far_ID=PM_Item_Master.PM_Far_ID	
		<CFIF TRIM(FORM.PM_Position_ID) NEQ "">
		INNER JOIN 	PM_Owner_Position ON PM_Owner_Position.PM_Item_Master_ID=PM_Item_Master.PM_Item_Master_ID  
					AND PM_Owner_Position.User_Positions_ID = #FORM.PM_Position_ID#
		</CFIF>

		
		WHERE 		PM_Item_Master.PM_Deleted = 0 AND PM_Priority.PM_Priority_Deleted = 0 AND PM_Status.PM_Status_Deleted = 0 AND
					PM_Sponsor.PM_Sponsor_Deleted = 0 
					
					<CFIF FORM.PM_Acct_Project NEQ "">
						AND PM_Item_Master.PM_Acct_Project LIKE '%#PreserveSingleQuotes(FORM.PM_Acct_Project)#%'
					</CFIF>
					<CFIF FORM.PM_CER NEQ "">
						AND PM_Item_Master.PM_CER LIKE '%#FORM.PM_CER#%'
					</CFIF>	
					<CFIF FORM.PM_Sponsor_ID NEQ "">
						AND PM_Item_Master.PM_Sponsor_ID LIKE '#FORM.PM_Sponsor_ID#'
					</CFIF>		
					<CFIF FORM.PM_Priority_ID NEQ "">
						AND PM_Item_Master.PM_Priority_ID LIKE '#FORM.PM_Priority_ID#'
					</CFIF>		
					<CFIF PM_Status_ID_List NEQ "">
						AND PM_Item_Master.PM_Status_ID	IN (#PreserveSingleQuotes(PM_Status_ID_List)#)
					</CFIF>		
					<CFIF FORM.PM_Phase_ID NEQ "">
						AND PM_Item_Master.PM_Phase_ID LIKE '#FORM.PM_Phase_ID#'
					</CFIF>
					<CFIF FORM.PM_FAR_ID NEQ "">
						AND PM_Item_Master.PM_FAR_ID LIKE '#FORM.PM_FAR_ID#'
					</CFIF>
					
					<CFIF PM_Value_Pounds NEQ "" AND PM_Value_Pounds_Filter NEQ "">											
						AND PM_Item_Master.PM_Value_Pounds	#FORM.PM_Value_Pounds_Filter# #FORM.PM_Value_Pounds#
					</CFIF>
					<CFIF PM_Value_Dollars NEQ "" AND PM_Value_Dollars_Filter NEQ "">
						AND PM_Item_Master.PM_Value_Dollars	#FORM.PM_Value_Dollars_Filter# #FORM.PM_Value_Dollars#
					</CFIF>
					<CFIF PM_Resources NEQ "">
						AND PM_Item_Master.PM_Resources	LIKE '%#FORM.PM_Resources#%'
					</CFIF>
					<CFIF PM_Ext_Budget NEQ "" AND PM_Ext_Budget_Filter NEQ "">
						AND PM_Item_Master.PM_Ext_Budget #FORM.PM_Ext_Budget_Filter# #FORM.PM_Ext_Budget#
					</CFIF>
					<CFIF PM_Actual NEQ "" AND PM_Actual_Filter NEQ "">
						AND PM_Item_Master.PM_Actual #FORM.PM_Actual_Filter# #FORM.PM_Actual#
					</CFIF>
					<CFIF PM_Support NEQ "">
						AND PM_Item_Master.PM_Support	like '%#FORM.PM_Support#%'
					</CFIF>		
					<CFIF PM_Start_Date NEQ "" AND PM_End_Date NEQ "">
						AND (	(CONVERT(Char(10),PM_End_Date,101)	>=	'#FORM.PM_Start_Date#' AND
							  	 CONVERT(Char(10),PM_Start_Date,101)<=	'#FORM.PM_Start_Date#')							  
							  OR							  
							  	(CONVERT(Char(10),PM_End_Date,101)	>=	'#FORM.PM_End_Date#' AND
								 CONVERT(Char(10),PM_Start_Date,101)<=	'#FORM.PM_End_Date#' )	)
					</CFIF>		
					<CFIF PM_Start_Date NEQ "" AND PM_End_Date EQ "">
						AND ( 	PM_Start_Date	<=	'#FORM.PM_Start_Date#' AND 
								PM_End_Date >=	'#FORM.PM_Start_Date#' 	)
					</CFIF>					
					<CFIF PM_Start_Date EQ "" AND PM_End_Date NEQ "">
						AND (	PM_Start_Date	<=	'#FORM.PM_End_Date#' AND
								PM_End_Date		>=	'#FORM.PM_End_Date#'	)
					</CFIF>
					
					AND EXISTS
						(	SELECT		TOP 1 PM_Owner_Position.PM_Item_Master_ID
							FROM		PM_Owner_Position

							WHERE 		<CFIF Len(ListOfPositionsUnderMine) GT 0>
											PM_Owner_Position.User_Positions_ID IN (#ListOfPositionsUnderMine#)
										<CFELSE>
											1=2
										</CFIF>										
										AND PM_Owner_Position.PM_Item_Master_ID = PM_Item_Master.PM_Item_Master_ID
						)
					<CFIF FORM.Broker_ID NEQ "0" AND FORM.Broker_ID NEQ "" >
						AND EXISTS
							(	SELECT		TOP 1 PM_Brokers.PM_Item_Master_ID
								FROM		PM_Brokers
								
								WHERE		PM_Brokers.BSA_Foodservice_Brokers_ID = '#FORM.Broker_ID#' AND
											PM_Brokers.PM_Item_Master_ID=PM_Item_Master.PM_Item_Master_ID	
							)
					</CFIF>		
		ORDER BY 	#FORM.SORT_BY# #FORM.SORT_ORDER#		
				
	</CFQUERY> 
	</CFOUTPUT>	
	
	<BR>
	
	<cfparam name="FORM.startrow"  default="1">
   <CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   <cfparam name="FORM.pageLength"  default=12>
   <CFSET startrow=FORM.startrow>
   <CFSET frompage=FORM.frompage>
   <cf_Number_of_Rows maxrows="#FORM.pageLength#">
		<!--- <CFOUTPUT>
	--#FORM.PM_Item_Master_ID#--<BR><BR>
	--#Already_Selected_List#--<BR><BR>
	--#FORM.Items_OnThis_Page#--
	</CFOUTPUT> --->
	
	<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
</style>
	
	
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Already_Selected_List" VALUE="#FORM.Already_Selected_List#"> 
   	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
	<INPUT TYPE="Hidden" NAME="SubmittoPM_reassign" VALUE="0">
	</CFOUTPUT>
	
	
	
	<CFSET A_Header_Value_List = "PM_Acct_Project,PM_Priority_Description,PM_Status_Description,PM_Sponsor_Name_First,PM_Far_Description,PM_Position_ID"><!---Doc_Description,Uploaded_By,Doc_Family  --->
	<CFSET A_Header_Name_List = "ACCT/PROJECT,PRIORITY,STATUS,SPONSOR,FUNCTIONAL AREA,OWNER POSITION">
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
	
		<TR ID="header" BGCOLOR="ffce84" VALIGN="top">
			<TD ID="header">
				<input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);">
			</TD>
			<CFOUTPUT>
			<CFSET Counter = 1>
			<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
				<CFSET thisSortOrder = "ASC">
				<CFSET Image_Name = "/Images/down_1.gif">
				<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
				<CFIF ThisHeaderItem EQ FORM.SORT_BY>
					<CFIF FORM.SORT_ORDER EQ "ASC">
						<CFSET thisSortOrder = "DESC">
						<CFSET Image_Name = "/Images/up_1.gif">
					</CFIF>
				</CFIF>				
				<TD ID="header">	
				<CFIF LCase(ThisHeaderItemName) NEQ "owner position">
				<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>
				<CFELSE>
				<B>#ThisHeaderItemName#</B>
				</CFIF>				
				</TD>
				<CFSET Counter = Counter + 1>
			</CFLOOP>
			</CFOUTPUT>
		</TR>	
		<!--- <TR BGCOLOR="ffce84">
			<TD CLASS="tableheader">
				<input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);">
			</TD>
			<TD CLASS="tableheader"><B>ACCT/PROJECT</B></TD>
			<TD CLASS="tableheader"><B>PRIORITY</B></TD>
			<TD CLASS="tableheader"><B>STATUS</B></TD>
			<TD CLASS="tableheader"><B>SPONSOR</B></TD>
			<TD CLASS="tableheader"><B>FUNCTIONAL AREA</B></TD>
			<TD CLASS="tableheader"><B>OWNER POSITION</B></TD>			
		</TR>	 --->	
		<CFSET Items_OnThis_Page = "">
		<CFOUTPUT QUERY="Get_Data" startrow="#StartRow#" maxrows="#MaxRows#">		
		<CFSET Items_OnThis_Page = ListAppend(Items_OnThis_Page,PM_Item_Master_ID,",")>
		
		<CFQUERY NAME="Check_Locked" DATASOURCE="#Application.Datasource#">
			SELECT 		Name_First,
						Name_Last 
						
			FROM 		_Users 
			
			INNER JOIN 	PM_Item_Master ON PM_Item_Master.PM_Locked_By_User_ID = _Users.User_ID
			WHERE 		PM_Item_Master_ID='#PM_Item_Master_ID#' AND PM_Locked = 1
		</CFQUERY>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD WIDTH="21" CLASS="tdbody" <CFIF Check_Locked.Recordcount GT 0>TITLE="This project is currently locked by #Check_Locked.Name_First# #Check_Locked.Name_Last#"</CFIF>>			
				<input TYPE="Checkbox" NAME="PM_Item_Master_ID" VALUE="#PM_Item_Master_ID#" <CFIF ListFindNoCase(FORM.Already_Selected_List,PM_Item_Master_ID,",")>CHECKED</CFIF> <CFIF Check_Locked.Recordcount GT 0>DISABLED</CFIF>>
			</TD>
			<TD CLASS="tdbody">#PM_Acct_Project#</TD>
			<TD CLASS="tdbody">#PM_Priority_Description#</TD>
			<TD CLASS="tdbody">#PM_Status_Description#</TD>			
			<TD CLASS="tdbody" NOWRAP>#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</TD>			
			<TD CLASS="tdbody">#PM_Far_Description#</TD>
			<CFQUERY NAME="Get_Ower_Label" DATASOURCE="#Application.Datasource#">
				SELECT 		Position_Label 
				FROM 		User_Positions 
				INNER JOIN 	PM_Owner_Position ON User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
				WHERE 		PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
			<TD CLASS="tdbody">&nbsp;<CFIF Get_Ower_Label.Recordcount GT 1>Several...<CFELSE>#Get_Ower_Label.Position_Label#</CFIF></TD>
		</TR>
		</CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="Items_OnThis_Page" VALUE=<CFOUTPUT>"#Items_OnThis_Page#"</CFOUTPUT>>		
	</TABLE>
	<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="PM_reSearch"
    query="Get_Data"
    maxpages="40"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>
	<BR>
   <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
   	<TR>
		<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><CFIF Get_Data.recordcount GT 0><A Href="##" ONCLICK="Javascript: SubmitToReProjects()">Import selected projects</A><CFELSE>Import selected projects</CFIF><FONT COLOR="red" SIZE="2"> ]</B></FONT>
		&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="red" SIZE="2">[ </FONT><CFIF Get_Data.recordcount GT 0><A Href="##" ONCLICK="Javascript: UncheckAll()">Remove all selected projects</A><CFELSE>Remove all selected projects</CFIF><FONT COLOR="red" SIZE="2"> ]</B></FONT>
		&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: Closewindow()">Back to reassign projects</A><FONT COLOR="red" SIZE="2"> ]</B></FONT></TD>
	</TR>
   </TABLE>
</FORM>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT language="JavaScript">



function SubmitToReProjects()
{	
		if(Any_Object_Checked(document.all.PM_Item_Master_ID))
		{
			document.PM_reSearch.SubmittoPM_reassign.value="1";
			document.PM_reSearch.submit();
			//window.location.href ="View_Edit_Approve.cfm"
			//return false;
		}
		else
		{
			alert("Please select at least a project to import.")
		}

	
}
function UncheckAll()
{
	document.all.allbox.checked = false;
	document.all.allbox.fireEvent("onclick");	
	document.PM_reSearch.Already_Selected_List.value="";
	document.PM_reSearch.PM_Item_Master_ID.value="";
}
function Closewindow()
{
	window.close();
}
function selectAll(thisobj)
	{
		var bCheck = thisobj.checked;
		var chObjs = document.all.PM_Item_Master_ID;
		if(chObjs.length)
		{
			var chObjLen = chObjs.length;
			var i;
			for(i=0;i<chObjLen;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}
		
	}
function formReset()
{
	var x = document.PM_reSearch;
	x.PM_Acct_Project.value = "";
	x.PM_CER.value="";
	x.PM_Sponsor_ID.value = "<CFOUTPUT>#URL.Disable_Sponsor#</CFOUTPUT>";
	x.PM_Position_ID.value= "<CFOUTPUT>#URL.Disable_Position#</CFOUTPUT>";
	x.PM_FAR_ID.value="<CFOUTPUT>#URL.Disable_Far#</CFOUTPUT>"
	x.PM_Priority_ID.value="";	
	x.PM_Status_ID.selectedIndex = 0;
	x.PM_Status_ID.value="";		
	x.PM_Phase_ID.value="";
	x.PM_Start_Date.value="";
	x.PM_End_Date.value="";
	x.Broker_ID.value="";
	x.PM_Value_Pounds_Filter.value="";
	x.PM_Value_Pounds.value="";
	x.PM_Value_Dollars_Filter.value="";
	x.PM_Value_Dollars.value="";
	x.PM_Ext_Budget_Filter.value="";
	x.PM_Ext_Budget.value="";
	x.PM_Actual_Filter.value="";
	x.PM_Actual.value="";
	x.PM_Support.value="";
}
function formSubmit()
{
	document.PM_reSearch.submit();
}
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>
</body>
</html>
