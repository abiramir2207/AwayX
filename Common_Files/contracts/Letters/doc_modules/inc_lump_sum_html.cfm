<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_lump_sum_html.cfm
CREATED: 		11/1/2011 - Milan
EDITED:	

FUNCTIONALITY:
- This file is utilized to show the lumpsum details.
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<!--- If it is a "distributor" letter AND it is "One distributor per letter" AND Dist Product Codes (Customer Product Number)" is ON at the letter tab of the template --->
<cfset IncludeDistProdCode = 0>
<cfif thisTag.abbreviation eq "dis" AND thisTag.qGetLetterSettings.Distributor_Letter_Type eq 1 AND attributes.stPDFBodyInfo.bDistributorDistProductCodes>
  <cfset IncludeDistProdCode = 1>
</cfif>

<cfset IncludeGTIN = 0>
<!--- If it is an "operator" letter, check whether "GTIN" is ON at the letter tab of the template --->
<cfif (thisTag.abbreviation eq "opr" AND ThisTag.stPDFBodyInfo.bOperatorGTIN)
OR				
<!--- If it is a "distributor" letter, check whether "GTIN" is ON at the letter tab of the template --->
	(thisTag.abbreviation eq "dis" AND ThisTag.stPDFBodyInfo.bDistributorGTIN)>		
  <cfset IncludeGTIN = 1>
</cfif>

<!--- Check whether Line # exists even for a single product --->
<cfquery name="qCheckLineNumber" datasource="#application.datasource#">
	SELECT 	Line_Number
	FROM	##TMP_LumpSum_Details
	WHERE	Line_Number IS NOT NULL
</cfquery>

<cfset IncludeLine = 0>
<!--- If Line # exists for at least one product --->
<cfif qCheckLineNumber.recordcount GT 0>
	<!--- If it is an "operator" letter, check whether "Line #" is ON at the letter tab of the template --->
	<cfif (thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorLine)
	OR 
	<!--- If it is an "distributor" letter, check whether "Line #" is ON at the letter tab of the template --->
		  (thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorLine)>
	  <cfset IncludeLine = 1>
	</cfif>
</cfif>

<cfif IncludeLine eq 1>
	<cfset IDLength = 13>
	<cfset DescLength = 27>
	<cfset colspan1 = 5>
	<cfset colspan2 = 8>
<cfelse>	
	<cfset IDLength = 15>
	<cfset DescLength = 34>
	<cfset colspan1 = 3>
	<cfset colspan2 = 6>
</cfif>


 <cfset showLumpsum = 0>

<!--- If there is a lumpsum (products OR not) AND lumpsum discount is ON at the letter tab of the template 
for either distributor or operator, then showLumpsum = 1.
--->
 <cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount 
 AND (
	(thisTag.abbreviation eq "dis" AND thisTag.stPDFBodyInfo.bDisplayLumpSumDis)
	OR 
	(thisTag.abbreviation eq "opr" AND thisTag.stPDFBodyInfo.bDisplayLumpSumOpr)
     )>

     <cfset showLumpsum = 1>

</cfif>


<!--- If "lumpsum" is ON for letters --->
<cfif showLumpsum eq 1>

<cfoutput>
<table width="100%" cellspacing="0" cellpadding="0">
<!--- Add the Rebate Header --->

<!--- If an operator letter AND "Discount Type" template setting for operators on letters is set to "Display" --->
<cfif (thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorDiscountType)
      OR
<!--- If a distributor letter AND "Discount Type" template setting for distributors on letters is set to "Display" --->
      (thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorDiscountType)
>
  <tr>
  		<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" valign="middle" height="20"><b>#UCASE(Application.LumpSumLabel)#<b></td>
  </tr>
</cfif>
  <tr>
		<td colspan="100%" height="7"></td>
  </tr>
</table>
</cfoutput>

<!--- Loop through the lumpsum components. Group By "program_lump_sum_id" --->
<cfoutput query="thisTag.qProgramLumpSum" group="program_lump_sum_id">

<cfset itemCounter = 0>
	
<cfquery name="getItemCountForComponent" datasource="#application.datasource#">
	SELECT 	Count(Program_Lump_Sum_ID) As ItemCount
	FROM	##TMP_LumpSum_Details
	WHERE Program_Lump_Sum_ID = '#thisTag.qProgramLumpSum.program_lump_sum_id#'
	AND Item IS NOT NULL
