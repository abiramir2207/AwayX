<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.2.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.AjaxCFC.js"></script>
<script type="text/javascript">
		// additional files
		// $.AjaxCFC({require:'dDumper'});
		// more additional files
		// $.AjaxCFC({require:'jquery.fastSerialize'});

		// optional global settings
		// using these setters also automatically include dependencies
		$.AjaxCFCHelper.setDebug(false);
		$.AjaxCFCHelper.setBlockUI(false);
		$.AjaxCFCHelper.setUseDefaultErrorHandler(true);
		$.AjaxCFCHelper.setSerialization('json'); // json, wddx
	</script>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!--- <CFDUMP VAR="#FORM#">
<CFDUMP VAR="#URL#"> --->

<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<cfparam name="Closure_Type" default="NoReason">
<cfparam name="Reason_Code" default="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<CFPARAM NAME="FORM.FilterSearchPrograms" DEFAULT="">
<CFPARAM NAME="FORM.IsTrade" DEFAULT="">
<CFPARAM NAME="FORM.FromProgramSearch" DEFAULT="0">
<cfparam name="url.frompopup" default="0" >
<cfparam name="url.PopupReasonCode" default="0" >
<!--- Dev Note: Clay 9131: Allow Credit Write-Off (labels to match deduction type) --->
<CFPARAM NAME="Deduction_Label" Default="Deduction" />
<CFIF Deduction_Info.Is_Credit EQ 1>
	<cfset Deduction_Label = "Credit" />
</CFIF>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />


<CFIF FORM.FromProgramSearch EQ 1>
	<cfif businessSegManager.isEnabled()>
		<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(FORM.Program_ID) />
	</cfif>
	<cfset useLakebaseForAssociateProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForAssociateProgram>
		<cftry>
			<cfset associateData = { "program_id" = FORM.Program_ID }>
			<cfif IsDefined("busSegIdForProgram")>
				<cfset associateData.business_segment_id = busSegIdForProgram>
			</cfif>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				associateData
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForAssociateProgram = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAssociateProgram>
	<CFQUERY NAME="AssociateProgram" DATASOURCE="#Application.Datasource#">
		UPDATE  Deductions
		SET 	<CFIF IsDefined("busSegIdForProgram")>
				Business_Segment_ID = '#busSegIdForProgram#',
				</CFIF>
			Program_ID = '#FORM.Program_ID#'
		WHERE	Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
</CFIF>
<cfset useLakebaseForDeductionSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForDeductionSettings>
	<cftry>
		<cfset DeductionSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionSettings>
<cfquery name="DeductionSettings" datasource="#application.datasource#">
SELECT * FROM Deduction_Settings
</cfquery>
</cfif>

<cfset useLakebaseForAutoCloseReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_close")>
<cfif useLakebaseForAutoCloseReason>
	<cftry>
		<cfset AutoCloseReason = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_auto_close", {
				"select" = "dd_reason_code_id"
			}),
			"dd_reason_code_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForAutoCloseReason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAutoCloseReason>
<cfquery name="AutoCloseReason" datasource="#application.datasource#">
SELECT DD_Reason_Code_ID
FROM DD_Auto_Close
</cfquery>
</cfif>

<cfquery name="GetReasonCodes" datasource="#application.datasource#">
SELECT * 
FROM DD_Reason_Code
WHERE Deleted = 0 AND Display_In IN (1,3)
<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>	
AND GL_Account_Code like '%#Deduction_Info.GL_Account_Code#%'
</cfif>
<CFIF AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
AND DD_Reason_Code_ID != #AutoCloseReason.DD_Reason_Code_ID#
</CFIF>
<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
<CFIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 1>
AND Closing_Method = 1
<CFELSEIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type EQ 5>
AND Closing_Method = 2
<CFELSEIF Deduction_Info.Is_Last_Status_Rebill>
AND Closing_Method = 4
<CFELSEIF Deduction_Info.Is_Write_Off>
AND Closing_Method = 3
<CFELSEIF Deduction_Info.DD_Rejected>
AND Closing_Method = 5
</CFIF>
</CFIF>
ORDER BY DD_Reason_Code_Description
</cfquery>
<CFSET Show_Operator_List = VALUELIST(GetReasonCodes.Show_Operator)>
<CFSET Reason_Code_ID_List = VALUELIST(GetReasonCodes.DD_Reason_Code_ID)>


