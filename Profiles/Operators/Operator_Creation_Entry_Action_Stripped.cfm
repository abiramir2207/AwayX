<CFPARAM NAME="FORM.zzz_Operator_Phone" 		DEFAULT="">
<CFPARAM NAME="Operator_Phone" 					DEFAULT="">
<cfparam name="Action" 							DEFAULT="add">
<cfparam name="FinalItemList"					DEFAULT="">
<cfparam name="Legacy_ID"						DEFAULT="">
<cfparam name="Source"							DEFAULT="">
<cfparam name="Display_code"							DEFAULT="">
<cfparam name="Notes"							DEFAULT="">
<cfparam name="form.q_brand_legacy"				DEFAULT="">
<CFPARAM NAME="FORM.Business_Segment" default="0" >

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>


<!--- Check for duplicate operators only when a Legacy ID exists (Milan - 8961) --->
<cfset IsOperatorExist = 0>
	<CFIF Legacy_ID NEQ "">
			<!--- Start - Dev Note(73064) - When a user "edits" a record and enters a LegacyID which already exists for another operator, then do not allow it. --->
			<cfif Action eq "edit" AND ISDefined("form.BSA_Operator_ID") AND form.BSA_Operator_ID NEQ "">
				<cfquery name="checkOtherOprExistsSameLegacyID" datasource="#application.datasource#">
					SELECT	Legacy_ID,BSA_Operator_id
					FROM 	BSA_Operator
					WHERE	Legacy_ID = <cfqueryparam value="#trim(Legacy_ID)#" cfsqltype="CF_SQL_VARCHAR">
					AND	BSA_Operator_ID != '#form.BSA_Operator_ID#'
				</cfquery>

				<cfif checkOtherOprExistsSameLegacyID.recordcount>
					<div class="error" style="height:15px;">
					<p>
					<cfoutput>
					<b>&nbsp;The #application.returned_customer_setting.Operator_Legacy_Id_label#:
					#legacy_id# that you have entered already exists. <br /> There cannot be more than
					one #lcase(application.returned_customer_setting.operator_label_singular)# with the same 
					#application.returned_customer_setting.Operator_Legacy_Id_label#.
					</cfoutput> 
					</p>
					</div>
					<br />
					<cfoutput><a href="/profiles/operators/operator_creation_entry_form_stripped.cfm?OID=#trim(form.BSA_Operator_ID)#&Action=Edit" style="font-size:10px;">#application.util.string.actionLinkFormat2("go back to change info")#</a></cfoutput>
					<cfabort>
				</cfif>
			</cfif>
			<!--- End - Dev Note(73064) - When a user "edits" a record and enters a LegacyID which already exists for another operator, then do not allow it. --->

		<cfquery name="checkoprexists" datasource="#application.datasource#">
			SELECT	Legacy_ID,BSA_Operator_id
			FROM 	BSA_Operator
			WHERE	Legacy_ID = <cfqueryparam value="#trim(Legacy_ID)#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
				<cfset IsOperatorExist = checkoprexists.recordcount>
	<CFELSE>
				<cfset IsOperatorExist = 0>
	</CFIF>

<!--- Active operators is Display_code = 'A" and Deleted = 0. For InActive ones, the difference is the deleted bit only  (Milan - 8961) --->
	<CFIF Display_code EQ "A">
		<CFSET Deleted = 0>
	<CFELSEIF Display_code EQ "N">
			<CFSET Deleted = 1>
	</CFIF>

