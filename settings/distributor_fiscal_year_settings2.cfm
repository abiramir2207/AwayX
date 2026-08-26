<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Select <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> / Accounting Periods</TITLE>
</HEAD>

<cfset useLakebaseForGetFamilyNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForGetFamilyNames>
	<cftry>
		<cfset GetFamilyNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_family", {
				"deleted" = "eq.0",
				"order" = "family_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFamilyNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFamilyNames>
<cfquery name="GetFamilyNames" datasource="#application.datasource#">
	SELECT *
	FROM Distributor_Family
	WHERE Deleted = 0
	ORDER BY Family_Name
</cfquery>
</cfif>

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Ask for the number of periods in the distributor fiscal year												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFFORM ACTION="distributor_fiscal_year_settings3.cfm" METHOD="post" NAME="MyForm">

<SPAN CLASS="title2">Step I</SPAN>
<HR COLOR="Orange">
Select the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>
<SELECT NAME="Distributor_Name">
	<cfoutput query="GetFamilyNames">
		<OPTION VALUE="#Family_ID#">#Family_Name#</OPTION>
	</cfoutput>
</SELECT>

<BR><BR>
<SPAN CLASS="title2">Step II</SPAN>
<HR COLOR="Orange">
How many Accounting periods does the fiscal year of your <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> have?

<SELECT NAME="Number_of_Periods">
	<CFLOOP INDEX="i" FROM="1" TO="13" STEP="1">
		<CFOUTPUT><OPTION VALUE="#i#"<CFIF i EQ 4> SELECTED</CFIF>>#i# Period<CFIF i GT 1>s</CFIF></OPTION></CFOUTPUT>
	</CFLOOP>
</SELECT>
<BR><BR><BR><BR>


<CF_button
	button_name		=	"MyButton"
	button_caption	=	"next step"
	button_action	=	"javascript:document.all.MyForm.submit();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">

</CFFORM>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