<cfset useLakebaseForAlreadyApprovingforRFA = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rfa")>
<cfif useLakebaseForAlreadyApprovingforRFA>
	<cftry>
		<cfset AlreadyApprovingforRFA = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rfa", {
				"deduction_id" = "eq.#Deduction_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForAlreadyApprovingforRFA = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAlreadyApprovingforRFA>
<cfquery name="AlreadyApprovingforRFA" datasource="#application.datasource#">
SELECT * FROM DD_RFA
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<cfif AlreadyApprovingforRFA.Recordcount GT 0>
	<cfset Reason_Code = AlreadyApprovingforRFA.Reason_Code>
	<cfif Closure_Type IS "NoReason">
		<Cfset Closure_Type = AlreadyApprovingforRFA.Closing_Method>
	</cfif>
</cfif>

<!---If it's a parent, check to make sure all the children are closed--->
<cfif Deduction_Info.DD_IsParent IS 1>

	<!---Goes to see if it has any unclosed children--->
	<cfset useLakebaseForAreThereUnclosedChildren = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForAreThereUnclosedChildren>
		<cftry>
			<cfset AreThereUnclosedChildren = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "deduction_id",
					"dd_parent_id" = "eq.#Deduction_ID#",
					"deleted" = "eq.0"
				}),
				"deduction_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForAreThereUnclosedChildren = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAreThereUnclosedChildren>
	<cfquery name="AreThereUnclosedChildren" datasource="#application.datasource#">
	SELECT Deduction_ID
	FROM Deductions
	WHERE DD_Parent_ID = '#Deduction_ID#'
	AND Deleted = 0
	AND (DD_Status < 4 OR DD_Status = 7)
	</cfquery>
	</cfif>
	<cfif AreThereUnclosedChildren.Recordcount GT 0>
	<br><div align="center" style="font-size: 14px;"><cfoutput><strong>There are #AreThereUnclosedChildren.Recordcount# unclosed children.

<p></p>
You cannot close a parent deduction until all its children are closed.</strong>
</cfoutput></div>
	<cfabort>
	</cfif>


</cfif>

<CFIF Deduction_Info.DD_Status EQ 2 OR Deduction_Info.DD_Status EQ 7>
	<cfset useLakebaseForDeletePrevious = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_agreed_info")>
	<cfif useLakebaseForDeletePrevious>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_agreed_info", { "deduction_id" = "eq.#Deduction_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDeletePrevious = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeletePrevious>
	<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
		DELETE FROM DD_Agreed_Info WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
	<cfset useLakebaseForDDUpdateRFA = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDDUpdateRFA>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"dd_status" = 3,
					"rfa_by" = request.AccessStructure.User_ID,
					"rfa_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDDUpdateRFA = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDDUpdateRFA>
	<CFQUERY NAME="DDUpdateRFA" DATASOURCE="#Application.Datasource#">
		UPDATE Deductions
		SET DD_Status = 3,
			RFA_By = '#request.AccessStructure.User_ID#',
			RFA_Date = getdate()
		WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>

	<cfset useLakebaseForUpdateApprovablePositions = application.oLakebase.isEnabled() AND application.oLakebase.isProcMigrated("Populate_Deduction_Approvable_Positions")>
	<cfif useLakebaseForUpdateApprovablePositions>
		<cftry>
			<cfset application.oLakebase.callProcedure("Populate_Deduction_Approvable_Positions", { "deduction_id" = Deduction_ID })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateApprovablePositions = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateApprovablePositions>
	<CFQUERY NAME="UpdateApprovablePositions" DATASOURCE="#Application.Datasource#">
		EXEC Populate_Deduction_Approvable_Positions '#Deduction_ID#'
	</CFQUERY>
	</cfif>

	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">This <cfoutput>#Deduction_Label#</cfoutput> status has been changed as Request For Approval.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?CenterToShow=Closure&Closure_Type=Approve&deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);


	</SCRIPT>
	<CFABORT>
</CFIF>

<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery>
</cfif>

