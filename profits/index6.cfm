<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFOUTPUT>#Total_Calculated_Cost#</CFOUTPUT> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="FORM.PRID" DEFAULT="">
<CFPARAM NAME="Form.Total_Calculated_Cost_Lag" DEFAULT="#Form.Total_Calculated_Cost#">

<CFIF FORM.PRID NEQ "">
		<!--- Save edited data to the database --->
		<CFQUERY NAME="Save_Pricing_Rule" datasource="#application.datasource#">
		Update		Pricing_Rule
		Set			Pricing_Rule_Name			=	'#form.aa_rulename#',
					Pricing_Rule_Date			=	#createodbcdatetime(now())#,
					Pricing_Rule_Author			=	'#form.User_ID#',
					Pricing_Rule_Final_Cost		=	#form.Total_Calculated_Cost#,
					Pricing_Rule_Final_Cost_Lag	=	#form.Total_Calculated_Cost_Lag#,
					Pricing_Rule_Data			=	'#form.xml_profit_rule_name#'
		Where		Pricing_Rule_ID				=	'#FORM.PRID#'
		</CFQUERY>
		
		<!--- First delete the old products that belonged to this rule... --->
		<cfset useLakebaseForDelete_Products = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pricing_rule_products")>
<cfif useLakebaseForDelete_Products>
	<cftry>
		<cfset application.oLakebase.deleteRows("pricing_rule_products", {
			"pricing_rule_id" = "eq.#FORM.PRID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Products = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Products>
<CFQUERY name="Delete_Products" datasource="#application.datasource#">
		DELETE FROM Pricing_Rule_Products WHERE Pricing_Rule_ID = '#FORM.PRID#'
		</CFQUERY>
</cfif>
		
		<!--- Then save the new group of products to the Pricing_Rule_Products table --->
		<CFLOOP index="item" list="#form.AA_PRODUCT_LIST#">
		<cfset useLakebaseForSave_Pricing_Rule_Products = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pricing_rule_products")>
<cfif useLakebaseForSave_Pricing_Rule_Products>
	<cftry>
		<cfset application.oLakebase.insertRow("pricing_rule_products", {
			"pricing_rule_id" = "#FORM.PRID#",
			"pricing_rule_products_item_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Pricing_Rule_Products = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Pricing_Rule_Products>
<CFQUERY NAME="Save_Pricing_Rule_Products" datasource="#application.datasource#">
		Insert Into Pricing_Rule_Products
		(Pricing_Rule_ID, Pricing_Rule_Products_Item_ID)
		Values
		('#FORM.PRID#','#item#')
		</CFQUERY>
</cfif>
		</CFLOOP>

<CFELSE>
	<!--- Save new data to the database --->
	
	<CFQUERY NAME="Save_Pricing_Rule" datasource="#application.datasource#">
		Insert Into Pricing_Rule
			(
				Pricing_Rule_Name,
				Pricing_Rule_Author,
				Pricing_Rule_Final_Cost,
				Pricing_Rule_Final_Cost_Lag,
				Pricing_Rule_Data
			)
		Values
			(
				'#form.aa_rulename#',
				'#form.User_ID#',
				#form.Total_Calculated_Cost#,
				#form.Total_Calculated_Cost_Lag#,
				'#form.xml_profit_rule_name#'
			)
	</CFQUERY>

<!--- 
	<CFQUERY NAME="Save_Pricing_Rule" datasource="#application.datasource#">
		Insert Into Pricing_Rule
			(
				Pricing_Rule_Name,
				Pricing_Rule_Author,
				Pricing_Rule_Products,
				Pricing_Rule_Final_Cost,
				Pricing_Rule_Data
			)
		Values
			(
				'#form.aa_rulename#',
				'#form.User_ID#',
				'#form.AA_PRODUCT_LIST#',
				#form.Total_Calculated_Cost#,
				'#form.xml_profit_rule_name#'
			)
	</CFQUERY>
 --->	
	
<!--- The id of the last created record is A_ID --->
<CFSET Last_ID_Created=Save_Pricing_Rule.A_ID>

<!--- Save the prodcuts list --->
<CFLOOP index="item" list="#form.AA_PRODUCT_LIST#">
	<CFQUERY NAME="Save_Pricing_Rule_Products" datasource="#application.datasource#">
		Insert Into Pricing_Rule_Products
			(Pricing_Rule_ID, Pricing_Rule_Products_Item_ID)
		Values
			('#Last_ID_Created#','#item#')
	</CFQUERY>
</CFLOOP>

</CFIF>

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="715" HEIGHT="25">
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold;">Pricing Rule saved</SPAN>
	</TD>
</TR>
</TABLE>

<BR><BR><BR><BR>

<BLOCKQUOTE>
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0">
  <TR>
    <TD ALIGN="RIGHT"><B>Name</B></TD>
    <TD ROWSPAN="100%" BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1"></TD>
    <TD><CFOUTPUT>#ReplaceList(form.aa_rulename,"<,>","&lt;,&gt;")#</CFOUTPUT></TD>
  </TR>
  <TR>
    <TD ALIGN="RIGHT"><B>Date/Time</B></TD>
    <TD><CFOUTPUT>#dateformat(now(), 'mm/dd/yy')# #timeformat(now(), 'hh:mmtt')#</CFOUTPUT></TD>
  </TR>
  <TR>
    <TD>&nbsp;</TD>
    <TD>&nbsp;</TD>
  </TR>
</TABLE>

<BR><BR><BR>

<B>
<FONT COLOR="#FF0000" size="2">[</FONT>
<FONT size="2"><a href="index.cfm" TARGET="_top">view all rules</a></FONT>
<FONT COLOR="#FF0000" size="2">]</FONT>
</B>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;


</BLOCKQUOTE>

<script language="JavaScript">
function seeya()
{
	window.parent.window.location.href="index.cfm";
}
setTimeout('seeya()',2000); 
</script>
