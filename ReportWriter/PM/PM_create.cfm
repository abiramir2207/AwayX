<CFSET PAGE_TITLE="Project Management">
<CFSET GROUP="pm">
<CFPARAM NAME="URL.FID" 	DEFAULT="">
<CFPARAM NAME="FORM.FID" 	DEFAULT="#URL.FID#">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<SCRIPT LANGUAGE="JavaScript">
function submitSaveForm()
{
	var bErr = false;
	if(document.all.PM_Priority_ID.value == "")
	{
		alert("Select a priority");
		bErr = true;
		document.all.PM_Priority_ID.focus();
		return;
	}
	if(document.all.PM_Status_ID.value == "")
	{
		alert("Select a status");
		bErr = true;
		document.all.PM_Status_ID.focus();
		return;
	}
	if(document.all.PM_Phase_ID.value == "")
	{
		alert("Select a phase");
		bErr = true;
		document.all.PM_Phase_ID.focus();
		return;
	}
	if(document.all.PM_FAR_ID.value == "")
	{
		alert("Select a functional area responsible");
		bErr = true;
		document.all.PM_FAR_ID.focus();
		return;
	}
	if(document.all.PM_Sponsor_ID.value == "")
	{
		alert("Select a sponsor");
		bErr = true;
		document.all.PM_Sponsor_ID.focus();
		return;
	}
	if(document.all.User_Positions_List.value == "")
	{
		alert("Select an owner");
		bErr = true;
		document.all.PM_Position_ID.focus();
		return;
	}
	if(document.all.PM_Value_Pounds.value > 999999999999)
	{
		alert("Numbers '> 999,999,999,999' are not allowed in the field 'Value Lbs'...");
		bErr = true;
		document.all.PM_Value_Pounds.focus();
		return;
	}
	if(document.all.PM_Value_Dollars.value > 999999999999.99)
	{
		alert("Numbers '> 999,999,999,999.99' are not allowed in the field 'Value $'...");
		bErr = true;
		document.all.PM_Value_Dollars.focus();
		return;
	}
	if(document.all.PM_Resources.value > 999999999999.99)
	{
		alert("Numbers '> 999,999,999,999.99' are not allowed in the field 'Resources $'...");
		bErr = true;
		document.all.PM_Resources.focus();
		return;
	}
	if(document.all.PM_Ext_Budget.value > 999999999999.99)
	{
		alert("Numbers '> 999,999,999,999.99' are not allowed in the field 'Budget $'...");
		bErr = true;
		document.all.PM_Ext_Budget.focus();
		return;
	}
	if(document.all.PM_Actual.value > 999999999999.99)
	{
		alert("Numbers '> 999,999,999,999.99' are not allowed in the field 'Actual $'...");
		bErr = true;
		document.all.PM_Actual.focus();
		return;
	}
	//<OPTION VALUE="" SELECTED>------ Select Phase ------</OPTION>
	
	
	if(!bErr)
	{
		document.all.PM_Create_Form.action='PM_save.cfm';
		document.all.submitForm.click();
	}
}


function formatRate(oInput, fne)
{
	useAlternateFormat = 0;
	tb = oInput;
	us = eval('document.all.PM_Create_Form' + fne)
	
	clenseText(tb,'0123456789.')
		
	
 	decimalCount = 2
	adjustPlace = 0;


	if(event.type == "keyup") 
	{
		if(tb.value.indexOf(".") != -1)
		{
			if(tb.value.length - tb.value.indexOf(".") >= (4-adjustPlace)) 
			{
				var validNumber = new NumberFormat();
				validNumber.setCommas(false);
				validNumber.setCurrency(false);
				validNumber.setPlaces(decimalCount);		
				validNumber.setNumber(tb.value);
				tb.value = validNumber.toFormatted();
			}
		}
	}
		
	if(event.type == "blur" || event.type == "change") 
	{
		var validNumber = new NumberFormat();
		validNumber.setCommas(false);
		validNumber.setCurrency(false);
		validNumber.setPlaces(decimalCount);		
		validNumber.setNumber(tb.value);
		tb.value = validNumber.toFormatted();			
	}
}
	
</SCRIPT>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

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
			Width: 185px;
		}
</style>

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<SCRIPT LANGUAGE="JavaScript" SRC="../../script/javascript/string_functions.js">
<!--- <CFINCLUDE TEMPLATE="../../script/javascript/string_functions.js"> --->
</SCRIPT>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<B>
	<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">

		<A HREF="/ReportWriter/PM/PM_Glossary.cfm" onclick="NewWindow(this.href,'name','600','500','Yes', 'No');return false;" TITLE="Glossary">glossary</A>
		</FONT>
	<FONT SIZE="2" COLOR="Red">]</FONT>
</B> <BR><BR>
<!--- <CFINCLUDE TEMPLATE="PM_Glossary.cfm">
		<b>
		<FONT SIZE = "2" COLOR="Red">[</FONT>&nbsp;<FONT SIZE="2" COLOR="Blue"><A HREF="##" onClick="javaScript: showGlossaryDiv();">glossary</A></FONT>&nbsp;<FONT COLOR="Red">]</FONT>
		</b> --->

<cfparam name="Form.RID" 	default="">
<cfparam name="URL.RID" 	default="#Form.RID#">
<!--- Include the queries used by the lookup tables --->
<CFINCLUDE TEMPLATE="PM_lookup_tables.cfm">

<CFINCLUDE TEMPLATE="PM_Lock.cfm">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the passed record via the URL											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		*
	From		PM_Item_Master	
	Where		PM_Item_Master_ID	like	'#URL.RID#'
</CFQUERY>

<CFIF isDefined("Form.UPDATE_STATE")>
	<CFSET Get_Data = QueryNew("UPDATE_STATE,RID,PM_DELETED,PM_ACCT_PROJECT,PM_PRIORITY_ID,PM_STATUS_ID,PM_PHASE_ID,PM_BROKER,PM_FAR_ID,PM_VALUE_POUNDS,PM_VALUE_DOLLARS,PM_QBRANDS_ID,PM_RESOURCES,PM_SPONSOR_ID,PM_POSITION_ID,PM_CER,PM_SUPPORT,PM_EXT_BUDGET,PM_ACTUAL,PM_CONTRACT_NUMBER,Contract_Number,PM_NOTES,PM_Start_Date,PM_End_Date,PM_Hide")>
	<cfset temp = QueryAddRow(Get_Data)>
	
	<CFLOOP INDEX="item" LIST="#Get_Data.columnList#">
		<CFIF isDefined("Form.#item#")>
			<CFSET  Temp = QuerySetCell(Get_Data, item, Evaluate("Form.#item#"))>
		</CFIF>
	</CFLOOP>