<!--- application setting saying whether they're allowed to add an operator to the database directly, or need to send an email or both (0- for email,1- for update database, 2- for both) --->
<cfif appSettings.getAllowed_to_Add_Operator() IS 1 OR appSettings.getAllowed_to_Add_Operator() IS 2 OR Source IS "Management">

	<cfif Action IS "Add">

		<cfif IsOperatorExist EQ 0 OR application.returned_customer_setting.operator_legacy_id_on EQ 0>
		  <!---
            Dev Notes: Anand Rao/04-Feb-10
            Changed the @@IDENTITY to SCOPE_IDENTITY() as @@IDENTITY does not return the expected value
            when the table has triggers on them. In this case the @@IDENTITY was returning 1 all the time
      --->
			<cfquery name="InsertIntoDB" datasource="#application.datasource#">
			SET NOCOUNT ON
			INSERT INTO BSA_Operator
			(
				OPERATOR_NAME,
				OPERATOR_ADDRESS,
				OPERATOR_CITY,
				OPERATOR_STATE,
				OPERATOR_ZIP,
				OPERATOR_Country_Code,
				OPERATOR_NUMBER_OF_LOCATIONS,
				OPERATOR_TYPE,
				OPERATOR_LOCATION_TYPE,
				OPERATOR_DBA,
				OPERATOR_FIRST_NAME,
				OPERATOR_LAST_NAME,
				OPERATOR_TITLE,
				zzz_Operator_Phone,
				Operator_Phone,
				User_Added,
				Legacy_ID,
				Display_code,
				DELETED,
				Added_By,
				Notes,
				Q_Brand_Legacy,
				Contact_Address,
				Contact_City,
				Contact_State,
				Contact_Zip,
				Contact_Email,
				Business_Segment_ID
			)
			VALUES
			(	/* Replace any accent characters. eg: "�" with "E". */
				DBO.removeAccentCharacters('#OPERATOR_NAME#'),
				'#OPERATOR_ADDRESS#',
				'#OPERATOR_CITY#',
				'#OPERATOR_STATE#',
				'#OPERATOR_ZIP#',
				'#OPERATOR_Country_Code#',
				'#OPERATOR_NUMBER_OF_LOCATIONS#',
				'#OPERATOR_TYPE#',
				'#OPERATOR_LOCATION_TYPE#',
				'#OPERATOR_DBA#',
				'#OPERATOR_FIRST_NAME#',
				'#OPERATOR_LAST_NAME#',
				'#OPERATOR_TITLE#',
				'#zzz_Operator_Phone#',
				'#Operator_Phone#',
				1,
				'#Legacy_ID#',
				'A',
				#Deleted#,
				'#request.AccessStructure.User_ID#',
				'#Notes#',
				'#form.q_brand_legacy#',
				'#form.contact_address#',
				'#form.contact_city#',
				'#form.contact_state#',
				'#form.contact_zip#',
				'#form.contact_email#',
				#form.Business_Segment#
			)

			SELECT BSA_Operator_ID = SCOPE_IDENTITY()
			SET NOCOUNT OFF
			</cfquery>

			<cfset BSA_Operator_ID = InsertIntoDB.BSA_Operator_ID>
				<!--- Dev Note (Milan - 41132)
				If the client does not use "Legacy_ID", then update "Legacy_ID" to be the same as BSA_Operator_ID.
				This is useful in the flex operator alias tool.
				--->
				<cfif application.returned_customer_setting.operator_legacy_id_on eq 0>
					<cfquery name="UpdateOperator" datasource="#application.datasource#">
						UPDATE BSA_Operator
							SET Legacy_ID = BSA_Operator_ID
						WHERE BSA_Operator_ID = #BSA_Operator_ID#
					</cfquery>
				</cfif>

		<!---Legacy ID is turned on and there is a duplicate --->
		<cfelse>
			<cfset BSA_Operator_ID = checkoprexists.BSA_Operator_ID>
		</cfif>

	<!---You should update --->
	<cfelse>
		<cfquery name="UpdateOperator" datasource="#application.datasource#">
		UPDATE BSA_Operator						/* Replace any accent characters. eg: "�" with "E". */
		SET OPERATOR_NAME 					= 	DBO.removeAccentCharacters('#OPERATOR_NAME#'),
			OPERATOR_ADDRESS				= 	'#OPERATOR_ADDRESS#',
			OPERATOR_CITY					= 	'#OPERATOR_CITY#',
			OPERATOR_STATE					= 	'#OPERATOR_STATE#',
			OPERATOR_ZIP					= 	'#OPERATOR_ZIP#',
			OPERATOR_Country_Code			= 	'#OPERATOR_Country_Code#',
			OPERATOR_NUMBER_OF_LOCATIONS	= 	'#OPERATOR_NUMBER_OF_LOCATIONS#',
			OPERATOR_TYPE					= 	'#OPERATOR_TYPE#',
			OPERATOR_LOCATION_TYPE			= 	'#OPERATOR_LOCATION_TYPE#',
			OPERATOR_DBA					= 	'#OPERATOR_DBA#',
			OPERATOR_FIRST_NAME				= 	'#OPERATOR_FIRST_NAME#',
			OPERATOR_LAST_NAME				= 	'#OPERATOR_LAST_NAME#',
			OPERATOR_TITLE					= 	'#OPERATOR_TITLE#',
			zzz_Operator_Phone				= 	'#zzz_Operator_Phone#',
			Operator_Phone					= 	'#Operator_Phone#',
			<cfif application.returned_customer_setting.operator_legacy_id_on eq 1>
			Legacy_ID						=	'#Legacy_ID#',
			</cfif>
			Display_code					=	'A',
			Deleted							=	#Deleted#,
			User_Date_Edited				= 	getdate(),
			Edited_By						= 	'#request.AccessStructure.User_ID#',
			Notes							= 	'#Notes#',
			Q_Brand_Legacy					=   '#form.q_brand_legacy#',
			Contact_Address                 =   '#form.contact_address#',
			Contact_City                    =   '#form.contact_city#',
			Contact_State                   =   '#form.contact_state#',
			Contact_Zip                     =   '#form.contact_zip#',
			Contact_Email                   =   '#form.contact_email#',
			Business_Segment_ID			= #form.Business_Segment#
		WHERE BSA_Operator_ID 				= 	'#BSA_Operator_ID#'
		</cfquery>

	<!---Update or insert--->
	</cfif>
