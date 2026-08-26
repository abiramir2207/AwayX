<!-----------------------------------------------------------------------------

FILE NAME:		competitive_data_package.cfm
DESCRIPTION:	This file get all the details for the Package
              and saves the data into the DB
CREATED BY:		09-Jun-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
Anand Rao	09-Jun-2010	 CREATED

------------------------------------------------------------------------------> 
<cfsilent>

<cfset tr_border_width = 2>
<cfset td_fore_color = "FFE083">
<cfoutput>
<style type="text/css">
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	
	
	TD.headernotselected
  {
   background-color 	: dddddd;
   border-bottom		: solid #TR_BORDER_WIDTH#px black;
   cursor				: pointer;	
  }
  TD.headerselected
  {
   border-left			: solid #TR_BORDER_WIDTH#px black;
   border-top			: solid #TR_BORDER_WIDTH#px black;
   border-right			: solid #TR_BORDER_WIDTH#px black;
   background-color 	: #TD_FORE_COLOR#;
   cursor				: pointer;	
   TEXT-TRANSFORM		: uppercase;
  }

  TD.headerspacer
  {
   border-bottom		: solid #TR_BORDER_WIDTH#px black;
  }


</style>
</cfoutput>

<cfparam name="blnSubmit" default="0">
<cfparam name="URL.CD_ID" default="0">
<!--- <cfparam name="FORM.PR_Operator_Category" 	default="0">
<cfparam name="FORM.PR_Operator_Priority" 	default="0">
<cfparam name="FORM.PR_Date_Range"			default="0">
 --->
<!--- 
Program_Bid_Package_ID
Program_Bid_Package_Code
Program_Bid_Package_Description
Active
Deleted
Created_Date
Updated_Date
Updated_By 
--->

</cfsilent>
<cfmodule template="/customTags/layout.cfm" 
							layoutID = "competitiveData" >
<cfif blnsubmit is 1>
	
	<!--- Delete record --->
	<cfif FORM.deleterecord EQ 1>
		
		<cfquery name="delete_Data" datasource="#application.datasource#">
      UPDATE Program_Bid_Package 
      SET     Deleted = 1,  
              Updated_Date			= #Now()#,
						  Updated_By				= '#request.AccessStructure.User_ID#' 
      WHERE Program_Bid_Package_ID = #FORM.Program_Bid_Package_ID#
		</cfquery>
	
	<cfelseif FORM.Program_Bid_Package_ID EQ "">
	
		<!--- Insert the record --->
		<cfquery name="Save_Data" datasource="#application.datasource#">
			INSERT INTO Program_Bid_Package
				(Program_Bid_Package_Code,Program_Bid_Package_Description,Active,Updated_Date,Updated_By,Deleted)
			VALUES
				('#FORM.ProgramBidWonByCode#','#FORM.ProgramBidWonByDescription#',#FORM.Active#,#Now()#,'#request.AccessStructure.User_ID#',0)
		</cfquery>
		
	<cfelse>
		
		<!--- Update the record --->
		<cfquery name="Save_Data" datasource="#application.datasource#">
			UPDATE 		Program_Bid_Package
			SET 		Program_Bid_Package_Code = '#FORM.ProgramBidWonByCode#',
              Program_Bid_Package_Description = '#FORM.ProgramBidWonByDescription#',
              Active = #FORM.Active#,
						  Updated_Date			= #Now()#,
						  Updated_By				= '#request.AccessStructure.User_ID#'
 			WHERE		Program_Bid_Package_ID		= #FORM.Program_Bid_Package_ID#
		</cfquery>
	</cfif>
	
</cfif>

<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<!--- <cfset qGetPackageLabel 	= labelComp.GetGeneralLabels('Operator Package') />
<cfset qGetPriorityLabel 	= labelComp.GetGeneralLabels('Operator Priority') />
<cfset qGetSourceLabel		= LabelComp.getGeneralLabels('Source') /> 
<cfset qGetSourceTypeLabel	= LabelComp.getGeneralLabels('Source Type') />  --->

<cfset qGetWonByLabel 	= LabelComp.getGeneralLabels('Won By') />
<cfset qGetCategoryLabel 	= LabelComp.getGeneralLabels('Category') />
<cfset qGetPackageLabel 	= LabelComp.getGeneralLabels('Package') />
<cfset qGetSourceLabel		= LabelComp.getGeneralLabels('Source') /> 
<cfset qGetSourceTypeLabel	= LabelComp.getGeneralLabels('Source Type') /> 

<cfquery name="Get_LastUpdated_Details" datasource="#application.datasource#">
	SELECT		TOP 1 *
	FROM		Program_Bid_Package
	<cfif URL.cd_id neq 0>
	Where		Program_Bid_Package_ID = #URL.CD_ID#
	</cfif>
	Order by	Updated_Date Desc
</cfquery>

<cfif get_lastupdated_details.recordcount gt 0>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_LastUpdated_Details.Updated_By#",
				"select" = "name_last as user_fullname"
			}), "name_last as user_fullname"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<cfquery name="getUserName" datasource="#application.datasource#">
		SELECT 	_Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM 	_Users
		WHERE 	User_ID = '#Get_LastUpdated_Details.Updated_By#'
	</cfquery>
