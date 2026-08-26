<!DOCTYPE HTML>
<html>
<head>
	<title>Untitled</title>
	<script>
		function showDistSearchWindow() 
		{	
			//document.DD_Reassign.target = "_self";
			document.DD_Reassign.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
			NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=DD_Reassign&SelectSingleSearchResultOnly=0", "DD_Reassign", 800, 600, "yes", "yes")
		}

		function showSearchWindow() 
		{
			//document.all.Form_Submitted.value=0;
			//document.DD_Reassign.target = "_self";
			document.DD_Reassign.SelectSingleSearchResultOnly.value = 0;
			document.DD_Reassign.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";					
			NewWindow("/Billbacks/search_Screens/PM_select_Brokers.cfm?Formname=DD_Reassign", "DD_Reassign", 800, 600, "yes", "yes")
		}

		function ValidateSearch()
		{
		var ErrorString;
			ErrorString = '';
			if(document.all.Distributor_ID.value !='' && document.all.Distributor_Name.value !='')
			{
				ErrorString = 'You cannot use both - Distributor ID and Distributor Name';
			}

			if(ErrorString != ''){
				ErrorString = ErrorString + '\n' + ' ';
			}

			if(document.all.Broker_ID.value !='' && document.all.Broker_Name.value !='')
			{
				ErrorString = ErrorString + 'You cannot use both - Broker ID and Broker Name';
			}

				if(ErrorString != '')
				{
					alert(ErrorString);
				}

				else
				{
					SubmittoDDSelection();
				}
		}
	</script>
	<!--- D42846 :: Deduction tool upgrades START --->
	<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
	<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
	<!--- D42846 :: Deduction tool upgrades END --->
	<STYLE>
	TABLE.BorderTable TD 
	{
		border-bottom:solid #93BEE2 1px;
	}
	</STYLE>