</cfif>

<!---Add to database or email--->
<cfif Source IS NOT  "Management" AND (appSettings.getAllowed_to_Add_Operator() IS 0 OR appSettings.getAllowed_to_Add_Operator() IS 2)>

	<!---Get address to send it to--->
	<cfquery name="GetOperatorAdmin" datasource="#application.datasource#">
		SELECT User_Email
		FROM _Users
			INNER JOIN General_Settings
			ON General_Settings.Operator_Admin_ID = _Users.User_ID
		WHERE _Users.Deleted = 0
		AND	General_Settings.Operator_Admin_ID != '#request.AccessStructure.User_ID#'
	</cfquery>

	<cfif GetOperatorAdmin.RecordCount GT 0 > <!--- Dev Note: KAL; Send out email only if the user is not the admin to add operator : 9807  --->
		<cfset Email_To = GetOperatorAdmin.User_Email>
		<cfoutput>

			<cfif action IS "add">
				<cfset Actionverb = "add">
			<cfelse>
				<cfset Actionverb = "modify">
			</cfif>

			<CF_EMAILWRAPPER TO			=	"#Email_To#"
			        FROM		=	"#request.AccessStructure.User_Email#"
			        SUBJECT		=	"Request to #Actionverb# an operator"
					TYPE		=	"html"
					messagetype="1"
					generatedby="3"
					apparea="1"
					userid="#request.AccessStructure.user_id#">

					#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# has requested to have the following operator <cfif action IS "add">added<cfelse>modified</cfif>:
					<p></p>
						#OPERATOR_NAME#<Br>
						#OPERATOR_ADDRESS#<br>
						#OPERATOR_CITY# #OPERATOR_STATE#  #OPERATOR_ZIP#'<Br>
						#OPERATOR_Country_Code# #zzz_Operator_Phone#<Br>
						Number of locations: #OPERATOR_NUMBER_OF_LOCATIONS#<br>
						Operator Type: #OPERATOR_TYPE#<Br>
						Operator Location Type:	 #OPERATOR_LOCATION_TYPE#<br>
						Doing Business As: #OPERATOR_DBA#<Br>
						Contact Person: #OPERATOR_FIRST_NAME# #OPERATOR_LAST_NAME# #OPERATOR_TITLE#<br>
						Contact_Phone: #Operator_Phone#
					<p></p>

			</CF_EMAILWRAPPER>

		</cfoutput>
	</cfif> <!--- End <cfif GetOperatorAdmin.RecordCount GT 0 > --->
	<!---Add to database or email--->
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><cfoutput>#application.returned_customer_setting.operator_label_singular# </cfoutput> <cfif action IS "add">Created<cfelse>Modified</cfif></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">

