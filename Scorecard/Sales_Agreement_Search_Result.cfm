<CFPARAM name="Form.IFRAME_Extra_URL" 	default="">
<CFPARAM name="Form.PL_PostSubmit" 		default="">
<CFPARAM name="Form.PL_PreSubmit" 		default="">
<CFPARAM name="Form.PL_Final" 			default="">
<CFPARAM name="Form.PL_ImportProducts"  default="0">
<CFPARAM name="Form.PL_ImportAllProducts"  default="0">
<CFPARAM name="printresults" default="0">
<CFPARAM name="URL.SearchIsConductedFromOtherWindow" default="0">

<cfif url.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?ShowCheckBoxes=1&SearchIsConductedFromOtherWindow=1">

	<cf_List_Compare List1="#Form.PL_PostSubmit#" List2="#Form.PL_PreSubmit#">
	
	<cfif listlen(trim(LC_Results1)) GT 0>
		<CFSET Form.PL_Final = listappend(Form.PL_Final, LC_Results1)>
	</cfif>
	
	<cfif listlen(trim(LC_Results2)) GT 0>
		<cfloop index="x" list="#LC_Results2#">
			<CFSET ItemPosition = listfind(Form.PL_Final, x)>
			<cfif ItemPosition NEQ 0>
				<cfset Form.PL_Final = listdeleteAt(Form.PL_Final, ItemPosition)>
			</cfif>
		</cfloop>
	</cfif>
	
</cfif>

<cfif form.PL_ImportProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#Form.PL_Final#';
		window.close();
	</script>
	</cfoutput>
<cfabort>
</cfif>

<cfif form.PL_ImportAllProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#form.PL_AllProductList#';
		window.close();
	</script>
	</cfoutput>
</cfif>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFINCLUDE TEMPLATE="Tables_Measures.cfm">

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">

<CFIF isdefined("FORM.DOSEARCH")>

<CFSET PW_Type="1">
 <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
  <br><br><br>
   <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
  <br><br><br>
 </SPAN>
<CFFLUSH>
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFPARAM NAME="FORM.Status" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Start_date" DEFAULT="">
<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.End_date" DEFAULT="">
<CFPARAM NAME="FORM.Agreement_Title" DEFAULT="">
<CFPARAM NAME="FORM.Agreement_Number" DEFAULT="">
<CFPARAM NAME="FORM.User_Position_Operator" 	DEFAULT="">
<CFPARAM NAME="FORM.User_Position_Of" 	DEFAULT="">
<CFPARAM NAME="FORM.User_Position" 	DEFAULT="#FORM.User_Position_Of#">
<CFPARAM NAME="FORM.Distributor_shipto" 	DEFAULT="">
<cfparam name="FORM.currentAgreementList" default="">
<cfparam name="FORM.currentStatusList" default="">

<!---
<cfif url.SearchIsConductedFromOtherWindow EQ 0>
	<CFINCLUDE TEMPLATE="unlock_programs.cfm">
</cfif>
--->
<!------ Get application settings ----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!----------------------------------------------------------
Access Permissions
----------------------------------------------------------->

<CFINCLUDE TEMPLATE="access_permissions.cfm">

<!---------------------------------------------------
Access Permission End
---------------------------------------------------->


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<cfparam name="FORM.sort_by" 	default="#Default_Sort#">
<cfparam name="FORM.sort_Order" 	default="#Default_Sort_Order#">

<CFSET sql_Sort_By="dbo.Export_Sales_Agreement.Export_Sales_Agreement_Number">
<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="AR">
		<CFSET sql_Sort_By="dbo.Export_Sales_Agreement.Export_Sales_Agreement_Number">
	</CFCASE>
	<CFCASE value="CT">
		<CFSET sql_Sort_By="dbo.Export_Sales_Agreement.Export_Sales_Agreement_Name">
	</CFCASE>
	<CFCASE value="SD">
		<CFSET sql_Sort_By="dbo.Export_Sales_Agreement.Export_Start_Date">
	</CFCASE>
	<CFCASE value="ED">
		<CFSET sql_Sort_By="dbo.Export_Sales_Agreement.Export_End_Date">
	</CFCASE>
	<CFCASE value="DI">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.Name">		
	</CFCASE>
	<CFCASE value="ST">
		<CFSET sql_Sort_By="dbo.Export_Sales_Agreement.Contract_Status_Type_IDX">		
	</CFCASE>
</CFSWITCH>

<CFIF FORM.sort_Order EQ "DESC">
	<CFSET sql_Sort_By="#sql_Sort_By# DESC">
<CFELSE>
	<CFSET sql_Sort_By="#sql_Sort_By# ASC">
