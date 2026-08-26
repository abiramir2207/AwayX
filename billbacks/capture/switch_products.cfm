<!---
Name: 			switch_products.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	11/09/2009
Created By:		Tim Ford    
Description:	This file is responsible for switching products within a Billback while maintaining the rate and volume data.  
--->
<cfparam name="PAGE_TITLE" default="Billback Switch Products">
<cfparam name="url.BBID" default="0" />
<cfset billbackObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(url.BBID) >

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
	<script>
	
		function dyniframesize()
		{
			var iframeids=["contentIFrame"];
			var iframehide="yes";
			var dyniframe=new Array()
			for (i=0; i<iframeids.length; i++)
			{
				if (document.getElementById){ //begin resizing iframe procedure
					dyniframe[dyniframe.length] = document.getElementById(iframeids[i]);
					if (dyniframe[i] && !window.opera)
					{
						dyniframe[i].style.display="block"
						if (dyniframe[i].contentDocument && dyniframe[i].contentDocument.body.offsetHeight)
						{ //ns6 syntax
							dyniframe[i].height = dyniframe[i].contentDocument.body.offsetHeight+FFextraHeight;
						}
						else if (dyniframe[i].Document && dyniframe[i].Document.body.scrollHeight)
						{ //ie5+ syntax
							dyniframe[i].height = dyniframe[i].Document.body.scrollHeight;
						}
					}
				}
	
				//reveal iframe for lower end browsers? (see var above):
				if ((document.all || document.getElementById) && iframehide=="no")
				{
					var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
					tempobj.style.display="block"
				}
			}
		}
		
	</script>
	
	<style>
		TABLE.Maintable TD
		{
			border-bottom:solid #93BEE2 1px; 
			font-size : 10px;
		}
		#header 
		{
			font-size: 12px; 
			font-weight: bold;
		}
		#cellLabel
		{
			font-size: 10px; 
			font-weight: bold; 
			vertical-align : top;
		}
		#dataStyle
		{
			font-size: 10px;
		}
		TD
		{
			font-family:Arial;
			font-size:10px;
		}	
		HR
		{
			color: Navy;
		}
		.LeftRightBorder
		{
			border-left:solid #93BEE2 1px;
			border-right:solid #93BEE2 1px;
			border-top:solid #93BEE2 1px;
			font-size : 10px;
		}
		TABLE.LeftRightBorder TD	
		{
			border-bottom:solid #93BEE2 1px; font-size : 10px;
		}	
		.ThreeBorders
		{
			border-left:solid ffe4b5 1px; 
			border-right:solid ffe4b5 1px; 
			border-bottom:solid ffe4b5 1px;
			font-size: 10px;
			font-family: arial;
		}
		.RegularText
		{
			font-size: 10px;
			font-family: arial;
		}
		.underLineRow td
		{
			border-bottom:1px solid #000000;
			border-top:none;
			border-left:none;
			border-right:none;
		}
			
		.programTD TD
		{
			background-color:F0E68C;
			border-top: 2px solid #808080;
			border-bottom: 2px solid #808080;
			font-size:12px;
			font-weight:bold;
		}
	</style>
</head>
<body>

<cfset qGetBillbackInfo = billbackObj.getBillbackInfo(url.BBID) />
<cfset qGetDistList = billbackObj.getMultiDistList(url.BBID) />
<cfset qGetProgramProducts = billbackObj.Get_Program_Products(url.BBID, qGetDistList.Distributor_ID, 0, 0) />

<cfparam name="form.Product_List" default="#valueList(qGetProgramProducts.BSA_Foodservice_Items_Master_ID)#" />

<form action="switch_products_action.cfm" method="post" name="switchProductForm">
<TABLE CELLPADDING="3" id="programsproducts" CELLSPACING="0" BORDER="0" WIDTH="98%" ALIGN="center">
	<tr>
		<td colspan="100%" class="programTD">
			<B><FONT SIZE="+1" COLOR="Navy">Payable Number: <cfoutput>#qGetBillbackInfo.BB_Code#</cfoutput></FONT></B>
			<HR COLOR="Navy">
		</td>
	</tr>
	<tr bgcolor="FFCE84">
		<td id="header" style="font-size:9px">
			Product
		</td>
		<td id="header" style="font-size:9px">
			Rate
		</td>
		<td id="header" style="font-size:9px">
			Volume
		</td>
		<td id="header" style="font-size:9px">
			UOM
		</td>
		<td>&nbsp;</td>
	</tr>
