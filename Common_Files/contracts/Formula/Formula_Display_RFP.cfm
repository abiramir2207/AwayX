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
	appSettings = application.appSettingsGet;
	oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
	oFormulaItem    = CreateObject("component", "mvc.Models.Program.FormulaItemLevel");
	oRFP   = CreateObject("component", "mvc.Models.Program.RfpManager");
	q = oFormula.getProgramFormula(URL.Program_Id,URL.Contract_products_Id,URL.Formula_ID);
	if(q.recordCount == 0){
	  oFormula.saveProgramFormula(URL.Program_Id,0,'', URL.Contract_products_Id);
	  q = oFormula.getProgramFormula(URL.Program_Id,URL.Contract_products_Id);
	}
	url.Formula_ID = q.Program_Formula_Pricing_Rule_ID;

	qGetSavedFormulas = oFormulaItem.getSavedFormulas();

	qGetComps = oRFP.getRFPCompIdListQuery(URL.Program_Id);
</cfscript>
<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css" 
                                        ] )#>
<script>
	window.onunload = function (e) {
	    opener.getRFPProducts();
	};

	function createFromSaved(){
		var formulaId = $('#saved_formula').val();
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#URL.Program_Id#</cfoutput>,
										formulaId: formulaId,
										contractProductsId: <cfoutput>#URL.Contract_products_Id#</cfoutput>,
										oldFormulaId: <cfoutput>'#url.Formula_ID#'</cfoutput>,
										method: 'createFromSavedRFP' }
							//,dataType: "json"
							,success: function (data) {
								location.reload();
				            }
				            ,error: function (data) {
				            	// console.log(data);
				                alert('An error occurred (createFromSavedRFP).  ' + JSON.stringify(data) );
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

<CFQUERY NAME="Formula_Details" DATASOURCE="#application.datasource#">
	SELECT  *,
			ISNULL(PFCN.Program_Fixed_Component_Name,'') AS CompName,
			ISNULL(PFCN.Program_Fixed_Component_Name_Id,'0') AS CompNameID,
			ISNULL(PFPPD.Program_Fixed_Component_Id,'0') AS CompID
	FROM Program_Formula_Pricing_Rules R
	INNER JOIN Contract_Main CM ON CM.Contract_Main_Id =  R.Program_id
	LEFT JOIN FP_Schedule_Options O ON
		O.FP_Schedule_Option_ID = ISNULL(CM.Formula_Price_Rebate_Type,0)
	LEFT JOIN FP_Formula_Types T ON
		T.FP_Formula_Type_ID = R.FP_Formula_Type_ID
	LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
				PFPPD.Contract_Products_ID = R.Contract_Products_Id AND
				PFPPD.Deleted = 0 AND
				PFPPD.Program_Fixed_Component_ID = R.Program_Fixed_Component_Id
	LEFT JOIN Program_Fixed_Component_Name PFCN ON
				R.Program_Fixed_Component_Name_Id = PFCN.Program_Fixed_Component_Name_Id
	--- LEFT JOIN Program_Fixed_Component PFC ON PFC.Program_Fixed_Component_Id = R.Program_Fixed_Component_Id
	WHERE	R.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
			R.Deleted = 0
</CFQUERY>

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
SELECT	CED.Exchange_Detail_Abrev,
		CED.Exchange_Detail_Name,
		PFPPD.Fixed_Price_Value,
		PFPPD.Market_Price_Rate_Orig,
		CD.*,
		CS.*,
		T.*,
		ISNULL(CP.Net_Weight,I.Net_Weight) as Net_Weight,
		ISNULL(CP.Gross_Weight,I.Gross_Weight) as Gross_Weight,
		PFPPD.Contract_Products_ID
	FROM	Contract_Products CP --ON 
			--	CP.Contract_Products_ID = PFPPD.Contract_Products_ID
			LEFT JOIN BSA_Foodservice_Items_Master I ON I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
			LEFT JOIN  Program_Formula_Pricing_Rule_Comm_Data CD ON
				CD.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
				CD.Deleted = 0	
			LEFT JOIN Program_Formula_Pricing_Rules R ON
				R.Program_Formula_Pricing_Rule_ID = CD.Program_Formula_Pricing_Rule_ID
			LEFT JOIN Commodities_Symbol CS ON 
				CD.Commodities_Symbol_id = CS.Commodities_Symbol_id 
			LEFT JOIN Commodities_Exchange_Detail CED ON 
				CD.Exchange = CED.Exchange_Detail_ID
			LEFT JOIN FP_Formula_Types T ON
				T.FP_Formula_Type_ID = CD.FP_Formula_Type_ID
			LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
				PFPPD.Contract_Products_ID = R.Contract_Products_Id	 AND 
				PFPPD.Program_Fixed_Component_ID = R.Program_Fixed_Component_Id	
	WHERE CP.Contract_Products_Id = #URL.Contract_Products_Id#
			
	Order by CED.Exchange_Detail_Abrev, CS.Symbol_Description
</CFQUERY>
<!--- 
<cfdump var="#Formula_Details_Commodities#">
<cfdump var="#Formula_Details#">
<CFQUERY NAME="Formula_Details_Overage" DATASOURCE="#application.datasource#">
	SELECT	*,ISNULL(Compound_Price,0) AS Compound_Price_notNull
	FROM	Program_Formula_Pricing_Rule_Overage
	WHERE
			Program_Formula_Pricing_Rule_Overage.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
			Program_Formula_Pricing_Rule_Overage.Deleted = 0
	ORDER BY Calc_Type DESC, Overage_Index
</CFQUERY>

<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#' AND
			Deleted = 0
</CFQUERY> --->

<html>
<head>
	<title>Formula - <CFOUTPUT>#Formula_Details.Rule_Name#</CFOUTPUT></title>
	<style>
		.fieldText {
			border-left:1px solid #ccc;	/* Border similar to items at top of Program page */
			padding-left:5px; 
			margin-left: 20px;
		}
		.fieldTextRight {	/* Border similar to items at top of Program page */
			text-align: right;
		}
		.title7{
			text-align: right;
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
	&nbsp;&nbsp;<a HREF="Formula_Price_Step1_RFP.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&Program_Id=#URL.Program_Id#&Contract_products_Id=#URL.Contract_products_Id#&Program_Fixed_Component_Id=#Formula_Details.compId#&Program_Fixed_Component_Name_Id=#Formula_Details.compNameId#">#application.util.string.actionLinkFormat("#linkName# commodities")#</a>
	</CFOUTPUT>
	<cfif Formula_Details.Number_Of_Comms GT 0>&nbsp;&nbsp;<CFOUTPUT><a HREF="Formula_Price_Step2_RFP.cfm?RID=#Formula_Details.Program_Formula_Pricing_Rule_ID#&Program_Id=#URL.Program_Id#&Contract_products_Id=#URL.Contract_products_Id#&Program_Fixed_Component_Id=#Formula_Details.compId#&Program_Fixed_Component_Name_Id=#Formula_Details.compNameId#">#application.util.string.actionLinkFormat("#linkName# commodity values")#</a>
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
        <td CLASS="Title3"><SPAN>## Commodities: </SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#Formula_Details.Number_Of_Comms#</SPAN>
        </td>
    </tr>
    <tr width="400">
        <td CLASS="Title3"><SPAN>Schedule:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#sSchedule#</SPAN>
        </td>
    </tr>

    <tr width="400">
        <td CLASS="Title3"><SPAN>Component Name:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#Formula_Details.CompName#</SPAN>
        </td>
    </tr>

    <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
	    <tr width="400">
	        <td CLASS="Title3"><SPAN>Type:</SPAN>
	        </td>
	        <td><SPAN CLASS="fieldText">&nbsp;#Formula_Details.Formula_Type_Description#</SPAN>
	        </td>
	    </tr>
	</cfif>
	<!---  <tr width="400">
        <td CLASS="Title3"><SPAN>Price Date:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;#DateFormat(Formula_Details.Price_DAte,"short" )#</SPAN>
        </td>
    </tr> --->

    <tr width="400">
        <td CLASS="Title3"><SPAN>Gross Weight:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;<CFIF EDIT_RULE><INPUT Type="TEXT" ID="Gross_Weight" Name="Gross_Weight" value="#Formula_Details_Commodities.Gross_Weight#">
        	<CFELSE>#numberFormat(Formula_Details_Commodities.Gross_Weight,'999,999.9999')#</CFIF></SPAN>
        </td>
    </tr>

    <tr width="400">
        <td CLASS="Title3"><SPAN>Net Weight:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;<CFIF EDIT_RULE><INPUT Type="TEXT" ID="Net_Weight" Name="Net_Weight" value="#Formula_Details_Commodities.Net_Weight#">
        	<CFELSE>#numberFormat(Formula_Details_Commodities.Net_Weight,'999,999.9999')#</CFIF></SPAN>
        </td>
    </tr>
    <tr width="400">
        <td CLASS="Title3"><SPAN>Current FOB Price:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;$#numberFormat(Formula_Details.Market_Price_Rate_Orig,'99.99')#</SPAN>
        </td>
    </tr>
    <tr width="400">
        <td CLASS="Title3"><SPAN>New FOB Price:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;$#numberFormat(Formula_Details.Fixed_Price_Value,'99.99')#</SPAN>
        </td>
    </tr>

     <tr width="400">
        <td CLASS="Title3"><SPAN>$ Change:</SPAN>
        </td>
        <td><SPAN CLASS="fieldText">&nbsp;$#numberFormat(Formula_Details.Formula_Price,'99.9999')#</SPAN>
        </td>
    </tr>
    <CFIF ISNUMERIC(Formula_Details.Fixed_Price_Value) AND ISNUMERIC(Formula_Details.Market_Price_Rate_Orig) AND Formula_Details.Market_Price_Rate_Orig NEQ '0'>
	    <tr width="400">
	        <td CLASS="Title3"><SPAN>% Change:</SPAN>
	        </td>
	        <td><SPAN CLASS="fieldText">&nbsp;#numberFormat((Formula_Details.Fixed_Price_Value - Formula_Details.Market_Price_Rate_Orig)/ Formula_Details.Market_Price_Rate_Orig * 100,'99.9999')# %</SPAN>
	        </td>
	    </tr>
	</CFIF>
</table>
</CFOUTPUT>

<cfset SumWeightedPrice = 0>
<cfif ISNUMERIC(Formula_Details_Commodities.Start_Price)>
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
		<table  border="0" cellpadding="2" cellspacing="0" CLASS="Maintable">
		 	  <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
			  	<tr>
			    	<td CLASS="Title2" nowrap="nowrap"><b>Formula Type:</b>&nbsp;&nbsp;</td>
			        <td CLASS="Title6" width="150"><b>#Formula_Details_Commodities.Formula_Type_Description#</b> </td>
			        <td width="450">&nbsp; </td>
			    </tr>
			</cfif>

			<tr bgcolor="C6FFC6">
		        <td CLASS="Title3"  nowrap="nowrap">Price Date:&nbsp;&nbsp;</td>
	        	<td CLASS="Title7">#DateFormat(Formula_Details_Commodities.Price_Date,"short" )#</td>
	        	 <td>&nbsp; </td>
		    </tr>

			<tr>
		        <td CLASS="Title3"  nowrap="nowrap">Energy Converter:&nbsp;&nbsp;</td>
	        	<td CLASS="Title7" ><CFIF FindNoCase('energy',Exchange_Detail_Name) NEQ 0 OR FindNoCase('power',Exchange_Detail_Name) NEQ 0>#numberFormat(weight,99.9999)#</CFIF></td>
	        	 <td>&nbsp; </td>
		    </tr>
		    <tr bgcolor="C6FFC6">
		        <td CLASS="Title3" nowrap="nowrap">Current Benchmark:&nbsp;&nbsp;</td>
		        <td CLASS="Title7"  >$#numberFormat(Formula_Details_Commodities.Start_Price,'999,999.9999')# </td>
		         <td>&nbsp; </td>
		     </tr>
		     <tr>
				<td CLASS="Title3"  nowrap="nowrap">New Benchmark:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" >$#numberFormat(Formula_Details_Commodities.Comm_End_Price,'999,999.9999')#</td>
		         <td>&nbsp; </td>
		    </tr>
		    <tr bgcolor="C6FFC6">
				<td CLASS="Title3"  nowrap="nowrap">% Benchmark Change:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" ><cfif Formula_Details_Commodities.Start_Price NEQ 0>#numberFormat(((Formula_Details_Commodities.Comm_End_Price - Formula_Details_Commodities.Start_Price)/Formula_Details_Commodities.Start_Price)*100,'999,999.9999')#<cfelse>#numberFormat(0,'999,999.9999')#</cfif>%</td>
		        <td>&nbsp; </td>
		    </tr>
		    <tr>
				<td CLASS="Title3"  nowrap="nowrap">$ Benchmark Change:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" >$#numberFormat(Formula_Details_Commodities.Comm_End_Price - Formula_Details_Commodities.Start_Price,'999,999.9999')#</td>
		        <td>&nbsp; </td>
		    </tr>

		     <!--- <tr bgcolor="C6FFC6">
				<td CLASS="Title3"  nowrap="nowrap">Current FOB Price:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" >$#numberFormat(Formula_Details_Commodities.Market_Price_Rate_Orig,'999,999.9999')#</td>
		         <td >&nbsp; </td>
		    </tr> --->
		   <!---   <tr>
				<td CLASS="Title3"  nowrap="nowrap">Gross Weight:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" >#numberFormat(Formula_Details_Commodities.Gross_Weight,'999,999.9999')#</td>
		        <td>&nbsp; </td>
		    </tr>
		    <tr bgcolor="C6FFC6">
				<td CLASS="Title3"  nowrap="nowrap">Net Weight:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" >#numberFormat(Formula_Details_Commodities.Net_Weight,'999,999.9999')#</td>
		         <td>&nbsp; </td>
		    </tr> --->
		    <tr bgcolor="C6FFC6">
				<td CLASS="Title3"  nowrap="nowrap" style="border-bottom: 0;">Total $:&nbsp;&nbsp;</td>
		        <td CLASS="Title7" style="border-bottom: 0;">$#numberFormat(Formula_Details_Commodities.Final_Price,'999,999.9999')#</td>
		         <td class="empty" style="border-bottom: 0;">&nbsp; </td>
		    </tr>
		<!---     <tr>
				<td CLASS="Title3"  nowrap="nowrap">Final Price:&nbsp;&nbsp;</td>
		        <td CLASS="Title7"  width="25" >$#numberFormat(Formula_Details_Commodities.Final_Price,'999,999.9999')#</td>
		        <td CLASS="Title7"  width="260">&nbsp; </td>
		    </tr> --->
		  
		</table>
		</CFOUTPUT>
		</FieldSet>
		<br>
	</CFLOOP>
</CFIF>
<script>
	$("#Net_Weight").change(function(){
	    saveWeight(); //$( this ).val()
	});

	$("#Gross_Weight").change(function(){
	    saveWeight(); //$( this ).val()
	});

	function saveWeight(){
		var netWeight = $('#Net_Weight').val();
		var grossWeight = $('#Gross_Weight').val();
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#URL.Program_Id#</cfoutput>,
										netWeight: netWeight,
										grossWeight: grossWeight,
										contractProductsId: <cfoutput>#Formula_Details.Contract_products_Id#</cfoutput>,
										method: 'saveWeight' }
							//,dataType: "json"
							,success: function (data) {			
								if(data == 0){
									console.log('ZERO');
								}
								else if(netWeight == 0){
									$('#Net_Weight').val(data);
								}
								else if(grossWeight == 0){
									$('#Gross_Weight').val(data);
								}
				            }
				            ,error: function (data) {
				            	// console.log(data);
				                alert('An error occurred (createFromSaved).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/RfpManager.cfc"
				});
		}

</script>
</body>
</html>
