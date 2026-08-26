<!--- D31561: Operator Groups Search START--->
<cfparam name="URL.Is_Group" default="0" />
<cfparam name="URL.showProgramItems" default="0" />
<!--- D31561: Operator Groups Search END--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the URL																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET BSA_Operator_ID = URL.OID>
<!--- D31561: Operator Groups Search START--->
<cfif url.Is_Group>

<cfoutput>
	<table border="0" cellpadding="3" cellspacing="0" bgcolor="ffce84" CLASS="Maintable" width="100%">
		<cfif showProgramItems EQ 0>
			<cfset qGetOperators = CreateObject("component", "components.operator.Group.DataManager").getOperatorsInGroup(BSA_Operator_ID) />
					<tr BGCOLOR="##FFCE84">
						<td id="header">
							<b>#application.returned_customer_setting.operator_label_plural#</b> (#qGetOperators.RecordCount# Records)
						</td>
					</tr>
			<cfif qGetOperators.RecordCount>
					<cfloop query="qGetOperators">
					<tr BGCOLOR="#IIf(qGetOperators.currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<td>#Legacy_ID# - #Operator_Name#</td>
					</tr>	
					</cfloop>
			<cfelse>
					<tr>
						<td>There are no #application.returned_customer_setting.operator_label_plural# for this group</td>
					</tr>
			</cfif>	
	
		<cfelse>
			<cfset qGetOperators = CreateObject("component", "components.operator.Group.DataManager").getOperatorsInProgram(BSA_Operator_ID, url.programID) />
					<tr BGCOLOR="##FFCE84">
						<td id="header">
							<b>#application.returned_customer_setting.operator_label_plural#</b> (#qGetOperators.RecordCount# Records)
						</td>
					</tr>
				<cfif qGetOperators.recordcount>
					<cfloop query="qGetOperators">
					<tr BGCOLOR="#IIf(qGetOperators.currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<td>#Legacy_ID# - #Operator_Name#</td>
					</tr>	
					</cfloop>
				<cfelse>
					<tr>
						<td>There are no #application.returned_customer_setting.operator_label_plural# for this group</td>
					</tr>
				</cfif>
		</cfif>
	</table>
</cfoutput>
	
<cfabort>
	
</cfif>
<!--- D31561: Operator Groups Search END--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all the information for this operator														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Operator_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Operator_Data>
	<cftry>
		<cfset Get_Operator_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#BSA_Operator_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Data>
<CFQUERY NAME="Get_Operator_Data" datasource="#application.datasource#">
Select		*
From		BSA_Operator
Where		BSA_Operator_ID		=		'#BSA_Operator_ID#'
</CFQUERY>
</cfif>

<!---72360 :: Add customer label for BSA ID START --->
<cfset CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels() />
<!---72360 :: Add customer label for BSA ID END --->


<CFOUTPUT QUERY="Get_Operator_Data">



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>#application.returned_customer_setting.operator_label_singular# Profile</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>

<BODY ONBLUR="self.focus();" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">




<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>#Operator_Name#</B></FONT></TD>
</TR>
</TABLE>

<BR>



<TABLE border="0" cellpadding="0" cellspacing="3" WIDTH="350" ALIGN="center">
  <TR>
    <TD colspan="2" nowrap valign="top">
      <DIV class="title2">
        Summary
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.operator_label_singular# Type:</B></TD>
    <TD width="100%" valign="top">#Operator_Type#</TD>
  </TR>
  
  <cfif application.returned_customer_setting.operator_legacy_id_on>
  <TR>
    <TD align="right" nowrap valign="top"><B><CFIF trim(legacy_id) EQ "">#CustomerSettingsLabels.BSA_ID_label#<cfelse>#application.returned_customer_setting.Operator_Legacy_Id_label#</cfif>:</B></TD>
    <TD width="100%" valign="top"><CFIF trim(legacy_id) EQ "">#BSA_Operator_Id#<cfelse>#legacy_id#</cfif></TD>
  </TR>
  </cfif>
  
  <TR>
    <TD align="right" nowrap valign="top"><B>Location Type:</B></TD>
    <TD width="100%" valign="top">#Operator_Location_Type#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Locations:</B></TD>
    <TD width="100%" valign="top"><CFIF Operator_Number_Of_Locations EQ 0>n/a<CFELSE>#numberformat(Replace(Operator_Number_Of_Locations,'-','','ALL'), '_,___,___')#</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Employees:</B></TD>
    <TD width="100%" valign="top"><CFIF IsNumeric(zzz_Operator_Total_Employees)  EQ 1>#numberformat(evaluate(zzz_Operator_Total_Employees), '_,___,___')#<CFELSE>n/a</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Annual Sales:</B></TD>
    <TD width="100%" valign="top"><cfif IsNumeric(zzz_Operator_Annual_Sales)>$#numberformat(evaluate(zzz_Operator_Annual_Sales/1000000), '_,___,___')# Million<cfelse>n/a</cfif></TD>
  </TR>