<CFOUTPUT QUERY="qGetProgramProducts" GROUP="Billback_Program_ID">
	<tr bgcolor="FFCE84" class="programTD">
		<td COLSPAN="100%" bgcolor="##F0E68C" id="header" style="font-size:9px">
			<font color="660033">
			#qGetProgramProducts.Program_Number#
			#qGetProgramProducts.Program_Title# -- #dateformat(qGetProgramProducts.Start_Date, 'mm/dd/yyyy')# to #dateformat(qGetProgramProducts.End_Date, 'mm/dd/yyyy')#
			</font>
		</td>
	</tr>
	
	<cfif len(trim(dist_id))>
	<cfoutput group="dist_id">
		<tr bgcolor="8B0000">
			<td nowrap valign="top" style="font-size:9px; color:white;" colspan="100%">
				<strong>#qGetProgramProducts.ship_to# :: #qGetProgramProducts.name#</strong>
			</td>
		</tr>

        <cfset productcount = 0>
        <cfset tempProductList = "" />
        <cfoutput group="Billback_Product_ID">
    
            <cfif not listFindNoCase(tempProductList, BSA_Foodservice_Items_Master_ID)>
                <cfset tempProductList = listAppend(tempProductList, BSA_Foodservice_Items_Master_ID) /> 
            </cfif>
            <cfset productcount = productcount + 1>
            <cfset urlString = "switch_products_select.cfm?Formname=switchProductForm" />
            <cfset urlString = urlString & "&ExistingProductList_Field_Name=ExistingProductList_#replace(qGetProgramProducts.Billback_Program_ID, "-", "_", "ALL")#" />
            <cfset urlString = urlString & "&PID=#qGetProgramProducts.Program_ID#" />
            <cfset urlString = urlString & "&BBID=#url.BBID#" />
            <cfset urlString = urlString & "&PayeeID=#qGetProgramProducts.dist_id#" />
            <cfset urlString = urlString & "&Billback_Program_ID=#qGetProgramProducts.Billback_Program_ID#" />
            <cfset urlString = urlString & "&Product_ID=#qGetProgramProducts.BSA_Foodservice_Items_Master_ID#" />
            <cfset urlString = urlString & "&Billback_Product_ID=#qGetProgramProducts.Billback_Product_ID#" />
            
            <cfif Evaluate(productcount mod 2) eq 0>
                <cfset tmpBgColor = "FFFFFF" />
            <cfelse>
                <cfset tmpBgColor = "ccffcc" />
            </cfif>
            <tr bgcolor="#tmpBgColor#">
                <td align="left" valign="top" style="font-size:10px;font-face:Ariel;">
                    #qGetProgramProducts.Item_Number# #qGetProgramProducts.Description#
                </td>
                <td align="left" valign="top" style="font-size:10px;font-face:Ariel;">
                    #qGetProgramProducts.Billback_Rate#
                </td>
                <td align="left" valign="top" style="font-size:10px;font-face:Ariel;">
                    #qGetProgramProducts.BB_Product_Quantity#
                </td>
                <td align="left" valign="top" style="font-size:10px;font-face:Ariel;">
                    #qGetProgramProducts.Unit_Of_Measure_Desc#
                </td>
                <td>
                    <CF_smallLink 
                        title = "switch products" 
                        url = "##"
                        parameters = "onClick=""javascript: NewWindow('#urlString#', 'productwindow', 800, 600, 'yes', 'yes'); return false;"""
                >
                </td>
            </tr>
            
        </cfoutput>
        <INPUT TYPE="hidden" NAME="ExistingProductList_#replace(qGetProgramProducts.Billback_Program_ID, "-", "_", "ALL")#" VALUE="#tempProductList#">
        <cfset productcount = 0>

    </cfoutput>
	</cfif>

</CFOUTPUT>
</TABLE>
</form>
<script>
		try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>
</html>

