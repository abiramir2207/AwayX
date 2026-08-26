 <!-----------------------------------------------------------------------------
    
FILE NAME:		BB_DisagreeFlx.cfm
DESCRIPTION: This file will be called from the flex grid when the disagree 
button is clicked.
CREATED BY:		Anand Rao/30-Mar-10
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

Arguments:
 returns to calling page
------------------------------------------------------------------------------>

<cfparam name="URL.BBID" default="" />
<cfparam name="URL.source" default="" />
<cfparam name="FORM.FlexAppName" default=""> 
<cfparam name="IsBillbackApproved" default="0">
<cfparam name="url.FlexAppName" default="#FORM.FlexAppName#">
<cfparam name="URL.parentName" default="" />

<cfset strSource = "" />
<cfif URL.source NEQ "">
    <cfset strSource = URL.source />
 </cfif>
  <!--- This is for 6.0 --->
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfif URL.BBID NEQ "" AND isNumeric(URL.BBID)>
  <cfset oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO") />
  <cfset URL.BBID = oBillbackDAO.getBillbackUUID(URL.BBID) />
</cfif>

 <!---  
 This is for 5.1
 <cfset appSettings = request.applicationAppSettingsManager.getApplicationAppSettings()> 
 --->
<cfif (appSettings.getbusinessconsiderations_on() IS 1)>
<cfif (isDefined("URL.bbReset") AND URL.bbReset EQ 1)>
	<cfoutput>
		<script language="JavaScript">
			window.location = 'BB_Business_Consideration.cfm?MODE=3&BBID=#URL.BBID#&source=#URL.source#&FlexAppName=#URL.FlexAppName#&parentName=#url.parentName#';
		</script>
	</cfoutput>
 <!---  <cflocation url="'BB_Business_Consideration.cfm?MODE=3&BBID=#URL.BBID#&source=#URL.source#&FlexAppName=#URL.FlexAppName#&parentName='+window.parent.name" addtoken="No"/> --->
<cfelse>
  <!---<cflocation url="BB_Business_Consideration.cfm?MODE=9&BBID=#URL.BBID#&source=#URL.source#&FlexAppName=#URL.FlexAppName#&parentName='+window.parent.name" addtoken="No"/>--->
  <cfoutput>
	<script language="JavaScript">
			window.location = 'BB_Business_Consideration.cfm?MODE=9&BBID=#URL.BBID#&source=#URL.source#&FlexAppName=#URL.FlexAppName#&parentName='+ window.parent.name;
	</script>
</cfoutput>
</cfif>
  <cfabort /> 
</cfif>

<!--- This code will get executed only if Business consideration is OFF --->

<cfoutput>
<script language="JavaScript">
	function VerifyDisagreeFlex(paramSource)
	{
	   if (paramSource == 'flexBB' || paramSource == 'FlexBB' || paramSource == 'AgGridBB')
		{
			if(window.confirm("This billback will be reset to work in progress. Do you want to proceed?") == 0)
			{
				// Dev Note: Kal: 30645 - Disagree in deviation screen should reset BB to WIP : Call from the Flex App 
				// When called from Flex BB Edit this page is a pop-up so close it, if cancelled.
				// window.location = "/flex/Billback/BillbackDevAppFX.cfm?bbid=#URL.BBID#&userID=#request.AccessStructure.User_ID#&source=#URL.source#&caller=#URL.source#"; 
				window.close();
			}
			else
			{
				// redirect to the Flex BB Screen;
				window.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=#BBID#&resetBillback=1&IsBillbackApproved=#IsBillbackApproved#&Disagree=1&FromFlex=1&FlexAppName=#url.FlexAppName#';				
			}
		}
		else if(paramSource == 'BBFlexScoreCard' || paramSource == 'BBAgGridScoreCard')
		{
			if(window.confirm("This billback will be reset to work in progress. Do you want to proceed?") == 0)
			{
				<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
				window.location = "/billbacks/Deviation/Deviation_Main.cfm?bbid=#URL.BBID#&source=#strSource#&caller=#strSource#";
				<cfelse>
				 window.location = "/flex/Billback/BillbackDevAppFX.cfm?bbid=#URL.BBID#&userID=#request.AccessStructure.User_ID#&source=#strSource#&caller=#strSource#";	
				</cfif>
			}
			else
			{
				window.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=#BBID#&resetBillback=1&IsBillbackApproved=#IsBillbackApproved#&Disagree=1&FromFlex=1';
			}
		}
	}
</script>
</cfoutput>
 
<body onLoad="javascript:VerifyDisagreeFlex('<cfoutput>#URL.source#</cfoutput>');" >
<br>
<br>
<br>

<center>
Waiting for user response....<br><br>

<img src="/Images/ajax-loader.gif" />
</center>  
</body> 
</html> 