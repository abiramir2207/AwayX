<CFSET PAGE_TITLE="Freight Charges Calculator">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>


<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>




<CFPARAM NAME="Zip_Code" DEFAULT="">




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the list of Warehouses...															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Warehouses = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_freight_charges")>
<cfif useLakebaseForGet_Warehouses>
	<cftry>
		<cfset Get_Warehouses = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_freight_charges", {
				"select" = "warehouse"
			}), "warehouse"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Warehouses = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Warehouses>
<CFQUERY NAME="Get_Warehouses" datasource="#application.datasource#">
Select	distinct Warehouse
From	BSA_Foodservice_Freight_Charges
</CFQUERY>
</cfif>


<CFFORM ACTION="index.cfm" METHOD="post">

<BR><BR>
<SPAN CLASS="title2">Please enter the destination's Zip code:</SPAN>
<HR SIZE="2" COLOR="Orange">
<BLOCKQUOTE>
<CFINPUT TYPE="Text" NAME="Zip_Code" MESSAGE="Please enter the ZIP code" VALIDATE="zipcode" REQUIRED="Yes" STYLE="width:75; font-size: 14pt; color: Navy;" VALUE="#Zip_Code#">
&nbsp;&nbsp;
<INPUT TYPE="submit" VALUE="Get Freight Charges">
</BLOCKQUOTE>
</CFFORM>


<CFIF Zip_Code EQ "">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</BLOCKQUOTE>
	</BLOCKQUOTE>
	</BODY>
	</HTML>
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The Freight Charges calculator goes here														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="freight_charges_action.cfm">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE>
</BLOCKQUOTE>
</BODY>
</HTML>