</cfif>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0">
<tr><td>
<cfif get_lastupdated_details.recordcount gt 0>
	<font size="2"><b>This <cfif URL.CD_ID neq 0>Item<cfelse> setting</cfif> was last updated on <cfoutput>#dateformat(Get_LastUpdated_Details.Updated_Date, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.Updated_Date, 'h:mm:ss TT')#</cfoutput> by <cfoutput>#getUserName.User_FullName#</cfoutput></b></font></td></tr></table>
</cfif>
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_package")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_package", {
				"deleted" = "eq.0",
				"order" = "program_bid_package_description.asc",
				"select" = "program_bid_package_id,program_bid_package_code,program_bid_package_description,active,deleted,created_date,updated_date,updated_by"
			}), "program_bid_package_id,program_bid_package_code,program_bid_package_description,active,deleted,created_date,updated_date,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<cfquery name="Get_Data" datasource="#application.datasource#">
	SELECT		Program_Bid_Package_ID,
            Program_Bid_Package_Code,
            Program_Bid_Package_Description,
            Active,
            Deleted,
            Created_Date,
            Updated_Date,
            Updated_By
	FROM		Program_Bid_Package 
  WHERE Deleted = 0  
	ORDER BY	Program_Bid_Package_Description
  
</cfquery>
</cfif>
<table border="0" cellspacing="10" cellpadding="0" width="750">
	<tr>
		<td valign="top">
			<cfoutput><span class="title2">Existing #qGetPackageLabel.General_Labels_Label#</span></cfoutput>
			<hr color="Blue" size="1">
			
			<table border="0" cellspacing="0" cellpadding="2" width="200" class="Maintable">
				<tr>
					<td nowrap width="100%"><span style="font-size: 12px;"><b>Description</b></span></td>
					<td nowrap><span style="font-size: 12px;"><b>Status</b></span></td>
				</tr>
				<cfoutput query="Get_Data">
				<tr>
					<td nowrap><a href="competitive_data_Package.cfm?CD_ID=#Program_Bid_Package_ID#">#Program_Bid_Package_Description#</a></td>
					<td nowrap>
						<cfif Active EQ 1>
							<img src="/images/yes_small.gif" title="active record...">
						<cfelse>
							<img src="/images/no_small.gif" title="inactive record...">
						</cfif>
					</td>
				</tr>
				</cfoutput>
			</table>
			<br>
			<img src="/images/yes_small.gif" border="0" title="" align="middle"> - active record<br>
			<img src="/images/no_small.gif" border="0" title="" align="middle"> - inactive record
		</td>
		<td valign="top">
      <cfif (URL.CD_ID NEQ 0)>
			  <span class="title2">Edit Record</span>
      <cfelse>
        <span class="title2">Add Record</span>
      </cfif>
      
			<hr color="Blue" size="1">
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- Retrieve the data for the ID of the item passed --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
 
			<cfparam name="Get_Item.Deleted" default="0">

			<cfset useLakebaseForGet_Item = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_package")>
<cfif useLakebaseForGet_Item>
	<cftry>
		<cfset Get_Item = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_package", {
				"program_bid_package_id" = "eq.#URL.CD_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Item = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Item>
