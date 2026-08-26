<cfset useLakebaseFordeleteBuckets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_aging_buckets")>
<cfif useLakebaseFordeleteBuckets>
	<cftry>
		<cfset application.oLakebase.deleteRows("deduction_aging_buckets", {})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteBuckets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteBuckets>
<cfquery name="deleteBuckets" datasource="#application.datasource#">
DELETE
FROM Deduction_Aging_Buckets
</cfquery>
</cfif>


<cfif len(trim(FORM.BUCKET_1_LABEL)) GT 0>
	<cfquery name="saveBuckets" datasource="#application.datasource#">
		INSERT INTO Deduction_Aging_Buckets
		(Bucket_Label, Start_range, End_Range, Last_Updated)
		VALUES
		('#FORM.BUCKET_1_LABEL#', '#FORM.Bucket_1_Start#', '#FORM.Bucket_1_End#', getdate())
	</cfquery>
</cfif>

<cfif len(trim(FORM.BUCKET_2_LABEL)) GT 0>
	<cfquery name="saveBuckets" datasource="#application.datasource#">
		INSERT INTO Deduction_Aging_Buckets
		(Bucket_Label, Start_range, End_Range, Last_Updated)
		VALUES
		('#FORM.BUCKET_2_LABEL#', '#FORM.Bucket_2_Start#', '#FORM.Bucket_2_End#', getdate())
	</cfquery>
</cfif>

<cfif len(trim(FORM.BUCKET_3_LABEL)) GT 0>
	<cfquery name="saveBuckets" datasource="#application.datasource#">
		INSERT INTO Deduction_Aging_Buckets
		(Bucket_Label, Start_range, End_Range, Last_Updated)
		VALUES
		('#FORM.BUCKET_3_LABEL#', '#FORM.Bucket_3_Start#', '#FORM.Bucket_3_End#', getdate())
	</cfquery>
</cfif>

<cfif len(trim(FORM.BUCKET_4_LABEL)) GT 0>
	<cfquery name="saveBuckets" datasource="#application.datasource#">
		INSERT INTO Deduction_Aging_Buckets
		(Bucket_Label, Start_range, End_Range, Last_Updated)
		VALUES
		('#FORM.BUCKET_4_LABEL#', '#FORM.Bucket_4_Start#', '#FORM.Bucket_4_End#', getdate())
	</cfquery>
</cfif>

<cfif len(trim(FORM.BUCKET_5_LABEL)) GT 0>
	<cfquery name="saveBuckets" datasource="#application.datasource#">
		INSERT INTO Deduction_Aging_Buckets
		(Bucket_Label, Start_range, End_Range, Last_Updated)
		VALUES
		('#FORM.BUCKET_5_LABEL#', '#FORM.Bucket_5_Start#', '#FORM.Bucket_5_End#', getdate())
	</cfquery>
</cfif>

<CFLOCATION URL="aging_buckets.cfm" ADDTOKEN="No">