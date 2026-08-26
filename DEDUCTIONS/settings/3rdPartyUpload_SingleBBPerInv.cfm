<!---  
       Name:          Billback_Type_Label_Settings.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  
       Created By:    
       Label:		      
       Description:   
--->

<cfparam name="Form.III_P_Upload_Single_BB_Per_Invoice"	default=0 />
<CFPARAM NAME="Form.deletedFamilyID"				default="0" />
<CFPARAM NAME="Form.deletedCustomerID"				default="0" />
<CFPARAM NAME="Form.jumpTodefaultPayee"				default="0" />
<CFPARAM NAME="Form.SubmitBBIII_P_Upload"			default="0" />
<CFPARAM NAME="URL.Single_BB_Per_InvoiceChecked"	default="0" />

<cfif Form.jumpTodefaultPayee eq "1">
		<cflocation url = "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings&Single_BB_Per_InvoiceChecked=1&##FamilyNameDefaultPayee" addtoken="false"/>
</cfif>

<!---<cfset appSettings = application.appSettingsGet>--->
<cfset oBillbackSettings = createObject("component", "components.billback.BillbackSettingsManager") />

<cfif form.SubmitBBIII_P_Upload eq 1>
	<cfset oBillbackSettings.saveIII_P_UploadSingleBBPerINV(III_P_UPLOAD_SINGLE_BB_PER_INVOICE) />
	<cflocation url = "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings">
</cfif>