</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" >
<div id="content">
<BR>


<style>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
input,select, TEXTAREA
	{
		width:	200px;
		font-size: 10px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 10px;
	}
div#content {
	width:100%;
	margin:0 3%;
}
tr {
	height: 18px;
}
</style>
<link rel="stylesheet" type="text/css" href="/common_files/feedback.css">




<!--- <B>The following information <cfif appSettings.getAllowed_to_Add_Operator() IS 1 and checkoprexists.recordcount EQ 0>was saved<cfelse>has been submitted</cfif></B> --->

<cfif IsOperatorExist EQ 0 OR application.returned_customer_setting.operator_legacy_id_on EQ 0  OR Action IS NOT "add">
	<div class="success" style="height:15px;">
	<p>
		<cfif action IS "Add">&nbsp;Your information was<cfelse>&nbsp;Your changes were</cfif>

		<cfif appSettings.getAllowed_to_Add_Operator() neq 2>
			<cfif appSettings.getAllowed_to_Add_Operator() IS 1 OR Source IS "Management">saved<cfelse>submitted for approval</cfif>
		<cfelse>
			<cfif Source IS "Management">saved<cfelse>saved and submitted for approval</cfif>
		</cfif>
	</p>
	</div>
</cfif>

<cfif IsOperatorExist GT 0 AND application.returned_customer_setting.operator_legacy_id_on EQ 1 and Action IS "Add">
	<div class="error" style="height:15px;">
<p>
<b>&nbsp;The <cfoutput>#application.returned_customer_setting.Operator_Legacy_Id_label#:
#legacy_id#</cfoutput> that you have entered already exists. This new
<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> will
not be saved because duplicates cannot be created.</b>
</p>
	</div>
</cfif>

<TABLE style="width:100%">

<CFOUTPUT>
    <TR>
    <TD valign="top" style="width:30%"><B> #application.returned_customer_setting.operator_label_singular# Name: </B></TD>
    <TD>
		#Form.Operator_Name# <cfif appSettings.getAllowed_to_Add_Operator() IS 1 OR appSettings.getAllowed_to_Add_Operator() IS 2>[#BSA_Operator_Id#]</cfif>
	</TD>
	</TR>
	<cfif application.returned_customer_setting.operator_legacy_id_on>
		<tr><td valign="top"><strong>#application.returned_customer_setting.Operator_Legacy_Id_label#:</strong></td>
			<td valign="top">#Legacy_ID#</td>
		</tr>
		</cfif>
</CFOUTPUT>

	<cfif appSettings.getOperatorQBrandLegacy() neq "0">
		<cfoutput>
		<cfquery name="variables.qBrand" datasource="#application.datasource#">
			SELECT Q_Brand
		  	  FROM Q_BRAND_DESC
		     WHERE Deleted = 0 AND Q_Brand_Legacy = '#form.q_brand_legacy#'
		</cfquery>
		<tr>
		   	<TD valign="top"><B>#application.returned_customer_setting.Q_Brand_Label_Singular#:</B></TD>
    	   	<TD>#(variables.qBrand.recordCount gt 0 ? variables.qBrand.Q_Brand : "NOT SELECTED")#</TD>
		</tr>
		</cfoutput>
	</cfif>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START--->
