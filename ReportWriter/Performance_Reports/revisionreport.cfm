<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Revision Report</TITLE>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">    				<!--28430-->
<style type="text/css">
.datagrid .odd  { background:#FFFFFF }
.datagrid .even { background:#CCFFCC }
.fr { float:right; }
.left { text-align: left; }
span.lbl { display:inline-block; width:107px; font-weight: bold; margin:2px 0;}
#rev124 td, #rev124 th { font-size:10px; }
</style>
</HEAD>
<cfparam name = "form.dosearch" default="0">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFPARAM NAME="URL.CPAccess" DEFAULT=""><!--- 83860 URL.CPAccess will be used in Application_Common.cfm ---->
<cfset local.URLCPAccessArgN = "" />
<cfset local.URLCPAccessArg1 = "" />
<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
	<cfset local.External_Customer_Profile_Access = 1 />
	<cfset local.URLCPAccessArg1 = "?CPAccess=#URL.CPAccess#" />
	<cfset local.URLCPAccessArgN = "&CPAccess=#URL.CPAccess#" />
</cfif>

<BODY>
<cfif request.AccessStructure.External_Customer_Profile_Access NEQ "1">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
</cfif>
<cfset Document_Title = "Program Revision Report">

<cfparam name="url.Contract_Number" default="">
<cfparam name="url.Contract_main_id" default="">
<cfparam name="url.Contract_Status" default="">
<cfparam name="url.runReport" default="0"> 	<!--- 49859 --->
<cfparam name="url.CID" default=""> 				<!--- 49859 --->
<cfparam name="form.sort_order" default="desc">
<cfparam name="form.sort_by" default="Revision_Report_Nightly.Contract_Number">
<cfparam name="form.program_number" default="">
<cfparam name="form.approval_type" default="0">
<cfparam name="url.bypassRevSummary" default="0">
<!--- add url program number into form scope for proper filter in query --->
<cfif !structKeyExists(form, "program_number")>
    <cfset form.program_number = structKeyExists(url, "contract_number") ? url.contract_number : ''>
</cfif>

<!--- Tim Ford WR 52484 - Revision Summary link Generating event error 4341: url.CID doesn't always get passed. If url.CID is an empty string then try to use url.Contract_main_id --->
<cfif trim(url.CID) eq "" and trim(url.Contract_main_id) NEQ "">
	<cf_cryp type="en" string ="#url.Contract_main_id#" key="#request.key#">
	<cfset url.CID = cryp.value />
</cfif>

<cfif url.Contract_main_id NEQ "" OR form.dosearch EQ 1>
<style>
	TD.Maintable {border-bottom:solid #93BEE2 1px;}
</style>

<cfquery name="Get_Parent" datasource="#application.datasource#">
	Select	contract_main_id, ISNULL(revision_of_contract_main_id, 0) as revision_of_contract_main_id, Approved, contract_number, ProgramType_ID
	From	contract_main
	where  	0=0
	<cfif form.program_number NEQ "">
		and contract_number like <cfqueryparam value="%#form.program_number#%" cfsqltype="cf_sql_varchar">
	</cfif>
	<cfif url.Contract_main_id NEQ "">
		and contract_main_id = <cfqueryparam value="#url.Contract_main_id#" cfsqltype="cf_sql_integer">
	</cfif>
	order by contract_main_id desc
</cfquery>

  <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#Get_Parent.ProgramType_ID#",
				"select" = "first_parent_id"
			}), "first_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID
    FROM Program_Control_Panel_Options
    WHERE ProgramControl_Panel_Options_ID = #Get_Parent.ProgramType_ID#
  </cfquery>
</cfif>

<cfset MarginUploadCFC = CreateObject("component","components.settings.upload_margin_Targets.uploadMarginTargets")/>
<cfset qFilters = MarginUploadCFC.ProductFilters(url.contract_main_id, GetTemplateInfo.First_parent_ID, 0) />

<!--- DEV Note: Kal 49859 -  Revision Report workflow and on-demand run --->
<cfquery name="qGetlastRunDate" datasource="#application.datasource#">
	SELECT 	TOP 1 Created_Date
	FROM 		o_Revisions_WFA
	-- WHERE 	contract_number = '#url.contract_number#'
	WHERE 	contract_main_id = <cfqueryparam value="#url.Contract_main_id#" cfsqltype="cf_sql_integer">
	ORDER BY Created_Date DESC
</cfquery>

<TABLE BORDER="0" ALIGN="center" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD align="left" style="border-bottom: 2px solid black;"><span style="font-size: 15px; font-weight:bold; color:black;left: 30px;">Program Revision Report</span></TD>
		 <!--- 49859 --->
		<TD align="left" style="border-bottom: 2px solid black;">
			<cfif request.AccessStructure.External_Customer_Profile_Access NEQ "1">
			<span style="font-size:10px; left: 10px;">
				<a href="/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id=<cfoutput>#EncodeForUrl(url.Contract_main_id)#</cfoutput>&Contract_Status=<cfoutput>#EncodeForUrl(url.Contract_Status)#</cfoutput>&CID=<cfoutput>#EncodeForUrl(url.cid)#</cfoutput>&contract_number=<cfoutput>#EncodeForUrl(url.Contract_Number)#</cfoutput>&runReport=1&bypassRevSummary=<cfoutput>#EncodeForUrl(url.bypassRevSummary)#</cfoutput>"><b>Update Revision Report</b></a> &nbsp;&nbsp;
				  (<cfoutput>last update on #dateformat(qGetlastRunDate.Created_Date, "mmm d, yyyy")# at #timeFormat(qGetlastRunDate.Created_Date, "short")#</cfoutput>)
			</span>
			</cfif>
		</TD>
		<TD align="right" style="border-bottom: 2px solid black; font-size: 10px; font-weight:bold;">
			<cfif url.bypassRevSummary eq 0>
				<a href="##" onClick='javaScript:viewRevisionSummary();'>Revision Summary</a>
			</cfif>
		</TD>
		<TD align="right" style="border-bottom: 2px solid black; color:red;">***This report only includes changed records***	</TD>
	</TR>
</TABLE>


<!--- 49859 --->
<script>
	function viewRevisionSummary(){
		window.open('/common_files/contracts/contract_revision_history.cfm?Contract_number=<cfoutput>#Get_Parent.contract_number#</cfoutput>&CID=<cfoutput>#EncodeForUrl(url.CID)#</cfoutput>','RevisionHistory','scrollbars=1,resizable=0,width=1300,height=650,left=0');
	}
</script>


<cfoutput>
	<!--- Query to get the margin uot.--->
	<cfquery name="qGetMarginUOT" datasource="#application.datasource#">
		SELECT	Volume_UOT.UOT_Desc, Volume_UOT.Unit_Multiplier
		FROM	_Users_Settings
				INNER JOIN Volume_UOT ON
				Volume_UOT.Volume_UOT_ID = _Users_Settings.Margin_UOT_ID
		WHERE	_Users_Settings.User_ID = <cfqueryparam value="#trim(request.AccessStructure.Company_Main_ID)#" cfsqltype="cf_sql_idstamp">
	</cfquery>

	<!--- Dev Note:Milan (23171) Call the job only if the program is not approved. Approved (and revised) programs already have an entry
			in the "Revision_Report_Nightly" table.
	--->
	<cfset vars.runStoredProc = false>
	<cfif Get_Parent.Approved eq 0>
		<cfset vars.runStoredProc = true>
	<cfelse>
		<!--28326 - if there is no revision record then we would need to run the stored proc-->
		<cfquery name="vars.qRevisions" datasource="#application.datasource#">
			SELECT TOP 1 1
			  FROM Revision_Report_Nightly
			 WHERE Contract_main_id = <cfqueryparam value="#url.Contract_main_id#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfset vars.runStoredProc = (vars.qRevisions.recordCount eq 0)>
	</cfif>

	<!--- DEV Note: Kal 49859 -  Revision Report workflow and on-demand run --->
	<cfif url.runReport> 	<cfset vars.runStoredProc = true> </cfif>

	<cfif vars.runStoredProc>
		<cfstoredproc procedure="SP_Revision_Report_Nightly" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@@CONTRACT_MAIN_ID" value="#url.Contract_main_id#" />
		</cfstoredproc>
	</cfif>

	<CFQUERY NAME="Get_Data" DATASOURCE="#application.datasource#">
		Select		Distinct Contract_Number,
					Generic_Type ,
					Discount_Identifier_id,
					Discount_Identifier_desc,
					contract_main_id,
					revision_of_contract_main_id,
					Requestor_Fname,
					Requestor_Lname,
					Broker_Name,
					requestor_id,
					contract_start_date,
					contract_end_date,
					contract_title,
					contract_status_type_desc,
					#form.sort_by#
		From		Revision_Report_Nightly
		inner join contract_status_types on
		contract_status_types.contract_status_type_id =
		Revision_Report_Nightly.contract_status_type_idx
		where  0=0
		<cfif form.program_number NEQ "">
			and contract_number like <cfqueryparam value="%#form.program_number#%" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif url.Contract_main_id NEQ "">
			and contract_main_id = <cfqueryparam value="#url.Contract_main_id#" cfsqltype="cf_sql_integer">
			<!--- --and Contract_Status_Type_IdX = #url.Contract_Status# --->
		</cfif>
		<cfif isdefined("form.Generic_Type")>
			<cfif form.Generic_Type NEQ 0 and form.Generic_Type NEQ "">
			and Generic_Type = <cfqueryparam value="#form.Generic_Type#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfif>
		<cfif isdefined("form.Discount_Identifier")>
			<cfif form.Discount_Identifier NEQ 0 and form.Discount_Identifier NEQ "">
			and Discount_Identifier_Id = <cfqueryparam value="#form.Discount_Identifier#" cfsqltype="cf_sql_integer">
			</cfif>
		</cfif>

		<cfif isdefined("form.Status")>
			<cfif form.Status NEQ 0 and form.Status NEQ "">
			and contract_status_type_idx = <cfqueryparam value="#form.Status#" cfsqltype="cf_sql_integer">
			</cfif>
		</cfif>
		<cfif isdefined("form.approval_type")>
			<cfif form.approval_type EQ 1>
			and contract_status_type_idx IN (4,5,6)
			<cfelseif form.approval_type EQ 2>
			and contract_status_type_idx IN (1,2)
			</cfif>
		</cfif>
		<cfif isdefined("form.Service_Region_ID")>
			<cfif form.Service_Region_ID NEQ 0 and form.Service_Region_ID NEQ "">
			and Service_Region_ID = <cfqueryparam value="#form.Service_Region_ID#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfif>
		<cfif isdefined("form.Responsible_Sales_Person")>
			<cfif form.Responsible_Sales_Person NEQ 0 and form.Responsible_Sales_Person NEQ "">
			and Responsible_user_id = <cfqueryparam value="#form.Responsible_Sales_Person#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfif>
		AND ( 0 = 0
		<CFIF 	isdefined("form.Start_Date") AND isdefined("form.Start_date_Operator")>
							<cfif ISDate(form.Start_Date)
								AND (form.Start_date_Operator EQ "Greater_Or_Equal"
									OR form.Start_date_Operator EQ "Equal"
									OR form.Start_date_Operator EQ "Less_Or_Equal"
									)>
							AND DateDiff(d, '#form.Start_Date#', approval_date)
							<CFSWITCH expression="#form.Start_date_Operator#">
								<CFCASE value="Greater_Or_Equal">
								>=
								</CFCASE>
								<CFCASE value="Equal">
								=
								</CFCASE>
								<CFCASE value="Less_Or_Equal">
								<=
								</CFCASE>
							</CFSWITCH>
							0
		</CFIF>
		</cfif>
		<CFIF 	isdefined("form.End_Date") AND isdefined("form.End_date_Operator")>
			<cfif ISDate(form.End_Date) AND (form.End_date_Operator EQ "Greater_Or_Equal" OR form.End_date_Operator EQ "Equal" OR form.End_date_Operator EQ "Less_Or_Equal")>
							AND DateDiff(d, '#form.End_Date#', approval_date)
							<CFSWITCH expression="#form.End_date_Operator#">
								<CFCASE value="Greater_Or_Equal">
								>=
								</CFCASE>
								<CFCASE value="Equal">
								=
								</CFCASE>
								<CFCASE value="Less_Or_Equal">
								<=
								</CFCASE>
							</CFSWITCH>
							0
		</CFIF>
		</CFIF> )
		Order by <cfoutput>#form.sort_by# #form.sort_order#</cfoutput>
	</CFQUERY>
</cfoutput>

<cfif NOT isdefined("URL.FAX_EMAIL") AND NOT isdefined("URL.PRINT") AND NOT isdefined("url.report_id")>
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>

	<SCRIPT>
		document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>
</cfif>

<cfsavecontent variable="revisionreportresults">
<cfif Get_Data.recordcount eq 0>
	<div align="center">
		<span style="font-size: 15px; font-weight:bold; color:black; left:30px;"> No Data to report</span>
		<cfoutput>
		<cfif Get_Parent.revision_of_contract_main_id NEQ 0 >
			<span style="font-size: 15px; font-weight:bold; left:30px; text-decoration: none;">&nbsp;&nbsp;
				<A HREF="program_changes.cfm?Program_ID=#Get_Parent.contract_main_id#&parent_program_id=#Get_Parent.revision_of_contract_main_id##local.URLCPAccessArgN#" onClick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;">Other Changes</A>
			</span>
		</cfif>
		</cfoutput>
	</div>
<cfelse>
	<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>

	<TABLE BORDER="0" ALIGN="center" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" id="rev124">
		<CFLOOP QUERY="Get_Data">
			<TR>
				<TD BGCOLOR="FFE083" colspan="2" style="font-size:11px;">
					<CFOUTPUT><span class="lbl">#Get_Data.Contract_Number#</span> #left(Get_Data.Contract_Title,75)# (#contract_status_type_desc#) &nbsp;&nbsp;<span style="text-decoration: none;"><A HREF="program_changes.cfm?Program_ID=#contract_main_id#&parent_program_id=#revision_of_contract_main_id##local.URLCPAccessArgN#" onClick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;"><b>Other Changes</b></A></span>
							<br><span class="lbl">Delivery Period:</span> #Dateformat(contract_start_date,"mmm d, yyyy")# - #Dateformat(contract_end_date,"mmm d, yyyy")# <br>
						<cfif discountIdentifierManager.discountIdentifierOn()>
							<span class="lbl">Discount Identifier:</span> #Discount_Identifier_desc#
						<cfelse>
							<span class="lbl">Program Generic Type:</span> #generic_type#
						</cfif>
					</CFOUTPUT>
				</TD>
			</TR>
			<TR>
				<TD BGCOLOR="FFE083" style="font-size:11px;"><B><CFOUTPUT>#Get_Data.Requestor_Fname# #Get_Data.Requestor_Lname#</CFOUTPUT></B></TD>
				<TD  BGCOLOR="FFE083" align="right">
					<FONT COLOR="red">	<B> [ </B> </FONT>
					<FONT COLOR="Blue">
							<B>
									<a href="##" id="b_csv" onclick="getCSVData();" style="color:blue;">export to csv</a>
							</B>
					</FONT>
					<FONT COLOR="red">	<B> ] </B> </FONT>&nbsp;&nbsp;
				</TD>
			</TR>

			<!--- MAKES THE FIRST CHARACTER OF THE ITEM LABEL UPPERCASE FOR UNIFORM HEADERS --->
			<cfset itemLabel = application.returned_customer_setting.item_label>
			<cfset itemLabel = ucase(removeChars(itemLabel,2,len(itemLabel))) & removeChars(itemLabel,1,1)>
			<tr>
				<td colspan="2">
				<div style="margin-top:10px;">
				<!--28430-->
				<table class="datagrid">
					<thead>
					<tr>
					    <th class="left">Ver</th>
					    <th class="left">Title</th>
					    <th class="left"><cfoutput>#itemLabel#</cfoutput> Number/Desc</th>
					    <th class="left">
								<select id="productAttributes" style="margin-left:5px;">
									<option value="0">Filter by Product Attributes</option>
									<CFOUTPUT QUERY="qFilters" GROUP="Category" GROUPCASESENSITIVE="No">
									  <optgroup label="#Category#">
										<CFOUTPUT>
											<option value="[#replace(category,' ','','all')# = #ID#]">#Description#</option>
										</CFOUTPUT>
									  </optgroup>
									</CFOUTPUT>
								</select>
							</th>
					    <th>Appr<br>Date</th>
					    <th class="left">Disc</th>
					    <th class="left">Component</th>
					    <th>Revised<br>Rate</th>
					    <th>Previous<br>Rate</th>
					    <th>Impact</th>
					</tr>
					</thead>

					<cfif appsettings.getrevisionreportuom() eq 3>            <!--28326-program UOM-->
						<CFQUERY NAME="Get_data2" DATASOURCE="#application.datasource#">
							SELECT DISTINCT BSA.Item
							                , Discount_Type_desc
							                , Current_uom
							                , Current_Rate = CASE Current_uom
							                                   WHEN 'LB' THEN Current_Rate_lb
							                                   ELSE Current_Rate_cs
							                                 END
							                , Revised_uom
							                , Revised_Rate = CASE Revised_uom
							                                   WHEN 'LB' THEN Revised_Rate_lb
							                                   ELSE Revised_Rate_cs
							                                 END
							                , Volume_cs        AS Volume
							                , Parent_Volume_cs AS Parent_Volume
															, Revision_Version
							                , Contract_Status_Type_IDX
							                , Component
							                , Description
							                , Approval_Date
							                , Contract_Title
							                ,BSA.Prod_Var_A_ID,BSA.Brand_ID,BSA.Type_Code_Desc_ID,BSA.Type_Group_Desc_ID,BSA.Q_Brand_ID
							  FROM Revision_Report_Nightly
							       INNER JOIN bsa_FoodService_Items_Master BSA
							         ON BSA.Item = Revision_Report_Nightly.Item
							 WHERE Contract_Number = <cfqueryparam value="#Trim(Get_Data.Contract_Number)#" cfsqltype="cf_sql_varchar">
							  AND Current_Rate_cs <> Revised_Rate_cs

							 ORDER BY Revision_Version DESC
							          , Discount_Type_desc
							          , BSA.Item
						</cfquery>
					<cfelseif appsettings.getrevisionreportuom() eq 1>
					  <!---
					    This was referring to Revision_Report_Nightly.Item earlier in the select changed
					    it to select BSA_Foodservice_Items_Master.Item in the below query
					    D18263 -  Anand Rao 03/02/09
					  --->
						<CFQUERY NAME="Get_data2" DATASOURCE="#application.datasource#">
								Select		distinct BSA.Item,Discount_Type_Desc,
											Current_Rate_CS as current_rate, Revised_Rate_CS as revised_rate,
											Volume_CS as volume, Parent_Volume_CS as Parent_Volume, Component, Description,
											Approval_Date
											, Current_uom = '#Application.UOMCaseAbrPlural#'
											, Revised_uom = '#Application.UOMCaseAbrPlural#'
			                , Contract_Title
											, Revision_Version
			                , Contract_Status_Type_IDX
			                ,BSA.Prod_Var_A_ID,BSA.Brand_ID,BSA.Type_Code_Desc_ID,BSA.Type_Group_Desc_ID,BSA.Q_Brand_ID
								From		Revision_Report_Nightly
								inner join BSA_Foodservice_Items_Master  BSA
								on 	BSA.Item = Revision_Report_Nightly.Item
								Where		Contract_Number	=	<cfqueryparam value="#Trim(Get_Data.Contract_Number)#" cfsqltype="cf_sql_varchar">
								AND			Current_Rate_CS <> Revised_Rate_CS
								Order by	Revision_Version Desc,Discount_Type_Desc,BSA.item
						</cfquery>
					<cfelse>
						<CFQUERY NAME="Get_data2" DATASOURCE="#application.datasource#">
								Select		distinct BSA.Item,Discount_Type_Desc,
											Current_Rate_LB as current_rate, Revised_Rate_LB as revised_rate,
											Volume_LB as volume, Parent_Volume_CS as Parent_Volume, Component, Description,
											Approval_Date
											, Current_uom = '#Application.UOMPoundAbrPlural#'
											, Revised_uom = '#Application.UOMPoundAbrPlural#'
			                , Contract_Title
											, Revision_Version
			                , Contract_Status_Type_IDX
			                ,BSA.Prod_Var_A_ID,BSA.Brand_ID,BSA.Type_Code_Desc_ID,BSA.Type_Group_Desc_ID,BSA.Q_Brand_ID
								From		Revision_Report_Nightly
								inner join BSA_Foodservice_Items_Master BSA
								on 	BSA.Item =	Revision_Report_Nightly.Item
								Where		Contract_Number	=	<cfqueryparam value="#Trim(Get_Data.Contract_Number)#" cfsqltype="cf_sql_varchar">
								AND			Current_Rate_LB <> Revised_Rate_LB
								Order by	Revision_Version Desc,Discount_Type_Desc,BSA.item
						</CFQUERY>
					</cfif>

					<!--28430-->
					<tbody>
					  <cfsetting enablecfoutputonly="true">
            <cfloop query="Get_data2">

									<cfif Get_data2.Prod_Var_A_ID NEQ ''>
										<cfset useLakebaseForgetDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("prod_var_a")>
<cfif useLakebaseForgetDesc>
	<cftry>
		<cfset getDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("prod_var_a", {
				"prod_var_a_id" = "eq.#Get_data2.Prod_Var_A_ID#",
				"select" = "prod_var_a_desc as description"
			}), "prod_var_a_desc as description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDesc>
<cfquery name="getDesc" datasource="#application.datasource#">
												SELECT Prod_Var_A_Desc AS Description FROM Prod_Var_A WHERE Prod_Var_A_ID = '#Get_data2.Prod_Var_A_ID#'
										</cfquery>
</cfif>
									<cfelseif Get_data2.Brand_ID NEQ ''>
										<cfquery name="getDesc" datasource="#application.datasource#">
												SELECT Brand_Name AS Description FROM Brand WHERE Brand_ID = '#Get_data2.Brand_ID#'
										</cfquery>
									<cfelseif Get_data2.Type_Code_Desc_ID NEQ ''>
										<cfquery name="getDesc" datasource="#application.datasource#">
												SELECT Type_Group_Desc AS Description FROM Type_Group_Desc WHERE Type_Code_Desc_ID = '#Get_data2.Type_Code_Desc_ID#'
										</cfquery>
									<cfelseif Get_data2.Type_Group_Desc_ID NEQ ''>
										<cfquery name="getDesc" datasource="#application.datasource#">
												SELECT Prod_Var_A_Desc AS Description FROM Prod_Var_A WHERE Type_Group_Desc_ID = '#Get_data2.Type_Group_Desc_ID#'
										</cfquery>
									<cfelseif Get_data2.Q_Brand_ID NEQ ''>
										<cfquery name="getDesc" datasource="#application.datasource#">
												SELECT Q_Brand AS Description FROM Q_Brand_Desc WHERE Q_Brand_ID = '#Get_data2.Q_Brand_ID#'
										</cfquery>
									</cfif>

              <cfoutput><tr ProdvarA='#Prod_Var_A_ID#' Brand='#Brand_ID#' TypeCode='#Type_Code_Desc_ID#' TypeGroup='#Type_Group_Desc_ID#' QBrand='#Q_Brand_ID#'></cfoutput>
          			<cfoutput><td class="maintable"><cfif Get_data2.Contract_Status_Type_IDX eq '1'>WIP<cfelseif Get_data2.Contract_Status_Type_IDX eq '2'>RFA<cfelse>V-<cfif len(Get_data2.revision_version) eq 4>#right("#Get_data2.revision_version#", 4)#<cfelseif len(Get_data2.revision_version) eq 5>#right("#Get_data2.revision_version#", 5)#<cfelse>#right("000#Get_data2.revision_version#", 3)#</cfif></cfif></td></cfoutput>
          			<cfoutput><td class="maintable">#Get_Data2.Contract_Title#</td></cfoutput>
          			<cfoutput><td class="maintable">#Get_Data2.Item# <br />#Get_Data2.Description#</td></cfoutput>
          			<cfoutput><td class="maintable">#getDesc.Description#</td></cfoutput>
          			<cfoutput><td class="maintable" width="75">#dateformat(Get_data2.approval_date, "mm/dd/yyyy")#</td></cfoutput>
			          <cfoutput><td class="maintable">#Get_Data2.discount_type_desc#</td></cfoutput>
      				  <cfoutput><td class="maintable">#Get_Data2.component#</td></cfoutput>
			          <cfoutput><td class="maintable" align="right"><CFIF Get_data2.Discount_Type_Desc NEQ 'Lump Sum'>#numberformat(Get_Data2.revised_rate, '$_,___,___,___.____')# / #Get_Data2.Revised_uom#</CFIF></td></cfoutput>
			          <cfoutput><td class="maintable" align="right"><CFIF Get_data2.Discount_Type_Desc NEQ 'Lump Sum'>#numberformat(Get_Data2.current_rate, '$_,___,___,___.____')# / #Get_Data2.Current_uom#</CFIF></td></cfoutput>
								<cfoutput><td class="maintable" align="right"></cfoutput>
								<CFIF Get_data2.Discount_Type_Desc EQ 'Lump Sum'>
									<cfoutput><CFIF Get_Data2.current_rate eq 0>#application.returned_customer_setting.item_label# added<CFELSEIF Get_Data2.revised_rate EQ 0>#application.returned_customer_setting.item_label# removed</CFIF></cfoutput>
								<CFELSE>
									<cfif Revised_uom EQ Current_uom>
										<CFSET delta = Revised_Rate - Get_Data2.Current_Rate>
										<CFIF delta eq 0>
											<cfoutput>$0.0000</cfoutput>
										<CFELSEIF delta GT 0>
												<cfoutput>#numberformat(delta, '$_,___,___,___.____')# / #Get_Data2.Revised_uom#</cfoutput>
										<CFELSE>
												<cfoutput><FONT COLOR="FF0000">#numberformat(delta, '$_,___,___,___.____')# / #Get_Data2.Revised_uom#</FONT></cfoutput>
										</CFIF>
									<cfelse>
										<cfoutput>UOM Changed</cfoutput>
									</cfif>
								</CFIF>
								<cfoutput></td></cfoutput>
              <cfoutput></tr></cfoutput>
            </cfloop>
            <cfsetting enablecfoutputonly="false">
					</tbody>
				</table>
				</div>
				</td>
			</tr>

		</CFLOOP>

	</TABLE>
	</cfif>
</cfsavecontent>
<cfoutput>#revisionreportresults#</cfoutput>

<cfset dest = "#Application.Doc_Path#\Temp_Files\RevisionReport\" >
<!--- check if destination directory is exising, if not, create one --->
<cfif Not DirectoryExists(dest)>
	<cfdirectory action="create" directory="#dest#">
</cfif>
<cfset filepath = "#Application.Doc_Path#\Temp_Files\RevisionReport\RevisionReport_#Replace(request.AccessStructure.user_id,"-","_","ALL")#">

<cflock timeout="10" type="exclusive">
	<cffile action="write" file="#filepath#.htm" output="#revisionreportresults#">
</cflock>

<cfif request.AccessStructure.External_Customer_Profile_Access NEQ "1">
<cfif NOT isdefined("URL.FAX_EMAIL") AND NOT isdefined("URL.PRINT") AND NOT isdefined("url.report_id")>
<cfset includefilepath = "/Temp_Files/RevisionReport/RevisionReport_#Replace(request.AccessStructure.user_id,"-","_","ALL")#.htm"><br>

<table align="center">
<tr>
			<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"NewWindow('/ReportWriter/Performance_Reports/report_print.cfm?Include_File_path=#urlencodedformat(includefilepath)#','name','800','600','Yes', 'No')"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"window.location.href='/ReportWriter/Performance_Reports/report_email_create.cfm?FAX_EMAIL=EMAIL&Include_File_path=#urlencodedformat(includefilepath)#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"fax"
						button_action	=	"window.location.href='/ReportWriter/Performance_Reports/report_email_create.cfm?FAX_EMAIL=FAX&Include_File_path=#urlencodedformat(includefilepath)#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare the contents of a fax to be sent"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			 --->
		</tr>

</table>
</cfif>
</cfif>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<form action="/common_files/csv.cfm<cfoutput>#local.URLCPAccessArg1#</cfoutput>" method ="post" id="csv_form">

<input type="hidden" name="csv_text" id="csv_text">

</form>

<!--28430-->
<cfif 1>
	<script type="text/javascript" src="/Script/javascript/revisionreport-ugly.js"></script>
<cfelse>
	<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.2-min.js"></script>
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-1.9.3.min.js"></script>
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
	<script type="text/javascript" src="/script/javascript/TableTools.min.js"></script>
	<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>
</cfif>

<script>
		getCSVData = function() {
		var csv_value=$('.datagrid').table2CSV();
		$("#csv_text").val(csv_value);
		$("#csv_form").submit();
		}
</script>

<script type="text/javascript">
$.fn.dataTableExt.afnSortData['rate-uom'] = function  ( oSettings, iColumn )
{
	var aData = [];
	$( 'td:eq('+iColumn+')', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
	  var x = $(this).text().toLowerCase();
		x = x.replace("$", "")                    /* remove currency sign */
	       .replace( /,/g, "" )                 /* remove commas */
	       .replace(" / cs", "")
	       .replace(" / lb", "")
	       .replace(" ", "")
	       ;
		aData.push( x );
	} );
	return aData;
}

$('#productAttributes').change(function() {
	if($(this).val() != 0){
    	$(".datagrid tbody tr").hide().filter($(this).val()).show();
    }else{
    	$(".datagrid tbody tr").show();
    }
}).change();

var grid = $('.datagrid').dataTable({
   "bAutoWidth": true
  ,"bPaginate": false
  ,"bStateSave": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'f<"fr">ti'
  ,"sScrollXInner": "100%"
  ,"aaSorting": [] <!---default sorting on version column--->
  ,"aoColumns": [   {"bSortable":true,  "bSearchable":true , "swidth":"7%"  }    <!---version--->
                  , {"bSortable":true,  "bSearchable":true , "swidth":"12%" }    <!---title--->
                  , {"bSortable":true,  "bSearchable":true , "swidth":"19%" }    <!---item--->
                  , {"bSortable":false,  "bSearchable":true, "swidth":"8%"  }    <!---Product Attributes--->
                  , {"bSortable":true,  "bSearchable":false, "swidth":"7%"  }    <!---approved date--->
                  , {"bSortable":true,  "bSearchable":false, "swidth":"7%"  }    <!---discount--->
                  , {"bSortable":true,  "bSearchable":false, "swidth":"10%" }    <!---component--->
                  , {"bSortable":true,  "bSearchable":false, "swidth":"10%", "sSortDataType":"rate-uom", "sType":"numeric" }    <!---prev rate--->
                  , {"bSortable":true,  "bSearchable":false, "swidth":"10%", "sSortDataType":"rate-uom", "sType":"numeric" }    <!---revised rate--->
                  , {"bSortable":true,  "bSearchable":false, "swidth":"10%", "sSortDataType":"rate-uom", "sType":"numeric" }    <!---impact--->
                ]
 ,"oLanguage": { "sSearch": "Filter by Version, Title or Item:&nbsp;" }
 })
 .fnSetFilteringDelay();
</script>
</BODY>
</HTML>