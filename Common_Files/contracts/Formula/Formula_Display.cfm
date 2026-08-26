<!------Formula_Display.cfm----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFPARAM NAME="URL.Formula_ID" 	DEFAULT="">
<CFPARAM NAME="Local.Program_Id" 	DEFAULT="0">
<CFPARAM NAME="URL.Program_Id" 	DEFAULT="#Local.Program_Id#">
<CFPARAM NAME="EDIT_RULE" 	DEFAULT=true>
<CFPARAM NAME="SHOW_ACTIVATE_BUTTON" 	DEFAULT=false>
<CFPARAM NAME="SHOW_RULE_TITLE" 	DEFAULT=true>
<CFPARAM NAME="URL.Contract_products_Id" 	DEFAULT="0">
<cfset tableWidth = 600/>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfscript>
	objProgramManager =  CreateObject("component", "components.programs.ProgramManager");
	decimalPrecision = objProgramManager.decimalPrecisionByUOM(2,1);
	decimalLen = objProgramManager.decimalPrecisionByUOM(2,0);
	appSettings = application.appSettingsGet;
	disableRFA = appSettings.getdisablepagesinrfa();
	oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
	oFormulaItem    = CreateObject("component", "mvc.Models.Program.FormulaItemLevel");
	q = oFormula.getProgramFormula(URL.Program_Id,URL.Contract_products_Id,URL.Formula_ID);
	if(q.recordCount == 0){
	  oFormula.saveProgramFormula(URL.Program_Id,0,'', URL.Contract_products_Id);
	  q = oFormula.getProgramFormula(URL.Program_Id,URL.Contract_products_Id);
	}
	url.Formula_ID = q.Program_Formula_Pricing_Rule_ID;

	qGetSavedFormulas = oFormulaItem.getSavedFormulas();
</cfscript>
<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css" 
                                        ] )#>
<script>
	window.onunload = function (e) {
	    opener.reloadGrid();
	};

	function createFromSaved(){
		var formulaId = $('#saved_formula').val();
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#URL.Program_Id#</cfoutput>,
										formulaId: formulaId,
										contractProductsId: <cfoutput>#URL.Contract_products_Id#</cfoutput>,
										oldFormulaId: <cfoutput>'#url.Formula_ID#'</cfoutput>,
										method: 'createFromSaved' }
							//,dataType: "json"
							,success: function (data) {
								location.reload();
				            }
				            ,error: function (data) {
				            	// console.log(data);
				                alert('An error occurred (createFromSaved).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
		}
</script>

<!---<CFSET URL.Formula_ID = Trim(URL.Formula_ID)>--->

<CFIF Len(URL.Formula_ID) LTE 0>
	<CFABORT>
</CFIF>
<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
	<CFQUERY NAME="Formula_Details" DATASOURCE="#application.datasource#">
		SELECT  *
		FROM Program_Formula_Pricing_Rules R
		INNER JOIN Contract_Main CM ON CM.Contract_Main_Id =  R.Program_id
		LEFT JOIN FP_Schedule_Options O ON
			O.FP_Schedule_Option_ID = ISNULL(CM.Formula_Price_Rebate_Type,0)
		LEFT JOIN FP_Formula_Types T ON
			T.FP_Formula_Type_ID = R.FP_Formula_Type_ID
		WHERE	R.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
				R.Deleted = 0
	</CFQUERY>
<cfelse>
	<CFQUERY NAME="Formula_Details" DATASOURCE="#application.datasource#">
		SELECT  * FROM Program_Formula_Pricing_Rules R
		LEFT JOIN FP_Schedule_Options O ON
			O.FP_Schedule_Option_ID = R.FP_Schedule_Option_ID
		LEFT JOIN FP_Formula_Types T ON
			T.FP_Formula_Type_ID = R.FP_Formula_Type_ID
		WHERE	R.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
				R.Deleted = 0
	</CFQUERY>
</cfif>

<cfset useLakebaseForgetProgramLockInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetProgramLockInformation>
	<cftry>
		<cfset getProgramLockInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#URL.Program_Id#",
				"select" = "contract_is_locked,contract_status_type_idx"
			}), "contract_is_locked,contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramLockInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramLockInformation>