</cfquery>

<table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tr>
  	<td width="1%" height="20"></td>
  	<cfif getItemCountForComponent.ItemCount GT 0>
	 <td class="darkGrayBG header_text whiteText" valign="middle" height="20" align="left" colspan="1">
  	<cfelse>
	 <td class="darkGrayBG header_text whiteText" valign="middle" height="20" align="left" width="40%">
	 </cfif>
	<!--- If it is a "distributor" letter, check whether "Pays To" is ON at the letter tab of the template --->
	<cfif (	
		(thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorPayableTo)
	<!--- If it is an "operator" letter, check whether "Pays To" is ON at the letter tab of the template --->
		OR
		(thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorPayableTo)
	      )>
	        <b>Pay to:<b>
		<cfif thisTag.qProgramLumpSum.component_paid_to EQ 1>
		 #application.returned_customer_setting.distributor_label_singular#

		<cfelseif thisTag.qProgramLumpSum.component_paid_to EQ 2>
		#application.returned_customer_setting.operator_label_singular#
		</cfif>
	<cfelse>
	&nbsp;
	</cfif>
	</td>
	<cfif getItemCountForComponent.ItemCount GT 0>
	  <td class="darkGrayBG header_text whiteText" valign="middle" height="20" align="left" colspan="#colspan1#">
	<cfelse>
	  <td class="darkGrayBG header_text whiteText" valign="middle" height="20" align="left" width="40%">
	</cfif>
	<!--- If it is an "operator" letter, check whether "Component Name" is ON at the letter tab of the template --->
	<cfif (
		(thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorComponentName)
	<!--- If it is a "distributor" letter, check whether "Component Name" is ON at the letter tab of the template --->
	      OR
		(thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorComponentName)
	      )
	      >
	<b>Component:&nbsp;#thisTag.qProgramLumpSum.program_lump_sum_name#<b>
	<cfelse>
	&nbsp;
	</cfif>
	</td>
	<cfif getItemCountForComponent.ItemCount GT 0>
	<td class="darkGrayBG header_text whiteText" height="20" align="right" colspan="1">#dollarFormat(Lump_Sum_Amount)#</td>
	<cfelse>
	<td class="darkGrayBG header_text whiteText" height="20" align="right" width="19%">#dollarFormat(Lump_Sum_Amount)#</td>
	</cfif>
  </tr>
  <tr>
  	<!--- If there is at least one Item for the lumpsum component --->
	<cfif getItemCountForComponent.ItemCount GT 0>
		<td height=".1" class="whiteBG" colspan="#colspan2#"></td>
	<cfelse>
		<td height=".1" class="whiteBG" colspan="4"></td>
	</cfif>
  </tr>

<!--- If there is at least one Item for the lumpsum component --->
<cfif getItemCountForComponent.ItemCount GT 0>
	  <tr>
	  	<td width="1%" height="20"></td>
		<td width="#IDLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Product ID<cfif IncludeGTIN><br />GTIN</cfif><cfif IncludeDistProdCode><br />Dist Product ID</cfif></td>
		<td width="#DescLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Description</td>
		<cfif IncludeLine eq 1>
		<td width="9%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Line ##</td>
		</cfif>
		<td width="1%" valign="middle" height="20">&nbsp;</td>
		<td width="#IDLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Product ID<cfif IncludeGTIN><br />GTIN</cfif><cfif IncludeDistProdCode><br />Dist Product ID</cfif></td>
		<td width="#DescLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Description</td>
		<cfif IncludeLine eq 1>
		<td width="9%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Line ##</td>
		</cfif>
	  </tr>
</cfif>

<!--- If there is at least one Item for the lumpsum component --->
<cfif getItemCountForComponent.ItemCount GT 0>
	   <tr>
    	 <td colspan="100%" height="1"></td>
  	   </tr>
	 
 <!--- color of the first row --->
 <cfset ItemBgColor = "ffffff">

<!--- The display of products will be in 4 column format. 2 column for the first item, next two columns for the second item and then 
	  a new row is added. Then the logic is repeated for the second row.