</CFIF>


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->	

	<cfset stSearch = StructNew()>
	<cfset stSearch = form>
	<cfset stSearch.GP_Position_List_From_My_Position_Down = GP_Position_List_From_My_Position_Down>
	<cfset stSearch.User_Positions_ID = UserPositionList>
	<cfset stSearch.ProgramsWithDistUnderMe = "0">
	<cfset stSearch.ProgramsWithBrokerUnderMe = "0">
	<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stSearch.ProgramsWithDistUnderMe = ProgramsWithDistUnderMe>
		<cfset stSearch.ProgramsWithBrokerUnderMe = ProgramsWithBrokerUnderMe>
	</cfif>
	<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
		<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
	</cfif>
	<cfset stSearch.Profiles_ID = request.AccessStructure.Profiles_ID>
	<cfset stSearch.sql_Sort_By = sql_Sort_By>

	<cfset TheQuery = CreateObject("component", "components.Export.Sales_Agreement").search(stSearch)>

		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			
			<cfparam name="FORM.startrow" 	default="1">
			<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
			<cfparam name="FORM.pageLength" 	default=13>
			<CFSET startrow=FORM.startrow>
			<CFSET frompage=FORM.frompage>
			<cf_Number_of_Rows maxrows="#FORM.pageLength#">
			
			<!---Startrow can never be less than 0 and never be non-integer--->
			<cfif startrow LT 1 OR isNumeric(startrow) IS false>
				<cfset startrow = 1>
			</cfif>
			<script>
					
	  var globalcurrentProgramList = "";
      function approveSelectedProgram() 
      {
	     if(globalcurrentProgramList.length > 0) 
	     {
	       if(confirm("Press OK to approve the selected agreements."))
	       {
			//document.all.massApprovalProgramList.value = globalcurrentProgramList;
			document.all.approvalForm.submit();
		   }
	     }
	     else
	     {
		    alert("Please select at least one agreement Ready For Approval first.")
	     }
	   }

      var globalcurrentStatusList = "";
      function editSelectedProgramStatus() 
      {
	       if(globalcurrentStatusList.length > 0) 
	       {
	          if(confirm("Press OK to change the selected agreements status."))
	          {
			    //document.all.massEditStatusList.value = globalcurrentStatusList;
			    document.all.editStatusForm.submit();
		      }
	       }
	       else
	       {
		        alert("Please select at least one agreement to change the proposal status.")
	       }
	  }
					
					
					
	var currentProgramList = <cfoutput>"#form.currentagreementList#"</cfoutput>;
	var currentStatusList = <cfoutput>"#form.currentStatusList#"</cfoutput>;
	var programStatus = "";

	</script>
	<CFINCLUDE TEMPLATE="Sales_Agreement_display_Agreement_List.cfm">
			
		<cfif printresults EQ 0>

			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="30"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
			</TD>
			<TD ALIGN="RIGHT">
				<FONT COLOR="Red" SIZE="2"><B>There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Agreement<CFELSE>Agreements</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</B></FONT>
			</TD>
			</TR>
			</TABLE>
		</cfif>
			<SCRIPT LANGUAGE="javaScript">
				function getthisPage(thisObj)
				{
					window.parent.showSearchResult(false, thisObj.startrow.value,thisObj.frompage.value);
					return false;
				}
				
			</SCRIPT>
			
			<CFOUTPUT>
			<FORM ACTION="/scorecard/Sales_Agreement_Search_Result.cfm#form.IFRAME_Extra_URL#" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javaScript: return getthisPage(this);">
			<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
			<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
			<input type="Hidden" name="ImportAllList" value="#ValueList(TheQuery.Export_Sales_Agreement_ID)#">
			<INPUT TYPE="Hidden" NAME="currentAgreementList" VALUE="#form.currentAgreementList#">
      <INPUT TYPE="Hidden" NAME="currentStatusList" VALUE="#form.currentStatusList#">
			</FORM>
			</CFOUTPUT>
			

			<SCRIPT>
			function generateSelectedProgramsList() {
				returnList = "";
				
				for(var x=0;x<window.document.all.SelectedPrograms.length; x++) {
					oTempBx = window.document.all.SelectedPrograms[x];
					
					if(oTempBx.checked) {
						returnList = returnList + oTempBx.value + ",";
					}
				}

				returnList = returnList.substring(0, returnList.length-1);

				return returnList
			}
			
			function navigate(frompage, startrow)
			{	
				<cfif URL.ShowCheckBoxes EQ 1><cfoutput>
					window.parent.document.all.chkAll.checked 		= false;
					window.parent.SearchForm.PL_PreSubmit.value 	= "#form.ILPL_PreSubmit#";
					window.parent.SearchForm.PL_PostSubmit.value 	= generateSelectedProgramsList();
					window.parent.SearchForm.PL_Final.value 		= "#Form.PL_Final#";
				</cfoutput></cfif>

				window.parent.showSearchResult(false, startrow,frompage);
			}
   
  
			</SCRIPT>


		<CFELSE>
			<BR>
			<FONT COLOR="Red" SIZE="2"><B>There are no agreements that match the specified criteria</B></FONT>
		</CFIF>	
		
</CFIF>
</BODY>