<CFQUERY NAME="getProgramLockInformation" datasource="#application.datasource#">
		SELECT Contract_Is_Locked,Contract_Status_Type_IDX
		FROM Contract_Main
		WHERE Contract_Main_ID = '#URL.Program_Id#'
	</CFQUERY>
</cfif>

<cfset CSL_Contract_Main_ID = URL.Program_Id>
<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">

<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0 OR getProgramLockInformation.Contract_Is_Locked EQ 0 OR DisAllowAccessBasedOnProfile EQ 1 OR DisAllowAccessBasedOnLockStatus EQ 1 OR getProgramLockInformation.Contract_Status_Type_IDX GT 2>
	<CFSET EDIT_RULE = false>
</CFIF>

<CFIF disableRFA EQ 1 AND getProgramLockInformation.Contract_Status_Type_IDX EQ 2> <!--- IF EDIT is not ALLOWED IN rfa  --->
	<CFSET EDIT_RULE = false>
</CFIF>

<CFIF Formula_Details.Active EQ 0>
	<CFSET EDIT_RULE = false>
</CFIF>

<!--- <cfif CSLGetContractInfo.modifying_program EQ 0 AND CSLGetContractInfo.CONTRACT_STATUS_TYPE_IDX eq 2 and appsettings.getmodifyagreeprogram()>
	<CFSET EDIT_RULE = false>
</cfif>
<cfif EDIT_RULE EQ true and CSLGetContractInfo.modifying_user_id NEQ request.AccessStructure.User_ID and CSLGetContractInfo.modifying_program EQ 1>
	<cfset EDIT_RULE = false>
</cfif> --->

<CFSET linkName = 'edit'>
<CFIF Formula_Details.Recordcount EQ 0>
	<CFSET linkName = 'add new'>
</CFIF>


<CFQUERY NAME="Formula_Details_Commodities" DATASOURCE="#application.datasource#">
	SELECT	CED.Exchange_Detail_Abrev,*
	FROM	Program_Formula_Pricing_Rule_Comm_Data CD
			INNER JOIN Commodities_Symbol CS ON 
				CD.Commodities_Symbol_id = CS.Commodities_Symbol_id 
			INNER JOIN Commodities_Exchange_Detail CED ON 
				CD.Exchange = CED.Exchange_Detail_ID
			LEFT JOIN FP_Formula_Types T ON
				T.FP_Formula_Type_ID = CD.FP_Formula_Type_ID
	WHERE
			CD.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
			CD.Deleted = 0
	Order by CED.Exchange_Detail_Abrev, CS.Symbol_Description
</CFQUERY>

<CFQUERY NAME="Formula_Details_Overage" DATASOURCE="#application.datasource#">
	SELECT	*,ISNULL(Compound_Price,0) AS Compound_Price_notNull
	FROM	Program_Formula_Pricing_Rule_Overage
	WHERE
			Program_Formula_Pricing_Rule_Overage.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
			Program_Formula_Pricing_Rule_Overage.Deleted = 0
	ORDER BY Calc_Type DESC, Overage_Index
</CFQUERY>

<cfset useLakebaseForGet_All_Commodity_Overage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_commodity_overage")>
<cfif useLakebaseForGet_All_Commodity_Overage>
	<cftry>
		<cfset Get_All_Commodity_Overage = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_pricing_commodity_overage", {
				"program_formula_pricing_rule_id" = "eq.#URL.Formula_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_All_Commodity_Overage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_All_Commodity_Overage>
<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
			Deleted = 0
</CFQUERY>
</cfif>

<html>
<head>
	<title>Formula - <CFOUTPUT>#Formula_Details.Rule_Name#</CFOUTPUT></title>
	<style>
		.fieldText {
			border-left:1px solid #ccc;	/* Border similar to items at top of Program page */
			padding-left:5px; 
			margin-left: 20px;
		}
        .HighlightRowBg{
            background-color:#FFFF00;
        }
	</style>
</head>
<body>

