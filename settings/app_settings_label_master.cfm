<!---
	FILENAME: 	app_settings_label_master.cfm
	Copyright 	(c) 2008 Blacksmith Applications, Inc.
	CREATED: 	??/??/?? 	DA
	EDITED: 	09/26/08 	RBL [16314]
--->

<!--- INSTANTIATE LABEL COMPONENT INTO THE REQUEST SCOPE --->
<cfif not isDefined("request.qLabels")>
	<cfset request.qLabels = createObject("component", "components.settings.Labels.Labels").init()>
</cfif>

<!--- PARAMETERS --->
<cfset currentPage = #GetFileFromPath(GetCurrentTemplatePath())#>
<cfparam name="rowhilite" default="">

<!--- parameters that control the navigation of label types --->
<cfparam name="URL.LabelMode" default="">
<cfparam name="URL.appSetCode" default="0">
<cfparam name="URL.incFile" default="">
<cfparam name="session.labelMode" default="">
<cfparam name="session.appSetCode" default="">
<cfparam name="session.incFile" default="">

<!--- BASE LEVEL URL COMMON TO ALL IN THIS LABELING TOOL --->
<cfset labelURL = "app_settings.cfm?command=LabelMaster&labelMode=">

<!--- REDIRECT URL FOR FORM ACTIONS --->
<cfset redirectURL = "#labelURL##SESSION.labelMode#&appSetCode=#SESSION.appSetCode#&incFile=#SESSION.incFile#&updated=1">

<!--- CREATES APPSETTINGS OBJECT TO GET APP SETTING DATA --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />

