<CFSET INC_Deviation_Constants = true>
<CFSET DEVIATION_CONSTANTS_Trade_Shelter = "Distributor Trade/Shelter">
<!--- Dev Note: 10048- Milan; Added "Operator Direct or HQ Programs" for volume validation --->
<CFSET DEVIATION_CONSTANTS_Operator_Deviated = "Operator-Deviated Pricing,Bid Request,Operator Direct or HQ Programs">

<CFSET DEVIATION_CONSTANTS_Trade_Eligibility_Triggers="Invoice Date, Ship Date">
<CFSET DEVIATION_VALID_ROW_INDICATOR_COLOR="FFFF00">
<CFSET DEVIATION_INVALID_ROW_INDICATOR_COLOR="E9967A">
<CFSET DEVIATION_QUANTITY_UOM="#request.app_general_functions.getUomDesc(1,0)#,#request.app_general_functions.getUomDesc(2,0)#,%,$">

<CFSET DEVIATION_VOLUME_FORMAT = "(__.___)">
<CFSET DEVIATION_PERCENT_FORMAT = "(__.____)">
<CFSET DEVIATION_RATE_FORMAT = "(_$_.____)">
<cfif application.util.query.get_Setting('Custom_RFP_Process',0) EQ 1>
	<CFSET DEVIATION_RATE_FORMAT = "(_$_.__)">
</cfif>

<CFSET DEVIATION_MAIN_PAGE_PERCENT_FORMAT = "(__.__)">

<CFSAVECONTENT VARIABLE="DEVIATION_SHOW_PNF">
&nbsp;<FONT COLOR="Red"><B>(PNF)</B></FONT>
</CFSAVECONTENT>

<CFSAVECONTENT VARIABLE="DEVIATION_SHOW_NA">
&nbsp;<FONT COLOR="Red"><B>NA</B></FONT>
</CFSAVECONTENT>


<CFSET DEVIATION_ROUND_TO_DECIMAL_PLACES_TO_CHECK_VALIDATION = 2>
<CFSET DEVIATION_OVERLAPPED_BB_STATUS = 3>

<CFSET Discount_Type_List="Fixed Price, #Application.RebateLabel#, #Application.LumpsumLabel#, Growth, Formula Price,6,7,8,9,10,Bid Request">

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

<CFPARAM NAME="ADDSCRIPT" 	DEFAULT="No">
<CFPARAM NAME="USEIMGGRAPH" 	DEFAULT=false>

<CFSCRIPT>
	function RoundToDecimalPlaces(val, decLen)
	{
		mult_div_value = 1;
		for(i = 1;i LTE decLen;i=i+1)
		{
			mult_div_value = mult_div_value * 10;
		}
		val1 = val * mult_div_value;
		val1 = Round(val1);
		val1 = val1/mult_div_value;
		return val1;
	}
	function getStRevisionProperties(D_First_Date, D_Last_Date, Rate_ID_FieldValue, this_Rate, programId)
	{
		stRevisionProperties = StructNew();
		stRevisionProperties.firstDate = D_First_Date;
		stRevisionProperties.lastDate = D_Last_Date;
		stRevisionProperties.idFieldValue = Rate_ID_FieldValue;
		stRevisionProperties.thisRate = this_Rate;
		stRevisionProperties.programId = programId;
		return stRevisionProperties;
	}
</CFSCRIPT>

<!------
<CFSET DETAIL_PAGE_EXPECTED_RATE="Deviation_Product_Rate.cfm,Deviation_Product_Rate.cfm, ,Deviation_Product_Growth_Rate.cfm,Deviation_Product_Rate.cfm">
<CFSET DETAIL_PAGE_EXPECTED_VOLUME="Deviation_Product_Volume.cfm,Deviation_Product_Volume.cfm, ,Deviation_Product_Growth_Volume.cfm,Deviation_Product_Volume.cfm">
----->
<CFSET DETAIL_PAGE_EXPECTED_RATE="Deviation_Product_Rate.cfm,Deviation_Product_Rate.cfm, ,Deviation_Growth_New.cfm,Deviation_Product_Rate.cfm">
<CFSET DETAIL_PAGE_EXPECTED_VOLUME="Deviation_Product_Volume.cfm,Deviation_Product_Volume.cfm, ,Deviation_Growth_New.cfm,Deviation_Product_Volume.cfm">


<STYLE>
TR.MaintableTHEAD TD 
{
	font-size : 11px;
	border-bottom:solid 93BEE2 0px;
	font-weight : bold;	
}

</STYLE>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset DEVIATION_LABEL = appSettings.getDeviationLabel() />
<cfset DEVIATION_LABEL_SMALL = LCase(DEVIATION_LABEL) /> 