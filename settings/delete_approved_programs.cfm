<!---
  * ==================================================================================================== 
  *    @File: \settings\delete_approved_programs.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2018-07-26 10:23:01
  * 
  * @Remarks:   
  *
  *
  * 
  *  
  * ==================================================================================================== 
--->
<cfparam name="form.action"          default="">
<cfparam name="form.contract_number" default="">
<cfparam name="form.contract_status" default="">
<cfparam name="form.selecteditems"   default="">
<!DOCTYPE HTML>
<html>
<body>
<style>
	tr.row:hover {
		background-color: #F6F6F6;
	}
</style>

<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/styles/css-loader.css, /common_files/dataTable.css">

<!--- If cancelling programs, cancel the list of programs --->
<cfoutput>
<cfif form.action is "delete">
	<!--- <cfdump var="#form#" abort="true"> --->
	<cfquery datasource="#application.datasource#">
		UPDATE Contract_Main
		   SET Deleted      = 1
		     , Deleted_Date = GETDATE()
		     , Deleted_By   = '#request.AccessStructure.User_ID#'
		 WHERE Contract_Main_ID IN (#Form.SelectedITEMS#)   
	</cfquery>

	<!--- Show the list of deleted programs --->
	<CFQUERY NAME="show_deleted_programs" DATASOURCE="#Application.Datasource#">
		SELECT 		Contract_Main_ID,
					Contract_Reference_Number,
					Contract_Number,
					Contract_Status_Type_Desc,
					Contract_Title,
					Contract_Start_Date,
					Contract_End_Date,
					_Users.Name_First + ' ' + _Users.Name_Last Responsible_User_Name
		FROM 		Contract_Main 
		INNER JOIN 	Contract_Status_Types
		ON 			Contract_Main.Contract_Status_Type_IDX = Contract_Status_Types.Contract_Status_Type_ID
		LEFT JOIN 	_Users
		ON 			_Users.User_ID = Responsible_user_ID
		WHERE 		Contract_Main_ID IN (#Form.SelectedITEMS#)
		ORDER BY 	Contract_Number
	</CFQUERY> 

	<p>
		The following programs were deleted:
	</p>
	<table border="0" cellpadding="2" cellspacing="0" width="75%" class="datagrid" align="center">
		<thead>
			<tr>
				<th>Program</th>
				<th>Title[Reference]</th>
				<th>Start Date</th>
				<th>End Date</th>
			</tr>
		</thead>
		<tbody>
			<cfloop QUERY="show_deleted_programs">				
				<TR VALIGN="top" class="row">						
					<TD NOWRAP>#Contract_Number#</TD>
					<TD>#Contract_Title# <cfif Len(Contract_Reference_Number)>[#Contract_Reference_Number#]</cfif>
						<cfif application.returned_customer_setting.Responsible_Person EQ 1>
							<br>SP:#Responsible_User_Name#
						</cfif>
					</TD>
					<TD NOWRAP>#DateFormat(Contract_Start_Date, "medium")#</TD>
					<TD NOWRAP>#DateFormat(Contract_End_Date, "medium")#</TD>
				</TR>
			</cfloop>											
		</tbody>
	</table> 

<!--- Show the page to select programs or the list of selected programs to cancel --->
<cfelse>
	<form name="delete_program" method="post">

	<input type="hidden" name="action">
	<input type="hidden" name="Contract_Number" value="#form.contract_number#">
	<input type="hidden" name="Contract_Status" value="#form.contract_status#">
	<input type="hidden" name="abc">

	<p style="text-align:center">
		<b>Delete Approved Programs</b>
		<br><br>
		<a href="javascript:dis_program();">#application.util.string.actionLinkFormat2("search programs")#</a>
		<cfif form.contract_number neq "">
			<a href="javascript:delete_program()" style="margin-left:20px">#application.util.string.actionLinkFormat2("delete")#</a>
		</cfif>
	</p>
	<CFIF form.Contract_Number neq "">
		<CFQUERY NAME="List_program" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_Main_ID,
						Contract_Reference_Number,
						Contract_Number,
						Contract_Status_Type_Desc,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						_Users.Name_First + ' ' + _Users.Name_Last Responsible_User_Name
			FROM 		Contract_Main 
			INNER JOIN 	Contract_Status_Types
			ON 			Contract_Main.Contract_Status_Type_IDX = Contract_Status_Types.Contract_Status_Type_ID
			LEFT JOIN 	_Users
			ON 			_Users.User_ID = Responsible_user_ID
			WHERE 		Contract_Main_ID IN (#FORM.Contract_Number#)
			ORDER BY 	Contract_Number
		</CFQUERY> 
		<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" CLASS="datagrid">
			<CFIF List_Program.recordcount GT 0>
				<thead>
					<TR>
						<th><input TYPE="checkbox" NAME="allbox" checked></th>
						<th>Status</th>
						<th>Program</th>
						<th>Title[Reference]</th>
						<th>Start Date</th>
						<th>End Date</th>
					</TR>
				</thead>
				<tbody>
					<cfloop QUERY="List_program"><!---  startrow="#StartRow#" maxrows="#MaxRows#" --->					
						<TR class="row">
							<TD><INPUT TYPE="Checkbox" class="row" NAME="SelectedITEMS" VALUE="#Contract_Main_ID#" CHECKED>&nbsp;</TD>
							<TD NOWRAP>#Contract_Status_Type_Desc#&nbsp;&nbsp;</TD>								
							<TD NOWRAP>#Contract_Number#&nbsp;&nbsp;</TD>
							<TD>#Contract_Title# <cfif Len(Contract_Reference_Number)>[#Contract_Reference_Number#]</cfif>
								<cfif application.returned_customer_setting.Responsible_Person EQ 1>
									<br>SP:#Responsible_User_Name#
								</cfif>
							</TD>
							<TD NOWRAP>#DateFormat(Contract_Start_Date,"medium")#</TD>
							<TD NOWRAP>#DateFormat(Contract_End_Date,"medimum")#</TD>
						</TR>
					</cfloop>											
				</tbody>
			</CFIF>							
		</TABLE> 
		<!--- <hr class="two"> --->
		<cfif list_program.recordCount gt 20>
			<p style="text-align:center">
				<a href="javascript:delete_program()">#application.util.string.actionLinkFormat2("delete")#</a>
			</p>
		</cfif>
	</CFIF>
	</FORM>
</cfif>
</cfoutput>
<script>
	function dis_program() {
		NewWindow("/Search_Screens/Program_Search.cfm?FormName=delete_program&FieldName=Contract_Number&ReturnFieldName=Contract_Main_ID&AllowImportAll=0&Disable_Locked=1&Contract_Status=1", 'pro_search', '800', '600', 'Yes', 'No', true);		
	}

	function delete_program() {	
		if ($("input.row:checked").length == 0) {
			alert("Please select at least one program to delete.");
			return false;
		}
		if (confirm("Are you sure you want to delete the selected programs?")) {
			show_loader();
			$("input[name=action]").val("delete");
			document.delete_program.submit();
		}
	}

	$("input[name=allbox]").click(function(){
		if ($(this).is(":checked")) {
			$("input.row").attr("checked", "checked");
		}
		else {
			$("input.row").removeAttr("checked");
		}
	});
</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>