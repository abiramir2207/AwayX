<!---
       Name:          BillbackUtilityAjax.cfc
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   This is a proxy for Ajax-related billback upload queries and tasks.
--->
 <cfcomponent extends="components.ajaxCFC.ajax">

	<cffunction name="getUploadDetails" output="no">
		<cfargument name="uploadID" type="any">
		<cfset var billbackUpload = CreateObject("component","components.billback.billbackuploadutility") />
		<cfset test = billbackUpload.getUploadDetailLog(arguments.uploadID) />
		<cfinvoke component="components.cfjson.json" method="encode" data="#test#" returnvariable="result" />
		<cfreturn result />
	</cffunction>

	<!--- name:  upload_billback_validate_sp
		  desc:  this procedure has two parts
				  1) Calls upload validation stored procedure
				  2) Reports file upload for validation status to the user via email.
		  notes: the stored procedure doesn't handle for header files with the
		         incorrect header format so this is used to quietly handle for this type of
				 error. Also, this function is called asynchronously to allow the user to
				 continue to work while validation is progress.
		--->
	<cffunction name="upload_billback_validate_sp" output="no">
		<cfargument	name="header_file_path" type="string" required="true" >
		<cfargument	name="detail_file_path" type="string" required="true" >
		<cfargument	name="user_id" type="string" required="true" >
		<cfargument	name="Billback_Upload_Business_Segment" type="numeric" required="false"><!--- D29947 Update billback upload for SO/DC  --->
		<cfargument	name="single_file_path" type="string" required="true" >
		<cfset var returnCode = "0">
		<cftry>
			<cfstoredproc procedure = "UPLOAD_BILLBACK_VALIDATE_SP" dataSource="#application.datasource#">
		   		<cfprocparam type="IN" CFSQLType="CF_SQL_LONGVARCHAR" value="#arguments.header_file_path#" variable="@headerRecord" />
		   		<cfprocparam type="IN" CFSQLType="CF_SQL_LONGVARCHAR" value="#arguments.detail_file_path#" variable="@detailRecord" />
		   		<cfprocparam type="IN" CFSQLType="CF_SQL_LONGVARCHAR" value="#arguments.user_id#" variable="@userCode" />
		   		<cfprocparam type="IN" CFSQLType="CF_SQL_LONGVARCHAR" value="#arguments.Billback_Upload_Business_Segment#" variable="@Billback_Upload_Business_Segment" /><!--- D29947 Update billback upload for SO/DC  --->
				<cfprocparam type="IN" CFSQLType="CF_SQL_LONGVARCHAR" value="#arguments.single_file_path#" variable="@singleRecord" />
			</cfstoredproc>

			<cfcatch type="any">
				<cfoutput>
					<cfset returnCode = 1 />
					<cfinvoke component="components.billback.billbackuploadutility" method="logUploadError">
						<cfinvokeargument name="error_message" value="File Format Error">
						<cfinvokeargument name="user_id" value="#request.accessstructure.user_id#">
					</cfinvoke>
			</cfoutput>
			</cfcatch>
		</cftry>

		<cfinvoke component="components.user.usermanager" method="getUserEmail" returnvariable="user_email">
			<cfinvokeargument name="userID" value="#arguments.user_id#">
		</cfinvoke>

		<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

		<cfoutput>


		<CF_EMAILWRAPPER TO	= "#request.AccessStructure.User_Email#"
        				 FROM		=	"#contact_admin_email_address#"
        				 SUBJECT	=	"Upload Validation Report"
						 TYPE		=	"html"
						 generatedBy="1"
						 appArea="1">

			Upload file validation <cfif returnCode EQ 0>is complete. Please return to the Billback Upload Utility to view validation results.<cfelse> failed.
			The upload files contained formatting errors which prevented them from being uploaded. Please verify format, header file and detail file order,  and upload them again.</cfif>
		</CF_EMAILWRAPPER>
		</cfoutput>

		<cfreturn returnCode />
	</cffunction>

	<!--- This procedure is called to identify whether the current user has upload
		  validations in progress --->
	<cffunction name="isValidating" output="no" access="public">
		<cfargument name="userid" type="string" required="true">

		<cfinvoke component="components.billback.billbackuploadutility" method="isValidating" returnvariable="qIsValidating">
			<cfinvokeargument name="userid" value="#arguments.userid#">
		</cfinvoke>

		<cfinvoke component="components.cfjson.json" method="encode" data="#qIsValidating#" returnvariable="result" />

		<cfreturn result />
	</cffunction>

	<!--- CFJSON: Method to Get Billbacks Associated to a Billback (for an Ajax call) --->
	<cffunction name="getRelatedBB">
		<cfargument name="upload_id" type="string" required="true">
		<cfargument name="upload_type_id" type="string" required="true">

		<cfinvoke component="components.billback.billbackuploadutility" method="getRelatedBB" returnvariable="recordset">
			<cfinvokeargument name="upload_id" value="#arguments.upload_id#">
            <cfinvokeargument name="upload_type_id" value="#arguments.upload_type_id#">
		</cfinvoke>

		<!--- cfinvoke component="components.cfjson.json" method="encode" argumentcollection="type=array" data="#recordset#" returnvariable="result" /--->

		<cfreturn recordset />
	</cffunction>

	<cffunction name="purge_upload">
			<cfargument name="upload_id" required="true" type="Numeric">
			<cfargument name="user_code" required="true" type="String">
		<cftry>
		<cfinvoke component="components.billback.billbackuploadutility" method="purge_upload">
			<cfinvokeargument name="upload_id" value="#arguments.upload_id#">
			<cfinvokeargument name="user_code" value="#arguments.user_code#">
		</cfinvoke>
		<cfcatch type="any">
			<cfmail to="developers@bigredflame.com" from="forgetrade@bigredflame.com" subject="purge failed">
				#cfcatch.ExtendedInfo#<br>#cfcatch.Detail#
			</cfmail>
		</cfcatch>
		</cftry>
		<cfset returnvar = "done">
		<cfreturn returnvar>
	</cffunction>

</cfcomponent>