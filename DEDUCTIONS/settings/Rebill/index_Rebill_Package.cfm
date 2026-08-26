 <!-----------------------------------------------------------------------------

FILE NAME:		index_Rebill_package.cfm
DESCRIPTION:	This is the Main page that calls all the other action/Display pages
CREATED BY:	 Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	05-Apr-10	 Created
------------------------------------------------------------------------------> 
<cfsilent>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> 
<cfparam name="FORM.display" 	default="active">
<cfparam name="FORM.command" 	default="">
<cfparam name="FORM.returnTo" 	default="">

<cfswitch expression="#FORM.display#">
	<cfcase value="active">       <cfset selectedIndex = 0>  </cfcase>
	<cfcase value="inActive">     <cfset selectedIndex = 1>  </cfcase>
	<cfcase value="add">          <cfset selectedIndex = 2>  </cfcase>
	<cfcase value="edit">         <cfset selectedIndex = 2>  </cfcase>
  <cfcase value="varsize">      <cfset selectedIndex = 3>  </cfcase>
  <cfcase value="rebillSettings">   <cfset selectedIndex = 4>  </cfcase>
</cfswitch>	
</cfsilent>
<cfmodule template="/customTags/layout.cfm" 
							layoutID = "rebillPackage" 
							selectedIndex = "#selectedIndex#" >

<script src="/script/javascript/string_functions.js"></script>
<script language="JavaScript" src="/Script/javascript/dom_common.js"></script>
<script language="JavaScript" src="rebill_component.js"></script>

<style>
input.arrowButton {   
   color:#050;   
   font: bold  'trebuchet ms',helvetica,sans-serif;   
   background-color:#fed;   
   border:1px solid;   
   border-color: #696 #363 #363 #696;   
 }  
</style>
</head>

<cfscript>
	rebillPackage = CreateObject("component","components.Deduction.rebill.Rebill");
</cfscript>
<cfset rebillSettingsManager = rebillPackage.getRebillSettings() />
<cfset varMaxSize = rebillSettingsManager.Rebill_Message_Size />

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD PACKAGE///////////--->
<cfif FORM.command eq "addRebillPackage">
			<cfif not(isdefined("FORM.chkDefaultMessage"))>
        <cfparam name="FORM.chkDefaultMessage" default=0 />
      </cfif>
	<cfscript>
		bSuccess =  rebillPackage.addRebillPackage(FORM.title,FORM.chkDefaultMessage,FORM.rebillMessage,FORM.Selected_Reason_Code_ID_List,FORM.Selected_Reason_Code_ID,FORM.Selected_Classification_ID_List, FORM.Selected_Classification_ID, request.accessstructure.User_ID);
  if(bSuccess == 0 )
  {
   writeOutput("<script>alert('Record Insert failed!! Reason: Duplicate Title');history.back();</script>");
  }
	</cfscript>
		
<!---/////////////DEACTIVATE SELECTED LIST OF CURRENCIES///////////--->
<cfelseif FORM.command eq "deactSel">
				
	<cfscript>
		rebillPackage.deActivatePackage(FORM.CID);
	</cfscript>
		
<cfelseif FORM.command eq "deActivate">
				
	<cfscript>
		rebillPackage.deActivatePackage(FORM.DD_Rebill_Package_Hdr_ID);
	</cfscript>
		
<!---/////////////ACTIVATE SELECTED LIST OF CURRENCIES///////////--->
  <cfelseif FORM.command eq "actSel">
				
	<cfscript>
		rebillPackage.activatePackage(FORM.CID);
	</cfscript>  
		
<!---/////////////ACTIVATE SINGLE SELECTED PACKAGE ///////////--->
<cfelseif FORM.command eq "activate">
		
	<cfscript>
	  rebillPackage.activatePackage(FORM.DD_Rebill_Package_Hdr_ID);
	</cfscript>
			
<!---////  DELETE SELECTED PACKAGE ///////--->
<cfelseif FORM.command eq "delete">
		
	<cfscript>
		rebillPackage.deletePackage(FORM.DD_Rebill_Package_Hdr_ID);
	</cfscript>
	