<CFIF Closure_Type EQ "Approve">
	<CFQUERY NAME="GetProgramDetails" DATASOURCE="#Application.Datasource#">
		SELECT 		Deductions.Program_ID,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Start_Date,
					Contract_End_Date,
					Contract_Main.Business_Segment_ID

		FROM 		Deductions
		LEFT JOIN  	Contract_Main ON Contract_Main.Contract_Main_ID = Deductions.Program_ID
		WHERE 		Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	<!--- <CFDUMP VAR="#GetProgramDetails#"> --->

	<CFIF GetProgramDetails.Program_ID NEQ "">
		<CFQUERY NAME="GetQ_Brand" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT Q_Brand_Desc.Q_Brand,Q_Brand_Desc.Q_Brand_ID

			FROM 		Contract_Main

			INNER JOIN 	Contract_Products ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID AND
						Contract_Products.Deleted = 0
			INNER JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
			INNER JOIN	Product_Q_Brand_Desc ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND
						Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND
						Product_Q_Brand_Desc.Deleted = 0
			INNER JOIN 	Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
			<CFELSE>
			INNER JOIN 	Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
			</CFIF>

			WHERE 		Contract_Main.Contract_Main_ID = #GetProgramDetails.Program_ID#
		</CFQUERY>
		<!--- <CFDUMP VAR="#GetQ_Brand#"> --->
	</CFIF>

</CFIF>

<script>
function showGLAccountCode(DD_Id)
	{
		$.AjaxCFC({
                  url: "/components/Deduction/settings/gl_search_ajax.cfc", // your CFC
                  method: "getGLAccountById",
                  data: DD_Id,
                  serialization: "json",
                  success: function(result){
                  	if (result.recordcount > 0)
                  	{
                  		$("#gl_account_code").html(result.data[0].gl_account_code);
                  	}
                  	else {
                  	$("#gl_account_code").html('&nbsp;');
                  	}

                  	 }
				});
	}
</script>
<form name="BeginClosingDeduction" method="post" action="/deductions/closure/index.cfm"><!--- /deductions/closure/closing_part_2.cfm --->
<cfoutput>
<input type="hidden" name="Program_ID" value="">
<INPUT TYPE="Hidden" NAME="FilterSearchPrograms" VALUE="#FORM.FilterSearchPrograms#">
<INPUT TYPE="Hidden" NAME="Closure_Type" VALUE="#Closure_Type#">
<INPUT TYPE="Hidden" NAME="FromProgramSearch" VALUE="0">
<INPUT TYPE="Hidden" NAME="dd_classification_id" VALUE="#Deduction_Info.dd_classification_id#">
<table width="90%" ><tr><Td valign="Center">
<strong><font size="+1" color="navy">Close the <cfoutput>#Deduction_Label#</cfoutput></font></strong></td><td valign="Center" align="right"><img src="/images/close1.gif">&nbsp; &nbsp; &nbsp; </TD></tr>


