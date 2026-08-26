<CFSET PAGE_TITLE="Project Management">
<CFSET GROUP="pm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<!------ Spinner ----->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
<br><br><br>
<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
<br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!------ Spinner ----->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Glossary div goes here
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!--- <CFINCLUDE TEMPLATE="PM_Glossary.cfm"> --->

<CFPARAM NAME="URL.FID" 	DEFAULT="">
<CFPARAM NAME="FORM.FID" 	DEFAULT="#URL.FID#">
<CFSET OBJ_FORM_VALUES = CreateObject("component", "components.general.Stored_Form_Values")>
<CFSET D_TEMP = OBJ_FORM_VALUES.Set_File_Properties(Application.Doc_Path, "\Temp_Files\Project_Search\", "#FORM.FID#")>

<CFSET D_TEMP = OBJ_FORM_VALUES.Load(1)>
<CFSET FORM.FID = OBJ_FORM_VALUES.Save()>


<!--- Setup the default settings for the master query --->
<CFPARAM NAME="PM_Acct_Project" DEFAULT="">
<CFPARAM NAME="PM_CER" DEFAULT="">
<CFPARAM NAME="PM_Sponsor_ID" DEFAULT="">
<!------<CFPARAM NAME="PM_Owner_ID" DEFAULT="">----->
<CFPARAM NAME="PM_Position_ID" DEFAULT="">
<!------<CFPARAM NAME="PM_Broker" DEFAULT="">----->
<CFPARAM NAME="PM_Priority_ID" DEFAULT="">
<CFPARAM NAME="PM_Status_ID" DEFAULT="">
<CFPARAM NAME="PM_Phase_ID" DEFAULT="">
<CFPARAM NAME="PM_Start_Date" DEFAULT="">
<CFPARAM NAME="PM_End_Date" DEFAULT="">
<CFPARAM NAME="PM_FAR_ID" DEFAULT="">
<CFPARAM NAME="PM_QBrands_ID" DEFAULT="">
<CFPARAM NAME="PM_Start_Period" DEFAULT="">
<CFPARAM NAME="PM_Eding_Period" DEFAULT="">
<CFPARAM NAME="PM_Value_Pounds" DEFAULT="">
<CFPARAM NAME="PM_Value_Pounds_Filter" DEFAULT="">
<CFPARAM NAME="PM_Value_Dollars" DEFAULT="">
<CFPARAM NAME="PM_Value_Dollars_Filter" DEFAULT="">
<CFPARAM NAME="PM_Resources" DEFAULT="">
<CFPARAM NAME="PM_Ext_Budget" DEFAULT="">
<CFPARAM NAME="PM_Ext_Budget_Filter" DEFAULT="">
<CFPARAM NAME="PM_Actual" DEFAULT="">
<CFPARAM NAME="PM_Actual_Filter" DEFAULT="">
<CFPARAM NAME="PM_Support" DEFAULT="">
<CFPARAM NAME="Sort_By" DEFAULT="PM_Item_Master.PM_Acct_Project">
<CFPARAM NAME="Sort_Order" DEFAULT="Asc">
<CFPARAM NAME="maxrows" DEFAULT="10">
<CFPARAM NAME="view" DEFAULT="0">
<cfparam name="Form.VIEW" 	default="0">
<CFPARAM NAME="PM_Hide" 	DEFAULT="">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<CFIF PM_Status_ID NEQ "">
<CFSET PM_Status_ID_List = ListQualify(FORM.PM_Status_ID,"'",",")>
</CFIF>
<CFIF Sort_Order NEQ "Desc">
	<CFSET Sort_Order = "Asc">
</CFIF>

<CFIF ListFindNoCase("PM_Item_Master.PM_Acct_Project,PM_Item_Master.PM_CER,PM_Item_Master.PM_Sponsor_ID,PM_Item_Master.PM_Position_ID,PM_Item_Master.PM_Priority_ID,PM_Item_Master.PM_Status_ID,PM_Item_Master.PM_Phase_ID,PM_Item_Master.PM_FAR_ID,PM_Item_Master.PM_Start_Date,PM_Item_Master.PM_End_Date,PM_Item_Master.PM_Value_Pounds,PM_Item_Master.PM_Value_Dollars,PM_Item_Master.PM_Resources,PM_Item_Master.PM_Support,PM_Item_Master.PM_Ext_Budget,PM_Item_Master.PM_Actual", Sort_By, ",") EQ 0>
	<CFSET Sort_By = "PM_Item_Master.PM_Acct_Project">
</CFIF>

							
<!---  initial user position--->
<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>
<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>


<!------<CFQUERY NAME="getUserIDs" datasource="#application.datasource#">
	SELECT 	User_ID
	FROM 	User_Position_Holders
	WHERE 	User_Positions_ID IN (#ListOfPositionsUnderMine#) AND Deleted = 0
</CFQUERY>

<CFSET eligibleUserID=ValueList(getUserIDs.User_ID)>
<CFSET eligibleUserID=ListQualify(eligibleUserID, "'", ",")>----->


<SCRIPT LANGUAGE="JavaScript">
	function submitToMailWindow(thisForm)
	{
		NewWindow('', thisForm.target, '600', '400', 'Yes', 'No');
	}
</SCRIPT>



<!-------- unlock projects -------->
<CFQUERY NAME="Unlock_Projects" DATASOURCE="#application.datasource#">
	UPDATE	PM_Item_Master
	SET		PM_Locked	=	0,
			PM_Locked_By_User_ID = NULL,
			PM_Locked_Date = NULL
	WHERE	
			PM_Locked = 1
			AND
			PM_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Projects																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset PM_Acct_Project = trim(replace(PM_Acct_Project, "'", "''", "all"))>
<CFQUERY NAME="Get_Projects" datasource="#application.datasource#">
	Select		PM_Item_Master.*, 		PM_Priority.*,			PM_Phase.*,
				PM_Status.*,			
				PM_Far.*,
				_Users.Name_First + ' ' + _Users.Name_Last AS Locked_By_User
	<!-----------
	From		PM_Item_Master,			PM_Priority,			PM_Phase,
				PM_Status,				
				PM_Far

	Where		PM_Item_Master.PM_Priority_ID	=	PM_Priority.PM_Priority_ID
				and
				PM_Item_Master.PM_Phase_ID		=	PM_Phase.PM_Phase_ID
				and
				PM_Item_Master.PM_Status_ID		=	PM_Status.PM_Status_ID

				and
				PM_Item_Master.PM_Far_ID		=	PM_Far.PM_Far_ID
	---------->
	FROM
				PM_Item_Master
				INNER JOIN PM_Priority
				ON
					PM_Item_Master.PM_Priority_ID	=	PM_Priority.PM_Priority_ID
				INNER JOIN PM_Phase
				ON
					PM_Item_Master.PM_Phase_ID		=	PM_Phase.PM_Phase_ID
				INNER JOIN PM_Status
				ON
					PM_Item_Master.PM_Status_ID		=	PM_Status.PM_Status_ID
				INNER JOIN PM_Far
				ON
					PM_Item_Master.PM_Far_ID		=	PM_Far.PM_Far_ID	
				LEFT JOIN _Users
				ON
					_Users.User_ID = PM_Item_Master.PM_Locked_By_User_ID
					AND
					PM_Item_Master.PM_Locked = 1	
				<CFIF TRIM(PM_Position_ID) neq "">
				INNER JOIN PM_Owner_Position
				ON
					PM_Owner_Position.PM_Item_Master_ID = PM_Item_Master.PM_Item_Master_ID
					AND
					PM_Owner_Position.User_Positions_ID = #PM_Position_ID#
				</CFIF>
	WHERE
				
				PM_Item_Master.PM_Deleted		=	0
					<!------ Hide From Scorecard ----->
				<CFIF TRIM(PM_Hide) NEQ "" AND isNumeric(PM_Hide)>
				AND
				PM_Item_Master.PM_Hide			=	#PM_Hide#
				</CFIF>				
				<!--- Project name --->				
				<CFIF TRIM(PM_Acct_Project) neq "">
					AND PM_Item_Master.PM_Acct_Project	like '%#preservesinglequotes(PM_Acct_Project)#%'
				</CFIF>
				
				<!--- CER/Acct number --->				
				<CFIF TRIM(PM_CER) neq "">
					AND PM_Item_Master.PM_CER	like '%#PM_CER#%'
				</CFIF>
				
				<!--- Sponsor --->				
				<CFIF TRIM(PM_Sponsor_ID) neq "">
					AND PM_Item_Master.PM_Sponsor_ID	like '%#PM_Sponsor_ID#%'
				</CFIF>
				
				<!--- Owner --->				
				<!------<CFIF TRIM(PM_Owner_ID) neq "">
					AND PM_Item_Master.PM_Owner_ID	like '%#PM_Owner_ID#%'
				</CFIF>----->
				<!------<CFIF TRIM(PM_Position_ID) neq "">
					AND PM_Item_Master.PM_Position_ID	like '%#PM_Position_ID#%'
				</CFIF>----->
				
				<!--- Broker --->				
				<!------<CFIF TRIM(PM_Broker) neq "">
					AND PM_Item_Master.PM_Broker	like '%#PM_Broker#%'
				</CFIF>----->
								
				<!--- Priority --->				
				<CFIF TRIM(PM_Priority_ID) neq "">
					AND PM_Item_Master.PM_Priority_ID	= '#PM_Priority_ID#'
				</CFIF>
				
				<!--- Status --->				
				<CFIF TRIM(PM_Status_ID) neq "">
					AND PM_Item_Master.PM_Status_ID	IN (#PreserveSingleQuotes(PM_Status_ID_List)#)
				</CFIF>
				
				<!--- Phase --->				
				<CFIF TRIM(PM_Phase_ID) neq "">
					AND PM_Item_Master.PM_Phase_ID	= '#PM_Phase_ID#'
				</CFIF>
				
				<!--- Functional Area Responsible --->				
				<CFIF TRIM(PM_FAR_ID) neq "">
					AND PM_Item_Master.PM_FAR_ID	= '#PM_FAR_ID#'
				</CFIF>
				
				<!--- QBrands --->				
				<!------<CFIF TRIM(PM_QBrands_ID) neq "">
					AND PM_Item_Master.PM_QBrands_ID	= '#PM_QBrands_ID#'
				</CFIF>----->

				
				<!--- Start/End Periods --->				
				<CFIF TRIM(PM_Start_Date) NEQ "" AND TRIM(PM_End_Date) NEQ "">
					AND 
						(
							(
								PM_End_Date		>=	'#PM_Start_Date#'
								and
								PM_Start_Date	<=	'#PM_Start_Date#'
							)
							or
							(
								PM_End_Date		>=	'#PM_End_Date#'
								and
								PM_Start_Date	<=	'#PM_End_Date#'
							)
						)
				</CFIF>

				<CFIF TRIM(PM_Start_Date) NEQ "" AND TRIM(PM_End_Date) EQ "">
					AND 
						(
							PM_Start_Date	<=	'#PM_Start_Date#'
							and
							PM_End_Date		>=	'#PM_Start_Date#'
						)
				</CFIF>

				<CFIF TRIM(PM_Start_Date) EQ "" AND TRIM(PM_End_Date) NEQ "">
					AND 
						(
							PM_Start_Date	<=	'#PM_End_Date#'
							and
							PM_End_Date		>=	'#PM_End_Date#'
						)
				</CFIF>

				
				
				<!--- Value in Pounds --->				
				<CFIF TRIM(PM_Value_Pounds) neq "" AND trim(PM_Value_Pounds_Filter) neq "">
					<CFIF IsNumeric(PM_Value_Pounds)>
					<CFSWITCH EXPRESSION="#PM_Value_Pounds_Filter#">
						<CFCASE DELIMITERS="," VALUE="=,>,<,>=,<=,<>">
							AND PM_Item_Master.PM_Value_Pounds	#PM_Value_Pounds_Filter# #PM_Value_Pounds#
						</CFCASE>
					</CFSWITCH>
					</CFIF>
				</CFIF>
				
				<!--- Value in Dollars --->	
				<CFIF TRIM(PM_Value_Dollars) neq "" AND trim(PM_Value_Dollars_Filter) neq "">
					<CFIF IsNumeric(PM_Value_Dollars)>
					<CFSWITCH EXPRESSION="#PM_Value_Dollars_Filter#">
						<CFCASE DELIMITERS="," VALUE="=,>,<,>=,<=,<>">
							AND PM_Item_Master.PM_Value_Dollars	#PM_Value_Dollars_Filter# #PM_Value_Dollars#
						</CFCASE>
					</CFSWITCH>
					</CFIF>	
				</CFIF>
				
				<!--- Resources --->				
				<CFIF TRIM(PM_Resources) neq "">
					AND PM_Item_Master.PM_Resources	like '%#PM_Resources#%'
				</CFIF>

				<!--- Budget --->				
				<CFIF TRIM(PM_Ext_Budget) neq "" AND trim(PM_Ext_Budget_Filter) neq "">
					<CFIF IsNumeric(PM_Ext_Budget)>
					<CFSWITCH EXPRESSION="#PM_Ext_Budget_Filter#">
						<CFCASE DELIMITERS="," VALUE="=,>,<,>=,<=,<>">
							AND PM_Item_Master.PM_Ext_Budget	#PM_Ext_Budget_Filter# #PM_Ext_Budget#
						</CFCASE>
					</CFSWITCH>					
					</CFIF>
				</CFIF>

				<!--- Actual --->				
				<CFIF TRIM(PM_Actual) neq "" AND trim(PM_Actual_Filter) neq "">
					<CFIF IsNumeric(PM_Actual)>
					<CFSWITCH EXPRESSION="#PM_Actual_Filter#">
						<CFCASE DELIMITERS="," VALUE="=,>,<,>=,<=,<>">
							AND PM_Item_Master.PM_Actual	#PM_Actual_Filter# #PM_Actual#
						</CFCASE>
					</CFSWITCH>		
					</CFIF>					
				</CFIF>

				<!--- Support --->				
				<CFIF TRIM(PM_Support) neq "">
					AND PM_Item_Master.PM_Support	like '%#PM_Support#%'
				</CFIF>
				<!-----
				<CFIF Len(ListOfPositionsUnderMine) GT 0>
				AND
				PM_Position_ID
				IN (#ListOfPositionsUnderMine#)
				</CFIF>
				---------->
				
				AND EXISTS
				(
					SELECT 	TOP 1 PM_Owner_Position.PM_Item_Master_ID
					FROM	PM_Owner_Position
					WHERE
							PM_Owner_Position.PM_Item_Master_ID = PM_Item_Master.PM_Item_Master_ID
							AND
							PM_Owner_Position.User_Positions_ID IN 
							(
							SELECT	DISTINCT Below_User_Positions_ID
							FROM	Positions_Below_Me
							WHERE	User_Positions_ID IN (#GP_Supplied_Position#)
							)
				)
				
				<CFIF FORM.Broker_ID NEQ "0" AND FORM.Broker_ID NEQ "">
					AND
					EXISTS
					(
						SELECT	TOP 1 PM_Brokers.PM_Item_Master_ID
						FROM	PM_Brokers
						WHERE
								PM_Brokers.PM_Item_Master_ID=PM_Item_Master.PM_Item_Master_ID
								AND
								PM_Brokers.BSA_Foodservice_Brokers_ID = '#FORM.Broker_ID#'
					)
				</CFIF>
	Order by	PM_Weight,#Sort_By# #Sort_Order#

</CFQUERY>

<cfset PM_Acct_Project = trim(replace(PM_Acct_Project, "''", "'", "all"))>

<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
</style>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the IDs of the items selected											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get status --->
<CFQUERY NAME="Get_Status" datasource="#application.datasource#">
	Select		PM_Status_Description
	From		PM_Status
	Where		PM_Status_ID		like	'#PM_Status_ID#'
</CFQUERY>

<!--- Get Priority --->
<CFQUERY NAME="Get_Priority" datasource="#application.datasource#">
	Select		PM_Priority_Description
	From		PM_Priority
	Where		PM_Priority_ID		like	'#PM_Priority_ID#'
</CFQUERY>

<!--- Get Phase --->
<CFQUERY NAME="Get_Phase" datasource="#application.datasource#">
	Select		PM_Phase_Description
	From		PM_Phase
	Where		PM_Phase_ID			like	'#PM_Phase_ID#'
</CFQUERY>

<!--- Get QBrand --->
<!------<CFQUERY NAME="Get_QBrands" datasource="#application.datasource#">
	Select		Q_Brand
	From		Q_Brand_Desc
	Where		q_brand_id		like	'#PM_QBrands_ID#'
</CFQUERY>----->

<!--- Get Functioanl Areas of Responsibility --->
<CFQUERY NAME="Get_FAR" datasource="#application.datasource#">
	Select		PM_FAR_Description
	From		PM_FAR
	Where		PM_FAR_ID	like	'#PM_FAR_ID#'
</CFQUERY>

<!--- Get Sponsor --->
<CFQUERY NAME="Get_Sponsor" datasource="#application.datasource#">
	Select		PM_Sponsor_Name_First, PM_Sponsor_Name_Last
	From		PM_Sponsor
	Where		PM_Sponsor_ID	like	'#PM_Sponsor_ID#'
</CFQUERY>

<!--- Get Owner --->
<!------<cfset useLakebaseForGet_Owner = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGet_Owner>
	<cftry>
		<cfset Get_Owner = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#PM_Owner_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Owner = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Owner>
<CFQUERY NAME="Get_Owner" datasource="#application.datasource#">
	Select		Name_First, 
				Name_Last
	From 		_Users	
	Where 		User_ID = '#PM_Owner_ID#'
</CFQUERY>
</cfif>----->

<cfset useLakebaseForGet_Position = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForGet_Position>
	<cftry>
		<cfset Get_Position = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"user_positions_id" = "eq.#PM_Position_ID#",
				"select" = "position_label"
			}), "position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Position = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Position>
<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
	Select		Position_Label
	From 		User_Positions	
	Where 		User_Positions_ID = '#PM_Position_ID#'
</CFQUERY>
</cfif>
<CFIF FORM.Broker_ID NEQ "0" AND FORM.Broker_ID NEQ "">
	<cfset useLakebaseForGet_Broker = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_active")>
<cfif useLakebaseForGet_Broker>
	<cftry>
		<cfset Get_Broker = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_active", {
				"bsa_foodservice_brokers_id" = "eq.#FORM.Broker_ID#",
				"select" = "broker_name"
			}), "broker_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Broker = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Broker>
<CFQUERY NAME="Get_Broker" datasource="#application.datasource#">
		Select		Broker_Name
		From 		broker_active	
		Where 		BSA_Foodservice_Brokers_ID = '#FORM.Broker_ID#'
	</CFQUERY>
</cfif>
<CFELSE>
	<cfset get_broker = QueryNew("Broker_Name")>
	<cfset temp = QueryAddRow(get_broker)>
	<cfset temp = QuerySetCell(get_broker,"Broker_Name","")>
	<!--- <CFSET Get_Broker.Broker_Name=""> --->
</CFIF>

<br>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
		<p>

<!--- <TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
<TR>
	<TD <!--- CLASS="tableheader" ---> COLSPAN="100%"><SPAN CLASS="Title2">Show Criteria used:</SPAN></TD>
</TR>
</TABLE> --->

<CFSET na="<FONT color=""CCCCCC"">no criteria</FONT>">

<CF_openLayer
	Border="yes"
	BorderSize="1"  
	BorderColor="orange"  
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="Hide Criteria Used:"  
	TitleClosed="Show Criteria Used:"  
	TitleTooltip="Click to Show/Hide Criteria Used"  
	TitleFont="font"  
	TitleColor="Blue"  
	TitleSize="9"  
	IsClosed="Yes"  
	Width="100%">		
			
		
<CFOUTPUT>
<TABLE WIDTH="92%" CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD WIDTH="12%"><B>Project</B></TD>
	<TD WIDTH="13%"><CFIF trim(PM_Acct_Project) EQ "">#na#<CFELSE>#PM_Acct_Project#</CFIF></TD>
	<TD WIDTH="12%"><B>CER/Acct Number</B></TD>
	<TD WIDTH="13%"><CFIF trim(PM_CER) EQ "">#na#<CFELSE>#PM_CER#</CFIF></TD>
	<TD WIDTH="12%"><B>Sponsor</B></TD>
	<TD WIDTH="13%"><CFIF trim(Get_Sponsor.PM_Sponsor_Name_First) EQ "">#na#<CFELSE>#Get_Sponsor.PM_Sponsor_Name_First# #Get_Sponsor.PM_Sponsor_Name_Last#</CFIF></TD>
	<TD WIDTH="12%"><B>Owner Position</B></TD>
	<!------<TD WIDTH="13%"><CFIF trim(PM_Owner_ID) EQ "">#na#<CFELSE>#Get_Owner.Name_First# #Get_Owner.Name_Last#</CFIF></TD>----->
	<TD WIDTH="13%"><CFIF trim(PM_Position_ID) EQ "">#na#<CFELSE>#Get_Position.Position_Label#</CFIF></TD>
</TR>
<TR>
	<!------<TD><B>Broker</B></TD>
	<TD><CFIF trim(PM_Broker) EQ "">#na#<CFELSE>#PM_Broker#</CFIF></TD>----->
	<TD><B>Priority</B></TD>
	<TD><CFIF trim(Get_Priority.PM_Priority_Description) EQ "">#na#<CFELSE>#Get_Priority.PM_Priority_Description#</CFIF></TD>
	<TD><B>Status</B></TD>
	<TD><CFIF trim(Get_Status.PM_Status_Description) EQ "">#na#<CFELSE>#Get_Status.PM_Status_Description#</CFIF></TD>
	<TD><B>Phase</B></TD>
	<TD><CFIF trim(Get_Phase.PM_Phase_Description) EQ "">#na#<CFELSE>#Get_Phase.PM_Phase_Description#</CFIF></TD>
	<TD><B>#application.returned_customer_setting.broker_label_singular#</B></TD>
	<TD TITLE="<CFIF trim(Get_Broker.Broker_Name) NEQ "">#LCase(Get_Broker.Broker_Name)#</CFIF>"><CFIF trim(Get_Broker.Broker_Name) EQ "">#na#<CFELSE>
	<CFSET display_Title=Left(Get_Broker.Broker_Name,10)>
	<CFIF LEN(display_Title) LT Len(Get_Broker.Broker_Name)>
		<CFSET display_Title="#display_Title#...">
	</CFIF>
	<CFIF len(trim(display_Title)) EQ 0>
		<CFSET display_Title="&nbsp;">
	</CFIF>
	#LCase(display_Title)#
	</CFIF></TD>
</TR>
<TR>
	<TD><B>Area Responsible</B></TD>
	<TD><CFIF trim(Get_FAR.PM_FAR_Description) EQ "">#na#<CFELSE>#Get_FAR.PM_FAR_Description#</CFIF></TD>
	<!------<TD><B>QBrands</B></TD>----->
	<!------<TD><CFIF trim(Get_QBrands.Q_Brand) EQ "">#na#<CFELSE>#Get_QBrands.Q_Brand#</CFIF></TD>----->
	<TD><B>Period</B></TD>
	<TD><CFIF trim(PM_Start_Date) EQ "" AND trim(PM_End_Date) EQ "">#na#<CFELSE>#dateformat(PM_Start_Date, 'm/d/yy')# to #dateformat(PM_End_Date, 'm/d/yy')#</CFIF></TD>
	<TD><B>Value (pounds)</B></TD>
	<TD><CFIF trim(PM_Value_Pounds_Filter) EQ "">#na#<CFELSE>#PM_Value_Pounds_Filter# #PM_Value_Pounds#</CFIF></TD>
</TR>
<TR>
	<TD><B>Value (dollars)</B></TD>
	<TD><CFIF trim(PM_Value_Dollars_Filter) EQ "">#na#<CFELSE>#PM_Value_Dollars_Filter# #PM_Value_Dollars#</CFIF></TD>
	<TD><B>Resources</B></TD>
	<TD><CFIF trim(PM_Resources) EQ "">#na#<CFELSE>#PM_Resources#</CFIF></TD>
	<TD><B>Ext. Budget</B></TD>
	<TD><CFIF trim(PM_Ext_Budget_Filter) EQ "">#na#<CFELSE>#PM_Ext_Budget_Filter# #PM_Ext_Budget#</CFIF></TD>
	<TD><B>Actual</B></TD>
	<TD><CFIF trim(PM_Actual_Filter) EQ "">#na#<CFELSE>#PM_Actual_Filter# #PM_Actual#</CFIF></TD>
</TR>
<TR>
	<TD><B>Support</B></TD>
	<TD><CFIF trim(PM_Support) EQ "">#na#<CFELSE>#PM_Support#</CFIF></TD>
	<TD><B>Sorted by</B></TD>
	<TD>
		<!--- Clean the variables being passed --->
		<CFSET SortBy=replace(Sort_BY,"_ID","","All")>
		<!--- Remove underscores --->
		<CFSET SortBy=replace(Sort_BY,"_"," ","All")>
		#mid(SortBy,find(".",SortBy,1)+4,len(SortBy))#
	</TD>
	<TD><B>Sort order</B></TD>
	<TD>#Sort_Order#</TD>
	<TD><B>Records/page</B></TD>
	<TD>#maxrows#</TD>
</TR>
</TABLE>

</CFOUTPUT>
</CF_openLayer>
<BR>

<CFIF view EQ 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Display results - table style																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<CF_Number_of_Rows maxrows="#maxrows#">
		<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
		<TR>			
			<TD CLASS="tableheader" COLSPAN="100%"><SPAN CLASS="Title2"><CFOUTPUT>#Get_Projects.recordcount#</CFOUTPUT> records returned - summary view:</SPAN>&nbsp;&nbsp;
			<CFOUTPUT><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="##" onClick="javaScript: document.all.MyForm.VIEW.value=1;document.all.MyForm.submit();return false;">detailed view</A>&nbsp;<FONT COLOR="Red">]</FONT></CFOUTPUT>
			<FONT COLOR="Red">[</FONT>&nbsp;<A HREF="/ReportWriter/PM/PM_Glossary.cfm" onclick="NewWindow(this.href,'name','600','500','Yes', 'No');return false;" TITLE="Glossary">glossary</A>&nbsp;<FONT COLOR="Red">]</FONT>
		</TD>
		</TR>
		</TABLE>
		
		<BR>

			<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="92%">
			<TR VALIGN="bottom" BGCOLOR="#FFCE84" HEIGHT="25">
				<TD CLASS="tableheader">&nbsp;</TD>
				<TD CLASS="tableheader">&nbsp;</TD>
				<TD CLASS="tableheader">Acct/Project</TD>				
				<TD CLASS="tableheader">&nbsp;</TD>
				<TD CLASS="tableheader">Priority</TD>
				<TD CLASS="tableheader">Status</TD>
				<TD CLASS="tableheader">Pounds</TD>
				<TD CLASS="tableheader">Dollars</TD>
				<!------<TD CLASS="tableheader">QBrands</TD>----->
				<TD CLASS="tableheader">Sponsor</TD>
				<TD CLASS="tableheader">Owner Position</TD>
				<TD CLASS="tableheader">Modified On</TD>
				<TD CLASS="tableheader">Modified By</TD>
			</TR>
				
			
			<CFOUTPUT QUERY="Get_Projects" STARTROW="#StartRow#" MAXROWS="#maxrows#">
			<!--- 	Get the ID of the user that last modified this record --->
			<CFQUERY NAME="Get_User" datasource="#application.datasource#">
				Select Name_Last, Name_First from _users where user_id like '#PM_Modified_By_ID#'
			</CFQUERY>
		
			<!--- 	Get the ID of the sponsor --->
			<CFQUERY NAME="Get_sponsor" datasource="#application.datasource#">
				Select PM_Sponsor_Name_First, PM_Sponsor_Name_Last, PM_Sponsor_Email from PM_Sponsor where PM_Sponsor_ID like '#PM_Sponsor_ID#'
			</CFQUERY>
		
			<!--- 	Get the ID of the Functional Area --->
			<CFQUERY NAME="Get_FAR" datasource="#application.datasource#">
				Select PM_Far_Description from PM_Far where PM_Far_ID like '#PM_Far_ID#'
			</CFQUERY>

			<!--- Get Owner --->
			<!------<CFQUERY NAME="Get_Owner" datasource="#application.datasource#">
				Select		User_Email, Name_First, Name_Last	From _Users	Where User_ID = '#PM_Owner_ID#'
			</CFQUERY>----->
			<!------
			<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
				Select		Position_Label	From User_Positions	Where User_Positions_ID = '#PM_Position_ID#'
			</CFQUERY>----->
			
			<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
				Select		Position_Label	
				From 		PM_Owner_Position
							INNER JOIN User_Positions	
							ON
							User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
				Where 		
							PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
			
			<CFQUERY NAME="Get_Position_Emails" datasource="#application.datasource#">
				Select		_Users.User_Email
				From 		PM_Owner_Position
							INNER JOIN User_Positions	
							ON
							User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
							INNER JOIN User_Position_Holders
							ON
							User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
							AND
							User_Position_Holders.Deleted = 0
							INNER JOIN _Users
							ON
							_Users.User_ID = User_Position_Holders.User_ID
							AND
							_Users.Deleted = 0
				Where 		
							PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
			<CFSET ownerEmails = ValueList(Get_Position_Emails.User_Email, ";")>
			<CFQUERY NAME="display_notes" DATASOURCE="#Application.Datasource#">
				SELECT * FROM PM_Notes 
				WHERE PM_Item_Master_ID = '#PM_Item_Master_ID#' 
				AND created_date = (SELECT MAX(Created_Date) FROM PM_Notes WHERE PM_Item_Master_ID = '#PM_Item_Master_ID#')				
			</CFQUERY>
			<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
			<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>
			<CFQUERY NAME="Check_attachments" DATASOURCE="#Application.Datasource#">
				SELECT Contract_Attachments.Doc_ID 
				FROM Contract_Attachments 
				INNER JOIN 	Document_Details ON contract_attachments.Doc_ID = Document_Details.Doc_ID 							
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preservesinglequotes(Access_Position_List)#)
									) 						
										OR Public_View = 0	
								)
				WHERE Project_ID = '#PM_Item_Master_ID#' AND Contract_Attachments.Deleted = 0
			</CFQUERY>
				
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" HEIGHT="25">
				<TD CLASS="tdbody"><CFIF PM_IsCritical EQ 1><img src="/Images/alert_icon_small.gif" alt="critical project" width="10" height="10" border="0"><CFELSE>&nbsp;</CFIF></TD>
				<TD CLASS="tdbody" width="12">
				<CFIF PM_Locked EQ 1>
					<IMG SRC="/images/lock.gif" ALT="This project is locked by user #ucase(Locked_By_User)#" height="16" width="12">					
				<CFELSE>
					<A Href="PM_Update_Notes.cfm?PM_Item_Master_ID=#PM_Item_Master_ID#&Descp=#PM_Acct_Project#" Onclick="NewWindow(this.href,'update','600','275','Yes', 'No');return false;" TITLE="Add Notes"><img src="../../Images/todo_create_item.gif" alt="Update notes" width="20" height="13" border="0"></A>
				</CFIF>				
				</TD><!--- #PM_Priority_Description##chr(13)# --->
				<CFSET Title_Notes = ReReplace(display_notes.PM_Notes,"""","&quot;","All")>
				<TD CLASS="tdbody"><A HREF="pm_create.cfm?RID=#PM_Item_Master_ID#&FID=#FORM.FID#" TITLE="Notes: <CFIF display_notes.PM_Notes NEQ "">#Title_Notes# #chr(13)#Date: #DateFormat(display_notes.Created_date,"m/d/yyyy")#<CFELSE>None.</CFIF>" STYLE="font: 10px; font-weight: bold;">#PM_Acct_Project#</A></TD>
				<TD CLASS="tdbody"><CFIF Check_attachments.recordcount GT 0><IMG SRC="/images/doc.gif" ALT="This project has #Check_attachments.recordcount# attached document(s)" height="16" width="13"></CFIF>&nbsp;</TD>
				<TD CLASS="tdbody"><A HREF="pm_create.cfm?RID=#PM_Item_Master_ID#&FID=#FORM.FID#" TITLE="Notes: #display_notes.PM_Notes# #chr(13)#Date: #DateFormat(display_notes.Created_date,"m/d/yyyy")#" STYLE="font: 10px; font-weight: bold;">#PM_Priority_Description#&nbsp;</A></TD>
				<TD CLASS="tdbody">#PM_Status_Description#&nbsp;</TD>
				<TD CLASS="tdbody" NOWRAP>#numberformat(PM_Value_Pounds, '_,___,___,___')#</TD>
				<TD CLASS="tdbody" NOWRAP>#numberformat(PM_Value_Dollars, '_,___,___,___')#</TD>
				<!------<TD CLASS="tdbody">#q_brand#&nbsp;</TD>----->
				<TD CLASS="tdbody"><cfif Get_sponsor.PM_Sponsor_Email NEQ "">
				<FORM STYLE="DISPLAY:INLINE" ACTION="PM_Email_Form.cfm" TARGET="mailWindow" METHOD="POST" ONSUBMIT="javaScript: submitToMailWindow(this);">
				<INPUT TYPE="Hidden" NAME="Subject" VALUE="#PM_Acct_Project# project">
				<INPUT TYPE="Hidden" NAME="Email_Address" VALUE="#Get_sponsor.PM_Sponsor_Email#">
				<INPUT TYPE="Image" SRC="/Images/email_small.gif" BORDER="0">
				&nbsp;</FORM></cfif>
				#Get_Sponsor.PM_Sponsor_Name_First# #Get_Sponsor.PM_Sponsor_Name_Last#&nbsp;</TD>

				<!------<TD CLASS="tdbody"><cfif Get_Owner.User_Email NEQ ""><a href="MAILTO:#Get_Owner.User_Email#?subject=#PM_Acct_Project# project"><IMG src="/Images/email_small.gif" border="0"></a>&nbsp;</cfif>#Get_Owner.Name_First# #Get_Owner.Name_Last#&nbsp;</TD>----->
				<TD CLASS="tdbody" TITLE="#ValueList(Get_Position.Position_Label, "#chr(13)#")#">
				<CFIF Len(ownerEmails) GT 0>
				<!------<a href="PM_Email_Form.cfm?To_Owners=#ownerEmails#&subject=#PM_Acct_Project# project"><IMG src="/Images/email_small.gif" border="0"></a>----->
				<FORM STYLE="DISPLAY:INLINE" ACTION="PM_Email_Form.cfm" TARGET="mailWindow" METHOD="POST" ONSUBMIT="javaScript: submitToMailWindow(this);">
				<INPUT TYPE="Hidden" NAME="Subject" VALUE="#PM_Acct_Project# project">
				<CFLOOP LIST="#ownerEmails#" INDEX="ThisOwnerEmail" DELIMITERS=";">
					<INPUT TYPE="Hidden" NAME="Email_Address" VALUE="#ThisOwnerEmail#">
				</CFLOOP>				
				<INPUT TYPE="Image" SRC="/Images/email_small.gif" BORDER="0">
				&nbsp;</FORM>
				</CFIF>
				<CFIF Get_Position.RecordCount GT 1>
				Several ...
				<CFELSE>
				#Get_Position.Position_Label#
				</CFIF>
				&nbsp;</TD>
				<TD CLASS="tdbody">#dateformat(PM_Date_Modified, 'mm/dd/yyyy')#&nbsp;</TD>
				<TD CLASS="tdbody" NOWRAP>#Get_User.Name_First# #Get_User.Name_Last#&nbsp;</TD>
			</TR>
			</CFOUTPUT>
			</TABLE>


<CFELSE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Display results - form style																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



		<CF_Number_of_Rows maxrows="#maxrows#">
		<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
		<TR>
			<TD CLASS="tableheader" COLSPAN="100%"><SPAN CLASS="Title2"><CFOUTPUT>#Get_Projects.recordcount#</CFOUTPUT> records returned  - detail view:</SPAN>&nbsp;&nbsp;
			<CFOUTPUT><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="##" onClick="javaScript: document.all.MyForm.VIEW.value=0;document.all.MyForm.submit();">summary view</A>&nbsp;<FONT COLOR="Red">]</FONT>
			<FONT COLOR="Red">[</FONT>&nbsp;<A HREF="/ReportWriter/PM/PM_Glossary.cfm" onclick="NewWindow(this.href,'name','500','400','Yes', 'No');return false;" TITLE="Glossary">glossary</A>&nbsp;<FONT COLOR="Red">]</FONT>
			</TD></CFOUTPUT>			
		</TR>
		</TABLE>
		
		<BR>
		
		<!--- Display data --->
		
		<TABLE border="0" cellspacing="0" cellpadding="2" bgcolor="WhiteSmoke" WIDTH="92%">
				<TR>
					<TD width="125"></TD>
					<TD></TD>
					<TD width="80"></TD>
					<TD></TD>
					<TD width="80"></TD>
					<TD></TD>
					<TD width="125"></TD>
					<TD></TD>
				</TR>
		
			
			<CFOUTPUT QUERY="Get_Projects" STARTROW="#StartRow#" MAXROWS="#maxrows#">
		
			<!--- 	Get the user that last modified this record --->
			<CFQUERY NAME="Get_User" datasource="#application.datasource#">
				Select Name_Last, Name_First from _users where user_id like '#PM_Modified_By_ID#'
			</CFQUERY>
		
			<!--- 	Get the sponsor --->
			<CFQUERY NAME="Get_sponsor" datasource="#application.datasource#">
				Select PM_Sponsor_Name_First, PM_Sponsor_Name_Last, PM_Sponsor_Email from PM_Sponsor where PM_Sponsor_ID like '#PM_Sponsor_ID#'
			</CFQUERY>
		
			<!--- Get Owner --->
			<!------<CFQUERY NAME="Get_Owner" datasource="#application.datasource#">
				Select		User_Email, Name_First, Name_Last	From _Users	Where User_ID = '#PM_Owner_ID#'
			</CFQUERY>----->
			
			<!------
			<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
				Select		Position_Label	From User_Positions	Where User_Positions_ID = '#PM_Position_ID#'
			</CFQUERY>---->
			
			<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
				Select		Position_Label, User_Positions.User_Positions_ID
				From 		PM_Owner_Position
							INNER JOIN User_Positions	
							ON
							User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
				Where 		
							PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
			
			<CFQUERY NAME="Get_Position_Emails" datasource="#application.datasource#">
				Select		_Users.User_Email, User_Positions.User_Positions_ID
				From 		PM_Owner_Position
							INNER JOIN User_Positions	
							ON
							User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
							INNER JOIN User_Position_Holders
							ON
							User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
							AND
							User_Position_Holders.Deleted = 0
							INNER JOIN _Users
							ON
							_Users.User_ID = User_Position_Holders.User_ID
							AND
							_Users.Deleted = 0
				Where 		
							PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
			<CFSET ownerEmails = ValueList(Get_Position_Emails.User_Email, ";")>

			<!--- 	Get the Functional Area --->
			<CFQUERY NAME="Get_FAR" datasource="#application.datasource#">
				Select PM_Far_Description from PM_Far where PM_Far_ID like '#PM_Far_ID#'
			</CFQUERY>

			<!--- 	Get the Priority --->
			<CFQUERY NAME="Get_Priority" datasource="#application.datasource#">
				Select PM_Priority_Description from PM_Priority where PM_Priority_ID like '#PM_Priority_ID#'
			</CFQUERY>
			
			<!--- 	Get the Status --->
			<CFQUERY NAME="Get_Status" datasource="#application.datasource#">
				Select PM_Status_Description from PM_Status where PM_Status_ID like '#PM_Status_ID#'
			</CFQUERY>
			
			<!--- 	Get the Phase --->
			<CFQUERY NAME="Get_Phase" datasource="#application.datasource#">
				Select PM_Phase_Description from PM_Phase where PM_Phase_ID like '#PM_Phase_ID#'
			</CFQUERY>
			
			<!--- Get progams associated with this project --->
			<CFQUERY NAME="Get_Programs" datasource="#application.datasource#">
				Select		distinct PM_Programs.*,
							Contract_Main.Contract_Title,
							Contract_Main.contract_main_id,
							Contract_Main.Deleted
				From		PM_Programs,
							Contract_Main
				Where		PM_Programs.PM_Item_Master_ID	like	'#Get_Projects.PM_Item_Master_ID#'
							and
							Contract_Main.Contract_Number	=	PM_Programs.PM_Contract_Number
							and
							Contract_Main.Deleted			=	0
				order by	PM_Programs.PM_Contract_Number, Contract_Main.Deleted
			</CFQUERY>
			
			<!--- Get qBrands associated with this project --->
			<!-------------
			<CFQUERY NAME="Get_QBrands" datasource="#application.datasource#">
				Select		distinct 
							qb.Q_Brand_ID,qb.Q_Brand
				From		Q_Brand_Desc qb
				Where		
							qb.Q_Brand_ID IN
							(
								SELECT 	Q_Brand_ID
								FROM	PM_Qbrands
								WHERE	PM_Qbrands.PM_Item_Master_ID	like	'#Get_Projects.PM_Item_Master_ID#'
							)
				order by	qb.Q_Brand
			</CFQUERY>
			------------->
			
			<CFQUERY NAME="Full_Type_Group_List" DATASOURCE="#application.datasource#">
				<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_type_group_syntax#">
			</CFQUERY>
			<CFQUERY NAME="Saved_Type_Groups" DATASOURCE="#application.datasource#">
				SELECT 	Q_Brand_ID
				FROM	PM_Qbrands
				WHERE	PM_Qbrands.PM_Item_Master_ID	like	'#Get_Projects.PM_Item_Master_ID#'
			</CFQUERY>
			<CFSET Saved_Type_Groups_List = ListQualify(ValueList(Saved_Type_Groups.Q_Brand_ID), "'")>
			<CFQUERY NAME="Get_QBrands" DBTYPE="Query">
				Select 	*
				FROM	Full_Type_Group_List
				WHERE
						1= 2
						<CFIF LEN(Saved_Type_Groups_List) GT 0>
						OR
						Full_Type_Group_List.Type_Group_Desc_ID IN
						(#PreserveSingleQuotes(Saved_Type_Groups_List)#)
						</CFIF>
						
			</CFQUERY>
			
			<!--- Get brokers associated with this project --->
			<CFQUERY NAME="Get_Brokers" datasource="#application.datasource#">
				Select		distinct 
							BSA_Foodservice_Brokers.Broker_Name
				From		BSA_Foodservice_Brokers
				Where		
							BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN
							(
								SELECT 	PM_Brokers.BSA_Foodservice_Brokers_ID
								FROM	PM_Brokers
								WHERE	
										PM_Brokers.PM_Item_Master_ID	like	'#Get_Projects.PM_Item_Master_ID#'
										AND
										PM_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							)
				order by	BSA_Foodservice_Brokers.Broker_Name
			</CFQUERY>
			
			<!--- Get distributors associated with this project --->
			<CFQUERY NAME="Get_Distributors" datasource="#application.datasource#">
				Select		distinct BSA_Foodservice_Customers.Name
				From		BSA_Foodservice_Customers
				Where		
							BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
							(
								SELECT 	PM_Distributors.BSA_Foodservice_Customers_ID
								FROM	PM_Distributors
								WHERE	
										PM_Distributors.PM_Item_Master_ID	like	'#Get_Projects.PM_Item_Master_ID#'
										AND
										PM_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
							)
				order by	BSA_Foodservice_Customers.Name
			</CFQUERY>
			
			<!--- Get operators associated with this project --->
			<CFQUERY NAME="Get_operators" datasource="#application.datasource#">
				Select		distinct BSA_Operator.Operator_Name
				From		BSA_Operator
				Where		
							BSA_Operator.BSA_Operator_ID IN
							(
								SELECT 	PM_operators.BSA_Operator_ID
								FROM	PM_operators
								WHERE	
										PM_operators.PM_Item_Master_ID	like	'#Get_Projects.PM_Item_Master_ID#'
										AND
										PM_operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
							)
				order by	BSA_Operator.Operator_Name
			</CFQUERY>

			
			<CFQUERY NAME="Get_Notes" DATASOURCE="#application.datasource#">
				SELECT	PM_Notes.PM_Notes, Name_First + ' ' + Name_Last AS Full_Name, PM_Notes.Created_Date
				FROM	PM_Notes
						INNER JOIN _Users
						ON _Users.User_ID = PM_Notes.User_ID
				WHERE
						PM_Notes.PM_Item_Master_ID = '#Get_Projects.PM_Item_Master_ID#'
				ORDER BY PM_Notes.Created_Date DESC
			</CFQUERY>
			
			<CFQUERY NAME="Check_attachments" DATASOURCE="#Application.Datasource#">
				SELECT Doc_ID FROM Contract_Attachments WHERE Project_ID = '#Get_Projects.PM_Item_Master_ID#'
			</CFQUERY>
			
				<TR BGCOLOR="##C6FFC6">
					<TD colspan="100%" width="100%" STYLE="border-bottom: solid 1px blue;">
					<B><A HREF="pm_create.cfm?RID=#PM_Item_Master_ID#&FID=#FORM.FID#" style="FONT: bold 14px; color: ##0000FF;">#ucase(PM_Acct_Project)#</A></B>
					<CFIF PM_Locked EQ 1>
						<IMG SRC="/images/lock.gif" ALT="This project is locked by user #ucase(Locked_By_User)#" height="16" width="12">
					</CFIF>
					&nbsp;&nbsp;
					<CFIF Check_attachments.recordcount GT 0><IMG SRC="/images/doc.gif" ALT="This project has #Check_attachments.recordcount# attached document(s)" height="16" width="13"></CFIF></TD>
				</TR>
				<TR>
					<TD nowrap align="right" valign="top"><B>Priority:</B></TD>
					<TD valign="top">#Get_Priority.PM_Priority_Description#</TD>
					<TD align="right" nowrap valign="top"><B>Value - lbs:</B></TD>
					<TD valign="top">#numberformat(PM_Value_Pounds, '_,___,___,___')#</TD>
					<TD nowrap align="right" valign="top"><B>Functional Area:</B></TD>
					<TD valign="top">#PM_Far_Description#</TD>
					<TD align="right" nowrap valign="top"><B>Sponsor:</B>					
					</TD>
					<TD valign="top" WIDTH="150">#Get_Sponsor.PM_Sponsor_Name_First# #Get_Sponsor.PM_Sponsor_Name_Last#&nbsp;
					<!------<a href="MAILTO:#Get_sponsor.PM_Sponsor_Email#?subject=#PM_Acct_Project# project"><IMG src="/Images/email_small.gif" border="0"></a>----->
					<CFIF Get_sponsor.PM_Sponsor_Email NEQ "">
					<FORM STYLE="DISPLAY:INLINE" ACTION="PM_Email_Form.cfm" TARGET="mailWindow" METHOD="POST" ONSUBMIT="javaScript: submitToMailWindow(this);">
					<INPUT TYPE="Hidden" NAME="Subject" VALUE="#PM_Acct_Project# project">
					<INPUT TYPE="Hidden" NAME="Email_Address" VALUE="#Get_sponsor.PM_Sponsor_Email#">
					<INPUT TYPE="Image" SRC="/Images/email_small.gif" BORDER="0">
					&nbsp;</FORM>
					</CFIF>
					</TD>
				</TR>
				<TR>
					<TD nowrap align="right" valign="top"><B>Status:</B></TD>
					<TD valign="top">#Get_Status.PM_Status_Description#</TD>
					<TD align="right" nowrap valign="top"><B>Value - $:</B></TD>
					<TD valign="top">#numberformat(PM_Value_Dollars, '_,___,___,___')#</TD>
					<TD align="right" nowrap valign="top"><B>Support:</B></TD>
					<TD valign="top">#PM_Support#</TD>
					<TD align="right" nowrap valign="top"><B>Timeline:</B></TD>
					<TD valign="top">#dateformat(PM_Start_Date, 'm/d/yy')# - #dateformat(PM_End_Date, 'm/d/yy')#</TD>
				</TR>
				<TR>
					<TD nowrap align="right" valign="top"><B>Phase:</B></TD>
					<TD valign="top">#Get_Phase.PM_Phase_Description#</TD>
					<TD align="right" nowrap valign="top"><B>Budget - $:</B></TD>
					<TD valign="top">#numberformat(PM_Ext_Budget, '_,___,___,___')#</TD>
					<TD align="right" nowrap valign="top"><B>Resources - $:</B></TD>
					<TD valign="top">#numberformat(PM_Resources, '_,___,___,___')#</TD>
					<TD align="right" nowrap valign="top"><B>Actual - $:</B></TD>
					<TD valign="top">#numberformat(PM_Actual, '_,___,___,___')#</TD>
				</TR>
				<TR>
					<TD nowrap align="right" valign="top"><B>CER/Acct number:</B></TD>
					<TD valign="top">#PM_CER#</TD>					
					<!------<TD COLSPAN="4"></TD>----->
					<TD></TD><TD></TD><TD></TD><TD></TD>
				</TR>
				<CFSET colCount = 4>
				<CFSET colPercent = 100 / colCount>
				
				
				<TR>
					<TD VALIGN="TOP" ALIGN="RIGHT">
					<CFIF Len(ownerEmails) GT 0>
					<!------<a href="MAILTO:#OwnerEmails#?subject=#PM_Acct_Project# project"><IMG src="/Images/email_small.gif" border="0"></a>----->
					<FORM STYLE="DISPLAY:INLINE" ACTION="PM_Email_Form.cfm" TARGET="mailWindow" METHOD="POST" ONSUBMIT="javaScript: submitToMailWindow(this);">
					<INPUT TYPE="Hidden" NAME="Subject" VALUE="#PM_Acct_Project# project">
					<CFLOOP LIST="#ownerEmails#" INDEX="ThisOwnerEmail" DELIMITERS=";">
						<INPUT TYPE="Hidden" NAME="Email_Address" VALUE="#ThisOwnerEmail#">
					</CFLOOP>				
					<INPUT TYPE="Image" SRC="/Images/email_small.gif" BORDER="0">
					&nbsp;</FORM>
					</CFIF>
					<B>Owner Positions:</B><BR>
					</TD>
					<TD COLSPAN="100%">					
					<CFIF Get_Position.recordCount GT 0>
						<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
						<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
						<TR>
						<CFSET Mycounter=0> 
						<CFLOOP QUERY="Get_Position">
							<cfset useLakebaseForThisUserPositionEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_position_emails")>
<cfif useLakebaseForThisUserPositionEmail>
	<cftry>
		<cfset ThisUserPositionEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_position_emails", {
				"user_positions_id" = "eq.#Get_Position.User_Positions_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThisUserPositionEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThisUserPositionEmail>
<CFQUERY NAME="ThisUserPositionEmail" DBTYPE="query">
								SELECT	*
								FROM	Get_Position_Emails
								WHERE
										User_Positions_ID = #Get_Position.User_Positions_ID#
							</CFQUERY>
</cfif>
							<CFSET ThisPositionEmails = ValueList(ThisUserPositionEmail.User_Email, ";")>		
		            	   	<TD STYLE="border-bottom: 1px silver solid">
							<CFIF Len(ThisPositionEmails) GT 0>
							<!------<a href="MAILTO:#ThisPositionEmails#?subject=#PM_Acct_Project# project"><IMG src="/Images/email_small.gif" border="0"></a>----->
							<FORM STYLE="DISPLAY:INLINE" ACTION="PM_Email_Form.cfm" TARGET="mailWindow" METHOD="POST" ONSUBMIT="javaScript: submitToMailWindow(this);">
							<INPUT TYPE="Hidden" NAME="Subject" VALUE="#PM_Acct_Project# project">
							<CFLOOP LIST="#ThisPositionEmails#" INDEX="ThisOwnerEmail" DELIMITERS=";">
								<INPUT TYPE="Hidden" NAME="Email_Address" VALUE="#ThisOwnerEmail#">
							</CFLOOP>				
							<INPUT TYPE="Image" SRC="/Images/email_small.gif" BORDER="0">
							&nbsp;</FORM>
							<CFELSE>&nbsp;
							</CFIF>
							<FONT SIZE="1">#Position_Label#</FONT></TD> 
				            <CFSET Mycounter=Mycounter+1> 
		               		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR>'))# 
	               	    </CFLOOP>
						<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
							<TD></TD>
						</cfloop> 
						</TABLE>
					</CFIF>
					</TD>
				</TR>
				
				<TR>
					<TD VALIGN="TOP" ALIGN="RIGHT">
					<B>#application.returned_customer_setting.type_group_label_plural#:</B><BR>
					</TD>
					<TD COLSPAN="100%">					
					<CFIF Get_QBrands.recordCount GT 0>
						<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
						<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
						<TR>
						<CFSET Mycounter=0> 
						<CFLOOP QUERY="Get_QBrands"> 					
	            	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#TYPE_GROUP_DESC#</FONT></TD> 
			            <CFSET Mycounter=Mycounter+1> 
	               		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=47" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=47" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=47" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=47" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=48">'))# 
	               	    </CFLOOP>
						<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
							<TD></TD>
						</cfloop> 
						</TABLE>
					</CFIF>
					</TD>
				</TR>
				
				
				<TR>
					<TD VALIGN="TOP" ALIGN="RIGHT">
					<B>#application.returned_customer_setting.broker_label_plural#:</B><BR>
					</TD>
					<TD COLSPAN="100%">
					<CFIF Get_Brokers.recordCount GT 0>
						<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
						<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
						<TR>
						<CFSET Mycounter=0> 
						<CFLOOP QUERY="Get_Brokers"> 					
	            	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#Broker_Name#</FONT></TD> 
			            <CFSET Mycounter=Mycounter+1> 
	               		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=50" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=50" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=50" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=50" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=51">'))# 
	               	    </CFLOOP>
						<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
							<TD></TD>
						</cfloop>
						</TABLE>
					</CFIF>	  
					</TD>
				</TR>
				
				
				<TR>
					<TD VALIGN="TOP" ALIGN="RIGHT">
					<B>#application.returned_customer_setting.distributor_label_plural#:</B><BR>
					</TD>
					<TD COLSPAN="100%">
					<CFIF Get_Distributors.recordCount GT 0>
						<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
						<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
						<TR>
						<CFSET Mycounter=0> 
						<CFLOOP QUERY="Get_Distributors"> 					
	            	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#Name#</FONT></TD> 
			            <CFSET Mycounter=Mycounter+1> 
	               		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=53" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=53" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=53" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=53" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=54">'))# 
	               	    </CFLOOP> 
						<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
							<TD></TD>
						</cfloop>
						</TABLE>					
					</CFIF>
					</TD>
				</TR>
				
				
				<TR>
					<TD VALIGN="TOP" ALIGN="RIGHT">
					<B>#application.returned_customer_setting.operator_label_plural#:</B><BR>
					</TD>
					<TD COLSPAN="100%">
					<CFIF Get_Operators.recordCount GT 0>
						<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
						<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
						<TR>
						<CFSET Mycounter=0> 
						<CFLOOP QUERY="Get_Operators"> 					
	            	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#Operator_Name#</FONT></TD> 
			            <CFSET Mycounter=Mycounter+1> 
	               		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=56" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=56" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=56" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=56" mmTranslatedValueOutline="OUTLINE=%22%3Ccfloop%3E%22" mmTranslatedValueOutlineID="OUTLINEID=57">'))# 
	               	    </CFLOOP> 
						<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
							<TD></TD>
						</cfloop>
						</TABLE>
					</CFIF>
					</TD>
				</TR>
				

				<TR>
					<TD nowrap align="right" valign="top"><B>Programs:</B></TD>
					<TD colspan="100%" valign="top" width="100%">

						<!--- Show contracts associated with this project --->
						<CFLOOP QUERY="Get_Programs">
							<CF_CRYP type="en" key="#request.key#" string="#contract_main_id#">
							<CFSET CID = cryp.value>
							<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="95%">
							<TR VALIGN="top">
								<TD NOWRAP STYLE="border-bottom: 1px silver solid"><A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:11PX;" TITLE="View the details for this program..."><B>#Get_Programs.PM_Contract_Number#</B></A></TD>
								<TD WIDTH="100%" STYLE="border-bottom: 1px silver solid"><SPAN STYLE="FONT-SIZE:10PX;">#left(Get_Programs.Contract_Title, 100)#...</SPAN></TD>
							</TR>
							</TABLE>
						</CFLOOP>

					</TD>
				</TR>
				<TR>
					<TD nowrap align="right" valign="top"><B>Next Step/Update:</B></TD>
					<TD colspan="100%" valign="top" width="100%">
					<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="95%">						
					<CFLOOP QUERY="Get_Notes">
					<TR VALIGN="top">
						<TD STYLE="border-bottom: 1px silver solid">#Full_Name#</TD>
						<TD STYLE="border-bottom: 1px silver solid">#DateFormat(Created_Date, "mm/dd/yyyy")#</TD>					
						<TD STYLE="border-bottom: 1px silver solid" WIDTH="80%">
						#PM_Notes#
						</TD>
						</TR>					
					</CFLOOP>
					</TABLE>
					</TD>
				</TR>
				<TR>
					<TD colspan="100%" valign="top" width="100%"><BR></TD>
				</TR>
				<TR>
					<TD colspan="100%" valign="top" width="100%" bgcolor="FFFFFF"><BR></TD>
				</TR>
		</CFOUTPUT>
		
			</TABLE>	

 




</CFIF>







	


<!------<cf_Next_Previous
	maxpages		=	"25"
	query			=	"Get_Projects"										
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams		=	"PM_Acct_Project,PM_CER,PM_Sponsor_ID,PM_Owner_ID,PM_Priority_ID,PM_Status_ID,PM_Phase_ID,PM_FAR_ID,PM_QBrands_ID,PM_Start_Period,PM_Eding_Period,PM_Value_Pounds,PM_Value_Pounds_Filter,PM_Value_Dollars,PM_Value_Dollars_Filter,PM_Resources,PM_Ext_Budget,PM_Ext_Budget_Filter,PM_Actual,PM_Actual_Filter,PM_Support,Sort_By,Sort_Order,view">
----->
<FORM ACTION="PM_Display.cfm" ID="MyForm" NAME="MyForm" METHOD="POST">
<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="FID" VALUE="#FORM.FID#">
<INPUT TYPE="Hidden" NAME="VIEW" VALUE="#FORM.VIEW#">
</CFOUTPUT>
</FORM>
<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="Get_Projects"
	maxpages="40"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
<BR><BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create XL output																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<CFSAVECONTENT VARIABLE="output_to_excel">
	<TABLE BORDER="1">
	<TR>
		<TD><B>Acct/Project</B></TD>
		<TD><B>Priority</B></TD>
		<TD><B>Status</B></TD>
		<TD><B>Phase</B></TD>
		<TD><B>Start Date</B></TD>
		<TD><B>End Date</B></TD>
		<!------<TD><B>Broker</B></TD>----->
		<TD><B>Pounds</B></TD>
		<TD><B>Dollars</B></TD>
		<!------<TD><B>QBrands</B></TD>----->
		<TD><B>FAR</B></TD>
		<TD><B>Sponsor<BR>FName</B></TD>
		<TD><B>Sponsor<BR>LName</B></TD>
		<!------<TD><B>Owner<BR>FName</B></TD>
		<TD><B>Owner<BR>LName</B></TD>----->
		<TD><B>Owner Position</B></TD>
		<TD><B>Resources</B></TD>
		<TD><B>Support</B></TD>
		<TD><B>Budget $</B></TD>
		<TD><B>Actual $</B></TD>
		<TD><B>CER/Acct number</B></TD>
		<TD><B>Created on</B></TD>
		<TD><B>Modified on</B></TD>
		<TD><B>Modified by</B></TD>
		<TD><B>Next Step/Update</B></TD>
	</TR>
	<CFOUTPUT QUERY="Get_Projects">

	<!--- Get the sponsor name --->
	<CFQUERY NAME="Get_Sponsor" datasource="#application.datasource#">
		Select		PM_Sponsor_Name_Last,
					PM_Sponsor_Name_First
		From		PM_Sponsor
		Where		PM_Sponsor_ID	=	'#PM_Sponsor_ID#'
	</CFQUERY>


	<!--- Get Owner --->
	<!------<CFQUERY NAME="Get_Owner" datasource="#application.datasource#">
		Select		Name_First, Name_Last	From _Users	Where User_ID = '#PM_Owner_ID#'
	</CFQUERY>----->
	
	<!------
	<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
		Select		Position_Label	From User_Positions	Where User_Positions_ID = '#PM_Position_ID#'
	</CFQUERY>----->
	
	<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
		Select		Position_Label	
		From 		PM_Owner_Position
					INNER JOIN User_Positions	
					ON
					User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
		Where 		
					PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
	</CFQUERY>

	<CFQUERY NAME="Get_User" datasource="#application.datasource#">
		Select Name_Last, Name_First from _users where user_id like '#PM_Modified_By_ID#'
	</CFQUERY>
	
	
	<CFQUERY NAME="Get_Notes" DATASOURCE="#application.datasource#">
		SELECT	PM_Notes.PM_Notes, Name_First + ' ' + Name_Last AS Full_Name, PM_Notes.Created_Date
		FROM	PM_Notes
				INNER JOIN _Users
				ON _Users.User_ID = PM_Notes.User_ID
		WHERE
				PM_Notes.PM_Item_Master_ID = '#PM_Item_Master_ID#'
		ORDER BY PM_Notes.Created_Date DESC
	</CFQUERY>

	<TR>
		<TD>#PM_Acct_Project#</TD>
		<TD>#PM_Priority_Description#</TD>
		<TD>#PM_Status_Description#</TD>
		<TD>#PM_Phase_Description#</TD>
		<TD>#DateFormat(PM_Start_Date,"mm/dd/yyyy")#</TD>
		<TD>#DateFormat(PM_End_Date,"mm/dd/yyyy")#</TD>
		<!------<TD>#PM_Broker#</TD>----->
		<TD>#PM_Value_Pounds#</TD>
		<TD>#PM_Value_Dollars#</TD>
		<!------<TD>#q_brand#</TD>----->
		<TD>#PM_Far_Description#</TD>
		<TD>#Get_Sponsor.PM_Sponsor_Name_First#</TD>
		<TD>#Get_Sponsor.PM_Sponsor_Name_Last#</TD>
		<!------<TD>#Get_Owner.Name_First#</TD>
		<TD>#Get_Owner.Name_Last#</TD>----->
		<TD>
		<TABLE BORDER="1">
		<CFLOOP QUERY="Get_Position">
		<TR><TD>#Position_Label#</TD></TR>
		</CFLOOP>
		</TABLE>
		</TD>
		<TD>#PM_Resources#</TD>
		<TD>#PM_Support#</TD>
		<TD>#PM_Ext_Budget#</TD>
		<TD>#PM_Actual#</TD>
		<TD>#PM_CER#</TD>
		<TD>#dateformat(PM_Date_Created, 'mm/dd/yyyy')#</TD>
		<TD>#dateformat(PM_Date_Modified, 'mm/dd/yyyy')#</TD>
		<TD>#Get_User.Name_First# #Get_User.Name_Last#</TD>
		<TD>
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="1" WIDTH="95%">						
		<CFLOOP QUERY="Get_Notes">
		<TR VALIGN="top">
			<TD>#Full_Name#</TD>
			<TD>#DateFormat(Created_Date, "mm/dd/yyyy")#</TD>
		</TR>
		<TR BGCOLOR="##eeeeee">
			<TD COLSPAN="2">
			#PM_Notes#
			</TD>
		</TR>					
		</CFLOOP>
		</TABLE>
		</TD>
	</TR>
	</CFOUTPUT>
	</TABLE>
</CFSAVECONTENT>



<!--- Create xl file name --->
<CFSET XL_file_name=createuuid()>

<!--- Replace the hifens with underscores --->
<CFSET XL_file_name=replace(XL_file_name,"-","_","All")>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get application Path and Drive Letter															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET appPath=request.APPLICATIONPATH>


<cfset output_to_excel="<cfcontent type=""application/unknown""><cfheader name=""Content-Disposition"" value=""attachment;filename=Project_List.xls"">#output_to_excel#">
<CFFILE ACTION="WRITE" FILE="#Application.Doc_Path#\temp_files\reportwriter\pm\excel_files\#XL_file_name#.CFM" OUTPUT="#output_to_excel#" ADDNEWLINE="Yes">


<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="pm_create.cfm">create a new project</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
&nbsp;&nbsp;
<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="index.cfm">search projects</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
&nbsp;&nbsp;
<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="/GetDocument.cfm?FilePath=temp_files/Reportwriter/pm/excel_files/<CFOUTPUT>#XL_file_name#</CFOUTPUT>.CFM">export projects to XL</A>&nbsp;<FONT COLOR="Red">]</FONT></B>

<BR><BR>

</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



