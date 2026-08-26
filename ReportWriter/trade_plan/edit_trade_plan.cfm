<!---
	Name:
		edit_trade_plan.cfm
	Created By:
		Tim Ford 04/10/2003 
	Description:
		This file is used for creating and editing a trade plan
--->
<html> 
<head>
<meta http-equiv="Content-Language" content="en-us">
<title>Edit <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Plan</title>
<script>

	function validate() 
	{
		//get all the form field values
		var title = document.createTradePlan.reportTitle.value;
		var dist = document.createTradePlan.Distributor_List.value;
		var prod = document.createTradePlan.Product_List.value;
		var note = document.createTradePlan.notes.value;
		if (!checkString(title))
		{
			alert("Please provide a report title");
			return false;
		}
		
		if (!checkString(dist))
		{
			alert("Please select a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>");
			return false;
		}
		
		if (!checkString(prod))
		{
			alert("Please select products");
			return false;
		}
		
		if (!checkString(note))
		{
			alert("Please provide a note");
			return false;
		}
		
		document.createTradePlan.action.value = "calculate";
		return true;
		
	}

	function checkString(value)
	{
		isEmpty = true;
		if(trim(value) == "")
			isEmpty = false;
		return isEmpty;
	}
	function trim(strText) 
	{ 
    	// this will get rid of leading spaces 
    	while (strText.substring(0,1) == ' ') 
        	strText = strText.substring(1, strText.length);

    	// this will get rid of trailing spaces 
    	while (strText.substring(strText.length-1,strText.length) == ' ')
        	strText = strText.substring(0, strText.length-1);
		return strText;
	}

	function showDistributorSearchWindow() 
	{
		NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=createTradePlan", "distributorwindow", 800, 600, "yes", "yes");
	}
	
	function showProductSearchWindow() 
	{
		NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=createTradePlan", "productwindow", 800, 600, "yes", "yes");
	}
</script>
</head>
 
<body LEFTMARGIN="0" TOPMARGIN="0">
<cfoutput>

<!---Queries--->
<cfquery name="qGetTradePlan" datasource="#application.datasource#">
	SELECT 	tp.Trade_Plan_ID,
			tp.Trade_Plan_Title,
			tp.Created_Date,
			tp.Distributor_ID,
			tp.notes,
			u.name_first,
			u.name_last
	FROM	Trade_Plan tp,
			_users u
	WHERE	tp.Created_By = u.user_id
	AND		tp.Trade_Plan_ID = '#Trade_Plan_ID#'
</cfquery>

<!---Set default values--->
<cfparam name="Product_List" default="" />
<cfparam name="ExistingProductList" default="" />
<cfparam name="Ship_To" default="" />
<cfparam name="Distributor_List" default="" />
<cfparam name="reportTitle" default="" />
<cfparam name="notes" default="" />
<cfloop query="qGetTradePlan">
	<cfset Distributor_List = ListAppend(Distributor_List, Distributor_ID) />
</cfloop>
<cfif Len(Distributor_List)>
	<cfset useLakebaseForqGetDist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForqGetDist>
	<cftry>
		<cfset qGetDist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Distributor_List#",
				"deleted" = "eq.0",
				"active_code" = "eq.A"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDist>
<cfquery name="qGetDist" datasource="#application.datasource#">
		SELECT 	*
		FROM 	BSA_Foodservice_Customers
		WHERE 	BSA_Foodservice_Customers_ID = '#Distributor_List#' 
		AND 	deleted = 0
		AND		active_code = 'A'
	</cfquery>
</cfif>
	
	<cfset Ship_To = #qGetDist.Ship_To# />
	
</cfif>

<!---If we have an product/item list then let's get the data from the database--->
<cfif Len(Product_List)>
	<cfquery name="qGetItems" datasource="#application.datasource#">
		SELECT 	BSA_Foodservice_Items_Master.Description
		FROM	BSA_Foodservice_Items_Master
		WHERE 	BSA_Foodservice_Items_Master.Deleted = 0
		AND		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID in (#replace(listqualify(Product_List, "'"), '"', "'")#)
		AND		active_code = 'A'
	</cfquery>
</cfif>

<form name="createTradePlan" method="post" onSubmit="return validate();">
<p>&nbsp;</p>
<div align="center">
  <center>
  <table border="0" cellpadding="0" cellspacing="10" style="border-collapse: collapse" bordercolor="111111" width="75%" id="AutoNumber1">
    <tr>
      <td align="right" nowrap valign="top">&nbsp;</td>
      <td bgcolor="000080" rowspan="95" valign="top">&nbsp;</td>
      <td width="100%" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">Report Title</td>
      <td width="100%" valign="top"><input type="text" name="reportTitle" size="61" value="#qGetTradePlan.Trade_Plan_Title#"></td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">Date</td>
      <td width="100%" valign="top">#dateFormat(qGetTradePlan.Created_Date, "mm/dd/yyyy")#</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">Created by</td>
      <td width="100%" valign="top">#qGetTradePlan.name_first# #qGetTradePlan.name_last#</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">#application.returned_customer_setting.distributor_label_singular#<br>
      <b><font color="FF0000">[</font> <a href="javascript: showDistributorSearchWindow();">get distributor</a>
      <font color="FF0000">]</font></b></td>
      <td width="100%" valign="top"><cfif Len(Distributor_List)>#qGetDist.Name#</cfif></td>
    </tr>
    <tr>
    	<td align="right" nowrap valign="top">Products<br>
      	<b><font color="FF0000">[</font> <a href="javascript: showProductSearchWindow();">get prodcuts</a>
      	<font color="FF0000">]</font></b></td>
      	<td width="100%" valign="top">
	  		<table>
				<cfif Len(Product_List)>
					<cfloop query="qGetItems">
						<tr>
							<td>#Description#</td>
						</tr>
					</cfloop>
				</cfif>
			</table>
		</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">&nbsp;</td>
      <td width="100%" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">Notes</td>
      <td width="100%" valign="top"><textarea rows="5" name="notes" cols="47">#qGetTradePlan.notes#</textarea></td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">&nbsp;</td>
      <td width="100%" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">&nbsp;</td>
      <td width="100%" valign="top">
      <input type="submit" value="Next..." name="Next"></td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">&nbsp;</td>
      <td width="100%" valign="top">&nbsp;</td>
    </tr>
  </table>
  </center>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>

<INPUT NAME="action" TYPE="Hidden" VALUE="edit" />
<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="" />
<INPUT NAME="Ship_To" TYPE="Hidden" VALUE="#Ship_To#" />
<INPUT NAME="Distributor_List" TYPE="Hidden" VALUE="#Distributor_List#" />
<INPUT NAME="Product_List" TYPE="Hidden" VALUE="#Product_List#" />
</form>

</cfoutput>
</body>
 
</html>