</head>
<body>
<CFPARAM NAME="FORM.Deduction_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Src_Analyst" 	DEFAULT="">
<CFPARAM NAME="FORM.Tar_Analyst" 	DEFAULT="">
<CFPARAM NAME="FORM.Src_Status" 	DEFAULT="">
<CFPARAM NAME="FORM.Distributor_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Broker_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="Selected_Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" DEFAULT="">
<CFPARAM NAME="Selected_Broker" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Status" DEFAULT="A">
<CFPARAM NAME="FORM.Broker_Status" DEFAULT="A">
<CFPARAM NAME="FORM.Tar_Classification" DEFAULT=""><!--- D33578 Ability to reclass when reassigning deduction --->
<!---D42846 :: Deduction tool upgrades --->
<CFPARAM NAME="FORM.src_Reason_Code" DEFAULT="">
<CFPARAM NAME="FORM.src_stage" DEFAULT="">
<cfparam name="form.create_list_numbers" default="">

		<CFIF FORM.Distributor_List NEQ "">
			<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
			<cfif useLakebaseForDist_Search_Result>
				<cftry>
					<cfset Dist_Search_Result = application.oLakebase.toQuery(
						application.oLakebase.selectRows("bsa_foodservice_customers", {
							"select" = "bsa_foodservice_customers_id,name",
							"bsa_foodservice_customers_id" = "in.(#FORM.Distributor_List#)",
							"deleted" = "eq.0",
							"active_code" = "eq.A",
							"order" = "name.asc"
						}),
						"bsa_foodservice_customers_id,name"
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForDist_Search_Result = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForDist_Search_Result>
			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name 
				FROM BSA_Foodservice_Customers 
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN ('#Replace(FORM.Distributor_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
			</cfif>
		<CFSET Selected_Distributor=ValueList(Dist_Search_Result.Name)>
		</CFIF>
		<CFIF FORM.Broker_List NEQ "">	
			<cfset useLakebaseForBroker_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
			<cfif useLakebaseForBroker_Search_Result>
				<cftry>
					<cfset Broker_Search_Result = application.oLakebase.toQuery(
						application.oLakebase.selectRows("bsa_foodservice_brokers", {
							"select" = "bsa_foodservice_brokers_id,broker_name",
							"bsa_foodservice_brokers_id" = "in.(#FORM.Broker_List#)",
							"deleted" = "eq.0",
							"active_code" = "eq.A",
							"order" = "broker_name.asc"
						}),
						"bsa_foodservice_brokers_id,broker_name"
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForBroker_Search_Result = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForBroker_Search_Result>
			<CFQUERY NAME="Broker_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Brokers_ID,Broker_Name 
				FROM BSA_Foodservice_Brokers 
				WHERE
					BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN ('#Replace(FORM.Broker_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
					AND
					BSA_Foodservice_Brokers.Deleted = 0
					AND
					BSA_Foodservice_Brokers.Active_Code = 'A'
				ORDER BY Broker_Name
			</CFQUERY>
			</cfif>
		<CFSET Selected_Broker= ValueList(Broker_Search_Result.Broker_Name)>
		</CFIF>

<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
	SELECT 		Analyst_User_ID,
				Name_First,
				Name_Last
	FROM 		DD_Analyst
	INNER JOIN	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID
	
	WHERE 		DD_Analyst.Deleted=0 AND 
				_Users.Deleted=0
	ORDER BY	_Users.Name_First,_Users.Name_Last
</CFQUERY>
<!--- D33578 Ability to reclass when reassigning deduction --->
<cfset useLakebaseForGet_Classification = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForGet_Classification>
	<cftry>
		<cfset Get_Classification = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"select" = "dd_classification_id,dd_classification_desc",
				"deleted" = "eq.0"
			}),
			"dd_classification_id,dd_classification_desc"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Classification = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Classification>
<CFQUERY NAME="Get_Classification" DATASOURCE="#Application.Datasource#">
	SELECT 	DD_Classification_ID, DD_Classification_Desc
	FROM 		DD_Classification
	WHERE 	Deleted=0
</CFQUERY>
</cfif>
<!--- D33578 Ability to reclass when reassigning deduction --->
<!---Get Possible statuses--->
<cfset useLakebaseForGetDDStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
<cfif useLakebaseForGetDDStatus>
	<cftry>
		<cfset GetDDStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_status", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetDDStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDDStatus>
<CFQUERY NAME="GetDDStatus" Datasource="#application.datasource#">
SELECT * 
FROM DD_Status 
WHERE Deleted = 0
	<!--- AND DD_Status_ID < 4 
		 OR DD_Status_ID = 7 ---> <!--- Dev Note: KAL; 7998 --->
</CFQUERY>
</cfif>
<!---D42846 :: Deduction tool upgrades START --->
<cfset useLakebaseForGetReasonCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForGetReasonCodes>
	<cftry>
		<cfset GetReasonCodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"deleted" = "eq.0",
				"display_in" = "in.(1,3)"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetReasonCodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetReasonCodes>
<cfquery name="GetReasonCodes" datasource="#application.datasource#">
	SELECT * 
	FROM DD_Reason_Code 
	WHERE Deleted = 0 
	AND Display_In IN (1,3)
</CFQUERY>
</cfif>
<!---D42846 :: Deduction tool upgrades END --->

<!--- START: D56649: Reassign Deductions - add drop down to reassign by 'action' --->
<cfset useLakebaseForGetDDStage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForGetDDStage>
	<cftry>
		<cfset GetDDStage = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_stage", {
				"deleted" = "eq.0",
				"order" = "dd_stage_description.asc"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetDDStage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDDStage>
<cfquery name="GetDDStage" datasource="#application.datasource#">
	SELECT *
	FROM DD_Stage WHERE Deleted = 0
	ORDER BY DD_Stage_Description
</cfquery>	
</cfif>
<!--- END: D56649: Reassign Deductions - add drop down to reassign by 'action' --->

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<FORM NAME="DD_Reassign" ACTION="Select_DD_BulkReassign.cfm" METHOD="Post">

<CFOUTPUT>
<INPUT TYPE="Hidden" VALUE="#FORM.Deduction_ID#" NAME="Deduction_ID">
</CFOUTPUT>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="85%" ALIGN="Center">
	<TR>
		<TD><FONT COLOR="navy" SIZE="3"><B>Reassign Deductions</B></FONT><HR COLOR="Orange"></TD>
	</TR>
	<TR>
		<TD>
			<TABLE BORDER="0" CELLPADDING="8" CELLSPACING="4" WIDTH="100%">
				<TR>
					<TD WIDTH="69%" BGCOLOR="ffce84">&nbsp;&nbsp;&nbsp;<B>Source:</B><BR></TD>					
					<TD WIDTH="31%" BGCOLOR="ffce84">&nbsp;&nbsp;&nbsp;<B>Target:</B><BR></TD>
				</TR>
				<TR BGCOLOR="C6FFC6" HEIGHT="30">
					<TD>
					<table width="100%" BORDER="0" cellpadding="4">
						<tr>
							<td align="left"><B>Analyst Name:</B>&nbsp;&nbsp;</td>
							<td align="left">
								<SELECT NAME="Src_Analyst" ONCHANGE="Javascript: ChangeDDID()" id="src_analyst"  multiple="multiple">
									<CFOUTPUT QUERY="Get_Analyst">
										<OPTION VALUE="#Analyst_User_ID#" <CFIF FORM.Src_Analyst EQ Analyst_User_ID>SELECTED</CFIF>>#Name_First# #Name_Last#</OPTION>
									</CFOUTPUT>
								</SELECT>
							</td>
							<td align="left"><B>Classification:</B>&nbsp;&nbsp;</td>
							<td align="left">
								<SELECT NAME="Src_Classification" id="src_classification"  multiple="multiple">
									<CFOUTPUT QUERY="Get_Classification">
										<OPTION VALUE="#DD_Classification_ID#" <CFIF FORM.Tar_Classification EQ DD_Classification_ID>SELECTED</CFIF>>#DD_Classification_Desc#</OPTION>
									</CFOUTPUT>
								</SELECT>
								<cfoutput><input type="hidden" value="#form.create_list_numbers#" name="create_list_numbers" value="#form.create_list_numbers#"></cfoutput>
								&nbsp; <cfoutput><a href="##" onclick="NewWindow('/common_files/createList2.cfm?parent=deduction', 'deduction_create_list', 350, 425, 'yes', 'yes');">#application.util.string.actionLinkFormat2("create list")#</a></cfoutput>
							</td>
						</tr>
						<tr>
						<!--- D42846 :: Deduction tool upgrades START --->
							<td align="left"><B>Reason Code:</B></td>
							<td align="left">
								<select name="src_Reason_Code"  id="src_Reason_Code"  multiple="multiple">
									<CFOUTPUT query="GetReasonCodes">
										<option value="#DD_Reason_Code_ID#">#trim(DD_Reason_Code_Description)#</option>
									</CFOUTPUT>
								</select>&nbsp;&nbsp;
							</td>	
						<!--- D42846 :: Deduction tool upgrades END--->
							<td align="left"><B>Status:</B></td>
							<td align="left">
								<select name="src_status"  id="src_status"  multiple="multiple">
								<cfoutput query="GetDDStatus">
								<option value="#DD_Status_ID#" <CFIF FORM.Src_Status EQ DD_Status_ID>SELECTED</CFIF>>#DD_Status_Description#</option>
								</cfoutput>
								</select>&nbsp;&nbsp;
							</td>		
						</tr>
						<!--- START: D56649: Reassign Deductions - add drop down to reassign by 'action' --->
							<cfif GetDDStage.RecordCount GTE 1>
								<tr>
									<td align="left"><B>Action:</B></td>
									<td align="left">
										<select name="src_stage"  id="src_stage"  multiple="multiple">
											<CFOUTPUT query="GetDDStage">
												<option value="#GetDDStage.DD_Stage_ID#" <CFIF FORM.src_stage EQ GetDDStage.DD_Stage_ID>SELECTED</CFIF>>#trim(DD_Stage_Description)#</option>
											</CFOUTPUT>
										</select>&nbsp;&nbsp;
									</td>	
									<td>&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
							</cfif>
						<!--- END: D56649: Reassign Deductions - add drop down to reassign by 'action' --->
					</table>
					</TD>			
					<TD style="vertical-align:top;"><B>Analyst Name:</B>&nbsp;&nbsp;
						<SELECT NAME="Tar_Analyst" style="width:150px;">
							<CFOUTPUT QUERY="Get_Analyst">
								<OPTION VALUE="#Analyst_User_ID#" <CFIF FORM.Tar_Analyst EQ Analyst_User_ID>SELECTED</CFIF>>#Name_First# #Name_Last#</OPTION>
							</CFOUTPUT>
						</SELECT>
						<!--- D33578 Ability to reclass when reassigning deduction --->
						<!--- <div style="margin-top:-10px;">&nbsp;</div> --->
						<br><br>
						<B>Classification:</B>&nbsp;&nbsp;
						<SELECT NAME="Tar_Classification" style="width:150px;" title="Select a new reason code to assign to all deductions or leave blank to retain existing classifications">
										<OPTION VALUE="" <CFIF FORM.Tar_Classification EQ ''>SELECTED</CFIF>></OPTION>
									<CFOUTPUT QUERY="Get_Classification">
										<OPTION VALUE="#DD_Classification_ID#" <CFIF FORM.Tar_Classification EQ DD_Classification_ID>SELECTED</CFIF>>#DD_Classification_Desc#</OPTION>
									</CFOUTPUT>
						</SELECT>
						<!--- <div style="margin-top:-10px;">&nbsp;</div> --->
					</TD>	
				</TR>
				<!--- D33578 Ability to reclass when reassigning deduction --->				
				<TR>
					<TD>
						<table  WIDTH="100%" BORDER="0">
							<CFPARAM NAME="FORM.Broker_Name" DEFAULT="">
						<cfoutput>
							<tr>
								<td WIDTH="15%"><B>#application.returned_customer_setting.broker_label_singular# ID:</B></td>
								<td WIDTH="15%"><input type="text" name="Broker_ID" size="7"></td>
								<td WIDTH="10%"><B>#application.returned_customer_setting.broker_label_singular#:</B></td>
								<td WIDTH="30%" nowrap><INPUT NAME="Broker_Name" ID="Broker_Name" VALUE="#Selected_Broker#" style="background-color: ##E9E9E9" READONLY>
								<a href="javascript: void(0);" onClick="javaScript: showSearchWindow();"><IMG border="0" src="/images/searchtool.gif"></a>
								 <B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript: document.all.DD_Reassign.Broker_Name.value=''">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
								</td>
								<td WIDTH="29%">
										<B>Status:</B>
										<SELECT NAME="Broker_Status" id="Broker_Status"  multiple="multiple">
											<OPTION VALUE="A">Active</OPTION>
											<OPTION VALUE="N">Inactive</OPTION>
										</SELECT>
								</td>
							</tr>
							</cfoutput>
						</table>
					</TD>
				</TR>
				<TR>
					<TD>
					<table  WIDTH="100%" BORDER="0">		
					<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
					<cfoutput>
						<tr>
							<td WIDTH="15%"><B>#application.returned_customer_setting.distributor_label_singular# ID:</B></td>
							<td WIDTH="15%"><input type="text" id="Distributor_ID" name="Distributor_ID" size="7"></td>
							<td WIDTH="10%"><B>#application.returned_customer_setting.distributor_label_singular#:</B></td>
							<td WIDTH="30%" nowrap><INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#Selected_Distributor#" style="background-color: ##E9E9E9" READONLY>
							<a href="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif"></a>
							<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript: document.all.DD_Reassign.Distributor_Name.value=''">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
							</td>
							<td WIDTH="29%">
							<B>Status:</B>
									<SELECT NAME="Distributor_Status" id="Distributor_Status"  multiple="multiple">
										<OPTION VALUE="A">Active</OPTION>
										<OPTION VALUE="N">Inactive</OPTION>
									</SELECT>
							</td>
						</tr>	
					</cfoutput>
					</table>
					</TD>
			</TR>					
			<TR>
				<TD COLSPAN="100%" ALIGN="Center"><BR><BR>			
					<SPAN ID="Resetall" <CFIF FORM.Deduction_ID NEQ "">STYLE="DISPLAY:NONE"</CFIF>>
					<CF_button
						button_name		=	""
						button_caption	=	"select deductions"
						button_action	=	"ValidateSearch();"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold">
						</SPAN>
				</TD>
			</TR>
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="85%" ALIGN="Center" CLASS="BorderTable" <CFIF FORM.Deduction_ID EQ "">STYLE="DISPLAY:NONE"</CFIF> ID="SelDD_Disp">
<CFIF FORM.Deduction_ID NEQ "">
	<!--- <CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT> --->
	<CFSET Selected_Items = ListQualify(FORM.Deduction_ID,"'",",","All")>
	<!--- <CFOUTPUT>#Selected_Items#</CFOUTPUT> --->
	
	<CFQUERY NAME="GetDeduction" DATASOURCE="#Application.Datasource#">
		SELECT 		Deductions.*,
							Distributor_Bill_To.Name,
							Distributor_Bill_To.Shr_Bill_To,
							DD_Status.DD_Status_Description,
							DD_Stage.DD_Stage_Description,
							BSA_Foodservice_Brokers.Broker_Name,
							Service_Regions.Region_Name,
							DD_Classification.DD_Classification_Desc,
							DD_Reason_Code.DD_Reason_Code_Description			
		FROM 			Deductions	
		LEFT JOIN 	Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID		 
		LEFT JOIN 	BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
		LEFT JOIN 	Service_Regions ON Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
		INNER JOIN 	DD_Status ON DD_Status.DD_Status_ID = Deductions.DD_Status
		LEFT JOIN 	DD_Stage ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage
		LEFT JOIN 	DD_Classification ON DD_Classification.DD_Classification_ID = Deductions.DD_Classification_ID	
		LEFT JOIN 	DD_Reason_Code ON Deductions.DD_Resolution_Code = DD_Reason_Code.DD_Reason_Code_ID              

		WHERE 		Deduction_ID IN (#PreserveSingleQuotes(Selected_Items)#)
	</CFQUERY>

	<CFQUERY NAME="Get_Max_Aging" DATASOURCE="#Application.Datasource#">
		SELECT 	* 
		FROM 	DD_Aging 
		WHERE 	Tier_Number = (	SELECT 	MAX(Tier_Number) 
								FROM 	DD_Aging 
								WHERE 	Deleted=0	) AND 
				Deleted=0
	</CFQUERY>

	<CFSET LastAgeEndRange = Get_Max_Aging.Start_Range>
	<CFSET LastAgeLabel = Get_Max_Aging.DD_Aging_Label>
	
	
		<TR>
			<TD COLSPAN="100%" STYLE="Border: None">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD STYLE="Border: None"><B>Deductions selected for reassignment</B>&nbsp;&nbsp;<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" OnClick= "SubmittoDDSelection()">back to deductions list</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
					<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
					<TD ALIGN="Right" STYLE="Border: None"><FONT COLOR="Red" SIZE="2">**</FONT><B>Check this to overwrite auto assignment.</B> </TD>
					</CFIF>
				</TR>
			</TABLE>
			</TD>
		</TR>
		<TR BGCOLOR="ffce84">
			<TD><INPUT TYPE="CheckBox" NAME="allbox" ONCLICK="javaScript: selectAll(this);" CHECKED></TD>
			<TD><B>DEDUCTION #</B></TD>
			<TD><B>CLASSIFICATION<BR>REASON CODE</B></TD><!--- D33578 Ability to reclass when reassigning deduction --->
			<TD><B>STATUS</B></TD>
			<TD><B>$ AMOUNT<BR>DISTRIBUTOR</B></TD>
			<TD><B>AGE<BR>ACTION</B></TD>
			<TD><B>BROKER<BR>REGION</B></TD>
			<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
			<TD><INPUT TYPE="CheckBox" NAME="PermanentReassign" ONCLICK="javaScript: selectAllForPer(this);" CHECKED><FONT COLOR="Red" SIZE="3">**</FONT></TD>
			</CFIF>
		</TR>
		<CFOUTPUT QUERY="GetDeduction">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD><INPUT TYPE="CheckBox" NAME="Selected_Deduction_ID" VALUE="#Deduction_ID#" CHECKED></TD>
			<TD><B>[ #DD_DedID_SP_Number#<!--- #DD_DedID# - <CFIF SP_Number EQ "">000<CFELSE>#SP_Number#</CFIF> ---> ]</B></TD>
			<TD><cfif len(DD_Classification_Desc)>#DD_Classification_Desc#<cfelse>N/A</cfif><br>#DD_Reason_Code_Description#</TD><!--- D33578 Ability to reclass when reassigning deduction --->
			<TD>#DD_Status_Description#</TD>
			<TD>#DollarFormat(DD_Amount)#<BR>#Name#</TD>
			<TD><CFSET NumberOfDays = DateDiff("d",DateFormat(DD_Date,"mm/dd/yyyy"),DateFormat(now(),"mm/dd/yyyy"))>
				<CFIF NumberOfDays GTE LastAgeEndRange>
					#LastAgeLabel# (#NumberOfDays# days)
				<CFELSE>
				<CFQUERY NAME="Get_Aging_Details" DATASOURCE="#Application.Datasource#">
					SELECT * FROM DD_Aging WHERE Deleted=0 AND Start_Range <= '#NumberOfDays#' AND End_Range >= '#NumberOfDays#'
				</CFQUERY>	
				#Get_Aging_Details.DD_Aging_Label# (#NumberOfDays# days)
				</CFIF><BR>
				#DD_Stage_Description#				
			</TD>
			<TD TITLE="#application.returned_customer_setting.billto_label#: #Shr_Bill_To#">#Broker_Name#<BR>#Region_Name#</TD>
			<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
			<TD><INPUT TYPE="CheckBox" NAME="PerReassign" VALUE="#Deduction_ID#" CHECKED></TD>
			</CFIF>
		</TR>
		</CFOUTPUT>				
</CFIF>
</TABLE>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="85%" ALIGN="Center" <CFIF FORM.Deduction_ID EQ "">STYLE="DISPLAY:NONE"</CFIF> ID="SelDD_Button">
	<CFIF FORM.Deduction_ID NEQ "">
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><HR COLOR="Orange"><BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Reassign Deductions"
					button_action	=	"Validate()"
					button_type		=	"javascript_link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold" >
			</TD>
		</TR>
	</CFIF>
	</TABLE>
<CFOUTPUT>
<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#Form.Distributor_list#">
<INPUT TYPE="Hidden" ID="Broker_List" NAME="Broker_List" VALUE="#Form.Broker_list#">
</CFOUTPUT>
<INPUT TYPE="Hidden" NAME="SelectSingleSearchResultOnly"	VALUE="0">
</FORM>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<!--- D42846 :: Deduction tool upgrades START--->
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.5.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>
<!---D42846 :: Deduction tool upgrades END --->
<SCRIPT language="JavaScript">
function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.Selected_Deduction_ID;
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

function selectAllForPer(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.PerReassign;
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

function SubmittoDDSelection()
{
	if (document.all.Src_Analyst.value != ""
		|| document.all.Distributor_ID.value != '' 
		|| document.all.Distributor_Name.value != ''
		|| document.all.Broker_ID.value != '' 
		|| document.all.Broker_Name.value != ''
		|| document.all.src_Reason_Code.value != ""
		|| seekElement("create_list_numbers").value != ""
		<cfif GetDDStage.RecordCount GTE 1>
			|| document.all.src_stage.value != ""
		</cfif>
		) {
		var formObj = document.DD_Reassign;
		var oldTarget = formObj.target;	
		formObj.target = "DDS";
		NewWindow("##", formObj.target, '870', '600', 'Yes', 'No', true);
		if(document.all.Distributor_Name.value == ''){
			document.all.Distributor_List.value = ''
		}
		if(document.all.Broker_Name.value == ''){
			document.all.Broker_List.value = ''
		}
		document.DD_Reassign.submit()
		formObj.target = oldTarget;
	}
	else {
		alert("Please select a search criteria");
	}
}
<!--- Dev Note: Milan;11515 - This function is no longer needed now as now the deduction search is not only based
			on analyst but also on broker and distributor --->
function ChangeDDID()
{
	//SelDD_Disp.style.display="none";
	//SelDD_Button.style.display="none";
	//Resetall.style.display="";
	//document.all.Deduction_ID.value="";
}
function Validate()
{
	var Submit_OK=1;
	var x=document.DD_Reassign;
	if (x.Tar_Analyst.value == "")
	{
		alert("Please select a 'Target' analyst.");
		Submit_OK=0;
		x.Tar_Analyst.focus();
		return;
	}
	else
	{
		if (x.Tar_Analyst.value == x.Src_Analyst.value)
		{
			alert("Source and target analyst canot be the same.")
			Submit_OK=0;
			x.Tar_Analyst.focus();
			return;
		}
	}
	if (!(Any_Object_Checked(x.Selected_Deduction_ID)))
	{
		alert("Please select at least one deduction to reassign.");
		Submit_OK=0;
		return;
	}
	
	if(Submit_OK)
	{
		x.action="Bulk_DD_Reassign_Action.cfm";
		x.submit();
	}
}

	/*D42846 :: Deduction tool upgrades START*/	
	$("#src_stage, #Broker_Status, #Distributor_Status, #src_analyst, #src_classification, #src_status, #src_Reason_Code").multiselect();
	/*
	$("#Broker_Status").multiselect(); 
	$("#Distributor_Status").multiselect(); 
	$("#src_analyst").multiselect();
	$("#src_classification").multiselect();
	$("#src_status").multiselect();
	$("#src_Reason_Code").multiselect();
	*/
	/*D42846 :: Deduction tool upgrades END*/	

</SCRIPT>
</body>
</html>