<CFIF SHOW_RULE_TITLE>	
	<CFOUTPUT>
		<BR>
		<SPAN CLASS="SectionHeader">
		Formula Rule: #Formula_Details.Rule_Name#
		</SPAN>
	</CFOUTPUT>
	<CFIF EDIT_RULE>
	<CFOUTPUT>
	&nbsp;&nbsp;<a HREF="Formula_Price_Step1.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&Program_Id=#URL.Program_Id#&Contract_products_Id=#URL.Contract_products_Id#">#application.util.string.actionLinkFormat("#linkName# commodities")#</a>
	</CFOUTPUT>
	<cfif Formula_Details.Number_Of_Comms GT 0>&nbsp;&nbsp;<CFOUTPUT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&Program_Id=#URL.Program_Id#&Contract_products_Id=#URL.Contract_products_Id#">#application.util.string.actionLinkFormat("#linkName# commodity values")#</a>
		&nbsp;&nbsp;<a HREF="##" onClick="window.close(); return false;">#application.util.string.actionLinkFormat("close")#</a></CFOUTPUT>
	<cfelseif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>&nbsp;&nbsp;
	<!--- 	<div class="ml-2"> --->
	     <label class="SectionHeader">Create From Existing:</label>
			<select name="saved_formula" id="saved_formula" class="border rounded">
				<!---  <option disabled selected value>-- Rate UOM --</option> --->
				<cfoutput query="qGetSavedFormulas">
				<!--- 	<cfset s = ''/>
					<cfif FP_Schedule_Option_ID eq selectedOptionId><cfset s = 'selected'/></cfif>  --->
					<option value="#Program_Formula_Pricing_Rule_ID#">#Rule_Name#</option>
				</cfoutput>
			</select>
			&nbsp;&nbsp;<CFOUTPUT><a HREF="##" onClick="createFromSaved(); return false;">#application.util.string.actionLinkFormat("create from saved")#</a></CFOUTPUT>
	</CFIF>
	

</CFIF>
<!---	<CFIF SHOW_ACTIVATE_BUTTON AND Formula_Details.Active_Code EQ 0>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a href="Formula_Price_Activate.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&active=false" onClick="javascript:return confirm('Do you want to activate the rule \'' + '#ReplaceNOCase(Formula_Details.RULE_NAME,"'","\'","All")#' + '\'?');">activate rule</a><FONT COLOR="FF0000">]</FONT></B>
	</CFIF>--->
	<cfif len(Formula_Details.Price_Day_Description)>
		<cfset sSchedule = "#Formula_Details.Price_Day_Description# :: #Formula_Details.Effective_Day_Description#">
	<cfelse>
		<cfset sSchedule = "">
	</cfif>
<HR COLOR="Navy">
<CFELSE>
	<BR>
</CFIF>
<CFOUTPUT>
<table  border="0">
    <tr width="400">
        <td><SPAN>## Commodities: </SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#Formula_Details.Number_Of_Comms#</SPAN>
        </td>
    </tr>
    <tr width="400">
        <td><SPAN>Schedule:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#sSchedule#</SPAN>
        </td>
    </tr>
    <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
	    <tr width="400">
	        <td><SPAN>Type:</SPAN>
	        </td>
	        <td><SPAN CLASS="fieldText">&nbsp;#Formula_Details.Formula_Type_Description#</SPAN>
	        </td>
	    </tr>
	</cfif>
	<!--- display Item and Description if the Formula Price Item Level setting is on --->
	 <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
		<tr width="400">
			<td><SPAN>Item:</SPAN>
			</td>
			<td><SPAN CLASS="fieldText">&nbsp;#q.Item# - #q.Description#</SPAN>
			</td>
		</tr>
	</cfif>
	<cfif CSLGetContractInfo.Formula_Pricing_Type eq 2>
		<cfset selectedComp = oFormula.getFormulaComponent(url.Formula_ID) />
		<tr width="400">
			<td><SPAN>Component Name:</SPAN>
			</td>
			<td><SPAN CLASS="fieldText">&nbsp;#selectedComp.Program_Fixed_Component_Name#</SPAN>
			</td>
		</tr>
	</cfif>
	 <tr width="400">
        <td><SPAN>Price Date:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#DateFormat(Formula_Details.Price_DAte,"short" )#</SPAN>
        </td>
    </tr>
	 <tr width="400">
        <td><SPAN>Formula Price:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;$#NumberFormat(Formula_Details.Formula_Price, decimalPrecision)#</SPAN>
        </td>
    </tr>
</table>

</CFOUTPUT>

<!------------------ Display End ------------------------->