<table border="0" width="100%" cellspacing="0" cellpadding="3" style="border-left:solid navy 2px; border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;">
	<CFIF Closure_Type EQ "Approve" AND application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
		<TR>
			<TD valign="top"><B>Check the box if it is a trade deduction:</B></TD><!--- style="border-right:solid navy 2px;" --->
			<CFSET IsChecked = "">
			<CFIF GetProgramDetails.Program_ID NEQ "" OR FORM.IsTrade EQ 1>
				<CFSET IsChecked = "checked">
			</CFIF>
			<TD><INPUT TYPE="CheckBox" NAME="IsTrade" VALUE="1" #IsChecked# ONCLICK="Javascript: HideProgramDetails()"></TD>
		</TR>
		<CFSET IsBusAvailable = 0>
		<!--- <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") /> --->
		<cfif businessSegManager.isEnabled()>
			<CFSET IsBusAvailable = 1>
			<TR>
				<TD style="border-top: solid navy 1px;" valign="top"><!--- border-right:solid navy 2px; --->
					<CFIF GetProgramDetails.Program_ID NEQ "">
						<B>Associated Business Segment:</B>
					<CFELSE>
						<B>Select a Business Segment:</B>
					</CFIF>
				</TD>
				<TD style=" border-top: solid navy 1px;">
					<!--- <CFIF GetProgramDetails.Program_ID NEQ ""> --->
					<CFIF GetProgramDetails.Program_ID NEQ "">
						<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(GetProgramDetails.Program_ID) />
						<CFQUERY NAME="GetBusinessSeg" DATASOURCE="#Application.Datasource#">
							SELECT Business_Unit_ID,Business_Unit_Desc,Business_Segment_ID
							FROM Business_Segment
							WHERE Business_Segment_ID =	'#busSegIdForProgram#'
						</CFQUERY>
					</CFIF>
						<SPAN ID="Disp_Bus_Seg" <CFIF GetProgramDetails.Program_ID EQ "">STYLE="DISPLAY:NONE"</CFIF>>
						<CFIF GetProgramDetails.Program_ID NEQ "">
						#GetBusinessSeg.Business_Unit_ID# -
						#GetBusinessSeg.Business_Unit_Desc#
						<CFSET FORM.Business_Segment_ID = GetBusinessSeg.Business_Segment_ID>
						</CFIF>
						</SPAN>
					<!--- <CFELSE> --->
						<CFPARAM NAME="FORM.Business_Segment_ID" DEFAULT="">
						<CFIF FORM.Business_Segment_ID NEQ "">
							<CFQUERY NAME="GetAllQBrand" DATASOURCE="#Application.Datasource#">
								SELECT 	Q_Brand_ID,
										Q_Brand,
										Q_Brand_Legacy

								FROM 	Q_Brand_Desc

								WHERE 	Business_Segment_ID = (SELECT Product_BS_Filter FROM Business_Segment WHERE Business_Segment_ID = '#FORM.Business_Segment_ID#') AND
										Deleted = 0
							</CFQUERY>
						</CFIF>
						<CFQUERY NAME="GetBusinessSegment" DATASOURCE="#Application.Datasource#">
							SELECT 	*
							FROM 	Business_Segment
							WHERE 	Active = 1 AND
									Deleted = 0
						</CFQUERY>
						<SPAN ID="Sel_Bus_Seg" <CFIF GetProgramDetails.Program_ID NEQ "">STYLE="DISPLAY:NONE"</CFIF>>
						<SELECT NAME="Business_Segment_ID" ONCHANGE="Javascript: getQBrandList()">
							<OPTION VALUE= "">
							<CFLOOP QUERY="GetBusinessSegment">
								<OPTION VALUE = "#Business_Segment_ID#" <CFIF FORM.Business_Segment_ID EQ Business_Segment_ID>SELECTED</CFIF>>#Business_Unit_ID# - #Business_Unit_Desc#</OPTION>
							</CFLOOP>
						</SELECT>
						</SPAN>
					<!--- </CFIF> --->&nbsp;
				</TD>
			</TR>
			<CFIF FORM.Business_Segment_ID NEQ "">
			<CFQUERY NAME="GetOpUnit" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Operating_Unit WHERE Business_Unit_Desc LIKE (SELECT Business_Unit_Desc FROM Business_Segment WHERE Business_Segment_ID = '#FORM.Business_Segment_ID#')
			</CFQUERY>
			<CFSET DummyVar = 0>
			<TR>
				<TD valign="top"><B>Pick an Operating Unit:</B></TD>
				<TD ID="OpUnit" <CFIF DummyVar EQ 1>STYLE="DISPLAY:NONE"</CFIF>>
					<SELECT NAME="Operating_Unit_ID">
						<OPTION VALUE="">
						<CFLOOP QUERY="GetOpUnit">
							<OPTION VALUE="#Operating_Unit_ID#">#Code# - #Operating_unit_Description#</OPTION>
						</CFLOOP>
					</SELECT>
				</TD>
			</TR>
			<TR ID="QBrandBasedOnBusSeg" <CFIF GetProgramDetails.Program_ID NEQ "">STYLE="DISPLAY:NONE"</CFIF>>
				<TD valign="top"><B>Pick a Q Brand</B></TD>
				<TD>
					<SELECT NAME="Q_Brand_ID">
					<OPTION VALUE="">
					<CFLOOP QUERY="GetAllQBrand">
						<OPTION VALUE="#Q_Brand_ID#">#Q_Brand#</OPTION>
					</CFLOOP>
					</SELECT>
				</TD>
			</TR>
			</CFIF>
		</cfif>
		<!--- Show this only if trade box is checked --->

			<TR ID = "Program_Det" <CFIF GetProgramDetails.Program_ID EQ "">STYLE="DISPLAY:NONE"</CFIF>>
				<TD><!--- style="border-right:solid navy 2px; border-top: solid navy 1px;" valign="top" --->
					<CFIF GetProgramDetails.Program_ID NEQ "">
						<B>Associated Program Details:</B>
					<CFELSE>
						<B>Associate a Program:</B>
					</CFIF>
				</TD>
				<TD><!---  style=" border-top: solid navy 1px;" --->
					<CFIF GetProgramDetails.Program_ID NEQ "">
						<B>#GetProgramDetails.Contract_Number#</B> &nbsp;&nbsp;
						<CFSET DispTitle = TRIM(GetProgramDetails.Contract_Title)>
						<CFSET DispTitleLen = LEN(DispTitle)>
						<CFIF DispTitleLen GT 25>
							<CFSET DispTitle = LEFT(DispTitle,25)>
							#DispTitle#...
						<CFELSE>
							#DispTitle#
						</CFIF>
						<BR>
						#DATEFORMAT(GetProgramDetails.Contract_Start_Date,"mm/dd/yyyy")# -
						#DATEFORMAT(GetProgramDetails.Contract_End_Date,"mm/dd/yyyy")#
					<CFELSE>
						<B><FONT COLOR="Red" SIZE="2">[ </FONT><A ONCLICK="SearchProgram()" STYLE="cursor: pointer;">pick a program</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
					</CFIF>
				</TD>
			</TR>

		<!--- END --->
		<!--- Show this only if trade box is checked --->
		<TR ID = "QBrand_Det" <CFIF GetProgramDetails.Program_ID EQ "">STYLE="DISPLAY:NONE"</CFIF>>
			<TD><B>Pick a Q Brand</B></TD><!---  style="border-right:solid navy 2px; border-top: solid navy 1px;" valign="top" --->
			<TD><!---  style="border-top: solid navy 1px;" --->
				<CFIF GetProgramDetails.Program_ID NEQ "">
				<SELECT NAME="Q_Brand_ID">
				<OPTION VALUE="">
				<CFLOOP QUERY="GetQ_Brand">
					<OPTION VALUE="#Q_Brand_ID#">#Q_Brand#</OPTION>
				</CFLOOP>
				</SELECT>
				</CFIF>
			</TD>
		</TR>
		<!--- end --->
	</CFIF>
	<cfset DDReasonCode = Deduction_Info.DD_Resolution_Code>
<!---D30737: Issue with non-trade deduction feature START--->
	<cfif url.PopupReasonCode EQ 0>
	<tr>
		<td  style="border-top: solid navy 1px;" valign="top"><strong>Select the reason for closing this <cfoutput>#lcase(Deduction_Label)#</cfoutput>:</strong></td><!--- border-right:solid navy 2px; --->
		<td style=" border-top: solid navy 1px;">
			<select name="ReasonCode" ONCHANGE=" <CFIF Closure_Type EQ "Approve" AND application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>CheckToShowOperator();</CFIF><cfif appsettings.getGL_Account_On()>showGLAccountCode(this.value);</cfif>">
			<CFIF GetReasonCodes.RecordCount GT 1>
			<OPTION VALUE="">Select a Reason Code</OPTION>
			</CFIF>
			<cfloop query="GetReasonCodes">
				<option value="#DD_Reason_Code_ID#" <cfif DD_Reason_Code_ID EQ Deduction_Info.DD_Resolution_Code>selected</cfif>>#trim(DD_Reason_Code_Description)#</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<cfelse>
		<input type="hidden" name="ReasonCode" value= #url.reasoncode#>
		<cfset DDReasonCode = url.reasoncode>
	</cfif>
<!---D30737: Issue with non-trade deduction feature END--->
    <cfif appsettings.getGL_Account_On()>
	 <tr>
		<td  style="border-top: solid navy 1px;font-weight:bold;" valign="top"><cfoutput>#Application.GLAccountLabel#</cfoutput> Code assigned to Reason Code:</strong></td><!---D42774 ---><!--- border-right:solid navy 2px; --->
		<td style=" border-top: solid navy 1px;">&nbsp;
			<span id="gl_account_code">
			<cfloop query="GetReasonCodes">
				<cfif (DD_Reason_Code_ID EQ DDReasonCode)>#GL_Account_Code#</cfif>
			</cfloop>
			</span>
		</td>
	</tr>
	</cfif>


	<cfif len(trim(Deduction_Info.DD_Closure_Type)) GT 0>
		<!---Billback--->
		<cfif Deduction_Info.DD_Closure_Type IS 1>
		<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
		SELECT	SUM(Paid_Amount) Paid_Amount
		FROM BB_Approved
		WHERE Billback_ID IN (SELECT DD_Closure_ID FROM DD_Closure_Detail
		WHERE Deduction_ID = '#Deduction_ID#' AND Interfaced_On IS NULL AND Ack_Received IS NULL AND Deleted = 0)
		</cfquery>

		</cfif>
	</cfif>
	<CFIF Closure_Type EQ "Approve" AND application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
		<cfset useLakebaseForGetOperator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
		<cfif useLakebaseForGetOperator>
			<cftry>
				<cfset GetOperator = application.oLakebase.toQuery(
					application.oLakebase.selectRows("dd_operator", {
						"deleted" = "eq.0"
					})
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetOperator = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetOperator>
		<CFQUERY NAME="GetOperator" DATASOURCE="#Application.Datasource#">
			SELECT * FROM DD_Operator WHERE Deleted = 0
		</CFQUERY>
		</cfif>
		<CFSET ShowOPDiv = 0>
		<INPUT TYPE="hidden" NAME="CheckOperator" VALUE="0">
		<TR ID="SEL_OP1" <CFIF ShowOPDiv EQ 0>STYLE="DISPLAY:NONE"</CFIF>>
			<TD <CFIF ShowOPDiv EQ 1>valign="top" style="border-right:solid navy 2px; border-top: solid navy 1px;"</CFIF>><strong>Select #application.returned_customer_setting.operator_label_singular#:</strong></TD>
			<TD <CFIF ShowOPDiv EQ 1>style=" border-top: solid navy 1px;"</CFIF>>
				<SELECT NAME="DD_Operator_ID">
					<OPTION VALUE=""></OPTION>
					<CFLOOP QUERY="GetOperator">
						<OPTION VALUE="#DD_Operator_ID#">#DD_Operator_Name#</OPTION>
					</CFLOOP>
				</SELECT>
			</TD>
		</TR>
	</CFIF>


	<!---Closure Amount--->
	<!---
	<cfif DeductionSettings.Use_Cleared_Amount IS 1>

	<tr>
		<td  style="border-top: solid navy 1px;" valign="top"><strong>Amount to Clear:</strong></td>
		<td style=" border-top: solid navy 1px;">
			<input type="text" size="15" maxlength="15" name="Cleared_Amount" value="#Deduction_Info.Cleared_Amount#" onKeyUp="clenseText(this, '0123456789.')">
		</td>
	</tr>
	<cfelse>
		<input type="hidden" name="Cleared_Amount" value="#Deduction_Info.DD_Amount#">
	</cfif>
	 --->

	<CFIF DeductionSettings.Require_BB_To_Close EQ 1 AND DeductionSettings.Use_Cleared_Amount EQ 1 AND Deduction_Info.DD_Closure_Type IS 1>
		<input type="hidden" name="Cleared_Amount" value="#GetBillbackInfo.Paid_Amount#">
	<CFELSE>
		<input type="hidden" name="Cleared_Amount" value="#Deduction_Info.DD_Amount#">
	</CFIF>
	<INPUT TYPE="Hidden" NAME="ClosingAction" VALUE="Approve">
	<!---
	<tr>
		<td valign="top" style="border-top: solid navy 1px;"><strong>Do you want to:<div id="error_Closure_Type">&nbsp;</div></strong></td><!--- border-right:solid navy 2px; --->
		<td style=" border-top: solid navy 1px;">
			<input type="radio" name="ClosingAction" value="Approve" <cfif Closure_Type IS "Approve"> checked</cfif><cfif Closure_Type IS "NoReason">checked</cfif> <CFIF Closure_Type EQ "Rebill" OR Closure_Type IS "Adjust">DISABLED</CFIF>> Close<br>
			<!--- <CFIF application.returned_customer_setting.DD_Show_Rebill EQ 1>
			<input type="radio" name="ClosingAction" value="Rebill" <cfif Closure_Type IS "Rebill"> checked</cfif><CFIF Closure_Type EQ "Approve" OR Closure_Type IS "Adjust">DISABLED</CFIF>> Rebill<br>
			</CFIF>
<cfif DeductionSettings.ExcandAdj IS 1 AND len(trim(Deduction_Info.Distributor_ID)) GT 0>
			<input type="radio" name="ClosingAction" value="Adjust" <cfif Closure_Type IS "Adjust"> checked</cfif> <CFIF Closure_Type EQ "Approve" OR Closure_Type IS "Rebill">DISABLED</CFIF>> Create Adjustment<br>
</cfif> --->
		</td>
	</tr>	 --->
</table>
<Br>
<div align="center">
	<!--- D29491: nonTrade START--->
<cfif url.frompopup>
	<a href="##" onclick="window.open('/deductions/closure/DD_Non_trade_all_items.cfm?Deduction_ID=#Deduction_ID#&Profile_ID=#Get_Profile_Settings.Profiles_ID#&from=pop-up', 'Non_Trade', 'width=850, height=600, scrollbars=yes');self.close();"><strong><font color="navy">[ back ]</font></strong></a>
	<a href="##" onclick="self.close();"><strong><font color="navy">[ close this window ]</font></strong></a>
<cfelse>
	<a href="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent"><strong><font color="navy">[ return to <cfoutput>#lcase(Deduction_Label)#</cfoutput> details ]</font></strong></a>&nbsp; &nbsp;
</cfif>
	<!--- D29491: nonTrade END--->
<cfif Deduction_Info.DD_Status GT 2 AND Deduction_Info.DD_Closure_Type EQ 1>

	<cfif (DeductionsProfilesSettings.DD_Approve IS 1) AND Deduction_Info.DD_Closure_Type EQ 1 AND (DeductionsProfilesSettings.DD_Approve_Amount EQ "*" OR DeductionsProfilesSettings.DD_Approve_Amount GTE GetBillbackInfo.Paid_Amount)>
		<div id="approveLink" style="display:inline">
		<a href="##" onclick="CloseDeduction('approveLink');return false;"><strong><font color="navy">[ approve <cfoutput>#lcase(Deduction_Label)#</cfoutput> ]</font></strong></a>
		</div>
	<CFELSEIF DeductionsProfilesSettings.DD_Approve IS 1 AND Get_Profile_Settings.DD_RFA_Agreed EQ 1>
		<div id="approveLink" style="display:inline">
		<a href="##" onclick="CloseDeduction('approveLink');return false;"><strong><font color="navy">[ agree <cfoutput>#lcase(Deduction_Label)#</cfoutput> ]</font></strong></a>
		</div>
	<CFELSE>
	[ you cannot approve this <cfoutput>#lcase(Deduction_Label)#</cfoutput> ]
	</CFIF>
<cfelse>
	
	<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1' AND (len(Deduction_Info.DD_Classification_ID) EQ 0 AND (len(Deduction_Info.DD_Stage) EQ 0 OR Deduction_Info.DD_Stage EQ 0))>	
		<cfset DDHasClassification = 0>
	<cfelse>
		<cfset DDHasClassification = 1>
	</cfif>
	<!--- 71877	Deduction Workflow Enhancement Updates START--->
	<CFIF DDHasClassification AND DeductionsProfilesSettings.DD_Approve IS 1 AND (DeductionsProfilesSettings.DD_Approve_Amount EQ "*" OR DeductionsProfilesSettings.DD_Approve_Amount GTE Deduction_Info.DD_Amount)>
		<CFSET ShowApprove = 1>
	<CFELSE>
		<CFSET ShowApprove = 0>
	</CFIF>
	<!--- 71877	Deduction Workflow Enhancement Updates END--->

	<div id="approveLink" style="display:inline">
		<cfset linktext = "">
			<CFIF ShowApprove EQ 1>
				<cfset linktext = "approve #lcase(Deduction_Label)#">
			<CFELSE>
				<cfset linktext = "Agree #lcase(Deduction_Label)#">
			</CFIF>
	<a href="##" onclick="CloseDeduction('approveLink');return false;">
		<cfoutput>#application.util.string.actionLinkFormat2('#linktext#')#</cfoutput> 
	</a>
	</div>
</cfif>
</div>
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">

</cfoutput>


</div>
</form>

<script>
function getQBrandList()
{
	document.BeginClosingDeduction.submit()
}

function HideProgramDetails()
{
	<CFIF Closure_Type EQ "Approve" AND application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
	var isProgramAssociated = "<CFOUTPUT>#GetProgramDetails.Program_ID#</CFOUTPUT>";
	var checkBusAvailable = "<CFOUTPUT>#IsBusAvailable#</CFOUTPUT>";
	<CFIF GetProgramDetails.Program_ID EQ "">
		var hideOpUnit = 1;
	<CFELSE>
		var hideOpUnit = 0;
	</CFIF>

	if (document.all.IsTrade.checked)
	{
		if (checkBusAvailable == 1)
		{
			document.all.Sel_Bus_Seg.style.display = "none";
			document.all.Disp_Bus_Seg.style.display = "";
			if (document.all.QBrandBasedOnBusSeg || document.all.Business_Segment_ID.value != "")
			{
				document.all.QBrandBasedOnBusSeg.style.display = "none";
			}
			if (hideOpUnit == 1)
			{
				if (document.all.OpUnit)
				{
					document.all.OpUnit.style.display = "none";
				}
			}
		}
		document.all.Program_Det.style.display = "";
		document.all.QBrand_Det.style.display = "";

	}
	else
	{
		if (isProgramAssociated != "")
		{
			if (confirm("Associated Program will be deleted from this <cfoutput>#lcase(Deduction_Label)#</cfoutput>"))
			{
				if (checkBusAvailable == 1)
				{
					document.all.Sel_Bus_Seg.style.display = "";
					document.all.Disp_Bus_Seg.style.display = "none";
					if (document.all.QBrandBasedOnBusSeg || document.all.Business_Segment_ID.value != "")
					{
						document.all.QBrandBasedOnBusSeg.style.display = "";
					}
				}
				document.all.Program_Det.style.display = "none";
				document.all.QBrand_Det.style.display = "none";
			}
		}
		else
		{
			if (checkBusAvailable == 1)
			{
				document.all.Sel_Bus_Seg.style.display = "";
				document.all.Disp_Bus_Seg.style.display = "none";
				if (document.all.QBrandBasedOnBusSeg || document.all.Business_Segment_ID.value != "")
				{
					document.all.QBrandBasedOnBusSeg.style.display = "";
				}
			}
			document.all.Program_Det.style.display = "none";
			document.all.QBrand_Det.style.display = "none";
		}
	}
	</CFIF>
}

function SearchProgram()
{
	document.all.FromProgramSearch.value = 1;
	<CFOUTPUT>
	NewWindow("/billbacks/search_screens/search_programs.cfm?FormName=BeginClosingDeduction&Deduction_ID=#Deduction_ID#&SelectSingleSearchResultOnly=1&Source=Deductions&Fieldname=Program_ID", "programswindow", 800, 600, "yes", "yes");
	</CFOUTPUT>
//onclick="NewWindow('/billbacks/search_screens/search_programs.cfm?FormName=BeginClosingDeduction&Deduction_ID=#Deduction_ID#&SelectSingleSearchResultOnly=1&Source=Deductions&Fieldname=Program_ID', 'programs', 800, 600, 'yes', 'yes')"
}
function CheckToShowOperator()
{
	var operatorList = "<CFOUTPUT>#Show_Operator_List#</CFOUTPUT>";
	var reasonCodeList = "<CFOUTPUT>#Reason_Code_ID_List#</CFOUTPUT>";
	var loopCount = "<CFOUTPUT>#GetReasonCodes.RecordCount#</CFOUTPUT>";
	var metCondition = 0;
	var operatorArray = new Array();
	var reasonCodeArray = new Array();
	operatorArray = operatorList.split(",");
	reasonCodeArray = reasonCodeList.split(",");
//	var operatorArray = new array(operatorList)

	for (i=0;i<loopCount;i++)
	{
		if (document.all.ReasonCode.value == reasonCodeArray[i])
		{
			if (operatorArray[i] == 1)
			{
				document.all.CheckOperator.value = 1;
				metCondition = 1;
				document.all.SEL_OP1.style.display="";
			}
		}
	}
	if (metCondition == 0)
	{
		document.all.CheckOperator.value = 0;
		document.all.SEL_OP1.style.display="none";
	}
}

function CloseDeduction(divName)
{
	var Submit_OK = 1;
	var validateBeforeClosing = 0;

	<CFIF Closure_Type EQ "Approve" AND application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
	validateBeforeClosing = 1;
	var programID = "<CFOUTPUT>#GetProgramDetails.Program_ID#</CFOUTPUT>";
	var isBusSegOn = "<CFOUTPUT>#IsBusAvailable#</CFOUTPUT>";
	var validateOperatorBeforeClosing = 0;
	<CFIF application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
	validateOperatorBeforeClosing = 1;
	</CFIF>
	if (validateBeforeClosing == 1)
	{
		if (document.all.IsTrade.checked)
		{
			if (programID == "")
			{
				alert("Please associate a program and try again.");
				Submit_OK = 0;
				return;
			}
			if (document.all.Q_Brand_ID.value == "")
			{
				alert("Please select a Q Brand and try again");
				Submit_OK = 0;
				return;
			}
		}
		else
		{
			if (isBusSegOn == 1)
			{
				if (document.all.Business_Segment_ID.value == "")
				{
					alert("Please select a business segment and try again");
					Submit_OK = 0;
					return;
				}
			}
		}

		if (validateOperatorBeforeClosing == 1)
		{
			if (document.all.CheckOperator.value == 1)
			{
				if (document.all.DD_Operator_ID.value == "")
				{
					Submit_OK = 0;
					alert("Please select a <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> and try again.");
					return;
				}
			}
		}
	}
	</CFIF>
	if (document.all.ReasonCode.value == "")
	{
		alert("Please select a reason code and try again");
		Submit_OK = 0;
		return;
	}
	if (Submit_OK == 1)
	{
		document.BeginClosingDeduction.action = "/deductions/closure/closing_part_2.cfm";
		document.BeginClosingDeduction.submit();
		disableButton(divName, true, false);
	}
}
</script>