<CFELSEIF Get_Data.recordCount GT 0>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get the Brokers, idstributors and operators that this project is associated with											 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Get_QBrands" datasource="#application.datasource#">
		Select		pq.Q_Brand_ID
		From		PM_Qbrands pq
		Where		pq.PM_Item_Master_ID	like	'#URL.RID#'					
	</CFQUERY>
	<CFSET Form.QBrand_List=ValueList(Get_QBrands.Q_Brand_ID)>
	
	<CFQUERY NAME="Get_User_Positions" datasource="#application.datasource#">
		Select		PM_Owner_Position.User_Positions_ID
		From		PM_Owner_Position
		Where		PM_Owner_Position.PM_Item_Master_ID	like	'#URL.RID#'					
	</CFQUERY>
	<CFSET Form.User_Positions_List=ValueList(Get_User_Positions.User_Positions_ID)>
	
	<CFQUERY NAME="Get_Brokers" datasource="#application.datasource#">
		Select		pb.BSA_Foodservice_Brokers_ID
		From		PM_Brokers pb
		Where		pb.PM_Item_Master_ID	like	'#URL.RID#'					
	</CFQUERY>
	<CFSET Form.Broker_List=ValueList(Get_Brokers.BSA_Foodservice_Brokers_ID)>
	
	<CFQUERY NAME="Get_Distributors" datasource="#application.datasource#">
		Select		pd.BSA_Foodservice_Customers_ID
		From		PM_Distributors pd
		Where		pd.PM_Item_Master_ID	like	'#URL.RID#'					
	</CFQUERY>
	<CFSET Form.Distributor_List=ValueList(Get_Distributors.BSA_Foodservice_Customers_ID)>
	
	<CFQUERY NAME="Get_Operators" datasource="#application.datasource#">
		Select		po.BSA_Operator_ID
		From		PM_Operators po
		Where		po.PM_Item_Master_ID	like	'#URL.RID#'					
	</CFQUERY>
	<CFSET Form.Operator_List=ValueList(Get_Operators.BSA_Operator_ID)>
	
	<CFQUERY NAME="Get_Attachments" datasource="#application.datasource#">
		Select		Doc_ID
		From		Contract_Attachments
		Where		Project_ID	like	'#URL.RID#'					
	</CFQUERY>
	<CFSET Form.Attachment_List=ValueList(Get_Attachments.Doc_ID)>
</CFIF>