<cfset SumWeightedPrice = 0>
<CFLOOP QUERY="Formula_Details_Commodities">
	<CFOUTPUT>
		<cfif isnumeric(Formula_Details_Commodities.Final_Price) >
			<cfset SumWeightedPrice = SumWeightedPrice + Formula_Details_Commodities.Final_Price>
		</cfif>
	<BR>
	<!--- <SPAN CLASS="navbarlinks2">#Formula_Details_Commodities.Exchange_Detail_Name# :: #Formula_Details_Commodities.Exchange_Detail_Abrev# --->
	<!---<br>
	#Formula_Details_Commodities.Symbol_Description# :: </SPAN><SPAN CLASS="Title5Red">%#numberFormat(weight,99.99)#</SPAN><br>--->
	<FIELDSET STYLE="padding:2px; width: #tableWidth#; border: 1px solid ##93BEE2;">
	<LEGEND Class="Title5">#Formula_Details_Commodities.Exchange_Detail_Abrev# :: #Formula_Details_Commodities.Symbol_Description#</LEGEND>
	<table  border="0" cellpadding="2" cellspacing="0">
	    <tr>
	    <!---	<td CLASS="navbarlinks2" width="100">Symbol:
	        </td>
	        <td width="200"><SPAN CLASS="Title6">#Formula_Details_Commodities.Symbol_Description#</SPAN>
	        </td>--->
	        <td CLASS="Title3" nowrap="nowrap">Start Price:&nbsp;&nbsp;</td>
	        <td CLASS="Title7" width="85">$#numberFormat(Formula_Details_Commodities.Start_Price,decimalPrecision)# </td>
			<td CLASS="Title3"  nowrap="nowrap">Weight:&nbsp;&nbsp;</td>
	        <td CLASS="Title7"width="85">%#numberFormat(weight, decimalPrecision)#</td>
			<td CLASS="Title3"  nowrap="nowrap">Final Price (Weighted):&nbsp;&nbsp;</td>
	        <td CLASS="Title7" width="55">$#numberFormat(Formula_Details_Commodities.Final_Price,decimalPrecision)#</td>
	    </tr>
	    <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
		  	<tr>
		    	<td CLASS="Title3" nowrap="nowrap">Formula Type:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" width="285" colspan='5'>#Formula_Details_Commodities.Formula_Type_Description# </td>
				<!--- <td CLASS="Title3"  nowrap="nowrap">&nbsp;&nbsp;</td>
		        <td CLASS="Title7"width="5"></td>
				<td CLASS="Title3"  nowrap="nowrap">&nbsp;&nbsp;</td>
		        <td CLASS="Title7" width="5"></td> --->
		    </tr>
		</cfif>
	</table>
	

	<!---<BR>--->
	<CFIF EDIT_RULE>
	<!---<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step1.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#">edit commodities</a><FONT COLOR="FF0000">]</FONT></B>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&Program_Id=#URL.Program_Id#">edit commodity values</a><FONT COLOR="FF0000">]</FONT></B>--->
	</CFIF>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="#tableWidth#">
		<!---<TR>
			<TD WIDTH="30%" STYLE="font-size:12px;font-weight:bold;">Sample Size: #Sample_Size#&nbsp;#Sample_Size_UOM#</TD>
			<TD WIDTH="30%" STYLE="font-size:12px;font-weight:bold;">Lag: #Point_In_Time#&nbsp;#Sample_Size_UOM#</TD>
			<CFIF Formula_Details_Commodities.recordcount GT 1>
			<TD WIDTH="30%" STYLE="font-size:12px;font-weight:bold;">Weight: #Weight#%</TD>
			</CFIF>			
		</TR> --->
	</CFOUTPUT>
		<cfset useLakebaseForCommodities_Overage_1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all_commodity_overage")>
<cfif useLakebaseForCommodities_Overage_1>
	<cftry>
		<cfset Commodities_Overage_1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all_commodity_overage", {
				"program_formula_pricing_rule_comm_data_id" = "eq.#Program_Formula_Pricing_Rule_Comm_Data_ID#",
				"calc_type" = "eq.1",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCommodities_Overage_1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCommodities_Overage_1>
