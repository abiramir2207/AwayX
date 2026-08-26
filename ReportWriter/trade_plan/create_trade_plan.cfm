<!---
	Name:
		create_trade_plan.cfm
	Created By:
		Tim Ford 04/10/2003 
	Description:
		This file is used for creating and editing a trade plan
--->
<html> 
<head>
<meta http-equiv="Content-Language" content="en-us">
<title>Create Trade Plan</title>
<script>

	function validate() 
	{
		//get all the form field values
		var title = document.createTradePlan.tradePlanTitle.value;
		var dist = document.createTradePlan.Distributor_List.value;
		var prod = document.createTradePlan.Product_List.value;
		var note = document.createTradePlan.notes.value;
		var startDate = document.createTradePlan.start_date.value;
		var endDate = document.createTradePlan.end_date.value;
		
		if (!checkString(title))
		{
			alert("Please provide a report title");
			return false;
		}
		
		if (!checkString(dist))
		{
			alert("Please select a distributor");
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
		
		if (!checkString(startDate))
		{
			alert("Please provide a Start Date");
			return false;
		}
		
		if (!checkString(endDate))
		{
			alert("Please provide an End Date");
			return false;
		}
		
		fromDate = new Date(startDate);
		toDate = new Date(endDate);		
		
		if(toDate < fromDate)
		{
			alert("The To Date Must Be After The From Date");
			return false;
		}

		
		document.createTradePlan.action.value = "create_calculate";
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
	
	function showVolApplicator() 
	{	
		var formObj = document.all.createTradePlan;		

		if(formObj)
		{
			var priorAction = formObj.action.value;
			var oldtarget = formObj.target;
			formObj.target = "volumewindow";
			formObj.action.value = "volumeApp";
			
			NewWindow("", "volumewindow", 800, 600, "yes", "yes");
			formObj.submit();
			
			formObj.action.value = priorAction;
			formObj.target = oldtarget;
			
			
			/*
			//var oldAction = formObj.action;
			var oldtarget = formObj.target;
			//formObj.action = "volume_popup.cfm";
			alert(formObj.action);
			//var tmp = formObj.getAttribute("action");
			//alert(tmp.tagName);
			formObj.setAttribute("action", "volume_popup.cfm");
			formObj.target = "volumewindow";
			NewWindow("", "volumewindow", 800, 600, "yes", "yes");
			formObj.submit();
			//formObj.action = oldAction;
			formObj.target = oldtarget;*/
		}
	}
</script>

</head>
<body LEFTMARGIN="0" TOPMARGIN="0">
<cfoutput>
<!---Set default values--->
<cfparam name="Product_List" default="" />
<cfparam name="Ship_To" default="" />
<cfparam name="Distributor_List" default="" />
<cfparam name="tradePlanTitle" default="" />
<cfparam name="notes" default="" />
<cfparam name="form.start_date" default="" />
<cfparam name="form.end_date" default="" />

<!---Queries--->


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

<!--- <form name="volumePopUp" action="volume_popup.cfm" method="post" target="volPopUp">
</form> --->
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
      <td align="right" nowrap valign="top">Report Title:</td>
      <td width="100%" valign="top"><input type="text" name="tradePlanTitle" size="61" value="#tradePlanTitle#"></td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">#application.returned_customer_setting.distributor_label_singular#:<br>
      <b><font color="FF0000">[</font> <a href="javascript: showDistributorSearchWindow();">get #application.returned_customer_setting.distributor_label_singular#</a>
      <font color="FF0000">]</font></b></td>
      <td width="100%" valign="top"><br><cfif Len(Distributor_List)>#qGetDist.Name#<cfelse>get #application.returned_customer_setting.distributor_label_singular#...</cfif></td>
    </tr>
    <tr>
    	<td align="right" nowrap valign="top">Products:<br>
      	<b><font color="FF0000">[</font> <a href="javascript: showProductSearchWindow();">get products</a>
      	<font color="FF0000">]</font></b></td>
      	<td width="100%" valign="top">
	  		<table>
				<cfif Len(Product_List)>
					<cfloop query="qGetItems">
						<tr>
							<td>#Description#</td>
						</tr>
					</cfloop>
				<cfelse>
					<br>get products...
				</cfif>
			</table>
		</td>
    </tr>
	<tr>
		<td align="right" nowrap valign="top">Span:</td>
		<td>
			<table>
				<tr>
					<td>
						From:<br>
						<CF_EASYDATE FORMNAME="createTradePlan" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.start_date#">
					</td>
					<td>
						To:<br>
						<CF_EASYDATE FORMNAME="createTradePlan" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.end_date#">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">
			<b><font color="FF0000">[</font> <a href="javascript: showVolApplicator();">volume</a><font color="FF0000">]</font></b>
		</td>
	</tr>
    <tr>
      <td align="right" nowrap valign="top">&nbsp;</td>
      <td width="100%" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td align="right" nowrap valign="top">Notes:</td>
      <td width="100%" valign="top"><textarea rows="5" name="notes" cols="47">#notes#</textarea></td>
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
<input type="hidden" name="createdBy" value="#request.AccessStructure.user_id#">
<INPUT TYPE="Hidden" NAME="action" VALUE="create" />
<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="" />
<INPUT NAME="Ship_To" TYPE="Hidden" VALUE="#Ship_To#" />
<INPUT NAME="Distributor_List" TYPE="Hidden" VALUE="#Distributor_List#" />
<INPUT NAME="Product_List" TYPE="Hidden" VALUE="#Product_List#" />
</form>

</cfoutput>
</body>
 
</html>