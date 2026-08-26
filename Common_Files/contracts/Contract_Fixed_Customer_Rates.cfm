<style type="text/css">
td.locked_top,th.locked_top{
		background-color:#ffce84;
     /* CSS expressions are not a part of IE 10. Comment the code below. Instead use the "keepHeaderFixed" function. */
    /*top: expression(document.getElementById('table_container').scrollTop);*/
    position: relative;
    z-index: 1;
  }

  #table_container {
     height: 65%;
     overflow: scroll;
	overflow-x: hidden;
  }
</style>

<script>
function keepHeaderFixed(topPosition,leftPosition){
	/* CODE FOR VERTICAL SCROLLING */
	
	/* Find the element which is a "<td>" */
	var cellObject = document.getElementsByTagName("td");
	   
	   /*Loop through the "<td>" object. Look for specific "id" (below), then move that cell from the top based on scroll position.
	   The position of the "<td>" will match the scroll position.
	   */
	   for(i=0;i<cellObject.length;i++)
	   {
		if (cellObject[i].getAttribute('id') == 'header') {
			cellObject[i].style.top = topPosition;
		}
	   }
}
</script>

<cfparam name="UOM_Type" default="">
<!--- Handle URL and Form Requests --->
<cfif StructIsEmpty(URL)>
	<cfset URL = structAppend(URL,Form) />
</cfif>
<cfset variables = structAppend(variables,URL) />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif UOM_Type eq "">
	<cfif appSettings.getMarginDisplaydefault() EQ 1>
		<cfset UOM_Type  = 1>
	<cfelse>
		<cfset UOM_Type  = 2>
	</cfif>
</cfif>

<cfquery name="getCust" datasource="#application.dataSource#" >
	SELECT Ship_To,
	   Name
	FROM BSA_FoodService_Customers BFC
	WHERE BFC.BSA_Foodservice_Customers_ID = '#variables.Distributor_ID#'
</cfquery>

<cfscript>
	objProgram = CreateObject("component", "components.programs.Program");
	objProdRateManager	= CreateObject("component","mvc.Models.Program.Component.ProductRateManager");
	objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
	
	qProgramInfo = objProgram.getProgramInfo(programId = ProgramID);
	qryFixedComp 		= objProdRateManager.getProductRate(ProgramID,1);
	qGetDistributors = objProgramTemplateManager.getDistributors(ProgramID, 0, 0,0);
</cfscript>
<!--- <cfdump var ="#qGetDistributors#" /> --->
<form name="frmCustRates" id="frmCustRates" action="Contract_Fixed_Customer_Rates.cfm" method="post"/>
<table border="0">
	<cfoutput>
	<tr>
		<td><b>Program ##:</b>&nbsp;#qProgramInfo.Contract_Number#</td>
	</tr>
	<tr>
		<td><b>Title:</b>&nbsp;#qProgramInfo.Contract_Title#</td>
	</tr>
	<tr>
		<td><b>Span:</b>&nbsp;#DateFormat(qProgramInfo.Contract_Start_Date,"MM/DD/YYYY")# - #DateFormat(qProgramInfo.Contract_End_Date,"MM/DD/YYYY")#</td>
	</tr>
	</cfoutput>
	<tr>
		 <td><b>Distributor: <select id="selCustomer" onchange="showCustomerRates(this.value)">
		 						<cfoutput query="qGetDistributors">
								 	<cfset selected = '' />
									 <cfif qGetDistributors.bsa_foodservice_Customers_Id EQ variables.Distributor_ID><cfset selected = 'selected' /></cfif>
							        <option value="#replace(qGetDistributors.bsa_foodservice_Customers_Id,'-','_')#" #selected#>#qGetDistributors.Name# (#qGetDistributors.Shr_Ship_To#)</option>
							  </cfoutput>
							</select>
							<cfoutput><input type="hidden" name="ProgramID" id="ProgramID" value="#ProgramID#"/></cfoutput>
							<input type="hidden" name="Distributor_ID" id="Distributor_ID"/>

	</tr>
</table>
</form>
<p>
<p>
<p>
<p>

<script language="javascript">
	function showCustomerRates(c){
		var custId = c.replace('_','-');
		frmCustRates.Distributor_ID.value = custId;
		//alert(frmCustRates.Distributor_ID.value);
		frmCustRates.submit();
		
	}
</script>

<cfset compName = "" />
<div id="table_container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">
<table border="0" cellspacing="0" width="100%" class="MainTable">
	<tr BGCOLOR="#FFCE84">
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="20%" class="locked_top"><b>ITEM</b></td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="32%" class="locked_top"><b>DESCRIPTION</b></td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top"><b>CONTRACT</b></td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top">
			<b><cfoutput>#UCASE(application.returned_customer_setting.distributor_label_singular)#</cfoutput></b>
		</td>

	</tr>

		<tr>
			<td style="border-bottom:0px;border-top:0px;">&nbsp;</td>
		</tr>

		<!---<tr>
			<td ID="header" style="border-bottom:0px;border-top:0px;">
				<u><b><cfoutput>#qryFixedComp.Name#</cfoutput></b></u>
			</td>
		</tr>
		<tr>
			<td style="border-bottom:0px;border-top:0px;">&nbsp;</td>
		</tr>--->
	<!---<cfoutput query="qryFixedComp" >--->
		<cfloop index = "idx" from = "1" to = #qryFixedComp.recordCount#>
			<cfoutput>
				<cfif qryFixedComp.fixedType[idx]EQ 3>
				<cfif qryFixedComp.Name[idx] NEQ compName >
					<cfset compName = qryFixedComp.Name[idx]/>
					<tr>
						<td ID="header" style="border-bottom:0px;border-top:0px;">
							<u><b>#qryFixedComp.Name[idx]#</b></u>
						</td>
					</tr>
					<tr>
						<td style="border-bottom:0px;border-top:0px;">&nbsp;</td>
					</tr>
				</cfif>
				<cfset sRateCust = 'RateCust_' & getCust.Ship_To />
				<cfset itemNumber = qryFixedComp.ItemNumber[idx]/>
				<cfif itemNumber EQ ''>
					<cfset itemNumber = 'Group'/>
				</cfif>
				<tr>
					<td width="20%">&nbsp;#itemNumber#</td>
					<td width="32%">#qryFixedComp.ItemDescription[idx]#</td>
					<td width="7%">&nbsp;#qryFixedComp.Rate[idx]#&nbsp;#qryFixedComp.ABBREVIATION[idx]#</td>
					<td width="7%">&nbsp;#qryFixedComp[sRateCust][idx]#&nbsp;#qryFixedComp.ABBREVIATION[idx]#</td>
				</tr>
				</cfif>
			</cfoutput>
		</cfloop>

</table>
</div>

<p>

<div align="center">
			<CF_smallLink 
			title = "close window" 
			url = "##"
			parameters = "onClick=""javascript: window.close();return false;"""
		>
</div>