--->  
<!--- Start the display of products. Use "cfoutput" after using "group attribue" inside query to display products --->
   <cfoutput>
   	
   <cfif thisTag.qProgramLumpSum.item neq "">    
   <cfset itemCounter = itemCounter + 1> 

	  <!--- If it is an odd-numbered row --->
	  <cfif itemCounter MOD 2 eq 1>
	  
	  	<!--- Since the colors will change for rows 1,2,5. We need to change colors whenever a new row starts --->
		<cfif ItemBgColor eq "ffffff">
			<cfset ItemBgColor = "eeeeee">
		 <cfelse>
			<cfset ItemBgColor = "ffffff">
		</cfif>
	  
	   <!--- (Start) Create the first two columns for showing product --->
	   <tr bgcolor="#ItemBgColor#">
	   	<!--- We do not want any background color for this cell - The color is therefore white --->
	   	<td width="1%" height="20" valign="top" style="background-color:ffffff"></td>
		<td width="#IDLength#%" valign="top" height="20">#thisTag.qProgramLumpSum.item#
			<!--- check whether "GTIN" is ON at the letter tab of the template --->
			<cfif IncludeGTIN>
				<br /><cfif thisTag.qProgramLumpSum.GTIN eq "">None<cfelse>#thisTag.qProgramLumpSum.GTIN#</cfif>
			</cfif>			
			<!--- "Dist Product Codes" --->
			<cfif IncludeDistProdCode>
				<br /><cfif thisTag.qProgramLumpSum.customer_product_number eq "">None<cfelse>#thisTag.qProgramLumpSum.customer_product_number#</cfif>
			</cfif>
		</td>
		<td width="#DescLength#%" valign="top" height="20">#thisTag.qProgramLumpSum.description#
		<!--- If it is an "operator" letter, check the "product attribute" at the letter tab of the template --->
		<cfif thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorProductAttribute_1 neq 0 AND operator_product_attribute_1 NEQ ""><br>#operator_product_attribute_1#
		<!--- If it is a "distributor" letter, check the "product attribute" at the letter tab of the template --->
		<cfelseif thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0 AND distributor_product_attribute_1 neq ""><br>#distributor_product_attribute_1#
		</cfif>
		</td>
		<cfif IncludeLine eq 1>
		<td width="9%" valign="top" height="20">#thisTag.qProgramLumpSum.line_number#</td>
		 </cfif>
		<td width="1%" valign="top" height="20">&nbsp;</td>
		<!--- If this is the last item for the lumpsum component, end the row --->
		<cfif getItemCountForComponent.ItemCount eq itemCounter>
		</tr>   	
	   </cfif>
	  </cfif>
	   <!--- (End) Create the first two columns for showing product --->
	  
	  <!--- If it is an even-numbered row --->
	  <cfif itemCounter MOD 2 eq 0>
	  	 <!--- (Start) Create the next two columns for showing product --->
		<td width="#IDLength#%" valign="top" height="20">#thisTag.qProgramLumpSum.item#
			<!--- check whether "GTIN" is ON at the letter tab of the template --->
			<cfif IncludeGTIN>
				<br /><cfif thisTag.qProgramLumpSum.GTIN eq "">None<cfelse>#thisTag.qProgramLumpSum.GTIN#</cfif>
			</cfif>			
			<!--- "Dist Product Codes" --->
			<cfif IncludeDistProdCode>
				<br /><cfif thisTag.qProgramLumpSum.customer_product_number eq "">None<cfelse>#thisTag.qProgramLumpSum.customer_product_number#</cfif>
			</cfif>
		 </td>
		 <td width="#DescLength#%" valign="top" height="20">#thisTag.qProgramLumpSum.description#
		 <!--- If it is an "operator" letter, check the "product attribute" at the letter tab of the template --->
		 <cfif thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorProductAttribute_1 neq 0 AND operator_product_attribute_1 NEQ ""><br>#operator_product_attribute_1#
		 <!--- If it is a "distributor" letter, check the "product attribute" at the letter tab of the template --->
		 <cfelseif thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0 AND distributor_product_attribute_1 neq ""><br>#distributor_product_attribute_1#
		 </cfif>
		 </td>
		 <cfif IncludeLine eq 1>
		 <td width="9%" valign="top" height="20">#thisTag.qProgramLumpSum.line_number#</td>
		 </cfif>
		 </tr>
	   </cfif>
	    <!--- (End) Create the next two columns for showing product --->
   </cfif>
  </cfoutput>

</cfif>

</table>
</cfoutput>

</cfif>
