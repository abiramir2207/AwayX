<!---Expected input parameters --->

<cfparam name="form.ComponentNameIDs" default="">

<cfquery name="InsertIntoBigBillbackSummary" datasource="#application.datasource#">
SET NOCOUNT ON
	INSERT INTO Big_Billback_Summary
	(
		Billback_ID,
		Program_ID,
		Discount_Type_ID,
		ComponentNameIDs
	)
	Values
	(
		'#form.Billback_ID#',
		'#form.Program_List#',
		'#form.Discount_Type_ID#',
		'#form.ComponentNameIDs#'
	)

SELECT Big_Billback_Summary_ID = @@IDENTITY
SET NOCOUNT OFF
</cfquery>

<!---Set file location --->
<cfinvoke
	component      = "components.billback.billbackuploadutility"
	method         = "getUploadPath"
	returnVariable = "variables.upload">

<cfscript>
	Big_Billback_Summary_ID  = InsertIntoBigBillbackSummary.Big_Billback_Summary_ID;

	// Identify unique file name
	UniqueGeneralName        = replace(request.AccessStructure.User_ID, "-", "_", "all") & dateformat(now(), 'mm_dd_mm_ss');
	UniqueFileName           = "BigBillback" & UniqueGeneralName & ".txt";

	variables.outputFilePath = variables.upload.File_Path & "\"  & UniqueFileName;
	ModifiedBulkData         = replace(form.BulkData, "#Chr(13)##Chr(10)#", "#Chr(9)##UniqueGeneralName##Chr(13)##Chr(10)#", "all");
</cfscript>


<!---Write file from form to server --->
<cffile action = "write"
	file       = "#variables.outputFilePath#"
	output     = "#trim(ModifiedBulkData)#">

<cfquery name="ExecuteSP" datasource="#application.datasource#">
	exec SP_BIG_BILLBACK_PROCESSING '#variables.outputFilePath#', '#Billback_ID#', '#request.AccessStructure.User_ID#', '#Big_Billback_Summary_ID#', '#UniqueGeneralName#'
</cfquery>

<script>
	try { window.parent.dyniframesize(); } catch (err) { };
</script>

<!--- Delete file from server --->
<cffile action = "delete"
	    file   = "#variables.outputFilePath#">

<!--- Go to display page with first 100 records, organized by the Error = 1 then by ID --->
<cfoutput>
	<cflocation url="bigbillback_validation.cfm?Billback_ID=#Billback_ID#&Big_Billback_Summary_ID=#Big_Billback_Summary_ID#">
</cfoutput>