<cfset appSettings = genSettingsManager.get(0)>
<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID)>
<!--- FORM ACTIONS --->
	<!--- column labels --->
	<cfif isDefined("FORM.modifyLabelsCol") AND FORM.modifyLabelsCol EQ 1>
		<cfset request.qLabels.modifyColLabels()>
		<cfset genSettingsManager.save(11)>
		<cflocation url="#redirectURL#&tblName=#FORM.tblName#">
	</cfif>

	<!--- pricing level --->
	<cfif isDefined("FORM.priceLevelModify") AND FORM.priceLevelModify EQ 1>
		<cfset request.qLabels.modifyPricingLevels()>
		<cfset genSettingsManager.save(12)>
		<cflocation url="#redirectURL#">
	</cfif>

	<!--- customer settings labels --->
	<!---------------------------------------------------------------------------
		Dev Notes: D18971
			Now that Customer, Distributor and Product has been combined under
			one page all the different modifications calls are made at once.
			-Anand Rao/12-May-09
	----------------------------------------------------------------------------->
	<cfif isDefined("FORM.settingsModify") AND FORM.settingsModify EQ 1>
		<!--- looking for customer id label in distributor attribute setting --->
		<cfloop from="1" to="#form.loopCnt#" index="counter">
			<!--- reach the end of distributor attributes setting bail out --->
			<cfif !structKeyExists(form, "BALABELDIST" & counter)>
				<cfbreak>
			</cfif>
			<!--- found customer id setting copy the value to customer setting & bail out --->
			<cfif form[ "BALABELDIST" & counter ] is "Customer ID">
				<cfset form.loopCnt                        = form.loopCnt + 1>
				<cfset form[ "columnName" & form.loopCnt ] = "customer_id_label">
				<cfset form[ "data" & form.loopCnt ]       = form[ "DISTLABEL" & counter ]>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfscript>
			request.qLabels.modifyCustomerSettings();
			request.qLabels.modifyProductGroupLevelLabels();
			request.qLabels.modifyDistributorGroupLevelLabels();
			request.qLabels.modifyOperatorSearchSettings();
			
			genSettingsManager.save(8);
		</cfscript>

		<cfloop from="1" to="#form.loopCnt#" index="counter">
			<cfif form[ "columnName" & counter ] is "BUSINESS_SEGMENT_LABEL">
				<!--- 76381 save business segment label to internal application (the original location) due to the existing of many references --->
				<cfquery datasource="#application.datasource#">
					UPDATE _Application_Settings SET Business_segment_label = '#form[ "data" & counter ]#'
				</cfquery>
				<cfbreak>
			</cfif>
		</cfloop>

		<cflocation url="#redirectURL#">
	</cfif>

	<!--- program summary labels --->
	<cfif isDefined("FORM.programLabelsModify")>
		<cfswitch expression="#FORM.programLabelsModify#">
			<!--- UPDATE LABEL SET --->
			<cfcase value="1">
				<cfset updateNotice = request.qLabels.modifyProgramLabels()>
			</cfcase>
			<!--- CREATE LABEL SET --->
			<cfcase value="2">
				<cfset updateNotice = request.qLabels.CreateProgramLabels()>
			</cfcase>
		</cfswitch>
		<cfset genSettingsManager.save(13)>
		<cfset URL.ProgramLabelSet = FORM.labelSetName>
		<cfset URL.command = "LabelMaster">
		<cfset URL.labelMode = SESSION.labelMode>
		<cfset URL.appSetCode = SESSION.appSetCode>
		<cfset URL.incFile = SESSION.incFile>
	</cfif>

	<!--- item language codes --->
	<cfif isDefined("FORM.itemLanguageModify")>
		<cfswitch expression="#FORM.itemLanguageModify#">
			<!--- UPDATE LANGUAGE CODE --->
			<cfcase value="1">
				<cfset updateNotice = request.qLabels.ModifyItemLanguageCode()>
			</cfcase>
			<!--- CREATE LANGUAGE CODE --->
			<cfcase value="2">
				<cfset updateNotice = request.qLabels.CreateItemLanguageCode()>
			</cfcase>
		</cfswitch>
		<cfset genSettingsManager.save(13)>
		<cfset URL.ItemLanguageCode = FORM.LangCode>
		<cfset URL.command = "LabelMaster">
		<cfset URL.labelMode = SESSION.labelMode>
		<cfset URL.appSetCode = SESSION.appSetCode>
		<cfset URL.incFile = SESSION.incFile>
	</cfif>

	<cfif isDefined("FORM.txtFileName")>
		<cffile action="upload"
				filefield="txtFileName"
				destination="#request.qLabels.txtFilePath#"
				accept="text/html,text/plain"
				nameconflict="overwrite">

		<cfset UploadedFileName = CFFILE.serverFile>
		<cfset updateNotice = "Item Language Code file (#UploadedFileName#) successfully uploaded.">

		<cfset request.qLabels.ReadLangFile()>

		<cfset genSettingsManager.save(13)>
		<cfset URL.command = "LabelMaster">
		<cfset URL.labelMode = SESSION.labelMode>
		<cfset URL.appSetCode = SESSION.appSetCode>
		<cfset URL.incFile = SESSION.incFile>
	</cfif>

	<!--- margin settings --->
	<cfif isDefined("FORM.modifyMarginLabels") AND FORM.modifyMarginLabels EQ 1>
		<cfparam name="form.marginColHeader1" 	default="" />
		<cfparam name="form.marginColHeader2" 	default="" />
		<cfparam name="form.marginColHeader3" 	default="" />
		<cfparam name="form.marginColHeader4" 	default="" />
		<cfparam name="form.marginColHeader5" 	default="" />
		<cfparam name="form.marginColHeader6" 	default="" />
		<cfparam name="form.marginColHeader7" 	default="" />
		<cfparam name="form.marginColHeader8" 	default="" />
		<cfparam name="form.marginColHeader9" 	default="" />
		<cfparam name="form.marginColHeader10" 	default="" />
		<cfparam name="form.marginColHeader11" 	default="" />
		<cfparam name="form.marginColHeader12" 	default="" />
		<cfparam name="form.marginColHeader13" 	default="" />
		<cfparam name="form.marginColHeader14" 	default="" />
		<cfparam name="form.marginColHeader15" 	default="" /> <!--- 16314 --->
		<cfparam name="form.marginColHeader16" 	default="" /> <!--- 20537 --->
		<cfparam name="form.marginColHeader17" 	default="" /> <!--- 20537 --->
		<cfparam name="form.marginColHeader18" 	default="" /> <!--- 24130 --->
		<cfparam name="form.marginColHeader19" 	default="" /> <!--- 24130 --->
		<cfparam name="form.marginColHeader20" 	default="" /> <!--- 25239 --->
		<cfparam name="form.marginColHeader21" 	default="" /> <!--- 25239 --->
		<cfparam name="form.marginColHeader22"	 	default="" /> <!--- 39801 --->
		<cfparam name="form.marginColHeader23"	 	default="" /> <!--- 42990 --->
        <!---65744 - CC - Move LaborOH cost to a different product cost field START --->
        <cfparam name="form.marginColHeader24"	 	default="" />
        <cfparam name="form.marginColHeader25"	 	default="" />
        <!---65744 - CC - Move LaborOH cost to a different product cost field END --->		
        <cfparam name="form.marginColHeader26"	 	default="" /><!---76537 --->

        <cfparam name="form.marginCostColHeader1" 	default="" />
		<cfparam name="form.marginCostColHeader2" 	default="" />
		<cfparam name="form.marginCostColHeader3" 	default="" />
		<cfparam name="form.marginCostColHeader4" 	default="" />
		<cfparam name="form.marginCostColHeader5" 	default="" />
		<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using--->
		<cfparam name="form.marginCostColHeader6" 	default="" />
		<cfparam name="form.marginCostColHeader7" 	default="" />
		<cfparam name="form.marginCostColHeader8" 	default="" />

		<cfparam name="form.marginCostColHeader1_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader2_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader3_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader4_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader5_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader6_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader7_delete" 	default="0" />
		<cfparam name="form.marginCostColHeader8_delete" 	default="0" />
		<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using--->
        
		<cfset appSettings.setMarginColHeader1(form.marginColHeader1)>
		<cfset appSettings.setMarginColHeader2(form.marginColHeader2)>
		<cfset appSettings.setMarginColHeader3(form.marginColHeader3)>
		<cfset appSettings.setMarginColHeader4(form.marginColHeader4)>
		<cfset appSettings.setMarginColHeader5(form.marginColHeader5)>
		<cfset appSettings.setMarginColHeader6(form.marginColHeader6)>
		<cfset appSettings.setMarginColHeader7(form.marginColHeader7)>
		<cfset appSettings.setMarginColHeader8(form.marginColHeader8)>
		<cfset appSettings.setMarginColHeader9(form.marginColHeader9)>
		<cfset appSettings.setMarginColHeader10(form.marginColHeader10)>
		<cfset appSettings.setMarginColHeader11(form.marginColHeader11)>
		<cfset appSettings.setMarginColHeader12(form.marginColHeader12)>
		<cfset appSettings.setMarginColHeader13(form.marginColHeader13)>
		<cfset appSettings.setMarginColHeader14(form.marginColHeader14)>
		<cfset appSettings.setMarginColHeader15(form.marginColHeader15)> <!--- 16314 --->
		<cfset appSettings.setMarginColHeader16(form.marginColHeader16)> <!--- 20537 --->
		<cfset appSettings.setMarginColHeader17(form.marginColHeader17)> <!--- 20537 --->
		<cfset appSettings.setMarginColHeader18(form.marginColHeader18)> <!--- 24130 --->
		<cfset appSettings.setMarginColHeader19(form.marginColHeader19)> <!--- 24130 --->
		<cfset appSettings.setMarginColHeader20(form.marginColHeader20)> <!--- 25239 --->
		<cfset appSettings.setMarginColHeader21(form.marginColHeader21)> <!--- 25239 --->
		<cfset appSettings.setMarginColHeader22(form.marginColHeader22)> <!--- 39801 --->
		<cfset appSettings.setMarginColHeader23(form.marginColHeader23)> <!--- 42990 --->
		<!---65744 - CC - Move LaborOH cost to a different product cost field START --->
		<cfset appSettings.setMarginColHeader24(form.marginColHeader24)> 
		<cfset appSettings.setMarginColHeader25(form.marginColHeader25)> 
		<!---65744 - CC - Move LaborOH cost to a different product cost field END --->   
		<cfset appSettings.setMarginColHeader26(form.marginColHeader26)> <!---76537--->

		<cfset appSettings.setMarginCostColHeader1(form.marginCostColHeader1)>
		<cfset appSettings.setMarginCostColHeader2(form.marginCostColHeader2)>
		<cfset appSettings.setMarginCostColHeader3(form.marginCostColHeader3)>
		<cfset appSettings.setMarginCostColHeader4(form.marginCostColHeader4)>
		<cfset appSettings.setMarginCostColHeader5(form.marginCostColHeader5)>
		<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using--->
		<cfset appSettings.setMarginCostColHeader6(form.marginCostColHeader6)>
		<cfset appSettings.setMarginCostColHeader7(form.marginCostColHeader7)>
		<cfset appSettings.setMarginCostColHeader8(form.marginCostColHeader8)>

		<cfset appSettings.setMarginCostColHeader1_delete(form.marginCostColHeader1_delete)>
		<cfset appSettings.setMarginCostColHeader2_delete(form.marginCostColHeader2_delete)>
		<cfset appSettings.setMarginCostColHeader3_delete(form.marginCostColHeader3_delete)>
		<cfset appSettings.setMarginCostColHeader4_delete(form.marginCostColHeader4_delete)>
		<cfset appSettings.setMarginCostColHeader5_delete(form.marginCostColHeader5_delete)>
		<cfset appSettings.setMarginCostColHeader6_delete(form.marginCostColHeader6_delete)>
		<cfset appSettings.setMarginCostColHeader7_delete(form.marginCostColHeader7_delete)>
		<cfset appSettings.setMarginCostColHeader8_delete(form.marginCostColHeader8_delete)>
		<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using--->
   
		<cfset genSettingsManager.save(6)>
		<!--- 76381 save base sale label, net sale label to internal application (the original location) due to the existing of many references --->
		<cfquery datasource="#application.datasource#">
			UPDATE _Application_Settings 
			   SET  Base_Sale_label = '#form.marginColHeader2#'
			       ,Net_Sale_label  = '#form.marginColHeader8#'
		</cfquery>

		<cflocation url="#labelURL##SESSION.labelMode#&appSetCode=#SESSION.appSetCode#&incFile=#SESSION.incFile#&updated=1">
	</cfif>

	<!--- billback / auto pay report labels --->
	<cfif isDefined("FORM.modifyLabelsAutoPay") AND FORM.modifyLabelsAutoPay EQ 1>
		<cfset message = request.qLabels.modifyAutoPayLabels()>

		<!--- billback labels --->
		<cfif isDefined("FORM.tableName") AND FORM.tableName EQ "Billback">
			<cfset genSettingsManager.save(9)>

			<cflocation url="#redirectURL#&tblType=#FORM.tableName#">
		</cfif>
		<!--- pullback labels --->
		<cfif isDefined("FORM.tableName") AND FORM.tableName EQ "Pullback">
			<cfset genSettingsManager.save(10)>
			<cflocation url="#redirectURL#&tblType=#FORM.tableName#">
		</cfif>
	</cfif>

	<!--- claim summary --->
	<cfif isDefined("FORM.claimSummaryLabelsModify") AND FORM.claimSummaryLabelsModify EQ 1>
		<cfset variables.claimSummaryObj = createObject("component", "components.Products.Group.AttributeManager")>
		<cfset variables.delete = 0 />
			<cfloop from="1" to="#FORM.loopCnt#" index="i">
				<cfif #evaluate('FORM.customlabel#i#')# NEQ "">
					<cfif isDefined("FORM.active#i#")>
						<cfset variables.claimSummaryObj.updateClaimSummary(#evaluate('FORM.id#i#')#,#evaluate('FORM.customlabel#i#')#,#evaluate('FORM.active#i#')#)>
					<cfelse>
						<cfset variables.claimSummaryObj.updateClaimSummary(#evaluate('FORM.id#i#')#,#evaluate('FORM.customlabel#i#')#,variables.delete)>
					</cfif>
				</cfif>
			</cfloop>
		<cflocation url="#redirectURL#">
	</cfif>

	<!--- general labels --->
	<cfif isDefined("FORM.generalLabelModify") AND FORM.generalLabelModify EQ 1>
		<cfset request.qLabels.ModifyGeneralLabels()>
		<cfset genSettingsManager.save(16)>

		<!--- 76381 copy labels back to the old internal settings --->
		<cfquery name="qLabels" datasource="#application.datasource#">
			SELECT General_Labels_Desc, General_Labels_Label
			FROM General_Labels
			WHERE General_Labels_Desc IN ( 'Pullback Label', 'Label Notes', 'LOB Label' )
		</cfquery>
	
		<cfquery datasource="#application.datasource#">
			UPDATE _Application_Settings
				SET 
					<cfoutput query="qLabels">
						<cfif qLabels.currentRow gt 1>,</cfif>
						#replace( replaceNoCase(General_Labels_Desc, "Label Notes", "LabelNotes"), ' ', '_', "all" )# = '#General_Labels_Label#'
					</cfoutput>
		</cfquery>

		<cflocation url="#redirectURL#">
	</cfif>

	<!--- deduction labels --->
	<cfif isDefined("FORM.deductionLabelModify") AND FORM.deductionLabelModify EQ 1>
		<cfset request.qLabels.ModifyDeductionLabels()>
		<cfset genSettingsManager.save(17)>
		<cflocation url="#redirectURL#">
	</cfif>

 	<!--- Dev Note: Drachala; D27872: Add new Billback Lables START --->
	<cfif isDefined("FORM.BillbackLabelModify") AND FORM.BillbackLabelModify EQ 1>
		<cfset request.qLabels.ModifyBillbackLabels()>
		<cfset genSettingsManager.save(18)>

		<!--- 76381 copy deduction label back to the old internal settings --->
		<cfquery datasource="#application.datasource#">
			UPDATE dbo._Application_Settings
			   SET Deviation_Label = ( SELECT Billback_Labels_Label
										 FROM dbo.Billback_Labels
										WHERE Billback_Labels_Desc = 'Deviation' )
		</cfquery>
		
		<cflocation url="#redirectURL#">
	</cfif>
 	<!--- Dev Note: Drachala; D27872: Add new Billback Lables END --->

	<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->
	<cfif isDefined("FORM.DiscountTypes") AND FORM.DiscountTypes EQ 1>
		<cfset request.qLabels.saveDiscountTypes()>
		<cfset genSettingsManager.save(19)>
		<cflocation url="#redirectURL#">
	</cfif>
	<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth --->

	<!--- Dashboard Label --->
	<cfif isDefined("FORM.DashboardLabelModify") AND FORM.DashboardLabelModify EQ 1>
		<cfset request.qLabels.ModifyDashboardLabels()>
		<cfset genSettingsManager.save(20)>
		<cflocation url="#redirectURL#">
	</cfif>

	<!--- Program Letters Label --->
	<cfif isDefined("FORM.ProgramLettersLabelModify") AND FORM.ProgramLettersLabelModify EQ 1>
		<cfset request.qLabels.ModifyProgramLettersLabels()>
		<cfset genSettingsManager.save(21)>
		<cflocation url="#redirectURL#">
	</cfif>

	<!--- Planner Label --->
	<cfif isDefined("FORM.PlannerLabelModify") AND FORM.PlannerLabelModify EQ 1>
		<cfset request.qLabels.ModifyPlannerLabels()>
		<cfset genSettingsManager.save(22)>
		<cflocation url="#redirectURL#">
	</cfif>
<!--- END:: FORM ACTIONS --->

<!--- CUSTOM CSS FOR DISPLAY OF ALL LABEL TOOLS --->
<style>
	input {font-size:10px;font-family:Century Gothic,sans-serif;}
	#masterContainer {margin: 10;width: 700px;}
	#headerContainer {width: 830px;background-color: #ffce84;font-size: 12px;border-bottom:thin solid #990000;}
	#modifiedCont {border:thin solid Orange;width:700px;margin:15 0 10 10;padding:5;text-align:center;font-size:12px;color:red;background-color:White;font-weight:bold;}
	/* padding:top,right,bottom,left.
	Keep left "0". Without it, the "recapture report labels" and "billback report labels" page's header and rows are not aligned properly
	*/
	#innerheaderContainer, #innerHeaderContainer {width:200px;padding:5 5 5 0;font-family:Century Gothic;font-size:12px;font-weight:bold;color:#000099;text-align:left; display: inline;vertical-align:top;float:left;}
	#innerheaderContainerSM, #innerHeaderContainerSM {width:50px;padding:5 5 5 0;font-family:Century Gothic;font-size: 12px;font-weight: bold;color: #000099; display: inline; float:left;}
	#bodyContainer {width: 780px;font-size: 10px;}
	#innerbodyContainer, #innerBodyContainer {width:200px;text-align: left;padding: 2px;font-size: 10px;display: inline;float:left;}
	#innerBodyContainerSM {width: 50px;padding: 2px;font-size: 10px;display: inline;float:left;}
	#leftCont {width:350px;display: inline;}
	#rightCont {width:350px;text-align:right;display: inline;}
	.rowBg1 {background-color: #ffffff;}
	.rowBg2 {background-color: #EAFFEA;}
	.inactive {background-color: #DDDDDD;}
	.sortSection {width: 780px;border-bottom: 1px solid #DDDDDD;}
	.boxselect {border: 1px solid black;margin-left: 2px;}
	.boxselectover {border: 1px solid black;margin-left: 2px;background-color: #999999;color: white;cursor: pointer;}
	.boxselected {border: 1px solid black;background-color: #555555;color: white;margin-left: 3px;text-transform: uppercase;}
	.sortMe, .sortme {border: 1px solid black;cursor: n-resize;margin-top:5px;color:#ffffff;background-color:#777777;font:normal normal bold 8px Century Gothic;text-align:center;}
	#headerContainer:after, #bodyContainer:after, .sortSection:after {
	  content: "";
	  display: table;
	  clear: both;
	}
</style>
<!--- PROTOTYPE AJAX FRAMEWORK AND SCRIPTACULOUS EFFECTS --->
<SCRIPT SRC="/Script/javascript/prototype/prototype.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/prototype/scriptaculous.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/prototype/effects.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/prototype/dragdrop.js"></SCRIPT>
<script>
// REDIRECTS THE USER BASED ON MODE SELECTION
function selectLabelType(dropdown)
{
    var myindex  = dropdown.selectedIndex;
    var baseURL = dropdown.options[myindex].value;
    location.href = baseURL;

    return true;
}
// DISPLAYS ALERT IF A CHANGE IS MADE ON THE PAGE
function modified()
{
	// Added for D26584 not to allow single quotes and double quotes
	var eventObj = event.srcElement;
	var txtValue = "";
	var varREX = new RegExp("[~!$%^:;&*(){}?+-=_|/.,<>0-9a-zA-Z \r]", "g");
	var error = 0;
	var v1 = '"';
	var v2='\\';
	var v3='[';
	var v4=']';

	if (eventObj.value && (eventObj.value != "" || eventObj.value != "undefined"))
	{
		m = trim(eventObj.value);
		for (i = 0; i < m.length; i++)
    {
      if ((m.substring(i,i+1)).match(varREX) == null)
      {
            // since the regular expression  was not working right for the chars ",\ a separate we are doing a check for those
            // characters here
						// (m.substring(i,i+1)== v1) ||
      	if (!((m.substring(i,i+1)== v2) || (m.substring(i,i+1)== v3) || (m.substring(i,i+1)== v4)))
        {
        	error = error +  1;

          break;
         }
       }
		}
 		if (error > 0)
    {
			event.srcElement.value = m.substring(0,m.length-1)
			alert("The special character that was entered is not supported!");
      return false;
    }
	}


	if ($('modifiedCont').style.display == 'none') {
    	new Effect.BlindDown('modifiedCont',{duration: .2});
    	new Effect.Pulsate('modifiedCont',{pulses: 2, duration:1, from:.05});
	}
}
</script>

<!-----------------------------------------------------------------------------
      Dev Notes: D18971
          The below script is used in the "Settings Label" page which displays
          the Hide/Show Div and this script is called from there.
          -Anand Rao/12-May-09
------------------------------------------------------------------------------->
<script language="javascript" type="text/javascript">
     <!--
      function switchlayer(lyrid, title, titleclosed, borderwidth, imagea,imageb, colora,colorb) {
       if (document.all.length) {
        // determine if the layer is currently expanded or collapsed:
        var tmpstatus;
        eval("tmpstatus = document.all.lyrgroup_"+ lyrid +".style.display");
        // ok, then now expand or collapse it...
        if (tmpstatus == 'none') {
         eval("document.all.lyrgroup_"+ lyrid +".style.display='block';");
         eval("document.all.border_"+ lyrid +".style.borderwidth='"+borderwidth+"px';");
         eval("document.all.title_"+ lyrid +".innerhtml='"+title+"';");
         tmpimage = imagea;
         tmpcolor = colora;
        }
        else {
         eval("document.all.lyrgroup_"+ lyrid +".style.display='none'");
         eval("document.all.border_"+ lyrid +".style.borderwidth='0px';");
         eval("document.all.title_"+ lyrid +".innerhtml='"+titleclosed+"';");
         tmpimage = imageb;
         tmpcolor = colorb;
        }
        // if an image is used as the click-control, switch it...
        if ((tmpimage != null) && (imagea != imageb)) {
         eval("document.all.image_"+ lyrid +".src='"+tmpimage+"'");
        }
        // if different title-colors are used, switch them...
        if (tmpcolor != '') {
         eval("document.all.title_"+ lyrid +".style.color='"+tmpcolor+"'");
        }
       }
      }
     //-->
     </script>
<!--- SET VARIABLES FOR LABEL MODE SELECTION, CREATES LISTS FOR EACH VARIABLE --->
<!---31309 - placed all labels into a text variable, one label per line, fields are delimited by |
             1st line has the fields definition, delimited by commas
             this text will be converted into a query object later--->
<cfsavecontent variable="labels.rawtext">
label_title,label_code,app_set_code,include_file
margin settings | marginsettings | 6 | app_settings_6.cfm
billback report | BBautopaylabels | 7 | app_settings_8.cfm
<cfoutput>#lcase( application.appSettingsGet.pullbacklabel )#</cfoutput> report | PBautopaylabels | 8 | app_settings_8.cfm
pricing level | pricelevels | 10 | app_settings_10.cfm
<cfif application.appsettingsget.label_sets>
  program summary | pgmsum | 11 | app_settings_11.cfm
  item language description | itmlangdesc | 14 | app_settings_14.cfm
</cfif>
settings | cdpsettings | 13 | app_settings_12.cfm
claim summary | claimsummary | 0 | app_settings_13.cfm
<cfif request.accessstructure.user_rights_id eq 9999>
  column | collabels | 9 | app_settings_9.cfm
</cfif>
general | generalcodelabel | 16 | app_settings_16.cfm
deduction | deductionlabel | 17 | app_settings_17.cfm
billback | Billbacklables | 18 | app_settings_18.cfm
discount type labels | Discount Type Labels | 19 | app_settings_19.cfm
dashboard | dashboardlabel | 20 | app_settings_20_dashboardLabel.cfm
program Letters | programLetterslabel | 21 | app_settings_21.cfm
planner | plannerlabel | 22 | app_settings_22.cfm
</cfsavecontent>

<!---parse the above labels into a query object--->
<cfset labels.unsortedQuery = application.util.query.querySim( labels.rawtext )>
<!---sort the labels by titles--->
<cfquery name="labels.sortedQuery" dbtype="query">
	SELECT *
	  FROM labels.unsortedQuery
	  ORDER BY label_title
</cfquery>

<!-----------------------------------------------------------------------------
Dev Notes: D18971
	AppSetCode is set to 13 for the Labels, this is used in place of 12 & 13 and the
  customer settings which have now been combined into one under one tab "Labels"
  -Anand Rao/dd-mmm-yy
------------------------------------------------------------------------------>
<cfoutput>
<!--- LABEL MODE SELECTION DROPDOWN --->
<form name="selectLabelMode" method="post">
<div style=" width:100%; margin: 0px; border:#TR_BORDER_WIDTH#px solid black; border-top:0px; background-color: #TD_FORE_COLOR#; padding:5px;">Label Mode:
	<select name="labelMode" onchange="selectLabelType(this.form.labelMode);">
		<option value="app_settings.cfm?command=LabelMaster">** Select Label Mode -->#RepeatString("&nbsp;",30)#</option>
		<cfloop query="labels.sortedQuery">
			<cfset navURL = "#labelURL##labels.sortedQuery.label_code#&appSetCode=#labels.sortedQuery.app_Set_Code#&incFile=#labels.sortedQuery.include_file#">
			<option value="#navURL#" <cfif URL.LabelMode EQ labels.sortedQuery.label_code>style="color:green;" selected</cfif>>
				<cfif URL.LabelMode EQ labels.sortedQuery.label_code>
					#ucase("#labels.sortedQuery.label_title# <cfif not labels.sortedQuery.label_title contains 'labels'>labels</cfif>")#
				<cfelse>
					#labels.sortedQuery.label_title# <cfif not labels.sortedQuery.label_title contains "labels">labels</cfif>
				</cfif>
			</option>
		</cfloop>
	</select>
</div>
</form>
<!--- DISPLAYS LAST UPDATED BY INFORMATION 16314 (URL.appSetCode NEQ "" or)  --->

	<cfif URL.appSetCode NEQ "0">
		<cfset appSettings = genSettingsManager.get(1,URL.appSetCode,1)>
		<cfif Len(appSettings.getUpdatedByUserName()) GT 0>
		<br />
		<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;margin-left:10;" CELLPADDING="3" CELLSPACING="0">
			<TR>
				<TD>
					<FONT SIZE="2">
						<B>
							The settings were last updated
							on #dateformat(appSettings.getUpdatedOn(), 'mm/dd/yyyy')#
							at #timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')#
							by #appSettings.getUpdatedByUserName()#
						</B>
					</FONT>
				</TD>
			</TR>
		</TABLE>
		<br>
		</cfif>
	</cfif>
</cfoutput>

<!--- ALERT FOR USERS TO TELL THEM TO CLICK SAVE AT THE BOTTOM OF THE PAGE --->
<div id="modifiedCont" style="display:none;">
	Changes have been made.	To keep your changes, click on the save link. <br />
	REMINDER:  After you change an attribute to active on this page, go to the Filter tab within the program template and update the attribute to display.
</div>

<!--- DISPLAY THE PAGE SELECTED --->
<cfif URL.incFile NEQ "">
	<cfinclude template="#URL.incFile#">
</cfif>

<cfsetting showdebugoutput="true" />