<!---///////////// UPDATE PACKAGE ///////////--->
<cfelseif FORM.command eq "update">
  <cfif not(isdefined("FORM.chkDefaultMessage"))>
    <cfparam name="FORM.chkDefaultMessage" default=0 />
  </cfif>		
	<cfscript>
  bExists = 
 rebillPackage.updatePackage(FORM.DD_Rebill_Package_Hdr_ID,FORM.title,FORM.chkDefaultMessage,FORM.rebillMessage,FORM.Selected_Reason_Code_ID_List,FORM.Selected_Reason_Code_ID,FORM.Selected_Classification_ID_List, FORM.Selected_Classification_ID, request.accessstructure.User_ID);
  if(bExists)
  {
   writeOutput("<script>alert('Record Insert failed!! Reason: Duplicate Title');</script>");
  }
	</cfscript>
  
  <!----- //////////////// UPDATE VARIABLE SIZE /////////////////////////// ----->
  <cfelseif FORM.command eq "updVarSize">
    <cfscript>
      rebillPackage.updRebillVariableSize(FORM, request.accessstructure.User_ID);
    </cfscript>
  
  <cfelseif FORM.command eq "updRebillSettings">
    <cfscript>
      rebillPackage.updRebillSettings(FORM.DDRebillMessageMaxSize, request.accessstructure.User_ID);
    </cfscript>
    
  </cfif>


	
<cfset FORM.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->

<cfif FORM.display eq "active">
	
	<cfscript>
		qGetRebillPackage = rebillPackage.getActivePackage();
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->	
<cfelseif FORM.display eq "inActive">

	<cfscript>
		qGetRebillPackage = rebillPackage.getInActivePackage();
	</cfscript>

<cfelseif FORM.display eq "add">  
  <cfscript>
    qGetVariableSize = rebillPackage.getRebillVariables();
  </cfscript>
  

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif FORM.display eq "edit">
	
	<cfscript>
		qGetRebillPackage = rebillPackage.getRebillPackage(FORM.DD_Rebill_Package_Hdr_ID);
    qGetReasonCodeRS    = rebillPackage.getReasonCode(FORM.DD_Rebill_Package_Hdr_ID);
    qGetDDClassificationRS = rebillPackage.getDDClassification(FORM.DD_Rebill_Package_Hdr_ID);
	</cfscript>

<cfelseif FORM.display EQ "rebillSettings">
  <cfscript>
    qGetRebillSettings = rebillPackage.getRebillSettings();
  </cfscript>
</cfif> 

  <cfscript>
    qGetDDClassifications = rebillPackage.getDDClassifications();
    qGetDDReasonCode = rebillPackage.getDDReasonCode();
    qGetVariableSize = rebillPackage.getRebillVariables();
  </cfscript>
  
  <cfset iloopcount = 1 />
  <cfset ivariableidsizelist = "" />
  <cfoutput query="qGetVariableSize">
    <cfif iloopcount eq 1>
      <cfset ivariableidsizelist = qgetvariablesize.rebill_package_variable & "_" & qgetvariablesize.std_length /> 
    <cfelse>
      <cfset ivariableidsizelist = ivariableidsizelist & "|" & qgetvariablesize.rebill_package_variable & "_" & qgetvariablesize.std_length />
    </cfif>
    <cfset iloopcount= iloopcount + 1 />
  </cfoutput>
   
  
<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!---<cfinclude template="rebill_package_header.cfm" />--->

<br />

<form action="index_Rebill_Package.cfm" method="post" name="DataForm">
<cfoutput>
<input type="hidden" name="iVariableIDSizeList" value="#iVariableIDSizeList#" />
</cfoutput>
<!--switch for each action--->
<cfswitch expression="#FORM.display#">
	
	<cfcase value="active">
		<cfinclude template="rebill_package_display.cfm" />
	</cfcase>
	
	<cfcase value="inActive">
		<cfinclude template="rebill_package_display.cfm" />
	</cfcase>
	
	<cfcase value="add">
		<cfinclude template="rebill_package_add.cfm" />
	</cfcase>
	
	<cfcase value="edit">
		<cfinclude template="rebill_package_edit.cfm" />
	</cfcase>
  
  <cfcase value="varsize">
    <cfinclude template="rebill_package_variable_size.cfm" />
  </cfcase>
  
  <cfcase value="rebillSettings">
    <cfinclude template="rebill_settings.cfm" />
  </cfcase>
  

</cfswitch>	

<cfoutput>
<!---hidden FORM fields--->
<input name="display" type="hidden" value="#FORM.display#" />
<input name="command" type="hidden" value="#FORM.command#" />
<input name="DD_Rebill_Package_Hdr_ID" type="hidden" value="" />
<input name="returnTo" type="hidden" value="#FORM.returnTo#"/>
<input type="hidden" name="appSetting_getDD_Show_Classification" value="#appSettings.getDD_Show_Classification()#" />

</cfoutput>
</form>

<form action="change_default.cfm" method="post" name="Change_Default_ID">
	<input type="hidden" name="New_Default_ID" value="1">
</form>


</cfmodule>