<cfif isDefined("Form.QBrand_List")>			
	<CFSET checkField="qb.Q_Brand_ID=">
	<CFSET fakeDelims=" OR #checkField#">
	<CFSET whereClause="#ListChangeDelims(ListQualify(FORM.QBrand_List, "'", ","), fakeDelims, ",")#">
		<CFQUERY NAME="Full_Type_Group_List" DATASOURCE="#application.datasource#">
			<CFINCLUDE TEMPLATE="#Application.Doc_mapping#/data_files/created/#application.returned_customer_setting.qry_type_group_syntax#">
		</CFQUERY>	
		<CFQUERY NAME="Get_QBrands" DBTYPE="Query">
			SELECT *
			FROM	Full_Type_Group_List
			WHERE
				1 = 2
			<CFIF Len(Form.QBrand_List) GT 0>						
				OR Type_Group_Desc_ID IN (#ListQualify(FORM.QBrand_List, "'", ",")#)
			</CFIF>
		</CFQUERY>
<cfelse>
	<CFSET Get_QBrands = QueryNew("Q_Brand")>								
</cfif>


<cfif isDefined("Form.User_Positions_List")>			
		<CFQUERY NAME="Get_User_Positions" datasource="#application.datasource#">
			SELECT User_Positions_ID, Position_Label
			FROM	User_Positions
			WHERE
				1 = 2
			<CFIF Len(Form.User_Positions_List) GT 0>						
				OR User_Positions_ID IN (#FORM.User_Positions_List#)
			</CFIF>
		</CFQUERY>
<cfelse>
	<CFSET Get_User_Positions = QueryNew("User_Positions_ID")>								
</cfif>


<cfif isDefined("Form.Broker_List")>
	<CFSET checkField="cfb.BSA_Foodservice_Brokers_ID=">
	<CFSET fakeDelims=" OR #checkField#">
	<CFSET whereClause="#ListChangeDelims(ListQualify(FORM.Broker_List, "'", ","), fakeDelims, ",")#">
	<CFQUERY NAME="Get_Brokers" datasource="#application.datasource#">
		SELECT
						cfb.Broker_Name, cfb.Broker_Shard, cfb.BSA_Foodservice_Brokers_ID
		FROM
						BSA_Foodservice_Brokers cfb
		WHERE     								
					1=2
			<CFIF Len(Form.Broker_List) GT 0>
				 OR cfb.BSA_Foodservice_Brokers_ID IN (#ListQualify(FORM.Broker_List, "'", ",")#)
			</CFIF>
			ORDER BY 	Broker_Name		
	</CFQUERY>
<cfelse>
	<CFSET Get_Brokers = QueryNew("BSA_Foodservice_Brokers_ID")>
</cfif>


<cfif isDefined("Form.Distributor_List")>			
	<CFSET checkField="cfc.BSA_Foodservice_Customers_ID=">
	<CFSET fakeDelims=" OR #checkField#">
	<CFSET whereClause="#ListChangeDelims(ListQualify(FORM.Distributor_List, "'", ","), fakeDelims, ",")#">
	<CFQUERY NAME="Get_Distributors" datasource="#application.datasource#">
		SELECT
						cfc.Ship_To, cfc.Name, cfc.BSA_Foodservice_Customers_ID
		FROM
						BSA_Foodservice_Customers cfc
		WHERE     								
					1=2
			<CFIF Len(Form.Distributor_List) GT 0>
  				 OR cfc.BSA_Foodservice_Customers_ID IN (#ListQualify(FORM.Distributor_List, "'", ",")#)
			</CFIF>
			ORDER BY 	name
	</CFQUERY>
<cfelse>
	<CFSET Get_Distributors = QueryNew("BSA_Foodservice_Customers_ID")>
</cfif>

<cfif isDefined("Form.Operator_List")>			
	<CFQUERY NAME="Get_Operators" datasource="#application.datasource#">
		SELECT
						co.Operator_Name, co.BSA_Operator_ID
		FROM
						BSA_Operator co
		WHERE     								
					1=2
			<CFIF Len(Form.Operator_List) GT 0>
				 OR co.BSA_Operator_ID IN (#ListQualify(FORM.Operator_List, "'", ",")#)
			</CFIF>
			ORDER BY 	Operator_Name
	</CFQUERY>
<cfelse>
	<CFSET Get_Operators = QueryNew("BSA_Operator_ID")>
</cfif>
<cfif isDefined("Form.Attachment_List")>			
	<CFQUERY NAME="Get_Attachments" datasource="#application.datasource#">
		SELECT
						*
		FROM
						Document_Details
		WHERE     								
					1=2
			<CFIF Len(Form.Attachment_List) GT 0>
				 OR (
				 		Document_Details.Doc_ID IN (#ListQualify(FORM.Attachment_List, "'", ",")#)						
						AND (	(	Public_View = 1
									AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
								) 						
									OR Public_View = 0	
							)
					)	
			</CFIF>
			ORDER BY 	Doc_Title
	</CFQUERY>
<cfelse>
	<CFSET Get_Attachments = QueryNew("Doc_ID")>
</cfif>

<CFQUERY NAME="Pre_Att_Doc" DATASOURCE="#Application.Datasource#">
	SELECT 		Document_Details.* 
	FROM 		Document_Details 
	INNER JOIN 	Contract_Attachments ON Document_Details.Doc_ID =  Contract_Attachments.Doc_ID
	WHERE 		1=2  
				<CFIF URL.RID NEQ ""> 
					OR (	
							Contract_Attachments.Project_ID = '#URL.RID#' 
							AND Contract_Attachments.Deleted = 0							
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preservesinglequotes(Access_Position_List)#)
									) 						
										OR Public_View = 0	
								)
						)
				</CFIF>
</CFQUERY>

<CFQUERY NAME="Get_Programs" datasource="#application.datasource#">
	Select		PM_Programs.*,
				Contract_Main.Contract_Title,
				Contract_Main.Deleted
	From		PM_Programs,
				Contract_Main
	Where		PM_Programs.PM_Item_Master_ID	like	'#URL.RID#'
				and
				Contract_Main.Contract_Number	=	PM_Programs.PM_Contract_Number
	order by	PM_Programs.PM_Contract_Number, Contract_Main.Deleted
</CFQUERY>

<CFIF URL.RID NEQ "">
	<CFQUERY NAME="Previous_Notes" DATASOURCE="#application.datasource#">
		SELECT	_Users.Name_First + ' ' + _Users.Name_Last AS Full_Name, PM_Notes.PM_Notes, PM_Notes.Created_Date
		FROM	PM_Notes
				INNER JOIN _Users
				ON
					_Users.User_ID = PM_Notes.User_ID
		WHERE
				PM_Notes.PM_Item_Master_ID = '#URL.RID#'
		ORDER BY	PM_Notes.Created_Date DESC
	</CFQUERY>
<CFELSE>
	<CFSET Previous_Notes = QueryNew("")>
</CFIF>

<cfparam name="Form.update_state" 	default="#Get_Data.recordcount#">

<CFSET PM_IsCritical = 0>
<CFIF Len(Get_Data.PM_Priority_ID) GT 0>
	<cfset useLakebaseForGet_Iscritical = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_priority")>
<cfif useLakebaseForGet_Iscritical>
	<cftry>
		<cfset Get_Iscritical = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pm_priority", {
				"pm_priority_id" = "eq.#Get_Data.PM_Priority_ID#",
				"select" = "pm_iscritical"
			}), "pm_iscritical"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Iscritical = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Iscritical>
<CFQUERY NAME="Get_Iscritical" DATASOURCE="#Application.Datasource#">
		SELECT 	PM_Iscritical 
		FROM 	PM_Priority 
		WHERE 	PM_Priority_ID = '#Get_Data.PM_Priority_ID#'
	</CFQUERY>
</cfif>
	<CFSET PM_IsCritical = Get_Iscritical.PM_Iscritical>
</CFIF>
<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2" ALIGN="center" BORDER="0">
	<TR>
		<TD ALIGN="Center"><CFIF PM_IsCritical EQ 1><img src="/Images/alert_icon_small.gif" alt="critical project" width="10" height="10" border="0"></CFIF></TD>
		<TD CLASS="tableheader"><SPAN CLASS="title">
		<CFIF PM_IS_LOCKED EQ 1>
		Create project
		<CFELSE>
		<CFOUTPUT>#Get_Data.PM_Acct_Project#</CFOUTPUT>
		</CFIF>
		</SPAN></TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="left">
		<!------------ lock here --------->	
		<div id="Layer1" style="position:absolute; width:101px; height:115px; z-index:1; left: 10px; top: 35px;"><CFOUTPUT>#Lock_String#</CFOUTPUT></div>
		
		

		</TD>
		<TD WIDTH="90%" ALIGN="center">
<CFIF PM_IS_LOCKED EQ 1>	
	<!------<CFFORM method="POST" action="PM_save.cfm">----->
	<CFFORM method="POST" action="PM_create.cfm" NAME="PM_Create_Form">
	<INPUT TYPE="hidden" NAME="first_time" VALUE="0">
	<INPUT TYPE="hidden" NAME="update_state" VALUE="<CFOUTPUT>#Form.update_state#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="RID" VALUE="<CFOUTPUT>#URL.RID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="FID" VALUE="<CFOUTPUT>#FORM.FID#</CFOUTPUT>">
	
	
	<CENTER>

	<TABLE border="0" cellspacing="0" cellpadding="3" width="95%"><!---  --->
	
	
		<TR>
			<TD COLSPAN="100%">
					
					<!--- Test if this is in editing or creation mode --->
					<CFIF RID NEQ "">
					<TABLE border="0" style="border: solid 2px red;" CELLPADDING="0" CELLSPACING="0" width="100%">
						<TR>
							<TD><INPUT TYPE="radio" NAME="PM_Deleted" VALUE="0" CHECKED></TD>
							<TD NOWRAP><B>Keep this project</B></TD>
							<TD width="50%"></TD>
							<CFIF Get_Data.PM_Hide EQ "">
								<CFSET Get_Data.PM_Hide = 0>
							</CFIF>
							<TD><INPUT TYPE="checkbox" NAME="PM_Hide" VALUE="1"<CFIF Get_Data.PM_Hide> CHECKED</CFIF>></TD>
							<TD NOWRAP><B>Hide from scorecard</B>&nbsp;&nbsp;&nbsp;</TD>
							<TD width="50%"></TD>
							<TD><INPUT TYPE="radio" NAME="PM_Deleted" VALUE="1"></TD>
							<TD NOWRAP><B>Delete this project</B>&nbsp;&nbsp;&nbsp;</TD>
						</TR>
					</TABLE>
					<!--- <BR> --->
					<CFELSE>
						<!--- <BR> --->
					</CFIF>
					<BR> 
				<B>Project:</B> <FONT COLOR=RED>Max Length: 100</FONT><BR>
				<CFINPUT TYPE="Text" NAME="PM_Acct_Project" VALUE="#Get_Data.PM_Acct_Project#" MESSAGE="You must enter a name for this project..." REQUIRED="Yes" SIZE="70" STYLE="font-size: 16px; Color: Red; font-weight: bold;" MAXLENGTH="100">
			</TD>
		</TR>
		<TR>
			<TD>
				<B>Priority:</B><BR>
				<SELECT size="1" name="PM_Priority_ID" CLASS="dropdown">
					<OPTION VALUE="" SELECTED>------ Select Priority ------</OPTION>
					<CFOUTPUT QUERY="Get_Priority"><OPTION VALUE="#PM_Priority_ID#" <CFIF PM_Priority_ID EQ Get_Data.PM_Priority_ID>SELECTED</CFIF>>#PM_Priority_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Status:</B><BR>
				<SELECT size="1" name="PM_Status_ID" CLASS="dropdown">
					<OPTION VALUE="" SELECTED>------ Select Status ------</OPTION>
					<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#PM_Status_ID#" <CFIF PM_Status_ID EQ Get_Data.PM_Status_ID>SELECTED</CFIF>>#PM_Status_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Phase:</B><BR>
				<SELECT size="1" name="PM_Phase_ID" CLASS="dropdown">
					<OPTION VALUE="" SELECTED>------ Select Phase ------</OPTION>
					<CFOUTPUT QUERY="Get_Phase"><OPTION VALUE="#PM_Phase_ID#" <CFIF PM_Phase_ID EQ Get_Data.PM_Phase_ID>SELECTED</CFIF>>#PM_Phase_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR VALIGN="top">
			<TD><B>Period:</B></CENTER>
			<CF_EASYDATE FORMNAME="PM_Create_Form" FIELDNAME="PM_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Data.PM_Start_Date#">
			<CF_EASYDATE FORMNAME="PM_Create_Form" FIELDNAME="PM_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Data.PM_End_Date#">
	
			</TD>
			
			<TD>
				<B>Owner Position:</B>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showUserPositionsSearchWindow();">pick from list</A><FONT COLOR="Red"> ]</FONT></B><BR>
				<CFPARAM NAME="FORM.User_Positions_ID" 	DEFAULT="">
				<SELECT size="5" name="PM_Position_ID" CLASS="dropdown"  onChange="javaScript:this.selectedIndex=-1;">
					<CFOUTPUT QUERY="Get_User_Positions">
						<OPTION VALUE="#User_Positions_ID#">#Position_Label#</OPTION>
					</CFOUTPUT>
				</SELECT>
				<BR>
				<FONT COLOR="#FF0000" SIZE="1"><B>Hold ctrl and click to select multiple items</B></FONT>
			</TD>
			
			
			<TD>
				
				<cfoutput><B>#application.returned_customer_setting.type_group_label_plural#:</B>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showQBrandSearchWindow();">pick from list</A><FONT COLOR="Red"> ]</FONT></B><BR></cfoutput>
				<SELECT NAME="pm_QBrands" SIZE="5" CLASS="dropdown" onChange="javaScript:this.selectedIndex=-1;">
					<CFOUTPUT QUERY="Get_QBrands">
					<OPTION VALUE="#Type_Group_Desc_ID#">#TYPE_GROUP_LEGACY# - #TYPE_GROUP_DESC#</OPTION>
					</CFOUTPUT>
				</SELECT>
	<!--- 
				<B>Broker Name:</B><BR>
				<INPUT type="text" name="PM_Broker" size="31" VALUE="<CFOUTPUT>#Get_Data.PM_Broker#</CFOUTPUT>">
	 --->
			</TD>		
		</TR>
		<TR>
			<TD>
				
				<SCRIPT LANGUAGE="JavaScript">
				function showUserPositionsSearchWindow() {
					NewWindow("/Search_Screens/Position_Search.cfm?Formname=PM_Create_Form&FieldName=User_Positions_List&AllowImportAll=1", "qbrandwindow", 800, 600, "yes", "yes")
				}
				
				function showQBrandSearchWindow() {
					NewWindow("pm_select_QBrands.cfm?Formname=PM_Create_Form", "qbrandwindow", 800, 600, "yes", "yes")
				}
				
				function showBrokersSearchWindow() {
					NewWindow("/Billbacks/search_screens/pm_select_brokers.cfm?Formname=PM_Create_Form", "brokerwindow", 800, 600, "yes", "yes")
				}
				
				function showDistribuitorsSearchWindow() {
					//NewWindow("PM_select_distributors.cfm?Formname=PM_Create_Form", "distributorwindow", 800, 600, "yes", "yes")
					NewWindow("/Billbacks/search_screens/PM_select_distributors.cfm?Formname=PM_Create_Form", "distributorwindow", 800, 600, "yes", "yes")
				}
				
				
				function showOperatorsSearchWindow() {
					NewWindow("/Billbacks/search_screens/PM_select_operators.cfm?Formname=PM_Create_Form", "operatorwindow", 800, 600, "yes", "yes")
				}
				</SCRIPT>
				
				
				
				
				<cfoutput><B>#application.returned_customer_setting.broker_label_plural#:</B>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showBrokersSearchWindow();">pick from list</A><FONT COLOR="Red"> ]</FONT></B><BR></cfoutput>
				<SELECT NAME="pm_Brokers" SIZE="5" CLASS="dropdown" onChange="javaScript:this.selectedIndex=-1;">
					<CFOUTPUT QUERY="Get_Brokers">
						<OPTION VALUE="#BSA_Foodservice_Brokers_ID#">#Broker_Shard# - #Broker_Name#</OPTION>
					</CFOUTPUT>
				</SELECT>
				
				
			</TD>
			<TD>
			
				
				<cfoutput><B>#application.returned_customer_setting.distributor_label_plural#</B>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showDistribuitorsSearchWindow();">pick from list</A><FONT COLOR="Red"> ]</FONT></B><BR></cfoutput>
				<SELECT NAME="pm_Distributors" SIZE="5" CLASS="dropdown" onChange="javaScript:this.selectedIndex=-1;">
					<CFOUTPUT QUERY="Get_Distributors">
					<OPTION VALUE="#BSA_Foodservice_Customers_ID#">#ship_To# - #Name#</OPTION>
					</CFOUTPUT>
				</SELECT>
				<INPUT TYPE="HIDDEN" NAME="SelectSingleSearchResultOnly" VALUE="0">
			</TD>
			<TD>
				
				<B><cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>:</B>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showOperatorsSearchWindow();">pick from list</A><FONT COLOR="Red"> ]</FONT></B><BR>
				<SELECT NAME="pm_Operators" SIZE="5" CLASS="dropdown" onChange="javaScript:this.selectedIndex=-1;">
					<CFOUTPUT QUERY="Get_Operators">
					<OPTION VALUE="#BSA_Operator_ID#">#Operator_Name#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
	<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>
		<TR>
			<TD><B>Value Lbs.:</B><BR>
				<INPUT TYPE="Text" NAME="PM_Value_Pounds" VALUE=<CFOUTPUT>"#NumberFormat(Get_Data.PM_Value_Pounds,"_")#"</CFOUTPUT>  SIZE="31" ONKEYUP="clenseText(this,'0123456789')" MAXLENGTH="12"><!--- < 9999999999999 --->
			</TD>
			<TD><B>Value $:</B><BR>
				<INPUT type="text" name="PM_Value_Dollars" VALUE=<CFOUTPUT>"#NumberFormat(Get_Data.PM_Value_Dollars,"_.__")#"</CFOUTPUT> REQUIRED="No" SIZE="31" MAXLENGTH="15" ONKEYUP="formatRate(this,'PM_Value_Dollars')" ONBLUR="formatRate(this,'PM_Value_Dollars')"><!--- MESSAGE="Only numbers (< 9999999.999) are allowed in the In the Value - $ field..." Range="0,9999999.999"--->
			</TD>
			<TD>
				<B>Resources $:</B><BR>
				<INPUT type="text" name="PM_Resources" size="31" VALUE=<CFOUTPUT>"#NumberFormat(Get_Data.PM_Resources,"_.__")#"</CFOUTPUT> REQUIRED="No" MAXLENGTH="15" ONKEYUP="formatRate(this,'PM_Resources')" ONBLUR="formatRate(this,'PM_Resources')"><!--- MESSAGE="Only numbers (< 9999999.999) are allowed in the In the Resources $ field..." Range="0,9999999.999" --->
			</TD>
		</TR>
		<TR>
			<TD>
				<B>Sponsor:</B><BR>
				<SELECT size="1" name="PM_Sponsor_ID" CLASS="dropdown">
					<OPTION VALUE="" SELECTED>------ Select Sponsor ------</OPTION>
					<CFOUTPUT QUERY="Get_Sponsor"><OPTION VALUE="#Get_Sponsor.PM_Sponsor_ID#" <CFIF PM_Sponsor_ID EQ Get_Data.PM_Sponsor_ID>SELECTED</CFIF>>#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</OPTION></CFOUTPUT>
				</SELECT>
	
			</TD>
	
	
	
	
			<TD>
				<B>Functional Area Responsible:</B><BR>				
				<SELECT size="1" name="PM_FAR_ID" CLASS="dropdown">
					<OPTION VALUE="" SELECTED>------ Select Functional Area ------</OPTION>
					<CFOUTPUT QUERY="Get_FAR"><OPTION VALUE="#PM_FAR_ID#" <CFIF PM_FAR_ID EQ Get_Data.PM_FAR_ID>SELECTED</CFIF>>#PM_FAR_Description#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			
	
			<TD>
				<B>CER/Acct Number:</B> <FONT COLOR=RED>Max Length: 50</FONT><BR>
				<INPUT type="text" name="PM_CER" size="31" VALUE="<CFOUTPUT>#Get_Data.PM_CER#</CFOUTPUT>" MAXLENGTH="50">
			</TD>
		</TR>
		<TR>
			<TD>
				<B>Support:</B> <FONT COLOR=RED>Max Length: 50</FONT><BR>
				<CFOUTPUT>
				<CFINPUT type="text" name="PM_Support" size="31" VALUE="#Get_Data.PM_Support#" MAXLENGTH="50">
				</CFOUTPUT>
			</TD>
			<TD>
				<B>Budget $:</B><BR>
				<INPUT TYPE="Text" NAME="PM_Ext_Budget" VALUE=<CFOUTPUT>"#NumberFormat(Get_Data.PM_Ext_Budget,"_.__")#"</CFOUTPUT> REQUIRED="No" SIZE="31" MAXLENGTH="15" ONKEYUP="formatRate(this,'PM_Ext_Budget')" ONBLUR="formatRate(this,'PM_Ext_Budget')">
			</TD>
			<TD>
				<B>Actual $:</B><BR>
				<INPUT TYPE="Text" NAME="PM_Actual" VALUE=<CFOUTPUT>"#NumberFormat(Get_Data.PM_Actual,"_.__")#"</CFOUTPUT> REQUIRED="No" SIZE="31" MAXLENGTH="15" ONKEYUP="formatRate(this,'PM_Actual')" ONBLUR="formatRate(this,'PM_Actual')">
			</TD>
		</TR>
		<TR>
			<TD colspan="3"><br>
				<SPAN STYLE="Font-Size: 15px; color : navy"><B>Programs:</SPAN>
				&nbsp;&nbsp;&nbsp;&nbsp;				
					<CFOUTPUT>
				<!----
				<FONT COLOR="Red">[</FONT> 				
					<A HREF="/ReportWriter/pm/pm_get_programs.cfm?RID=#URL.RID#"  onclick="NewWindow(this.href + '&Formname=PM_Create_Form','MyWindowName','800','600','Yes', 'Yes');return false;">pick from list</A> 
				<FONT COLOR="Red">]</FONT> 
				---->
				<FONT COLOR="Red">[</FONT> 
					<A HREF="/Search_Screens/Program_Search.cfm?ReturnFieldName=Contract_Number&AllowImportAll=1"  onclick="NewWindow(this.href + '&Formname=PM_Create_Form&FieldName=Contract_Number','MyWindowName','800','600','Yes', 'Yes');return false;">pick from list</A> 				
	
	
				<FONT COLOR="Red">]</FONT> 
				</CFOUTPUT>
				</B><BR>
				<HR color="navy">
	
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Get the programs that this project is associated with											 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					
		<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" <!--- 600 --->CLASS="MainTable">
	
			<TR><TD COLSPAN="100%"><SPAN STYLE="font-size: 12px; font-weight: bold;">Previously saved</TD></TR>	
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- Programs from the database --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->			
			<CFSET Saved_Contract_Number = ValueList(Get_Programs.PM_Contract_Number, ",")>
			<CFIF isDefined("Form.Contract_Number")>
				<CFSET Recently_Selected_Program_List = Form.Contract_Number>
			<CFELSE>
				<CFSET Recently_Selected_Program_List = Saved_Contract_Number>
			</CFIF>
			<CFPARAM NAME="Form.Contract_Number" DEFAULT="">
			<CFOUTPUT QUERY="Get_Programs" GROUP="PM_Contract_Number">  
			
			<!--- Check if this program has been deleted --->
			<CFIF Get_Programs.Deleted EQ 1>
				<CFSET status=" disabled">
				<CFSET flag="<IMG SRC=""/images/no_small.gif"" WIDTH=""12"" HEIGHT=""12"" BORDER=""0"" ALT=""This program has been deleted..."">">
			<CFELSE>
				<CFSET status="">
				<CFSET flag="<IMG SRC=""/images/fill.gif"" WIDTH=""12"" HEIGHT=""12"" BORDER=""0"" ALT=""This program has been deleted..."">">
			</CFIF>
		
			<TR VALIGN="top">
				<TD><INPUT TYPE="checkbox" NAME="PM_Contract_Number" VALUE="#PM_Contract_Number#" <CFIF ListFindNoCase(Recently_Selected_Program_List, PM_Contract_Number, ",")>CHECKED</CFIF>#status#></TD>
				<TD NOWRAP>#PM_Contract_Number# #flag#</TD>
				<TD>#Contract_Title#</TD>
			</TR>
			</CFOUTPUT>
			
			
	
			<TR><TD COLSPAN="100%"><SPAN STYLE="font-size: 12px; font-weight: bold;"><BR>Recently selected</SPAN> <FONT COLOR="Red">(not yet saved)</FONT></TD></TR>	
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- Programs from the selection page --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<CFSET Proper_New_Contract_Number = "">
			<CFLOOP INDEX="item" LIST="#Form.Contract_Number#">
			
			<CFIF NOT ListFindNoCase(Saved_Contract_Number, item, ",")>
				<cfset useLakebaseForGet_Programs_Selected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGet_Programs_Selected>
	<cftry>
		<cfset Get_Programs_Selected = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#Item#",
				"select" = "contract_title"
			}), "contract_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Programs_Selected = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Programs_Selected>