<CFQUERY NAME="Commodities_Overage_1" DBTYPE="query">
			SELECT	*
			FROM	Get_All_Commodity_Overage
			WHERE
					Get_All_Commodity_Overage.Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
					AND
					Calc_Type = 1
			ORDER BY Overage_Index
		</CFQUERY>
</cfif>
		<cfset useLakebaseForCommodities_Overage_2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all_commodity_overage")>
<cfif useLakebaseForCommodities_Overage_2>
	<cftry>
		<cfset Commodities_Overage_2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all_commodity_overage", {
				"program_formula_pricing_rule_comm_data_id" = "eq.#Program_Formula_Pricing_Rule_Comm_Data_ID#",
				"calc_type" = "eq.2",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCommodities_Overage_2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCommodities_Overage_2>
<CFQUERY NAME="Commodities_Overage_2" DBTYPE="query">
			SELECT	*
			FROM	Get_All_Commodity_Overage
			WHERE
					Get_All_Commodity_Overage.Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
					AND
					Calc_Type = 2
			ORDER BY Overage_Index
		</CFQUERY>
</cfif>
		
		<CFIF Commodities_Overage_1.RecordCount GT 0 OR Commodities_Overage_2.RecordCount GT 0>
		<TR>
			<TD COLSPAN="100%">
				<TABLE CELLPADDING="0" CELLSPACING="2" WIDTH="100%" BORDER="0">
					<TR  VALIGN="bottom">		
						<!--- If we have either, show both headers for consistency --->
						<CFIF (Commodities_Overage_1.RecordCount GT 0) OR (Commodities_Overage_2.RecordCount GT 0)>
							<TD BGCOLOR="FFCE84" ID="header">Compounded Calculations</TD>
							<TD BGCOLOR="FFCE84" ID="header" COLSPAN="2">Independent Calculations</TD>
						</CFif>
					</TR>
					<TR VALIGN="top">
						<TD WIDTH="50%">
						<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
							<cfset comp_Price = Formula_Details_Commodities.Start_Price/>
							<cfif NOT IsNumeric(comp_Price)>
								<cfset comp_Price = 0 >
							</cfif>
							<cfset ThisAmount = 0>
							<cfset ThisPrice = Formula_Details_Commodities.Start_Price>
							<CFLOOP QUERY="Commodities_Overage_2">
							<CFOUTPUT>
								<TR>
									<TD>#Description#</TD>
									<CFIF UOM EQ "%">
										<cfset ThisAmount = ((comp_Price * Amount)/100) -  comp_Price />					
										<TD>$#trim(numberformat(trim(ThisAmount + comp_Price), decimalPrecision))# ($#numberformat(comp_Price,decimalPrecision)# * #Amount##UOM#)</TD>
									<CFELSE>
										<cfset ThisAmount = Amount/>				
										<TD>#UOM##trim(numberformat(trim(Amount), decimalPrecision))#</TD>
									</CFIF>
								</TR>
							</CFOUTPUT>
						<!--- 	<cfset ThisPrice = comp_Price + ThisPrice/> ---> <!---it compounds so add --->
							<cfset comp_Price = comp_Price + ThisAmount />
							</CFLOOP>						
							<cfif comp_Price NEQ 0>
								<TR Class="totalsBg">
									<TD>Total $</TD>			
									<TD><cfoutput>#numberFormat(comp_Price,decimalPrecision)#</cfoutput></TD>
								</TR>
							</CFif>
						</TABLE>
						</TD>
						<TD WIDTH="50%">
						<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
							<cfset Idep_Price = 0>
							<cfset ThisAmount = 0> 
							<cfset ThisPrice = Formula_Details_Commodities.Start_Price>
							<CFLOOP QUERY="Commodities_Overage_1">
								<CFOUTPUT>
									<TR>
										<TD>#Description#</TD>
										<CFIF UOM EQ "%">
											<cfset ThisAmount = (ThisPrice * Amount)/100 />					
											<TD>$#trim(numberformat(trim(ThisAmount), decimalPrecision))# ($#numberformat(ThisPrice, decimalPrecision)# * #Amount##UOM#)</TD>
										<CFELSE>
											<cfset ThisAmount = Amount/>				
											<TD>#UOM##trim(numberformat(trim(Amount), decimalPrecision))#</TD>
										</CFIF>
									</TR>
								</CFOUTPUT>
								<cfset Idep_Price = Idep_Price + ThisAmount>
							</CFLOOP>
							<cfif Idep_Price NEQ 0>
								<TR Class="totalsBg">
									<TD>Total $</TD>			
									<TD><cfoutput>$#numberFormat(Idep_Price,decimalPrecision)#</cfoutput></TD>
								</TR>
							</CFif>
						</TABLE>
						</TD>
					</TR>
				</TABLE>			
			</TD>
		</TR>
		</CFIF>
	</TABLE>	
	</FieldSet>
	<br>
