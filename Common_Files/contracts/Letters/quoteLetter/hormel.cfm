<cfoutput>
<cfif URL.Email neq "1">
	<div class="floatr">
	<a href="##" onClick="window.location='emailQuoteLetter.cfm?Contract_Main_ID=#url.Contract_Main_ID#&Contract_Number=#vars.qProgram.Contract_Number#'" class="nonprintable">#LCase(ActionText("email"))#</a>
	<a href="##" onClick="window.print()" class="nonprintable" style="margin-left:15px">#LCase(ActionText("print"))#</a>
	</div>
</cfif>
<cfset QuoteLetter()>
</cfoutput>
<cfreturn>


<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="QuoteLetter" returntype="string" output="true">
<style type="text/css">
##company_name {
  float:right;
}
##opa_body {
  margin:0px 5px 0;
}
##opa_head img {
  display:block;
  /*margin:auto;*/
  margin-bottom:10px;
}
.clear {
  clear:both;
}
.floatl {
	float:left;
}
.floatr {
	float:right;
}
.head {
  color:blue;
  font:bold 16px Arial, Helvetica, sans-serif;
}
.hr {
  margin:5px 0 5px 0;
  border: none;
  border-bottom:1px solid ##FFFFFF;
  border-top:1px solid ##dcdcdc;
  height:0;
}
.dollar {
  text-align:right !important;
}
.center {
  text-align:center !important;
}
.label {
  float:left;
  font:bold 12px Arial, Helvetica, sans-serif;
}
.label2 {
  font:bold 12px Arial, Helvetica, sans-serif;
  width:140px;
}
.opa_group {
  color:##000;
  margin:5px 0;
  font:bold 14px Arial, Helvetica, sans-serif;
}
.opa_note {
  color:##000;
  font:bold 12px Arial, Helvetica, sans-serif;
}
.right {
  text-align:right !important;
}
.small {
  font-size:10px;
  font-weight:normal;
  position:relative;
  top:-5px;
}
table.Design2 {
  border-top:1px solid ##666;
  border-left:1px solid ##666;
  margin-bottom:10px;
  width:99%;
}
table.Design2 td {
  border-right:1px solid ##666;
  border-bottom:1px solid ##666;
  padding:.4em .4em;
}
table.Design2 th {
  border-right:1px solid ##666;
  border-bottom:1px solid ##666;
  border-collapse: collapse;
  font-weight:400;
  padding:.4em .4em;
}
table.Design2 th.Corner {
  text-align:left;
}
table.Design2 thead th {
  background-color:##E5E5E5;
  color:##000;
  font:bold 12px Arial, Helvetica, sans-serif;
  text-align:left;
}
</style>

<cfoutput>
<!---Heading--->
<div id="opa_head">
 <!---need to specify the full URL so image would be shown up on email--->
 <img src="http://#cgi.server_name#/images/Logon_Blacksmith/hormel_logo.jpg" title="Company Logo" height=70>
 <span id="company_name" class="head"><br/>OPERATOR PRICING AGREEMENT</span>
 <span class="head floatl">Hormel Food Sales, LLC<br/>Foodservice Division</span>
 <hr class="clear hr"/>
</div>  <!--opa_head-->

<div id="opa_body">
<cfif vars.qOperators.recordCount gt 0>
 <table>
   <tr><td class="label2">Operator Name:</td><td>#vars.qOperators.Operator_Name#</td></tr>
   <cfloop query="vars.qOperators" startrow="2">
    <tr><td>&nbsp;</td> <td>#vars.qOperators.Operator_Name#</td></tr>
   </cfloop>
 </table>
 </table>
  <hr class="hr"/>
</cfif>
<div class="clear"></div>

<table style="margin-bottom:5px;">
<tr><td class="label2">Program ID:</td> <td>#vars.qProgram.Contract_Number#</td></tr>
<tr><td class="label2">Contract Name:</td> <td>#vars.qProgram.Contract_Title#</td></tr>
<tr><td class="label2">Agreement Start Date:</td> <td>#DateFormat(vars.qProgram.Effective_Start_Date,'medium')#</td></tr>
<tr><td class="label2">Agreement End Date:</td> <td>#DateFormat(vars.qProgram.Effective_End_Date,'medium')#</td></tr>
<tr><td class="label2">Created:</td> <td>#vars.qProgram.Creator# <span style="margin-left:10px;">#DateFormat(vars.qProgram.Contract_Created_Date,'medium')#</span></td></tr>
<tr><td class="label2">Owner:</td> <td>#vars.qProgram.RSP_Name#<cfif len(trim(vars.qProgram.RSP_Phone))><span style="margin-left:15px;">[#Replace(vars.qProgram.RSP_Phone,' ','-','all')#]</span></cfif></td></tr>
<tr><td class="label2">&nbsp;</td> <td>#vars.qProgram.RSP_Email#</td></tr>
</table>
<hr class="hr"/>