<CFQUERY NAME="Get_Programs_Selected" datasource="#application.datasource#">
					Select		Contract_Main.Contract_Title
					From		Contract_Main
					Where		Contract_Main.Contract_Number	=	'#Item#'
				</CFQUERY>
</cfif>
		
				<TR VALIGN="top">
					<TD><CFOUTPUT><INPUT TYPE="checkbox" NAME="PM_Contract_Number" VALUE="#Item#" CHECKED></CFOUTPUT></TD>
					<TD NOWRAP><CFOUTPUT>#Item#</CFOUTPUT></TD>
					<TD><CFOUTPUT>#Get_Programs_Selected.Contract_Title#</CFOUTPUT></TD>
				</TR>
				<CFSET Proper_New_Contract_Number = ListAppend(Proper_New_Contract_Number, item, ",")>
			</CFIF>
			</CFLOOP>
			<CFSET Form.Contract_Number = ListAppend(Proper_New_Contract_Number, Saved_Contract_Number, ",")>			
		</TABLE>
	
	
	
		<TR>
			<TD colspan="3"> <br><SPAN STYLE="Font-Size: 15px; color : navy"><b>Documents:</b></SPAN>&nbsp;&nbsp;&nbsp;&nbsp;
				<B><CFOUTPUT>				
				<FONT COLOR="Red">[</FONT> 
					<A HREF="javascript: void(0);" onclick="NewWindow('/common_files/Documents/Attach_Document.cfm?Form_Name=PM_Create_Form','name','800','600','Yes', 'No');return false;" >attach from list</A> 					
				<FONT COLOR="Red">]</FONT> 
				</CFOUTPUT></B> 
				<HR color="navy">
				<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" <!--- 600 --->CLASS="MainTable">
					
					<TR><TD COLSPAN="100%"><SPAN STYLE="font-size: 12px; font-weight: bold;">Previously saved</TD></TR>						
					<CFIF Pre_Att_Doc.recordcount GT 0>
						<TR>
							<TD>&nbsp;</TD>
							<TD STYLE="font-size: 11px; font-weight: bold;">Date<br>Name</TD>
							<TD STYLE="font-size: 11px; font-weight: bold;">File</TD>
							<TD STYLE="font-size: 11px; font-weight: bold;">Title<br>Description</TD>
							<TD STYLE="font-size: 11px; font-weight: bold;">Type</TD>
						</TR>
					</CFIF>
						<CFSET Saved_Attachment_List = ValueList(Pre_Att_Doc.Doc_ID, ",")>
						
						<CFIF isDefined("Form.Attachment_List")>
							<CFSET Recently_Selected_Attach_List = Form.Attachment_List>
						<CFELSE>
							<CFSET Recently_Selected_Attach_List = Saved_Attachment_List>
						</CFIF>
						<CFOUTPUT QUERY = "Pre_Att_Doc">
						<cfset useLakebaseForUser_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForUser_Name>
	<cftry>
		<cfset User_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUser_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUser_Name>
