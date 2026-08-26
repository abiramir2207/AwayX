<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags"> 

<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetCompRebates.recordCount GT 0>
			<TD ALIGN="left" WIDTH="130" nowrap>
			<CFIF form.display eq "inActive">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelComps();">
			activate selected</a>
			<CFELSE>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelComps();">
			deactivate selected</a>
			</b></b></CFIF><B><B>
			<FONT COLOR="FF0000">]</FONT></B>
			</b></TD>
		</CFIF>
		<TD WIDTH="">&nbsp;</TD>
	</TR>
</TABLE>
<br>
<TABLE width="80%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Claim Mechanic</b>
		</TD>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()> <!--- if auto pay app switch is ON --->
		<TD STYLE="font-size:11px;">
			<b>Auto Pay</b>
		</TD>
		</cfif>
		<TD STYLE="font-size:11px;">
			<b>Off Invoice</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Restricted from Billback</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Program Interface Lock</b>
		</TD>
	<cfif appSettings.getProgramClaimRatesReportAvailable()>
		<TD STYLE="font-size:11px;">
			<b>Include in Claim Rates Report</b>
		</TD>
	</cfif>
	<cfif appSettings.getShowPricingReport()>
		<TD STYLE="font-size:11px;">
			<b>Include in Pricing Report</b>
		</TD>
	</cfif>
		<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
			<TD STYLE="font-size:11px;">
				<b>Payment Processor</b>
			</td>
		</cfif>
		<TD WIDTH="65" STYLE="font-size:11px;"><B>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></TD>
		<TD WIDTH="50" STYLE="font-size:11px;"><B>Delete</B></TD>
	</TR>
	
	<CFOUTPUT QUERY="qGetCompRebates">
		<!---check to see if we can delete this component--->
		<cfscript>
			bCanDelete = compRebate.canDelete(qGetCompRebates.Payment_Type_ID);
		</cfscript>
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Payment_Type_ID#"></TD>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Payment_Type_ID#');">#Payment_Type_Name#</a>
		</TD>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()> <!--- if auto pay app switch is ON --->
		<TD>
			<cfif Is_Auto_Pay IS 1>Yes<cfelse>No</cfif>
		</TD>
		</cfif>
		<TD>
			<cfif Off_Invoice IS 1>Yes<cfelse>No</cfif>
		</TD>
		<TD>
			<cfif Restrict_From_Billback IS 1>Yes<cfelse>No</cfif>
		</TD>
		<TD>
			<cfif Program_Lock_Type_ID>Yes<cfelse>No</cfif>
		</TD>
		<cfif appSettings.getProgramClaimRatesReportAvailable()>
		<TD>
			<cfif Include_Claim_Rates_Report>Yes<cfelse>No</cfif>
		</TD>
		</cfif>
		<cfif appSettings.getShowPricingReport()>
		<TD>
			<cfif Include_Pricing_Report>Yes<cfelse>No</cfif>
		</TD>
		</cfif>
		<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
		
			<td>
			
				<!---create the data struct to pass to the accountinSpecialist section if it's on in customer settings--->
				<cfset tmpStruct = StructNew() />
				<cfset tmpStruct.profileId = request.AccessStructure.Profiles_ID />
				<cfset tmpStruct.paymentTypeId = Payment_Type_ID />
				<cfset tmpStruct.handler = "edit" />
				<!---layout is just a namespace for the custom tag lib--->
				<layout:section name="views.programs.paymentTypePaymentProcessor" parameters="#tmpStruct#">
				
			</td>
				
		</cfif>
		
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate #Payment_Type_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#Payment_Type_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #Payment_Type_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate #Payment_Type_Name#" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#Payment_Type_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #Payment_Type_Name#" BORDER="0"></a></TD>
		</CFIF>
		
		
		<CFIF bCanDelete >
			<TD TITLE="Delete #Payment_Type_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#Payment_Type_ID#');"><img src="/images/no_small.gif" TITLE="Delete #Payment_Type_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>

