<cfinclude template="/helpsystem/help_link.cfm">
<cfset URL.PageTitle="Deductions: DEDUCTION TYPE LIST MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_type", {
				"order" = "deductiontype_desc.asc"
			}),
			"deductiontype_id,deductiontype_desc,deleted,is_default"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<cfquery name="Get_Data" datasource="#application.datasource#">
	SELECT *
	  FROM Deduction_Type
	 ORDER BY	DeductionType_Desc
</cfquery>
</cfif>


<table "actionTable" border="0" cellspacing="10" cellpadding="0" width="750">
<tr>
	<td valign="top">

		<span class="title2">Stored Records</span>
		<HR color="Blue" SIZE="1">

		<table border="0" cellspacing="0" cellpadding="2" width="275" class="Maintable" id="stageTable">
			<tr>
				<td nowrap width="125px" valign="bottom"><span style="font-size: 12px;"><B>Description</B></span></td>
				<td nowrap width="50px" valign="bottom" align="center"><span style="font-size: 12px;"><B>Status</B></span></td>
				<td nowrap width="50px" valign="bottom" align="center"><span style="font-size: 12px;"><B>System <br />Default</B></span></td>
			</tr>
			<cfoutput query="Get_Data">
			<tr>
				<td nowrap><a href="index.cfm?RID=#DeductionType_ID#">#DeductionType_Desc#</a></td>
				<td nowrap align="center">
						<cfif Deleted EQ 0>
						<img src="/images/yes_small.gif" title="active record...">
						<cfelse>
						<img src="/images/no_small.gif" title="inactive record...">
						</cfif>
				</td>
				<td align="center">
					<cfif Is_Default IS 1>
						<img src="/images/checkmark.gif" title="Is System Default">
					<cfelse>
						&nbsp; 
					</cfif>
				</td>	
			</tr>
			</cfoutput>
		</table>

		<br>

		<img src="/images/yes_small.gif" border="0" alt="" align="middle"> - active record<br>
		<img src="/images/no_small.gif" border="0" alt="" align="middle"> - inactive record
		
	</td>
	<td valign="top">

		<span class="title2">Edit Record</span>
		<HR color="Blue" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<cfparam name="URL.RID" default="0">
<cfparam name="Get_Item.DD_Classification_Description" default="">
<cfparam name="Get_Item.DeductionType_ID" default="">
<cfparam name="Get_Item.Deleted" default="0">
<cfparam name="Get_Item.Is_Default" default="0">
				

<cfquery name="Get_Item" datasource="#application.datasource#">
	SELECT		*
	  FROM		Deduction_Type
	 WHERE		DeductionType_ID	like	'#URL.RID#'
</cfquery>

<script language="JavaScript">
function alert_and_delete()
{	
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{			
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();		
	}
}	

function Validate()
{	
	if (document.all.DeductionType_Desc.value == "")
	{	
		alert("Please enter some description.");
		document.all.DeductionType_Desc.focus();
		return;
	}
	if (document.all.Actual_Default.value == 1 && (document.all.Deleted[1].checked || document.all.Is_Default.checked == false))
	{
		var formObj = document.MyForm;
		formObj.action = "DeleteDefault.cfm";	
		NewWindow("", 'delDef', '500', '200', 'Yes', 'No', true);
		formObj.target = "delDef";
		document.MyForm.submit();
		return
	}
	else
	{
		document.MyForm.submit();
	}
}
</script>

		<FORM ACTION="save.cfm" METHOD="post" name="MyForm">
		<cfoutput>
		<input type="Hidden" name="Actual_Default" value="#Get_Item.Is_Default#">
		</cfoutput>
		<table cellspacing="5" cellpadding="0">
			<tr>
				<td valign="top" align="right"><B>Description</B></td>
				<td valign="top">
					<cfoutput>
						<input SIZE="55" name="DeductionType_Desc" value="#Get_Item.DeductionType_Desc#" MAXLENGTH="20">
						<input type="hidden" name="DeductionType_ID" value="#Get_Item.DeductionType_ID#">
					</cfoutput>
				</td>
			</tr>
			
			<tr>
				<td valign="top" align="right"><B>Availability</B></td>
				<td valign="top">
	
				
				<!--- Is this record deleted? --->
				<cfif Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
					<cfset active=" CHECKED">
					<cfset inactive="">
				<cfelse>
					<cfset active="">
					<cfset inactive=" CHECKED">
				</cfif>
	
				<cfoutput>
				<input type="radio" value="0" name="Deleted"#active#>Active
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
				<input type="radio" value="1" name="Deleted"#inactive#>Inactive
				
				</cfoutput>
	
				</td>
			</tr>
			<tr>
			<td valign="top" align="right"><strong>Default</strong></td>
			<td valign="top">
						
				<input type="CheckBox" value="1" name="Is_Default" <cfif Get_Item.Is_Default EQ 1>CHECKED</cfif>>Yes
			</td>
			</tr>
			<tr>
			</tr>
			<tr>
				<td valign="top" align="right"></td>
				<td valign="top">
					<font color="#ff0000" SIZE="2"><B>[</B></font>
							<A href="javascript: Validate()"><B>save data</B></A>
					<font color="#ff0000" SIZE="2"><B>]</B></font>
					
				<input type="hidden" name="DeleteRecord" value="0">
				
						<cfif Get_Item.Deleted EQ 1>
					<font color="#ff0000" SIZE="2"><B>[</B></font>
							<A href="javascript: alert_and_delete();"><B>delete data</B></A><!--- href="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
					<font color="#ff0000" SIZE="2"><B>]</B></font>
					</cfif>
				</td>
			</tr>
		</table>
		</FORM>
	
	</td>
</tr>
</table>

<B>	
<font color="#ff0000" SIZE="2"><B>[</B></font>
	<A href="index.cfm?RID=0"><B>create new entry</B></A>
<font color="#ff0000" SIZE="2"><B>]</B></font>
</B>