<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
								SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
						</CFQUERY>
</cfif>
						<TR VALIGN="top">
							<TD WIDTH="3%"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#"<CFIF ListFindNoCase(Recently_Selected_Attach_List, Doc_ID, ",")>CHECKED</CFIF>></TD>
							<TD WIDTH="13%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#User_Name.Name_First# #User_Name.Name_Last#</TD>
							<CFSET SIZEinMB = #Doc_size#/1048576>
							<TD TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
							<CFSET Display_Name=Left(Doc_File_Name,20)>
							<CFIF len(trim(Doc_File_Name)) GT 20>
								#Display_Name#...
							<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
								&nbsp;
							<CFELSE>
								#Display_Name#	
							</CFIF>		
							</A><br>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</TD>
							<TD WIDTH="58%"><FONT color="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</TD>
							<TD WIDTH="12%">#Doc_Type#</TD>
						</TR>
						</CFOUTPUT>
					
					<TR><TD COLSPAN="100%"><SPAN STYLE="font-size: 12px; font-weight: bold;"><BR>Recently selected</SPAN> <FONT COLOR="Red">(not yet saved)</FONT></TD></TR>						
					<CFPARAM NAME="FORM.Attachment_List" DEFAULT="">					
					<CFLOOP INDEX="item" LIST="#Form.Attachment_List#">			
					<CFIF NOT ListFindNoCase(Saved_Attachment_List, item, ",")>
					<TR>
						<TD>&nbsp;</TD>
						<TD STYLE="font-size: 11px; font-weight: bold;">Date<BR>Name</TD>
						<TD STYLE="font-size: 11px; font-weight: bold;">File</TD>
						<TD STYLE="font-size: 11px; font-weight: bold;">Title<br>Description</TD>
						<TD STYLE="font-size: 11px; font-weight: bold;">Type</TD>
					</TR>	
					<CFBREAK>			
					</CFIF>
					</CFLOOP>
					<!--- <CFPARAM NAME="FORM.Attachment_List" DEFAULT=""> --->					
					<CFLOOP INDEX="item" LIST="#Form.Attachment_List#">			
					<CFIF NOT ListFindNoCase(Saved_Attachment_List, item, ",")>
						<cfset useLakebaseForGet_Document_Selected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_attachments")>