</CFLOOP>
<BR>
<CFIF Formula_Details_Overage.recordcount GT 0>
<SPAN CLASS="SectionHeader">Modifications:</SPAN>
<!---	<CFIF EDIT_RULE>
	<CFOUTPUT>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&Program_Id=#URL.Program_Id#">edit overage</a><FONT COLOR="FF0000">]</FONT></B>
	</CFOUTPUT>
	</CFIF> --->
	<HR COLOR="Navy">
	<cfset useLakebaseForFormula_Details_Overage_1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_details_overage")>
<cfif useLakebaseForFormula_Details_Overage_1>
	<cftry>
		<cfset Formula_Details_Overage_1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_details_overage", {
				"calc_type" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFormula_Details_Overage_1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFormula_Details_Overage_1>
<CFQUERY NAME="Formula_Details_Overage_1" DBTYPE="query">
		SELECT	*
		FROM	Formula_Details_Overage
		WHERE
				Calc_Type = 1
	</CFQUERY>
</cfif>
	<cfset useLakebaseForFormula_Details_Overage_2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_details_overage")>
<cfif useLakebaseForFormula_Details_Overage_2>
	<cftry>
		<cfset Formula_Details_Overage_2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_details_overage", {
				"calc_type" = "eq.2"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFormula_Details_Overage_2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFormula_Details_Overage_2>
<CFQUERY NAME="Formula_Details_Overage_2" DBTYPE="query">
		SELECT	*
		FROM	Formula_Details_Overage
		WHERE
				Calc_Type = 2
	</CFQUERY>