<!--- 
  <TR>
    <TD align="right" nowrap valign="top"><B>Industry:</B></TD>
    <TD width="100%" valign="top">#zzz_Operator_Industry#</TD>
  </TR>
 --->
  <TR>
    <TD align="right" nowrap valign="top"><B>Does Business as:</B></TD>
    <TD width="100%" valign="top">#Operator_DBA#</TD>
  </TR>
  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">
        General Info
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Address:</B></TD>
    <TD width="100%" valign="top">#Operator_Address#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top">&nbsp;</TD>
    <TD width="100%" valign="top">#Operator_City# #Operator_State# #Operator_Zip#</TD>
  </TR>
    <TR>
    <TD align="right" nowrap valign="top"><B>Country:</B></TD>
    <TD width="100%" valign="top">#Operator_Country_Code#</TD>
  </TR>
<!---   <TR>
    <TD align="right" nowrap valign="top"><B>Mailing Address:</B></TD>
    <TD width="100%" valign="top">#zzz_Operator_Mailing_Address#</TD>
  </TR>
 --->  
 
 <!---<TR>
    <TD align="right" nowrap valign="top">&nbsp;</TD>
    <TD width="100%" valign="top">#zzz_Operator_Mailing_City# #zzz_Operator_Mailing_State# #zzz_Operator_Mailing_Zip#</TD>
  </TR>
  --->
  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">
        Contact Information
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>

<!---   
  <TR>
    <TD align="right" nowrap valign="top"><!--- <B>Primary contact:</B> ---></TD>
    <TD width="100%" valign="top">
		#zzz_Operator_Title#<BR>
		#zzz_Operator_Salutation# #zzz_Operator_First_Name# #zzz_Operator_Middle_Initial# #zzz_Operator_Last_Name# #zzz_Operator_Suffix#<BR>
		Ph:#zzz_Operator_Phone# Fx:#zzz_Operator_Fax#<BR>
		<A HREF="mailto:#zzz_Operator_Email#">#zzz_Operator_Email#</A>
	</TD>
  <TR>
 --->
 
 
	<!---   Get the other contact information --->
	<cfset useLakebaseForGet_Contacts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Contacts>
	<cftry>
		<cfset Get_Contacts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"operator_name" = "eq.#Operator_Name#",
				"operator_address" = "eq.#Get_Operator_Data.Operator_Address#",
				"order" = "operator_last_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Contacts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Contacts>
<CFQUERY NAME="Get_Contacts" datasource="#application.datasource#">
	Select		*
	From		BSA_Operator
	Where		Operator_Name		=	'#Operator_Name#'
				and
				Operator_Address	=	'#Get_Operator_Data.Operator_Address#'
	Order by	Operator_Last_Name
	</CFQUERY>
</cfif>  
  	<CFSET contacts=0>
	<CFLOOP QUERY="Get_Contacts">
  <TR>
    <TD align="right" nowrap valign="top"><!--- <CFIF contacts EQ 0><B>Other Contacts:</B></CFIF> ---></TD>
    <TD width="100%" valign="top">
		#Get_Contacts.Operator_Title#<BR>
		#Get_Contacts.zzz_Operator_Salutation# #Get_Contacts.Operator_First_Name# #Get_Contacts.zzz_Operator_Middle_Initial# #Get_Contacts.Operator_Last_Name# #Get_Contacts.zzz_Operator_Suffix#<BR>

<!--- 		
		#Get_Contacts.Operator_Address#<BR>
		#Get_Contacts.Operator_City#, #Get_Contacts.Operator_State# #Get_Contacts.Operator_Zip#<BR>
		Ph:#Get_Contacts.zzz_Operator_Phone# Fx:#Get_Contacts.zzz_Operator_Fax#<BR>
 --->
		<A HREF="mailto:#Get_Contacts.zzz_Operator_Email#">#Get_Contacts.zzz_Operator_Email#</A>
	  	<CFSET contacts=1>
	</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"></TD>
    <TD width="100%" valign="top" BGCOLOR="silver"><IMG SRC="/images/fill.gif" WIDTH="100" HEIGHT="1"></TD>
  </TR>
</CFLOOP>
</TABLE>

</CFOUTPUT>

</BODY>
</HTML>