<cfif useLakebaseForGet_Document_Selected>
	<cftry>
		<cfset Get_Document_Selected = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_attachments", {
				"doc_id" = "eq.#Item#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Document_Selected = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Document_Selected>
<CFQUERY NAME="Get_Document_Selected" DBTYPE="query">
							Select		*
							From		Get_Attachments
							Where		Doc_ID	=	'#Item#'
						</CFQUERY>
</cfif>
						<CFOUTPUT QUERY="Get_Document_Selected">
						<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
								SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
						</CFQUERY>
						<TR VALIGN="top">
							<TR VALIGN="top">
							<TD WIDTH="3%"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" CHECKED></TD>
							<TD WIDTH="13%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#User_Name.Name_First# #User_Name.Name_Last#</TD>
							<CFSET SIZEinMB = #Doc_size#/1024>
							<TD NOWRAP TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
								<CFSET Display_Name=Left(Doc_File_Name,20)>
								<CFIF len(trim(Doc_File_Name)) GT 20>
									#LCASE(Display_Name)#...
								<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
									&nbsp;
								<CFELSE>
									#LCASE(Display_Name)#	
								</CFIF>		
							</A><br>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</TD>
							<TD WIDTH="58%"><FONT COLOR="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</TD>
							<TD WIDTH="12%">#Doc_Type#</TD>
						</TR>
						</CFOUTPUT>
						</TR>
					</CFIF>
					</CFLOOP>
				</TABLE>
			</TD>
		</TR>
		<BR>
		<!--- <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="600"> --->
		<TR>
			<TD colspan="100%" STYLE="Font-Size: 15px; color : navy"><BR><A name="Notes"></A><B>Notes:</B><HR color="navy"></TD>
		</TR>
		<TR>
			<TD colspan="100%">
			<B>Next Step / Update:</B><BR>
			<TEXTAREA rows="6" name="PM_Notes" cols="160"></TEXTAREA>
			</TD>
		</TR>
		
		<CFIF Previous_Notes.recordCount GT 0>	
		<TR>
			<TD colspan="100%">
				<CFSCRIPT>
					Border="Yes";
					BorderSize=1;  
					BorderColor="Silver";
					Image="/images/plus3.gif";
					ImageOpen="/images/minus3.gif";
					TitleColor="Navy"; 
					TitleFont="Arial";
					TitleSize=8;
					IsClosed="No";  
					WIDTH="100%";
				</CFSCRIPT>
				<CFSET Open_Layer_Caption = "Previous Update(s)">
				<CF_openLayer
					Border="#Border#"
					BorderSize="#BorderSize#"  
					BorderColor="#BorderColor#"  
					Image="#Image#"
					ImageOpen="#ImageOpen#"
					Title="Hide #Open_Layer_Caption#"  
					TitleClosed="Show #Open_Layer_Caption#"  
					TitleTooltip="#Open_Layer_Caption#"  
					TitleColor="#TitleColor#"  
					TitleFont="#TitleFont#"
					TitleSize="#TitleSize#"
					IsClosed="No"
					Width="#width#">
				<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%"<!--- 580 ---> CLASS="MainTable">
				<CFOUTPUT QUERY="Previous_Notes">
					<!-------
					<TR VALIGN="top">
						<TD>
							#Full_Name#<BR>#DateFormat(Created_Date, "mm/dd/yyyy")#
						</TD>
						<TD WIDTH="80%">
							&nbsp;#PM_Notes#
						</TD>							
					</TR>
					------->
					<TR VALIGN="top">
						<TD STYLE="border:none" NOWRAP><FONT SIZE="2"><B>#Full_Name#</B></FONT></TD>
						<TD STYLE="border:none" NOWRAP><FONT SIZE="2"><B> - #DateFormat(Created_Date, "mm/dd/yyyy")#</B></FONT></TD>
						<TD STYLE="border:none" WIDTH="90%">&nbsp;</TD>
					</TR>
					<TR VALIGN="top" BGCOLOR="eeeeee">
						<TD STYLE="border:none" COLSPAN="100%">#Replace(PM_Notes, "#chr(13)#", "<br>", "All")#&nbsp;</TD>
					</TR>
						
				</CFOUTPUT>
				</TABLE> 
				</CF_openLayer>
			</TD>
		</TR>
		</CFIF>
		<!--- </TABLE> --->
		</TD>
		</TR>
	</TABLE>	
	<input type="submit" value="Submit" id="submitForm" name="submitForm" style="display:none">
	<CFOUTPUT>
	
	<INPUT TYPE="Hidden" ID="Broker_List" NAME="Broker_List" VALUE="<cfif isDefined("Form.Broker_List")>#Form.Broker_List#</cfif>">
	<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="<cfif isDefined("Form.Distributor_List")>#Form.Distributor_List#</cfif>">
	<INPUT TYPE="Hidden" ID="Operator_List" NAME="Operator_List" VALUE="<cfif isDefined("Form.Operator_List")>#Form.Operator_List#</cfif>">
	<INPUT TYPE="Hidden" ID="Contract_Number" NAME="Contract_Number" VALUE="<cfif isDefined("Form.Contract_Number")>#Form.Contract_Number#</cfif>">
	<INPUT TYPE="Hidden" ID="QBrand_List" NAME="QBrand_List" VALUE="<cfif isDefined("Form.QBrand_List")>#Form.QBrand_List#</cfif>">
	<INPUT TYPE="Hidden" ID="User_Positions_List" NAME="User_Positions_List" VALUE="<cfif isDefined("Form.User_Positions_List")>#Form.User_Positions_List#</cfif>">
	<INPUT TYPE="Hidden" ID="Attachment_List" NAME="Attachment_List" VALUE="<cfif isDefined("Form.Attachment_List")>#Form.Attachment_List#</cfif>">
	
	</CFOUTPUT>
	</CFFORM>
	<B><FONT COLOR="Red">[</FONT>&nbsp;<A  onClick="javaScript: submitSaveForm();" HREF="#">save data</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<CFPARAM NAME="FORM.first_time" 	DEFAULT="1">
	<CFIF PM_IS_LOCKED EQ 1 AND URL.RID NEQ "" AND FORM.first_time EQ "1">
		<SCRIPT language="JavaScript">
		window.location.hash = "Notes";
		function focusToNotes()
		{
			document.PM_Create_Form.PM_Notes.focus()		 
		}
		document.body.onload = new Function("focusToNotes();");
		window.setTimeout("focusToNotes()", 500);
		</SCRIPT>
	</CFIF>
<CFELSE>
	<!------ Not locked -------->
	<CFOUTPUT>
	<STYLE>
		.project_Display TD
		{
			border-bottom: 1px ##eeeeee solid;
		}
		.no_border TD
		{
			border: none;
		}
	</STYLE>
	
	<TABLE CELLPADDING="0" CELLSPACING="4" BORDER="0" WIDTH="95%" CLASS="project_Display" ALIGN="center">
		<TR>
			&nbsp;
		</TR>

		<COLGROUP>
			<COL SPAN="1" STYLE="font-size:12px;font-weight:bold;" WIDTH="180"></COL>
			<COL SPAN="2" WIDTH="1"></COL>
			<COL SPAN="1" WIDTH=""></COL>
		</COLGROUP>
		
		
		<!---- Priority ---->
		<cfset useLakebaseForThis_Priority = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_priority")>
<cfif useLakebaseForThis_Priority>
	<cftry>
		<cfset This_Priority = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_priority", {
				"pm_priority_id" = "eq.#Get_Data.PM_Priority_ID#",
				"select" = "pm_priority_description"
			}), "pm_priority_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Priority = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Priority>