<cfquery name="Get_Item" datasource="#application.datasource#">
				SELECT		*
				FROM		Program_Bid_Package
				WHERE		Program_Bid_Package_ID	= #URL.CD_ID#
			</cfquery>
</cfif>

			<cfset FORM.ProgramBidWonByCode 	      = get_item.Program_Bid_Package_Code />
			<cfset FORM.ProgramBidWonByDescription 	= get_item.Program_Bid_Package_Description />
			<cfset FORM.Active 		                  = get_item.Active />
			
			<script language="JavaScript">
				function alert_and_delete()
				{
					var confirmdelete = confirm("Click OK to permanently delete this record. You won't be able to undo this change...");
					if (confirmdelete == true)
					{
						document.all.DeleteRecord.value=1;
						// document.all.Deleted.value=1;
						document.MyForm.submit();
					}
				}
				
				function SubmitForm()
				{
					var isError = 0;
					var re = /\s/g; 
					var strRequirement_Name = document.MyForm.ProgramBidWonByDescription.value.replace(re, "");
					if (strRequirement_Name.length == 0)
					{
						alert("Please enter a description.");
						isError = 1;
					}
					if (isError == 0)
					{
						MyForm.submit();
					}
					return false;
				}
			
			</script>			
			<form action="competitive_data_Package.cfm" method="post" name="MyForm">
			<table cellspacing="5" cellpadding="0" border="0">
				<cfoutput>
				<tr>
					<td valign="top" align="right"><b>Code: </b></td>
					<td valign="top" colspan="2">
						<input size="25" name="ProgramBidWonByCode" value="#Get_Item.Program_Bid_Package_Code#" maxlength="25">
						<input type="hidden" name="Program_Bid_Package_ID" value="#Get_Item.Program_Bid_Package_ID#">
					</td>
				</tr>
        <tr>
					<td valign="top" align="right"><b>Description: </b></td>
					<td valign="top" colspan="2">
						<input size="35" name="ProgramBidWonByDescription" value="#Get_Item.Program_Bid_Package_Description#" maxlength="50">
					</td>
				</tr>				
 
				</cfoutput>
				<tr>
					<td valign="top" align="right"><b>Availability</b></td>
					<td valign="top" colspan="2">
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<!--- Get the number of projects that have this phase: If there is at least 1 project that is active and has this phase, then I will not allow the user to delete this phase --->
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						
						<!--- Is this record deleted? --->
						<cfif get_item.RecordCount GTE 1 AND (get_item.Active EQ 0 or get_item.Active EQ "")>
							<cfset active="">
							<cfset inactive=" CHECKED">
 						<cfelse>
							<cfset active=" CHECKED">
							<cfset inactive="">
 						</cfif>
						<cfoutput>
						<input type="radio" value="1" name="Active"#active#>Active&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" value="0" name="Active"#inactive#>Inactive 
						</cfoutput>
					</td>
				</tr>
				<tr>
					<td valign="top" align="right"></td>
					<td valign="top" nowrap width="15">
            <input type="hidden" name="DeleteRecord" value="0">
						<cf_button
							button_name	=	""
							button_caption	=	"save data"
							button_action	=	"return SubmitForm();"
							button_type	=	"javascript_link"
							button_width	=	"75"
							button_color	=	"Navy"
							button_tip	=	""
							font_color	=	"White"
							font_size		=	"12"
							font_weight	=	"bold"
						>
          </td>  
          <td>
          &nbsp;
            <cfif get_item.recordcount gt 0>
 								<font color="##ff0000" size="2"><b>[</b></font>
								<a href="javascript: alert_and_delete();"><b>delete data</b></a>
								<font color="##ff0000" size="2"><b>]</b></font>
							</cfif>		
					</td>
				</tr>
			</table>
			<input type="hidden" name="blnSubmit" value="1">
			</form>
		</td>
	</tr>
</table>
<b>	
<font color="##ff0000" size="2"><b>[</b></font>
	<a href="competitive_data_Package.cfm"><b>create new entry</b></a>
<font color="##ff0000" size="2"><b>]</b></font>
</b>
</cfmodule>
