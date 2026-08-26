<cfsilent>
<!---
       Name:          displayGrid.cfm
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.
       Created Date:  12/01/2010
       Created By:    Kal
       Label:		  25195
       Description:   Mass Program Change Upload Utility
--->
</cfsilent>

<!--- Show Grid to edit the errors --->
<script type="text/javascript">
	function submitGridForm(){
		var thisForm = document.all.displayGridForm;
		thisForm.value ='1'
		thisForm.submit();
		return false;
	}
</script>

<!--- if grid is submitted the update the grid --->
<cfif IsDefined("form.submitGrid") is True>
	<!--- Dev Note: KAL; D26396: Event errors when running job to mass revise programs 
		  Removed the grid update tag as it was not finding the program grid sometimes.
		  Added the code below in the cfc to manually do the update.
	--->
	<cfif isDefined("form.ProgramChangeGrid.RowStatus.Action") AND ArrayLen(form.ProgramChangeGrid.RowStatus.Action)>
		<cfgridupdate grid = "ProgramChangeGrid" datasource="#application.datasource#" tableName = "MPCU_Data">
		<!---
			<cfset colNamesList = "CONTRACT_NUMBER,CONTRACT_TITLE,CONTRACT_START_DATE,CONTRACT_END_DATE,COMPONENT_ID,DISCOUNT_TYPE,ITEM,PRICE,UOM,VOLUME,CURRENCY,NOTES" />
			<cfset temp = MPCUManager.updateGridDataAll("PROGRAMCHANGEGRID", colNamesList, form) /> 
		--->
	</cfif>
	
	<!--- validate the data --->
	<cfstoredproc procedure="USP_Program_Upload_Validate" datasource="#application.datasource#">
		<cfprocparam cfsqltype = "cf_sql_varchar" type = "in" value="#variables.updateType#">
	</cfstoredproc>
</cfif>

<!--- set the data to a variable for the grid --->
<cfset gridData = MPCUManager.getErrorRecords() />

<cfform id="displayGridForm" name="displayGridForm" action="index.cfm">
	<fieldset>
		<legend class="buttonText" >Validation Errors:
			<CF_SmallHelp
		        displayShifyX="10"
		        displayShifyY="-100"
		        imgHeight="11"
						imgWidth="11"
		        imgPath="/Images/i.gif"
		        width="750">
			        <div class="helpInfo">
			        	<b>Validation Rules:</b><br/>
						1.	If the end date of an existing program is prior to the start date of the uploaded program, the record the record would fail validation.<br/>
						2.	If the start date of an existing program is after the end date of the uploaded program, the record would fail validation.<br/>
						3.	If a program being revised has a version that is currently in WIP or RFA status, the record would fail validation.<br/>
						4.	If the UOM is not CS or LBS, the record would fail validation.<br/>
						5.	If the end date of an existing program is after the effective end date in the upload, end date from the upload will be used.
					</div>
	    	</CF_SmallHelp>
		</legend>

		<cfgrid name="ProgramChangeGrid"
		 query="gridData"
		 selectmode="edit"
		 colheaders="false"
		 colheaderbold="true"
		 autowidth="true"
		 width="1000"
		 height="400"
		 striperows="true"
		 striperowcolor="##CCFFCC"
		 delete="true"
		 deletebutton="<b>delete row</b>"
		 insert="true"
		 insertbutton="<b>insert row</b>"
		 format="html"
		 sort="false" selectOnLoad="no">
			<cfgridcolumn name="MPCU_Data_ID" header="ID" select="true" width="25" >
			<cfgridcolumn name="contract_number" header="PROGRAM"  width="60">
			<cfgridcolumn name="contract_title" header="TITLE"  width="60">
			<cfgridcolumn name="contract_start_date" header="START DATE"  width="60">
			<cfgridcolumn name="contract_end_date" header="END DATE"  width="60">
			<cfgridcolumn name="component_id" header="COMPONENT"  width="60">
			<cfgridcolumn name="discount_type" header="TYPE" width="25">
			<cfgridcolumn name="item" header="ITEM"  width="60">
			<cfgridcolumn name="price" header="PRICE"  width="25">
			<cfgridcolumn name="uom" header="UOM"  width="25">
			<cfgridcolumn name="volume" header="VOLUME"  width="25">
			<cfgridcolumn name="currency" header="CURRENCY"  width="50" display="false" >
			<cfgridcolumn name="notes" header="NOTES" width="60">
		</cfgrid>
		<br/>

		<!--- error detail grid --->
		<cfgrid name="errorGrid"
		 autowidth = "true"
		 striperows="true"
		 striperowcolor="##CCFFCC"
		 format="html"
		 bind="cfc:mvc.Models.Program.Upload.MassProgramChange.getErrorDetails({ProgramChangeGrid.MPCU_Data_ID},{cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})"
		 bindonload="false">
			<cfgridcolumn name="Error_Column" header="Error Column" width="100">
			<cfgridcolumn name="Error_Msg" header="Error Detail" width="300">
		</cfgrid>
		<br/>

		<!--- submit button --->
		<cfinput name="submitGrid" type="hidden" value="0">

		<div align="left" width="100%" class="buttonText">
				<span class="redBracket">[</span><a href="##" onclick="javascript:submitGridForm();">update data</a><span class="redBracket">]</span>
		</div>
		<br/><br/>
	</fieldset>

</cfform>