<CFQUERY NAME="This_Priority" DBTYPE="query">
		SELECT	PM_Priority_Description
		FROM	Get_Priority
		WHERE
				PM_Priority_ID = '#Get_Data.PM_Priority_ID#'
		</CFQUERY>
</cfif>
		<TR>
			<TD>Priority:</TD>
			<TD ROWSPAN="100%" BGCOLOR="Navy"><IMG SRC="/Images/fill.gif" WIDTH="1"></TD>
			<TD ROWSPAN="100%" STYLE="border: none;">&nbsp;</TD>	
			<TD>#This_Priority.PM_Priority_Description#&nbsp;</TD>
		</TR>
		<!---- Status ---->
		<cfset useLakebaseForThis_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_status")>
<cfif useLakebaseForThis_Status>
	<cftry>
		<cfset This_Status = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_status", {
				"pm_status_id" = "eq.#Get_Data.PM_Status_ID#",
				"select" = "pm_status_description"
			}), "pm_status_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Status>
<CFQUERY NAME="This_Status" DBTYPE="query">
		SELECT	PM_Status_Description
		FROM	Get_Status
		WHERE
				PM_Status_ID = '#Get_Data.PM_Status_ID#'
		</CFQUERY>
</cfif>
		<TR>
			<TD>Status:</TD>			
			<TD>#This_Status.PM_Status_Description#&nbsp;</TD>
		</TR>
		<!---- Phase ---->
		<cfset useLakebaseForThis_Phase = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_phase")>
<cfif useLakebaseForThis_Phase>
	<cftry>
		<cfset This_Phase = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_phase", {
				"pm_phase_id" = "eq.#Get_Data.PM_Phase_ID#",
				"select" = "pm_phase_description"
			}), "pm_phase_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Phase = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Phase>
<CFQUERY NAME="This_Phase" DBTYPE="query">
		SELECT	PM_Phase_Description
		FROM	Get_Phase
		WHERE
				PM_Phase_ID = '#Get_Data.PM_Phase_ID#'
		</CFQUERY>
</cfif>
		<TR>
			<TD>Phase:</TD>			
			<TD>#This_Phase.PM_Phase_Description#&nbsp;</TD>
		</TR>
		<!---- Period --->
		<TR>
			<TD>Period:</TD>			
			<TD>#DateFormat(Get_Data.PM_Start_Date, "mm/dd/yyyy")# - #DateFormat(Get_Data.PM_End_Date, "mm/dd/yyyy")#&nbsp;</TD>
		</TR>
		
		<!---- Functional Area Responsible --->
		<cfset useLakebaseForGet_FAR = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_far")>
<cfif useLakebaseForGet_FAR>
	<cftry>
		<cfset Get_FAR = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pm_far", {
				"pm_far_id" = "eq.#Get_Data.PM_FAR_ID#",
				"select" = "pm_far_description"
			}), "pm_far_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_FAR = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_FAR>
<CFQUERY NAME="Get_FAR" datasource="#application.datasource#">
			SELECT PM_FAR_Description FROM PM_FAR WHERE PM_FAR_ID = '#Get_Data.PM_FAR_ID#' 
		</CFQUERY>