<cfif Form.deletedFamilyID neq 0>
	<cfset useLakebaseForsetDeletedBB_III_Upload_Default_Dist1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
	<cfif useLakebaseForsetDeletedBB_III_Upload_Default_Dist1>
		<cftry>
			<cfset application.oLakebase.updateRows("bb_iii_upload_default_dist",
				{ "family_id" = "eq.#Form.deletedFamilyID#", "ship_to_level" = "eq.0" },
				{ "deleted" = 1, "updated_by" = request.AccessStructure.user_id }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForsetDeletedBB_III_Upload_Default_Dist1 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForsetDeletedBB_III_Upload_Default_Dist1>
	<cfquery name="setDeletedBB_III_Upload_Default_Dist" datasource="#application.datasource#">
		UPDATE	BB_III_Upload_Default_Dist
		SET		Deleted = 1,
				Updated_By ='#request.AccessStructure.user_id#'
		WHERE	Family_ID = <cfoutput>'#Form.deletedFamilyID#'</cfoutput>
		AND		Ship_To_Level = 0
	</cfquery>
	</cfif>
	<cflocation url = "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings&Single_BB_Per_InvoiceChecked=1&##FamilyNameDefaultPayee" addtoken="false"/>
</cfif>

<cfif Form.deletedCustomerID neq 0>
	<cfset useLakebaseForsetDeletedBB_III_Upload_Default_Dist2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
	<cfif useLakebaseForsetDeletedBB_III_Upload_Default_Dist2>
		<cftry>
			<cfset application.oLakebase.updateRows("bb_iii_upload_default_dist",
				{ "bsa_foodservice_customers_id" = "eq.#Form.deletedCustomerID#", "ship_to_level" = "eq.1" },
				{ "deleted" = 1, "updated_by" = request.AccessStructure.user_id }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForsetDeletedBB_III_Upload_Default_Dist2 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForsetDeletedBB_III_Upload_Default_Dist2>
	<cfquery name="setDeletedBB_III_Upload_Default_Dist" datasource="#application.datasource#">
		UPDATE	BB_III_Upload_Default_Dist
		SET		Deleted = 1,
				Updated_By ='#request.AccessStructure.user_id#'
		WHERE	BSA_Foodservice_Customers_ID = <cfoutput>'#Form.deletedCustomerID#'</cfoutput>
		AND		Ship_To_Level = 1
	</cfquery>
	</cfif>
	<cflocation url = "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings&Single_BB_Per_InvoiceChecked=1&##FamilyNameDefaultPayee" addtoken="false"/>
</cfif>

<cfset qgetIII_P_UploadSingleBBPerINV	= oBillbackSettings.getIII_P_UploadSingleBBPerINV() />	
<cfset FORM.III_P_Upload_Single_BB_Per_Invoice = qgetIII_P_UploadSingleBBPerINV.III_P_Upload_Single_BB_Per_Invoice />

<cfif URL.Single_BB_Per_InvoiceChecked eq "1" AND FORM.III_P_Upload_Single_BB_Per_Invoice eq 0>
	<cfset FORM.III_P_Upload_Single_BB_Per_Invoice = "1" />
</cfif>

<script language="JavaScript">
	function BBIIIPUploadSubmitForm()
	{
		document.all.BBIIIPUpload.SubmitBBIII_P_Upload.value = 1;
		document.all.BBIIIPUpload.submit();
		return false;
	}

	function deleteDefaultPayeeSubmit(FamilyID)
	{
		if(confirm("Do you really want to delete the selected default payee ?"))
		{
			var thisForm	= document.BBIIIPUpload;
			thisForm.deletedFamilyID.value = FamilyID;
			document.BBIIIPUpload.submit();
			return false;
		}
		
		return false;	
	}

	function deleteDefaultPayeeShipToSubmit(CustomerID)
	{
		if(confirm("Do you really want to delete the selected default payee ?"))
		{
			var thisForm	= document.BBIIIPUpload;
			thisForm.deletedCustomerID.value = CustomerID;
			document.BBIIIPUpload.submit();
			return false;
		}
		
		return false;	
	}


	function toggleFieldDisplay(srcElement,dispElement1,dispElement2)  
  	{    
   	  var field1 = document.getElementById(dispElement1);
  	  var field2 = document.getElementById(dispElement2);
  	  var srcVal = document.getElementById(srcElement);
       
  	if (srcVal.checked) 
  	  {
 	     field1.style.display = 'none';
 	     field2.style.display = '';  
  	  }
   	 else 
    {
      field1.style.display = '';
      field2.style.display = 'none';  
    }  
  }
</script>

<a name="FamilyNameDefaultPayee"></a>
<form action="3rdPartyUpload_SingleBBPerInv.cfm" method="post" name="BBIIIPUpload" id="BBIIIPUpload">
<cfoutput>
  <cfif Len(trim(qgetIII_P_UploadSingleBBPerINV.III_P_Upload_Single_BB_Updated_By)) GT 0>
     <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="2">
    	<tr>
    		<td>
       			<FONT SIZE="2"><B>The settings were last updated on #dateformat(qgetIII_P_UploadSingleBBPerINV.III_P_Upload_Single_BB_Updated_Date, 'mm/dd/yyyy')# #timeformat(qgetIII_P_UploadSingleBBPerINV.III_P_Upload_Single_BB_Updated_Date, 'hh:mm:ss TT')# by #qgetIII_P_UploadSingleBBPerINV.Updated_By#</B></FONT>
       		</td>
    	</tr>
    </table>
  </cfif>
  <br>
  <table BORDER="0" CELLPADDING="0" CELLSPACING="0">
		<tr>
			<td colspan="2" nowrap>
				 <font color="navy" size=2><b><span class="subheading"><strong>3rd Party Upload � Single Billback Per Invoice:</span></b></font> 
				 <input name="III_P_Upload_Single_BB_Per_Invoice"  id = "III_P_Upload_Single_BB_Per_Invoice" type="checkbox" value="1" <cfif FORM.III_P_Upload_Single_BB_Per_Invoice eq 1>checked</cfif>  onclick="toggleFieldDisplay('III_P_Upload_Single_BB_Per_Invoice','III_P_Upload_Single_BB_Per_Invoice_Hide','III_P_Upload_Single_BB_Per_Invoice_select'); toggleFieldDisplay('III_P_Upload_Single_BB_Per_Invoice','TblSelectedDefaultPayee_Hide','TblSelectedDefaultPayee');"/>
			</td>
			<td id="III_P_Upload_Single_BB_Per_Invoice_select" <cfif FORM.III_P_Upload_Single_BB_Per_Invoice EQ "0">style="display:none;"</cfif> nowrap>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="##FF0000">[ </FONT><A HREF="3rdPartyUpload_SearchFamily.cfm" onclick="NewWindow(this.href,'Billback_Type_3rd_SingleFamily','800','500','yes', 'yes');return false;">Search Family</A><FONT COLOR="##FF0000"> ]</FONT></B>
				<span id ="III_P_Upload_Single_BB_Per_Invoice_Hide"></span>
				<span id ="TblSelectedDefaultPayee_Hide"></span>
			</td>
			<td id="III_P_Upload_Single_BB_Per_Invoice_select" <cfif FORM.III_P_Upload_Single_BB_Per_Invoice EQ "0">style="display:none;"</cfif> nowrap>
				<B><FONT COLOR="##FF0000">[ </FONT><A HREF="3rdPartyUpload_SearchShipTo.cfm" onclick="NewWindow(this.href,'3rdPartyUpload_SearchShipTo','800','500','yes', 'yes');return false;">Search #application.returned_customer_setting.shard_ship_to_label#</A><FONT COLOR="##FF0000"> ]</FONT></B>
				<span id ="III_P_Upload_Single_BB_Per_Invoice_Hide"></span>
				<span id ="TblSelectedDefaultPayee_Hide"></span>
			</td>
		</tr>
		<!---
		<tr id ="TblSelectedDefaultPayee" <cfif FORM.III_P_Upload_Single_BB_Per_Invoice EQ "0">style="display:none;"</cfif>><td width="10%"></td><td colspan="2">
		--->	
		<!---Selected Default Payee--->
		<cfif FORM.III_P_Upload_Single_BB_Per_Invoice eq 1>
			<cfquery name="SelectedDefaultPayee" datasource="#application.datasource#">
				SELECT	BB_III_Upload_Default_Dist.Family_ID,
						BB_III_Upload_Default_Dist.Distributor_ID,
						BSA_Foodservice_Customers.Name,
						Distributor_Family.Family_Name,
						BSA_Foodservice_Customers.Ship_To,
						BFC.Name AS Ship_To_Name,
						BB_III_Upload_Default_Dist.BSA_Foodservice_Customers_ID,
						BB_III_Upload_Default_Dist.Ship_To_Level
				FROM	BB_III_Upload_Default_Dist
						INNER JOIN BSA_Foodservice_Customers on BB_III_Upload_Default_Dist.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						LEFT JOIN Distributor_Family on BB_III_Upload_Default_Dist.Family_ID = Distributor_Family.Family_ID
						LEFT JOIN BSA_Foodservice_Customers BFC ON BFC.BSA_Foodservice_Customers_ID = BB_III_Upload_Default_Dist.BSA_Foodservice_Customers_ID
				WHERE BB_III_Upload_Default_Dist.DELETED = 0
				ORDER BY Distributor_Family.Family_Name
 			</cfquery>
			<cfif SelectedDefaultPayee.recordcount GT 0>
			
			<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
				<TR ID="HEADER" BGCOLOR="##FFCE84">
				<td>&nbsp;</td>
				<td nowrap><b>Family Name</b></td>
				<td nowrap><b>#application.returned_customer_setting.shard_ship_to_label# Name</b></td>
				<td nowrap><b>&nbsp;&nbsp;&nbsp;&nbsp;Default Payee</b></td>
				<td nowrap align="center"><b>Payee Number</b></td>
				<td>&nbsp;</td>
				</TR>		
				<cfloop query="SelectedDefaultPayee">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('CCFFCC'))#">
						<td>
							<cfif SelectedDefaultPayee.Ship_To_Level eq 0>
								<a href="" onClick="JavaScript: return deleteDefaultPayeeSubmit('#SelectedDefaultPayee.Family_ID#');"><img src="/images/scissor.gif" TITLE="Delete #SelectedDefaultPayee.Family_Name#" BORDER="0"></a>&nbsp;&nbsp;
							<cfelse>
								<a href="" onClick="JavaScript: return deleteDefaultPayeeShipToSubmit('#SelectedDefaultPayee.BSA_Foodservice_Customers_ID#');"><img src="/images/scissor.gif" TITLE="Delete #SelectedDefaultPayee.Ship_To_Name#" BORDER="0"></a>&nbsp;&nbsp;
							</cfif>
						</td>
						<td><cfif SelectedDefaultPayee.Ship_To_Level eq 0>#SelectedDefaultPayee.Family_Name#</cfif>&nbsp;</td>
						<td><cfif SelectedDefaultPayee.Ship_To_Level eq 1>#SelectedDefaultPayee.Ship_To_Name#</cfif>&nbsp;</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;#SelectedDefaultPayee.Name# </td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;#SelectedDefaultPayee.Ship_To#</td>
						<td>&nbsp;</td>
					</TR>
				</cfloop>
			</TABLE>
			
			</cfif>
		</cfif>	
		</td></tr>
  </table>
  <div  align="center">
		<br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return BBIIIPUploadSubmitForm();"""
			>
  </div>
</cfoutput>
<input name="SubmitBBIII_P_Upload" type="hidden" value="0" />
<input name="deletedFamilyID" type="hidden" value="0" />
<input name="deletedCustomerID" type="hidden" value="0" />
<input name="jumpTodefaultPayee" type="hidden" value="0" />
</form>
 
 