<cfif vars.qFixedPricedItems.recordCount gt 0>
  <p class="opa_group">Fixed Price Items</p>
  <table class="Design2" cellspacing="0" cellpadding="0">
  <thead>
    <tr>
      <th>Hormel SKU</th> <th>Description</th>
      <th class="right">Approved Price</th> <th class="center">LB or CS</th>
      <th class="center">Pricing Method</th> <th class="center">Payment Method</th>
    </tr>
  </thead>
  <tbody>
    <cfloop query="vars.qFixedPricedItems" >
      <tr>
        <td>#vars.qFixedPricedItems.Item#</td> <td>#vars.qFixedPricedItems.Description#</td>
        <td class="dollar">$#numberformat(vars.qFixedPricedItems.Fixed_Price_Value,"_.__")#</td> <td class="center">#lbcaseFormat(vars.qFixedPricedItems.Unit_Of_Measure_Desc)#</td>
        <td class="center">Fixed Price</td> <td>#vars.qFixedPricedItems.Payment_Type_Name#</td>
      </tr>
    </cfloop>
  </tbody>
  </table>
  <div class="small">Price quote is delivered to the authorized distributor(s) and does not include any additional freight charges for product picked up at a Distribution Center.</div>
</cfif>
</cfoutput>

<cfif vars.qFixedAllowances.recordCount gt 0>
  <p class="opa_group">Fixed Allowance Items</p>
  <table class="Design2" cellspacing="0" cellpadding="0">
  <thead>
    <tr>
      <th>Hormel SKU</th> <th>Description</th>
      <th class="right">Approved Allowance</th> <th class="center">LB or CS</th>
      <th class="center">Pricing Method</th> <th class="center">Payment Method</th>
    </tr>
  </thead>
  <tbody>
    <cfoutput query="vars.qFixedAllowances" group="Item">
      <tr>
      	<cfset vars.countForThisGroup = 0>
        <td>#vars.qFixedAllowances.Item#</td> <td>#vars.qFixedAllowances.Description#</td>
        <cfoutput>
      		<cfset vars.countForThisGroup = vars.countForThisGroup + 1>
        	<!--skip sku, description on items with the same item number-->
        	<cfif vars.countForThisGroup gt 1><tr><td>&nbsp;</td> <td>&nbsp;</td></cfif>
          <td class="dollar">$#numberformat(vars.qFixedAllowances.Rate,"_.__")#</td> <td class="center">#lbcaseFormat(vars.qFixedAllowances.Abbreviation)#</td>
          <td class="center">Allowance</td> <td>#vars.qRebateType.Payment_Type_Name#</td>
          </tr>
      	</cfoutput>
    </cfoutput>
  </tbody>
  </table>
</cfif>

<cfif vars.qFixedPricedItems.recordCount gt 0
   or vars.qFixedAllowances.recordCount gt 0>
  <hr class="hr"/>
</cfif>

<p class="opa_group">Approved Distributors <span class="opa_note">(Price quoted above is for Operator approved distributors listed below)</span></p>
<table id="opa_distributors" class="Design2" cellspacing="0" cellpadding="0">
<thead>
  <tr><th>Hormel Key Account</th> <th>Customer Number</th></tr>
</thead>
<tbody>
  <cfoutput query="vars.qDistributors" group="Name">
    <tr><td>#vars.qDistributors.Name#</td> 
        <td>
        	<cfquery name="vars.qShipToInvoice" Datasource="#application.datasource#">
        		SELECT *
        		  FROM SHIPTO_INVOICE_RELATION
        		 WHERE Ship_To = <cfqueryparam value="#vars.qDistributors.Shr_Ship_To#" cfsqltype="cf_sql_varchar">
					</cfquery>
        <cfoutput>#Replace(ValueList(vars.qShipToInvoice.ShipTo_Invoice_Relation), ',', ', ', 'all')#&nbsp;</cfoutput></td></tr>
  </cfoutput>
</tbody>
</table>
</div>  <!--opa_body-->
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="lbcaseFormat" returntype="string" output="false">
  <cfargument name="uom" type="string" required="true" />

	<cfif ( arguments.uom contains "lb" ) or ( arguments.uom contains "Pound" )>
		<cfreturn "Pound"> 
	<cfelseif ( arguments.uom contains "cs" ) or ( arguments.uom contains "case" )>
	  <cfreturn "Case">
	<cfelse>
		<cfreturn arguments.uom>
	</cfif>
	
</cffunction>