</cfif>
		<TR>
			<TD>Functional Area Responsible:</TD>			
			<TD>#Get_FAR.PM_FAR_Description#&nbsp;</TD>
		</TR>
		
		<TR VALIGN="top">
			<TD>Owners</TD>
			<TD>
			
			<CFIF Get_User_Positions.recordCount GT 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" CLASS="no_border" WIDTH="100%">
				<CFLOOP QUERY="Get_User_Positions">
				<TR BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD>#Position_Label#</TD>
				</TR>
				</CFLOOP>
			</TABLE>
			<CFELSE>
			None Selected
			</CFIF>
			</TD>
		</TR>
		
		<!---- Type Groups ---->		
		<TR VALIGN="top">
			<TD>
			#application.returned_customer_setting.type_group_label_plural#:</TD>
			<TD>
			
			<CFIF Get_QBrands.recordCount GT 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" CLASS="no_border" WIDTH="100%">
				<CFLOOP QUERY="Get_QBrands">
				<TR BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD>#TYPE_GROUP_LEGACY# - #TYPE_GROUP_DESC#</TD>
				</TR>
				</CFLOOP>
			</TABLE>
			<CFELSE>
			None Selected
			</CFIF>
			</TD>
		</TR>
		
		<!---- Brokers ---->		
		<TR VALIGN="top">
			<TD>
			#application.returned_customer_setting.broker_label_plural#:</TD>
			<TD>
			
			<CFIF Get_Brokers.recordCount GT 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" CLASS="no_border" WIDTH="100%">
				<CFLOOP QUERY="Get_Brokers">
				<TR BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD>#Broker_Shard# - #Broker_Name#</TD>
				</TR>
				</CFLOOP>
			</TABLE>
			<CFELSE>
			None Selected
			</CFIF>
			</TD>
		</TR>
		
		<!---- Distributors ---->		
		<TR VALIGN="top">
			<TD>
			#application.returned_customer_setting.distributor_label_plural#:</TD>
			<TD>
			
			<CFIF Get_Distributors.recordCount GT 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" CLASS="no_border" WIDTH="100%">
				<CFLOOP QUERY="Get_Distributors">
				<TR BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD>#ship_To# - #Name#</TD>
				</TR>
				</CFLOOP>
			</TABLE>
			<CFELSE>
			None Selected
			</CFIF>
			</TD>
		</TR>
		
		<!---- Operators ---->		
		<TR VALIGN="top">
			<TD>#application.returned_customer_setting.operator_label_plural#:</TD>
			<TD>
			
			<CFIF Get_Operators.recordCount GT 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" CLASS="no_border" WIDTH="100%">
				<CFLOOP QUERY="Get_Operators">
				<TR BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD>#Operator_Name#</TD>
				</TR>
				</CFLOOP>
			</TABLE>
			<CFELSE>
			None Selected
			</CFIF>
			</TD>
		</TR>
		
		<!---- Value --->
		<TR>
			<TD>Value:</TD>			
			<TD>#Get_Data.PM_Value_Pounds# Lbs&nbsp;</TD>
		</TR>
		
		<!---- Value --->
		<TR>
			<TD>Value:</TD>			
			<TD>#DollarFormat(Get_Data.PM_Value_Dollars)#&nbsp;</TD>
		</TR>
		
		<!---- Resources --->
		<TR>
			<TD>Resources:</TD>			
			<TD>#DollarFormat(Get_Data.PM_Resources)#&nbsp;</TD>
		</TR>
		
		<!---- CER/Acct Number --->
		<TR>
			<TD>CER/Acct Number:</TD>			
			<TD>#Get_Data.PM_CER#&nbsp;</TD>
		</TR>
		
		<!---- Support --->
		<TR>
			<TD>Support:</TD>			
			<TD>#Get_Data.PM_Support#&nbsp;</TD>
		</TR>
		
		<!---- Support --->
		<TR>
			<TD>Budget:</TD>			
			<TD>#DollarFormat(Get_Data.PM_Ext_Budget)#&nbsp;</TD>
		</TR>
		
		<!---- Actual --->
		<TR>
			<TD>Actual:</TD>			
			<TD>#DollarFormat(Get_Data.PM_Actual)#&nbsp;</TD>
		</TR>
		
		<!---- Sponsor --->
		<cfset useLakebaseForThis_Sponsor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_sponsor")>
<cfif useLakebaseForThis_Sponsor>
	<cftry>
		<cfset This_Sponsor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_sponsor", {
				"pm_sponsor_id" = "eq.#Get_Data.PM_Sponsor_ID#",
				"select" = "pm_sponsor_name_first,pm_sponsor_name_last"
			}), "pm_sponsor_name_first,pm_sponsor_name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Sponsor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Sponsor>
<CFQUERY NAME="This_Sponsor" DBTYPE="query">
		SELECT	PM_Sponsor_Name_First, PM_Sponsor_Name_Last
		FROM	Get_Sponsor
		WHERE
				PM_Sponsor_ID = '#Get_Data.PM_Sponsor_ID#'
		</CFQUERY>
</cfif>
		<TR>
			<TD>Sponsor:</TD>			
			<TD>#This_Sponsor.PM_Sponsor_Name_First# #This_Sponsor.PM_Sponsor_Name_Last#&nbsp;</TD>
		</TR>
	</CFOUTPUT>
		<!---- Programs ----->
		<TR VALIGN="top">
			<TD>Programs</TD>
			<TD>
			
			<CFIF Get_Programs.recordCount GT 0>
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="no_border" WIDTH="100%">
				<CFOUTPUT QUERY="Get_Programs" GROUP="PM_Contract_Number">			
				<!--- Check if this program has been deleted --->
				<CFIF Get_Programs.Deleted EQ 1>
					<CFSET status=" disabled">
					<CFSET flag="<IMG SRC=""/images/no_small.gif"" WIDTH=""12"" HEIGHT=""12"" BORDER=""0"" ALT=""This program has been deleted..."">">
				<CFELSE>
					<CFSET status="">
					<CFSET flag="<IMG SRC=""/images/fill.gif"" WIDTH=""12"" HEIGHT=""12"" BORDER=""0"" ALT=""This program has been deleted..."">">
				</CFIF>
			
				<TR VALIGN="top" BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD NOWRAP>#PM_Contract_Number# #flag#</TD>
					<TD>#Contract_Title#</TD>
				</TR>
				</CFOUTPUT>
				</TABLE>
			<CFELSE>
				None Selected
			</CFIF>			
			</TD>
		</TR>
		<TR VALIGN="top">
			<TD>Attachments</TD>
			<TD>			
			<CFIF Pre_Att_Doc.recordCount GT 0>
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0"  WIDTH="100%">
				<CFOUTPUT QUERY = "Pre_Att_Doc">
					<TR VALIGN="top" BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
							SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
					</CFQUERY>
						<TD WIDTH="16%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#User_Name.Name_First# #User_Name.Name_Last#</TD>
						<CFSET SIZEinMB = #Doc_size#/1024>
						<TD NOWRAP TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#Doc_Uni_Name#');"  TITLE="Click here to view #Doc_File_Name#">
							<CFSET Display_Name=Left(Doc_File_Name,15)>
							<CFIF len(trim(Doc_File_Name)) GT 15>
								#LCASE(Display_Name)#...
							<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
								&nbsp;
							<CFELSE>
								#LCASE(Display_Name)#	
							</CFIF>		
							</A><BR>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</TD>
						<TD WIDTH="58%"><FONT COLOR="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</TD>
						<TD WIDTH="12%">#Doc_Type#</TD>
					</TR>
				</CFOUTPUT>
				</TABLE>
			<CFELSE>
				None Selected
			</CFIF>
			</TD>
		</TR>
	<CFOUTPUT>
		<!---- Notes ----->
		<TR VALIGN="top">
			<TD>Notes</TD>
			<TD>
			<CFIF Previous_Notes.recordCount GT 0>
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="no_border" WIDTH="100%">
				<CFLOOP QUERY="Previous_Notes">			
					<TR VALIGN="top" BGCOLOR="#IIF(CurrentRow MOD 2, DE("FFFFFF"), DE("CCFFCC"))#">
					<TD NOWRAP WIDTH="100"><B>#Full_Name#</B></TD>
					<TD NOWRAP WIDTH="100"><B>#DateFormat(Created_Date, "mm/dd/yyyy")#</B></TD>
					<TD>#Replace(PM_Notes, "#chr(13)#", "<br>", "All")#</TD>
					</TR>
				</TR>
				</CFLOOP>
				</TABLE>
			<CFELSE>
				None Selected
			</CFIF>			
			</TD>
		</TR>
	</TABLE>
	
	</CFOUTPUT>
</CFIF>
	<CFOUTPUT>
	<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="index.cfm">search projects</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
	<!------&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="#" ONCLICK="javaScript: return goback_To_Search();">back to search results</A>&nbsp;<FONT COLOR="Red">]</FONT></B>----->
	&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="PM_Display.cfm?FID=#FORM.FID#">back to search results</A>&nbsp;<FONT COLOR="Red">]</FONT></B>	
	<CFIF PM_IS_LOCKED EQ 1>
	&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="PM_Copy.cfm?RID=#URL.RID#&FID=#FORM.FID#" ONCLICK="return window.confirm('Do you really want to make a copy of this project?');">copy this project</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
	</CFIF>
	</CFOUTPUT>
</TD>
	</TR>
	</TABLE>
	
<SCRIPT>
	function goback_To_Search()
	{
		document.GotoSearchPage.submit();
		return false;
	}
</SCRIPT>

</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT LANGUAGE="JavaScript">
findselectboxes();
</SCRIPT>
</BODY>
</HTML>