</cfif>
	<cfset udf = createObject( "component", "components.udf" )>
	<cfset UOMDivideBy = 0 />
	<CFIF Formula_Details_Overage.RecordCount GT 0>
		<cfoutput>
		<FIELDSET STYLE="padding:2px; width: #tableWidth#; border: 1px solid ##93BEE2;">
		<LEGEND Class="Title6">Overages</LEGEND>
		<TABLE CELLPADDING="0" CELLSPACING="2" WIDTH="#tableWidth#" BORDER="0"></cfoutput>
			<TR  VALIGN="bottom">		
				<CFIF Formula_Details_Overage_2.RecordCount GT 0><TD BGCOLOR="FFCE84" ID="header">Compounded Calculations</TD><cfelse><TD></TD></CFif>
				<CFIF Formula_Details_Overage_1.RecordCount GT 0><TD BGCOLOR="FFCE84" ID="header" COLSPAN="2">Independent Calculations</TD><cfelse><TD></TD></CFif>
			</TR>
			<TR VALIGN="top">
				<TD WIDTH="50%">
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
					<cfset comp_Price = 0/>
					<cfset ThisAmount = 0>
					<cfset ThisPrice = SumWeightedPrice>
					<CFLOOP QUERY="Formula_Details_Overage_2">
					<CFOUTPUT>
						<TR class="#IIf(UOM EQ '/', DE('HighlightRowBg'), DE(''))#">
							<TD>#Description#</TD>
							<CFIF UOM EQ "%">
								<cfset ThisAmount = (ThisPrice * Amount)/100 />					
								<TD>$#trim(numberformat(trim(ThisAmount), decimalPrecision))# ($#numberformat(ThisPrice, decimalPrecision)# * #Amount##UOM#)</TD>
							<CFELSEIF UOM EQ "/">
								<!--- If user uses the divide by ( / ) in the modification section, instead of the calc input being in addition to the value, it would replace the value --->
								<cfset ThisAmount = udf.RoundToDecimalPlaces(ThisPrice / Amount, decimalLen) />
								<TD>$#trim(numberformat(trim(ThisAmount), decimalPrecision))# ($#numberformat(ThisPrice, decimalPrecision)# / #Amount#)</TD>
								<cfset ThisPrice = ThisAmount />
								<cfset comp_Price = ThisAmount />
								<cfset ThisAmount = 0 />
								<cfset UOMDivideBy = 1 />
							<CFELSE>
								<cfset ThisAmount = Amount/>				
								<TD>#UOM##trim(numberformat(trim(Amount), decimalPrecision))#</TD>
							</CFIF>
						</TR>
					</CFOUTPUT>
					<cfset comp_Price = comp_Price + ThisAmount>
					<cfset ThisPrice = ThisAmount + ThisPrice/>
					</CFLOOP>
					<cfif comp_Price NEQ 0>
						<cfif UOMDivideBy>
						  <TR Class="totalsBg" Title="When divide by is used, the calculated value is the base price moving forward. Any additional modifications will be added to the divide by base price">
							<TD>Total $ <sup>*</sup></TD>			
							<TD><cfoutput>$#trim(numberformat(trim(comp_Price), decimalPrecision))#</cfoutput></TD>
						  </TR>
  						<cfelse>
						<TR Class="totalsBg">
							<TD>Total $</TD>			
							<TD><cfoutput>$#trim(numberformat(trim(comp_Price), decimalPrecision))#</cfoutput></TD>
						</TR>
  						</cfif>
					</CFif>
				</TABLE>
				</TD>
				<TD WIDTH="50%">
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
					<cfset Idep_Price = 0>
					<cfset ThisAmount = 0> 
					<cfset ThisPrice = SumWeightedPrice>
					<CFLOOP QUERY="Formula_Details_Overage_1">
					<CFOUTPUT>
						<TR>
							<TD>#Description#</TD>
							<CFIF UOM EQ "%">
								<cfset ThisAmount = (ThisPrice * Amount)/100 />					
								<TD>$#trim(numberformat(trim(ThisAmount), decimalPrecision))# ($#numberformat(ThisPrice, decimalPrecision)# * #Amount##UOM#)</TD>
							<CFELSE>
								<cfset ThisAmount = Amount/>				
								<TD>#UOM##trim(numberformat(trim(Amount),decimalPrecision))#</TD>
							</CFIF>
						</TR>
					</CFOUTPUT>
					<cfset Idep_Price = Idep_Price + ThisAmount>
					</CFLOOP>
					<cfif Idep_Price NEQ 0>
						<TR Class="totalsBg">
							<TD>Total $</TD>			
							<TD><cfoutput>$#trim(numberformat(trim(Idep_Price), decimalPrecision))#</cfoutput></TD>
						</TR>
					</CFif>
				</TABLE>
				</TD>
			</TR>
		</TABLE>
		</Fieldset>
	</CFIF>
</cfif>
	<!------<CFIF Formula_Details_Overage.RecordCount GT 0>
		<TABLE CELLPADDING="0" CELLSPACING="2" WIDTH="100%" BORDER="0">
		<TR BGCOLOR="FFCE84" VALIGN="bottom">		
			<TD ID="header"><b>
			Compounded 
			Calculations</b></TD>
			<TD ID="header" COLSPAN="2"><b>
			Independent 
			Calculations</b></TD>
		</TR>
		<TR VALIGN="top">
		<CFSET Calc_Type_1 = false>
		<CFOUTPUT GROUP="Calc_Type" QUERY="Formula_Details_Overage">		
		<CFIF Calc_Type EQ 1>
			<CFSET Calc_Type_1 = true>
		<CFELSEIF  Calc_Type EQ 2>
			<CFIF NOT Calc_Type_1>
				<TD WIDTH="50%"></TD>
			</CFIF>
		</CFIF>
		<TD WIDTH="50%">
		<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">						
			<CFOUTPUT>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
				<TD>#Description#</TD>
				<CFIF UOM EQ "%">				
					<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
				<CFELSE>				
					<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
				</CFIF>
				</TR>
			</CFOUTPUT>
		</TABLE>
		</TD>
		</CFOUTPUT>
		</TR>
		</TABLE>
		<CFELSE>
		<BR><BR>
		<FONT SIZE="1" COLOR="Red">
		<B>None Found</B>
		</FONT>
		</CFIF>----->
</body>
</html>