<cfset businessSegManager= CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegManagerinfo =businessSegManager.get(Form.Business_Segment) />
<cfset OperatorSegEnable = businessSegManager.isEnabledForOperator()/>
	<cfif OperatorSegEnable>
		<cfoutput>
			<TR>
				<TD valign="top"><B> #appSettings.getbusiness_segment_label()#: </B></TD>
				<TD><CFOUTPUT>#businessSegManagerinfo.Business_Unit_Desc#</CFOUTPUT></TD>
			</TR>
		</cfoutput>
	</cfif>
 <!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END--->
    <TR>
    <TD valign="top"><B> Address: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Address#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> City, State, Postal Code: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_City#</CFOUTPUT>,
		<CFOUTPUT>#Form.Operator_State#</CFOUTPUT>,
		<CFOUTPUT>#Form.Operator_Zip#</CFOUTPUT>
	</TD>
	</TR>

	<TR>
    <TD valign="top"><B> Country: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Country_Code#</CFOUTPUT>
	</TD>
	</TR>

	 <TR>
    <TD valign="top"><B> Phone: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Phone#</CFOUTPUT>
	</TD>
	</TR>

	<TR>
    <TD valign="top"><B> Number of locations: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Number_Of_Locations#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> Type & Location: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Type#</CFOUTPUT>,
		<CFOUTPUT>#Form.Operator_Location_Type#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> Doing Buisness As: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_DBA#</CFOUTPUT>
	</TD>
	</TR>

	<TR>
    <TD valign="top"><B>Activation Status: </B></TD>
    <TD>
		<cfif DISPLAY_CODE eq 'A'>Active<cfelse>InActive</cfif>
	</TD>
	</TR>
	<cfoutput>
    <tr><td colspan="2"><hr></td></tr>
	<tr><td><b>Contact Person:</b> </td> <td>#form.Operator_First_Name# #Form.Operator_Last_Name# <cfif len(form.Operator_Title)>(#FORM.Operator_Title#)</cfif></td></tr>
	<tr><td><b>Address:</b> </td> <td>#form.contact_address#</td></tr>
	<tr><td><b>City, State, Postal Code:</b> </td> <td>#form.contact_city# <cfif form.contact_state neq '0'>#form.contact_state#</cfif> #form.contact_zip# </td></tr>
	<tr><td><b>Email:</b> </td> <td>#form.contact_email#</td></tr>
	<tr><td><b>Phone:</b> </td> <td>#form.zzz_Operator_Phone#</td></tr>
	</cfoutput>
</TABLE>
<BR>

<DIV ALIGN="center">
 <cfif IsOperatorExist eq 0>
<cfoutput>	<CF_smallLink
	title = "close window"
	url = "##"
	parameters = "onClick=""javascript: HomeRefresh();"""
	>
	<cfif appSettings.getAllowed_to_Add_Operator() IS 1 OR appSettings.getAllowed_to_Add_Operator() IS 2>
	<cfif Source IS NOT "Management">
		<cfif Action IS "Add" >
	&nbsp; &nbsp; &nbsp; &nbsp;
	<CF_smallLink
	title = "add <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput> to program"
	url = "##"
	parameters = "onClick=""javascript: addOpToProgram();"""
	>
	</cfif>
	</cfif>
	</cfif>
	</cfoutput>
	<cfelse>
	&nbsp; &nbsp; &nbsp; &nbsp;
	<cfoutput><a href="/profiles/operators/operator_creation_entry_form_stripped.cfm?OID=#trim(BSA_Operator_ID)#&Action=Edit">#application.util.string.actionLinkFormat2("go back to change info")#</a></cfoutput>
	</cfif>
	</DIV>
</div>
</BODY>
</HTML>
<cfoutput>

<cfif appSettings.getAllowed_to_Add_Operator() IS 1 OR appSettings.getAllowed_to_Add_Operator() IS 2>
<cfset FinalItemList = listappend(FinalItemList, BSA_Operator_ID)>
</cfif>


<script>
function addOpToProgram()
{
		opener.document.all.MyForm.LoadSavedOperators.value = 0;
		opener.document.all.MyForm.DoSearch.value = 0;
		opener.document.all.MyForm.FinalItemList.value = "#FinalItemList#";
		opener.document.all.MyForm.submit()

		window.close()

}

function HomeRefresh()

{
	opener.document.all.MyForm.DoSearch.value = 0;
	opener.document.all.MyForm.LoadSavedOperators.value = 1;
	opener.document.all.MyForm.submit()

	window.close()
}
</script>
</cfoutput>