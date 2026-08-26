<!---
FILE:
FILENAME:     Common_Files/contracts/contract_letters.cfm
CREATED:     02/28/2008 - RBL
EDITED:        03/16/2009 - RBL [MVC v11]

FUNCTIONALITY:
--->

<cfsilent>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	<!--- 17386 [begin] --->
	<cfparam name="variables.authorRSPID" type="string" default="">
	<!--- 17386 [end] --->
	<!--- MVC V11 Edit [begin] --->

	<cfscript>
		application.oController.getObject("mvc.Models.LetterManager");
	</cfscript>

	<!--- MVC V11 Edit [end] --->
	<cfset objProgramClaimRatesReport = CreateObject("component","components.programs.ProgramClaimRatesReport").init()/>

</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<cfset PAGE_TITLE = "Attachments">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<script language="JavaScript" type="text/JavaScript">
		function reloadPage(init)
		{  //reloads the window if Nav4 resized
		  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
		    document.pgW=innerWidth; document.pgH=innerHeight; onresize=reloadPage; }}
		  else if (innerWidth!=document.pgW || innerHeight!=document.pgH) location.reload();
		}

		reloadPage(true);

		function findObj(n, d)
		{ //v4.0
		  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
		    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
		  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
		  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=findObj(n,d.layers[i].document);
		  if(!x && document.getElementById) x=document.getElementById(n); return x;
		}

		function hide_allLayers()
		{
			var length = document.getElementsByTagName('div').length;
			for (i=0; i<length; i++)
			{
				//alert(document.getElementsByTagName('DIV')[i].id);
				document.getElementsByTagName('DIV')[i].style.display = "none";
			}
		}

		function hideLayer(layerName)
		{
			document.getElementById(layerName).style.display='none';
		}

		function changedivheight(layerName,height)
		{
			<!---
			// 2015 aug 18 chrisn :: adjusting top position lead to elements overlay on top of each other! use normal html element layout flow instead
			--->
			// document.getElementById(layerName).style.top = height;
		}


		function showHideLayers()
		{ //v9.0
		  var i,p,v,obj,args=showHideLayers.arguments;
		  for (i=0; i<(args.length-2); i+=3)
		  with (document) if (getElementById && ((obj=getElementById(args[i]))!=null)) { v=args[i+2];
		    if (obj.style) { obj=obj.style; v=(v=='show')?'block':(v=='hide')?'none':v; }
		    obj.display=v; }
		}

		function selectAll(startIndex,endIndex)
		{
			var chObjs = document.all.Dist_ID;
			var i;

			if(chObjs)
			{
				if(chObjs.length)
				{
				  /* Unselect All checkboxes */
				  for(i=0;i<chObjs.length;i++)
				  {
				    chObjs[i].checked = false;
				  }

				  /* Select checkboxes for a range of indexes */
				  for(i=startIndex;i<endIndex;i++)
				  {
				    chObjs[i].checked = true;
				  }
				}
			}
		}

	function ChangeDivHeightButtonSettings()
	{
		var btn_height_1;
		var btn_height_2;

/* If "Both" option exists (sometimes we only have distributors or operators and not both in a program) */
	if(document.all.Letter_Type[2])
	{
	/* If "Both" is selected for the selection of distributors */
		if(document.all.Letter_Type[2].checked)
		{
			btn_height_1 =  520;
			btn_height_2 =  370;
		}
		else
		{
			btn_height_1 =  440;
			btn_height_2 =  290;
		}
	}
	/* If only one (either operator or distributor) exists */
	else
	{
			btn_height_1 =  440;
			btn_height_2 =  290;
	}
		ChangeDisplay(btn_height_1, btn_height_2)
	}

	/* Change the DIV heights */
	function ChangeDisplay(btn_height_1, btn_height_2)
	 {
		if(document.getElementById('distributors_list').style.display != "none")
		{
				changedivheight('button_settings',btn_height_1);
				changedivheight('distributors_list',btn_height_2);
		}
		else
		{
				changedivheight('button_settings',btn_height_1);
				changedivheight('distributors_list',btn_height_2);
		}
	 }

		<!--- NOTE: customer product numbers NEVER display on Any operator letters... --->
		function showHideCustomerProductNumber()
		{
		/*
		LEGEND [begin]:
		[form.bAddCustomerProductNumbers] 0=default, 1=ADD customer product numbers, 0=do NOT add customer product numbers (user has to go back and enter them)
		[form.bDisplayFreight] 0=default, 1=INCLUDE freight summary 0=do NOT include freight summary
		[form.bIncludeVolumePage] 0=default, 1=INCLUDE volume summary 0=do NOT include volume summary
		[form.bInsertWatermark] 0=default, 1=INSERT watermark for each letter w/client's logo in application per user/environment 0=do NOT insert a watermark
		[CSL_Contract_Main_ID] each iteration expects ONE contract_main_id. If string, employ trim()
		[form.customerFreightUom] cs=default, lb=Pounds will be the UOM for the freight summary area cs=Cases will be the UOM for the freight summary area. This does not affect any other area within the letters.
		[form.Distributor_Letter_Type] 0=default, 1=one distributor per distributor letter, 2=multiple distributors per distributor letter
		[form.dis_letter_settings] 1=one operator per distributor letter, 2=all operators per distributor letter
		[form.Letter_Type] ''=default, 1=operator, 2=distributor, 3=both
		[form.notification_type] 1=generate letters and send email, 2=generate letters WITHOUT email notification  (MUST always be 2 here)
		[form.Operator_Letter_Type] 0=default, 1=one operator per operator letter, 2=multiple operators per operator letter
		[form.Opr_letter_settings] 0=default, 1=one distributor per operator letter, 2=all distributors per operator letter
		:LEGEND [end]
		*/
			if(Letters.Letter_Type)
			{
				if(document.all.Letter_Type.length)
				{
					// show the CustomerProductNumber check box IF Distributor letters AND 1 distributor per letter OR Both Letters and 1 distributor per  distributor letter [arrays 0 based]
					if((document.all.Letter_Type[1].checked && document.all.Distributor_Letter_Type[0].checked) || (document.all.Letter_Type[2].checked && document.all.Distributor_Letter_Type[0].checked))
					{
						showHideLayers('bAddcustprodnum','','show');
						showHideLayers('distributors_list','','show');

						changedivheight('button_settings','520');
					}
					else
					{
						showHideLayers('bAddcustprodnum','','hide');
						showHideLayers('distributors_list','','hide');;
					}
				}
				else
				{
					// show the CustomerProductNumber check box IF Distributor letter OR Both letters AND 1 Distributor per distributor letter
					if(document.all.Letter_Type.checked && (document.all.Letter_Type.value == '2' || document.all.Letter_Type.value == '3') && document.all.Distributor_Letter_Type[0].checked)
					{
						showHideLayers('bAddcustprodnum','','show');
						showHideLayers('distributors_list','','show');
					}
					else
					{
						showHideLayers('bAddcustprodnum','','hide');
						showHideLayers('distributors_list','','hide');
					}
				}
			}
		}
		<!--- NOTE: customer product numbers NEVER display on Any operator letters... --->

		<!--- show/hide "discount type" options --->
		function showHideOptions(selectedOption,operFixed,distFixed,operRebate,distRebate,operLumpsum,distLumpsum)
		{
			/* By default, hide all "discount type" options */
			showHideLayers('id_incl_fixed_price','','hide');
			showHideLayers('id_letter_incl_rebate','','hide');
			showHideLayers('id_letter_incl_lumpsum','','hide');

			/* If "operator" or "both" option is selected.
			Show the discount type, if it is ON for "operator" on the template.
			*/
			if(selectedOption == 1 || selectedOption == 3){
				if(operFixed == 1){
					showHideLayers('id_incl_fixed_price','','show');
				}
				if(operRebate == 1){
					showHideLayers('id_letter_incl_rebate','','show');
				}
				if(operLumpsum == 1){
					showHideLayers('id_letter_incl_lumpsum','','show');
				}
			}
			/* If "distributor" or "both" option is selected.
			Show the discount type, if it is ON for "distributor" on the template.
			*/
			if(selectedOption == 2 || selectedOption == 3){
				if(distFixed == 1){
					showHideLayers('id_incl_fixed_price','','show');
				}
				if(distRebate == 1){
					showHideLayers('id_letter_incl_rebate','','show');
				}
				if(distLumpsum == 1){
					showHideLayers('id_letter_incl_lumpsum','','show');
				}
			}
		}
	</script>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="checkradiobuttons();showHideCustomerProductNumber();ChangeDivHeightButtonSettings();">
<style>
	#distributors_letters, #operator_letters, #distributors_list, #button_settings { margin:15px 0; width: 100%; display: none; }
	#distributors_list { margin-top:20px; }
	TABLE.Maintable TD	{border-bottom2:solid #93BEE2 1px; border-bottom:0px solid white; font-size: 11px;}
	td#header {font-size: 12px; padding:5px; background-color:#c6ffc6; }
</style>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfparam name="URL.CID"	default="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">

<cfif NOT len(trim(URL.CID))>
	<cfset temp = 0>
<cfelse>
	<cfset temp = cryp.value>
</cfif>

<cfset CSL_Contract_Main_ID = temp>
<cfset CSL_CallingPageCode = "letters">

<cfparam name="dis_divtop" default="280px">
<cfparam name="opr_divtop" default="180px">
<cfparam name="form.command" 	default="">
<cfparam name="form.Letter_Type" default="0">
<cfparam name="form.Operator_Letter_Type" default="0">
<cfparam name="form.Distributor_Letter_Type" default="0">
<cfparam name="form.Opr_letter_settings" default="0">
<!---	Dev Note:Milan (31709): When the program does not have operators and the user selects "one operator per letter" for distributor letters, no letters get generated as
	the code loops through operatotrs which do not exist. The letters generate only for "All operators per letter" option. I have disabled the "operator" option for distributor
	letters when there are no operators in the program."dis_letter_settings =2" ("All operators per letter") is the default. "dis_letter_settings" should always exist in
	the form, except in this scenario and so I have set it to 2.
--->
<cfparam name="form.dis_letter_settings" default="2">
<cfparam name="form.notification_type" default="0">

<cfparam name="form.bAddCustomerProductNumbers" type="boolean" 	default="0">
<cfparam name="form.bIncludeVolumePage" 		type="boolean" 	default="0">
<cfparam name="form.bInsertWatermark" 			type="boolean" 	default="0">
<cfparam name="form.Distributor_List" 			type="string" 	default="">
<!--- D16586 [begin] MUST default to 0 --->
<cfparam name="form.bDisplayFreight" 			type="boolean" 	default="0">
<!--- D16586 [end] MUST default to 0 --->

<!--- Dev Note: KAL; D15961: Add Claim Rate to Letters, Flag to check whether to display or not --->
<cfparam name="bShowClaimRateDate" 	type="boolean" 	default="0">
<cfif isDefined("form.claim_rate_date") and len(form.claim_rate_date)>
	<cfset bShowClaimRateDate = 1/>
<cfelse>
	<!--- if claim_rate_date is not defined pass in a dummy value --->
	<cfset form.claim_rate_date = DateFormat(now(), "mm/dd/yyyy") />
</cfif>
<cfparam name="form.Dist_ID" 	type="string" 	default="0">
<!--- Dev Note: Kal; D48572: Enhancement modifications to the Program Letters --->
<cfparam name="form.letter_incl_freight_pricing" 	type="boolean" 	default="1">
<cfparam name="form.letter_incl_fixed_price" 	type="boolean" 	default="0">
<cfparam name="form.letter_incl_rebate" 	type="boolean" 	default="0">
<cfparam name="form.letter_incl_lumpsum" 	type="boolean" 	default="0">
<cfparam name="form.IncludeInactive" 		type="boolean" default="0">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset generateLetters = 1>
<cfset generateLettersAccess = 0>

<!--- Only users who have "Generate_Program_Letters" profile setting are authorized to generate letters. When a user who has this profile setting turned ON
      visits this page, do the following:
      - Since the letters are automatically being generated on approval using the coldfusion scheduled task, look for the scheduled file name and the program ID.
        If both exist in the URL of the job, then do not allow the user to generate letters.

--->
<cfif Get_Profile_Settings.Generate_Program_Letters eq 1>

	<cfset generateLettersAccess = 1>

	<!--- Initialize the Java Service Factory --->
	<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">

	<!--- Get all the jobs from the JAVA service factory --->
	<cfset allTasks = factory.CronService.listAll()>
	<CFOUTPUT>
    <cfloop array="#allTasks#" item="task">
		<!--- Look for file name "Scheduled/approvalLetter.cfm" and program id in the url of the job. If both exist, then the automated
		letter generation job is still running for the program. Set generateLetters = 0, so that no user can generate the letter while
		the job is running.
		--->
		<cfif FindNoCase("#CGI.HTTP_HOST#/Scheduled/approvalLetter.cfm", task.url) neq 0 
            and FindNoCase(url.CID, task.url) neq 0 
            <!--- wr 103889 - ignore expired CF scheduled task due to unexpected problems --->
            and task.status neq "Expired">                   
			<cfset generateLetters = 0>
			<cfbreak>
		</cfif>        
	</cfloop>
	</CFOUTPUT>

</cfif>

<cfquery name="variables.qGetFreightComponentType" datasource="#application.datasource#">
	SELECT	Freight_Component_Type, Include_Claim_Rates_Report
  	FROM	Contract_main_Aux_Data
  	WHERE	Contract_Main_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- we do not show "claim rates" for "letters available - custom 2" app setting OR when "Dont_Show_Claim_Rates_On_Program_Letters" app setting is ON  --->
<cfif appSettings.getlettersavailable() neq 2 AND appSettings.get_Setting('Dont_Show_Claim_Rates_On_Program_Letters') eq '0'>
	<cfset bShowClaimRateDate = objProgramClaimRatesReport.IsClaimRatesAvailableOnProgram(CSL_Contract_Main_ID)>
</cfif>

<!--- D16586 [begin]
<cfset LetterManager = application.oController.getObject("mvc.Models.LetterManager") />
D16586 [end] --->
<cfif form.command EQ "save">

	<!--- To prevent certain errors. If non-existent, there will be no future action on this anyway... --->
	<cfparam name="form.customerFreightUom" 				type="string" 	default="Cs">

	<!--- letter manager wants this so... --->
	<cfset form.addcustomerproductnumbers = form.bAddCustomerProductNumbers>

    <!--- D16586 [begin] --->
	<cfset application.oLetterManager.saveLetterSettings(CSL_Contract_Main_ID, form,request.AccessStructure.user_id)>
    <!--- D16586 [end] --->

	<cfif form.notification_type EQ 2>

	  <!--- CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN [begin]
	  If we had the CPN checkbox checked and then selected a different type of letter, even though the box became invisible, it still may have a positive value.
	  This logic makes sure it's only positive when we say it is positive... and since we are passing it, let's tell it like it is.
	  DO NOT CHANGE WITHOUT DISCUSSING W/RBL --->

	  <!--- IF all required settings are not in place, turn off customer_product_numbers, similar to initial JS above which fires on pageLoad etc. This fires upon form submission. Insurance! NOTE: This logic addesses the value whereas the JS above addresses the visibility. Both important. --->
	  <cfswitch expression="#form.Letter_Type#">
	  	  <!--- operator letters only --->
	      <cfcase value="1">
	      	<!--- NOTE: customer product numbers NEVER display on Any operator letters, so this value is sort of irrelevent here... --->
	      	<!--- IF All distributors per letter, NO customer product numbers allowed, even if prior settings indicate they are requested!
	      	<cfif form.Opr_letter_settings NEQ 1> --->
	        	<!--- no, no, no... --->
	        	<cfset form.bAddCustomerProductNumbers = 0>
	        <!--- </cfif> --->
	      </cfcase>
	      <!--- customer/distributor letters only --->
	      <cfcase value="2">
	      	<!--- IF Multiple distributors per letter, NO customer product numbers allowed, even if prior settings indicate they are requested! --->
	      	<cfif form.Distributor_Letter_Type NEQ 1>
	        	<!--- no, no, no... --->
	        	<cfset form.bAddCustomerProductNumbers = 0>
	        </cfif>
	      </cfcase>
	      <!--- both operator and customer/distributor letters --->
	      <cfcase value="3">
	      	<!--- form.Opr_letter_settings NEQ 1 OR --->
	      	<cfif form.Distributor_Letter_Type NEQ 1>
	        	<!--- no, no, no... --->
	        	<cfset form.bAddCustomerProductNumbers = 0>
	        </cfif>
	      </cfcase>
	  </cfswitch>

	  <!--- CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN [end]
	  If we had the CPN checkbox checked and then selected a different type of letter, even though the box became invisible, it still may have a positive value.
	  This logic makes sure it's only positive when we say it is positive... and since we are passing it, let's tell it like it is. --->
	
	<!--- DO NOT USE "center=true" for "cfwindow". It does not work correctly on CF 11 and IE 11 combination. Instead of "center=true", x and y attribites have 
	been used. It might not put the window in the center, but at least it is accessible.	I could have left "center=true" along with x and y attributes below, 
	but did not,as x and y attributes do not work, if "center=true" exists.
	--->

	<cfwindow
	    x="500"
	    y="300"
	    closable="false"
	    draggable="true"
	    height=70
	    initShow="true"
	    modal="true"
	    name="pdfGeneration"
	    resizable="false"
	    source="letters/generate_opr_dis_letters.cfm?CMID=#CSL_Contract_Main_ID#&company_name=#request.AccessStructure.Company_Name#&custprodnum=#form.bAddCustomerProductNumbers#&volumepage=#form.bIncludeVolumePage#&watermark=#form.bInsertWatermark#&freightpage=#form.bDisplayFreight#&freightuom=#form.customerFreightUom#&claim_rate_date=#form.claim_rate_date#&Dist_ID=#form.Dist_ID#&letterInclFreightPricing=#form.letter_incl_freight_pricing#&letterInclFixedPrice=#form.letter_incl_fixed_price#&letterInclRebate=#form.letter_incl_rebate#&letterInclLumpsum=#form.letter_incl_lumpsum#&manuallyGenerated=1&IncludeInactive=#form.IncludeInactive#"
	    title="Requested PDF Letters Are NOW Being Generated!"
	    width=340/>

		<!--- 
		NOTE:
		WHILE DEBUGGING, WE NEED TO COMMENT "cfwindow" ABOVE, AND USE THE BELOW "CFLOCATION" CODE, INSTEAD.
		KEEP: WE WILL NEED KEEP THIS OCCASIONALLY FOR TESTING CFDUMPS...

	      <cflocation url="/common_files/contracts/letters/generate_opr_dis_letters.cfm?CMID=#CSL_Contract_Main_ID#&company_name=#request.AccessStructure.Company_Name#&custprodnum=#form.bAddCustomerProductNumbers#&volumepage=#form.bIncludeVolumePage#&watermark=#form.bInsertWatermark#&freightpage=#form.bDisplayFreight#&freightuom=#form.customerFreightUom#&claim_rate_date=#form.claim_rate_date#&Dist_ID=#form.Dist_ID#&letterInclFreightPricing=#form.letter_incl_freight_pricing#&letterInclFixedPrice=#form.letter_incl_fixed_price#&letterInclRebate=#form.letter_incl_rebate#&letterInclLumpsum=#form.letter_incl_lumpsum#&manuallyGenerated=1">
		--->

	<cfelseif form.notification_type EQ 1>

		<cfset StartDate = dateformat(now(), "mm/dd/yyyy")>
		<cfset addminutes = DateAdd("n", "10", now())>
		<cfset StartTime = TimeFormat(addminutes, "hh:mm:ss")>
		<!--- It was earlier being written to the "data_files" folder, but has been changed to "temp_files" so that it can be cleaned up regularly.
		Actually, writing this log file is not really needed, because if there is an error, we can always get the url from the scheduled task
		and run the job from the browser to generate the error, but "publish='no'" (check CFSCHEDULE below) does not work for cfschedule below. 
		So, one has to write a log file- Testing on CF 9.
		If we SET publish='no' on CFSCHEDULE, a job will be created, but on running the job, an error occurs. Seems to be a CF issue.
		--->
		<cfset thisPath="#Application.Doc_Path#\Temp_Files\">

	    <!--- CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN [begin]
	  If we had the CPN checkbox checked and then selected a different type of letter, even though the box became invisible, it still may have a positive value.
	  This logic makes sure it's only positive when we say it is positive... and since we are passing it, let's tell it like it is. --->

	  <!--- IF all required settings are not in place, turn off customer_product_numbers, similar to initial JS above which fires on pageLoad etc. This fires upon form submission. Insurance! NOTE: This logic addesses the value whereas the JS above addresses the visibility. Both important. --->
	  <cfswitch expression="#form.Letter_Type#">
	  	  <!--- operator letters only --->
	      <cfcase value="1">
	      	<!--- NOTE: customer product numbers NEVER display on Any operator letters, so this value is sort of irrelevent here... --->
	      	<!--- IF All distributors per letter, NO customer product numbers allowed, even if prior settings indicate they are requested!
	      	<cfif form.Opr_letter_settings NEQ 1> --->
	        	<!--- no, no, no... --->
	        	<cfset form.bAddCustomerProductNumbers = 0>
	        <!--- </cfif> --->
	      </cfcase>
	      <!--- customer/distributor letters only --->
	      <cfcase value="2">
	      	<!--- IF Multiple distributors per letter, NO customer product numbers allowed, even if prior settings indicate they are requested! --->
	      	<cfif form.Distributor_Letter_Type NEQ 1>
	        	<!--- no, no, no... --->
	        	<cfset form.bAddCustomerProductNumbers = 0>
	        </cfif>
	      </cfcase>
	      <!--- both operator and customer/distributor letters --->
	      <cfcase value="3">
	      	<!--- form.Opr_letter_settings NEQ 1 OR --->
	      	<cfif form.Distributor_Letter_Type NEQ 1>
	        	<!--- no, no, no... --->
	        	<cfset form.bAddCustomerProductNumbers = 0>
	        </cfif>
	      </cfcase>
	  </cfswitch>
	  <!--- CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN [end]
	  If we had the CPN checkbox checked and then selected a different type of letter, even though the box became invisible, it still may have a positive value.
	  This logic makes sure it's only positive when we say it is positive... and since we are passing it, let's tell it like it is. --->

			<!---
				D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
				Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
				"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
			--->
			<cfschedule action = "update"
	  		task = "Generate Letters - #CSL_Contract_Main_ID#"
	  		operation = "HTTPRequest"
	  		url = "#application.HTTPVar##CGI.HTTP_HOST#/scheduled/schedule_opr_dis_letters.cfm?CMID=#CSL_Contract_Main_ID#&user_id=#request.AccessStructure.user_id#&custprodnum=#form.bAddCustomerProductNumbers#&volumepage=#form.bIncludeVolumePage#&watermark=#form.bInsertWatermark#&freightpage=#form.bDisplayFreight#&freightuom=#form.customerFreightUom#&claim_rate_date=#form.claim_rate_date#&letterInclFreightPricing=#form.letter_incl_freight_pricing#&letterInclFixedPrice=#form.letter_incl_fixed_price#&letterInclRebate=#form.letter_incl_rebate#&letterInclLumpsum=#form.letter_incl_lumpsum#&manuallyGenerated=1"
	  		startDate = "#StartDate#"
	  		enddate = ""
	  		startTime = "#StartTime#"
	  		interval = "once"
	  		resolveURL = "Yes"
	  		publish = "Yes"
	  		file = "generate_letters_output_#CSL_Contract_Main_ID#.log"  <!--- D57544 --->
	  		path = "#thisPath#"
	  		requestTimeOut = "600">
	</cfif>

</cfif>

<cfset FORM.Contract_Main_ID = CSL_Contract_Main_ID>

<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px;">
  	<cfinclude template="contract_status_legend.cfm">
  </div>
<cfelse>
	<cfinclude template="contract_status_legend.cfm">
</cfif>
<blockquote>
<cfif GetSettings.freight_uom[1] EQ 1>
	<cfparam name="form.customerFreightUom" 				type="string" 	default="Cs">
<cfelse>
	<cfparam name="form.customerFreightUom" 				type="string" 	default="Lb">
</cfif>


<cfif application.programlayout EQ 1>

<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 150px; top: 10px;">
</cfif>

    <cfinclude template="minimal_contract_info.cfm">

    <cfinclude template="Contract_Documents_Menu.cfm">


    <!--- D16586 [begin] --->

    <cfset getLetterSettings = application.oLetterManager.getLetterSettings(CSL_Contract_Main_ID,request.AccessStructure.user_id)>
    <!--- D16586 [end] --->



    <cfif getLetterSettings.recordCount>

  		<cfset form.Letter_Type = getLetterSettings.Letter_Type>
  		<cfset form.Operator_Letter_Type = getLetterSettings.Operator_Letter_Type>
  		<cfset form.Distributor_Letter_Type = getLetterSettings.Distributor_Letter_Type>
  		<cfset form.Opr_letter_settings = getLetterSettings.Opr_letter_settings>
  		<cfset form.dis_letter_settings = getLetterSettings.dis_letter_settings>
  		<cfset form.notification_type = getLetterSettings.notification_type>

  		<!--- CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN [begin] --->

  		<!--- 1.) let's grab our customer_product_number boolean value from Letter Manager to start with --->
  		<cfset form.bAddCustomerProductNumbers = getLetterSettings.Addcustomerproductnumbers>

  		<!--- IF all required settings are not in place, turn off customer_product_numbers, similar to initial JS above which fires on pageLoad etc. This fires upon form submission. Insurance! NOTE: This logic addesses the value whereas the JS above addresses the visibility. Both important. --->
  		<cfswitch expression="#form.Letter_Type#">
  	  		<!--- operator letters only --->
      		<cfcase value="1">
      	    <!--- NOTE: customer product numbers NEVER display on Any operator letters, so this value is sort of irrelevent here... --->
      	    <!--- IF All distributors per letter, NO customer product numbers allowed, even if prior settings indicate they are requested!
      	<cfif form.Opr_letter_settings NEQ 1> --->
        	<!--- no, no, no... --->
        	<cfset form.bAddCustomerProductNumbers = 0>
            <!--- </cfif> --->
      		</cfcase>
      		<!--- customer/distributor letters only --->
      		<cfcase value="2">
      	    <!--- IF Multiple distributors per letter, NO customer product numbers allowed, even if prior settings indicate they are requested! --->
      	    <cfif form.Distributor_Letter_Type NEQ 1>
        	    <!--- no, no, no... --->
        	    <cfset form.bAddCustomerProductNumbers = 0>
            </cfif>
      		</cfcase>
      		<!--- both operator and customer/distributor letters --->
      		<cfcase value="3">
      	    <!--- form.Opr_letter_settings NEQ 1 OR --->
      	    <cfif form.Distributor_Letter_Type NEQ 1>
        	    <!--- no, no, no... --->
        	    <cfset form.bAddCustomerProductNumbers = 0>
            </cfif>
      		</cfcase>
  		</cfswitch>
  		<!--- CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN CPN [end]  --->

    </cfif>


    <!--- D16340 - NOTE: It appears that getLetterSettings() and GetSettings() interrelate and may collide due to data integrity issues. The code below seems to handle this particular problem but dependencies could be better architected... RBL 06/30/08 --->

<FORM ACTION="contract_letters.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>" METHOD="post" NAME="Letters" STYLE="DISPLAY:INLINE;width:750px;">
		<cfif (GetSettings.operator_letters_required EQ 1 and GetSettings.distributor_letters_required EQ 1)>
			<cfif isdefined("form.Letter_Type") and (form.Letter_Type EQ 1 or form.Letter_Type EQ 2)>
				<cfset dis_divtop = "157px">
        		<cfset opr_divtop = "168px">
    			<cfelse>
				<cfset dis_divtop = "267px">
        		<cfset opr_divtop = "168px">
    		</cfif>
			<cfelseif GetSettings.operator_letters_required EQ 1 and GetSettings.distributor_letters_required EQ 0>
 			<cfif isdefined("form.Letter_Type") and (form.Letter_Type EQ 1 or form.Letter_Type EQ 2)>
				<cfset dis_divtop = "157px">
        		<cfset opr_divtop = "168px">
    			<cfelse>
				<cfset dis_divtop = "267px">
        		<cfset opr_divtop = "168px">
    		</cfif>
			<cfelseif GetSettings.operator_letters_required EQ 0 and GetSettings.distributor_letters_required EQ 1>
 			<cfif isdefined("form.Letter_Type") and (form.Letter_Type EQ 1 or form.Letter_Type EQ 2)>
				<cfset dis_divtop = "157px">
        		<cfset opr_divtop = "168px">
    			<cfelse>
				<cfset dis_divtop = "267px">
        		<cfset opr_divtop = "168px">
    		</cfif>
		</cfif>
 		<table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>" class="maintable">
 			<tr>
 <td id="header">
 					<cfif GetSettings.operator_letters_required EQ 1 and GetSettings.distributor_letters_required EQ 1>
 <b>Do you want to create <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> letters, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> letters or both?</b>
 						<cfelseif GetSettings.operator_letters_required EQ 1 and GetSettings.distributor_letters_required EQ 0>
  <b>Do you want to create <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> letters?</b>
 						<cfelseif GetSettings.operator_letters_required EQ 0 and GetSettings.distributor_letters_required EQ 1>
  <b>Do you want to create <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> letters?</b>
 					</cfif>
 </td>
			</tr>
 			<tr>
 				<td>
				<cfoutput>
				<cfif GetSettings.operator_letters_required EQ 1>
 						<input name="Letter_Type" type="radio" value="1" onClick="hideLayer('distributors_letters');showHideLayers('operator_letters','','show');showHideLayers('button_settings','','show');showHideLayers('claimRateDate','','hide');ClearSelection();
						showHideOptions('1','#GetSettings.Operator_Fixed_Pricing#','#GetSettings.Distributor_Fixed_Pricing#','#GetSettings.Operator_Rebate#','#GetSettings.Distributor_Rebate#','#GetSettings.Operator_Lumpsum#','#GetSettings.Distributor_Lumpsum#')"
 <cfif (GetSettings.operator_letters_required EQ 1 and GetSettings.distributor_letters_required EQ 0) OR (form.Letter_Type EQ 1)>checked</cfif>>
						<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Letters<br>
 					</cfif>
 					<!--- showHideFreightPageOptions(); --->
 					<cfif GetSettings.distributor_letters_required EQ 1>
 						<input name="Letter_Type" type="radio" value="2" onClick="hideLayer('operator_letters');showHideLayers('distributors_letters','','show');changedivheight('distributors_letters','180px');showHideLayers('button_settings','','show');showHideLayers('claimRateDate','','show');
						showHideOptions('2','#GetSettings.Operator_Fixed_Pricing#','#GetSettings.Distributor_Fixed_Pricing#','#GetSettings.Operator_Rebate#','#GetSettings.Distributor_Rebate#','#GetSettings.Operator_Lumpsum#','#GetSettings.Distributor_Lumpsum#')"
 <cfif (GetSettings.operator_letters_required EQ 0 and GetSettings.distributor_letters_required EQ 1) OR (form.Letter_Type EQ 2)>checked</cfif>>
						<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Letters<br>
 					</cfif>
 					<!--- showHideFreightPageOptions(); --->
					<cfif GetSettings.operator_letters_required EQ 1 and GetSettings.distributor_letters_required EQ 1>
 						<input name="Letter_Type" type="radio" value="3" onClick="showHideLayers('operator_letters','','show');showHideLayers('distributors_letters','','show');changedivheight('distributors_letters','280px');showHideLayers('button_settings','','show');showHideLayers('claimRateDate','','show');
						showHideOptions('3','#GetSettings.Operator_Fixed_Pricing#','#GetSettings.Distributor_Fixed_Pricing#','#GetSettings.Operator_Rebate#','#GetSettings.Distributor_Rebate#','#GetSettings.Operator_Lumpsum#','#GetSettings.Distributor_Lumpsum#')"
						<cfif form.Letter_Type EQ 3>checked</cfif>>
						Both
 					</cfif>
 					<!--- showHideFreightPageOptions(); --->
				</cfoutput>
 </td>
			</tr>
 		</table>

 <div id="operator_letters">
			<table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>" class="maintable">
				<tr>
	<td id="header" colspan="2">
		<b><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Section:</b>
	</td>
				</tr>
				<tr>
					<td width="50%" valign="top">
		Should the letter contain only 1 or multiple <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>?<br>
						<input name="Operator_Letter_Type" type="radio" value="1" <cfif form.Operator_Letter_Type EQ 1 OR form.Operator_Letter_Type EQ 0>checked</cfif>>
						One <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> per Letter<br>
 						<input name="Operator_Letter_Type" type="radio" value="2" <cfif form.Operator_Letter_Type EQ 2>checked</cfif>>
						Multiple <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> per Letter<br>
	</td>
					<td width="50%" valign="top">
						<!--- For HTML letters - Do not provide an option to include distributor info for OPERATOR LETTERS --->
						<cfif appSettings.getlettersavailable() neq 2>
		Should the letter contain only 1 or all or no <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>?<br>

							<input name="Opr_letter_settings" type="radio" value="1" <cfif form.Opr_letter_settings EQ 1>checked</cfif>>
							One <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> per Letter<br>
 							<input name="Opr_letter_settings" type="radio" value="2" <cfif form.Opr_letter_settings EQ 2 OR form.Opr_letter_settings EQ 0>checked</cfif>>
							All <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput><br>
							<cfelse>
		<br />
						</cfif>
		 				<!--- When there is no freight --->
		 				<cfif (application.appSettingsGet.getshow_fixed_freight() AND variables.qGetFreightComponentType.Freight_Component_Type[1] NEQ 0 AND variables.getSettings.include_freight_summary AND variables.getSettings.freight_program) eq 0>
		 					<input name="Opr_letter_settings" type="radio" value="3" <cfif form.Opr_letter_settings EQ 3 OR appSettings.getlettersavailable() eq 2>checked</cfif>>
							No <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput><br>
						</cfif>
	</td>
				</tr>
			</table>
		</div>
 <div id="distributors_letters">
 			<table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>" class="maintable" cellspacing="0">
				<tr>
	<td id="header" colspan="2">
		<b><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Section:</b>
	</td>
				</tr>
				<tr>
					<td width="50%">
		Should the letter contain only 1 or multiple <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>?<br>
						<input name="Distributor_Letter_Type" type="radio" value="1" <cfif form.Distributor_Letter_Type EQ 1 OR form.Distributor_Letter_Type EQ 0>checked</cfif>>
						One <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> per Letter<br>
 						<input onClick="ClearSelection();" name="Distributor_Letter_Type" type="radio" value="2" <cfif form.Distributor_Letter_Type EQ 2>checked</cfif>>
						Multiple <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> per Letter<br>
	</td>
					<td width="50%">
		Should the letter contain only 1 or all <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>?<br>
						<!--- If there are no operators on the program, disable the "operator" option. By default we have the "All operator per letter" (dis_letter_settings = 2) selected using cfparam at the top of the file --->
						<input name="dis_letter_settings" type="radio" value="1" <cfif form.dis_letter_settings EQ 1 AND CSLGetOperators.recordcount neq 0>checked</cfif><cfif CSLGetOperators.recordcount eq 0> disabled</cfif>>
						One <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> per Letter<br>
						<input name="dis_letter_settings" type="radio" value="2" <cfif (form.dis_letter_settings EQ 2 OR form.dis_letter_settings EQ 0) AND CSLGetOperators.recordcount neq 0>checked</cfif><cfif CSLGetOperators.recordcount eq 0> disabled</cfif>>
 		All <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput><br>
	</td>
				</tr>
			</table>
		</div>
		<!--- Get the count of distributors --->
 	    <cfset Dist_Count = checkForDistributors.recordcount>

        <!--- For HTML Letters - Check the number of DISTRIBUTOR GROUPS in the program --->
   		<cfif appSettings.getlettersavailable() eq 2>
			<CFQUERY NAME="checkGroupDistributorCount" datasource="#application.datasource#">
	  SELECT Count(Contract_Main_ID) As DistGroupNumber
	  FROM Contract_Distributors
	  WHERE	Contract_Main_ID =
			<cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
	  AND Is_Group = 1
	  AND Deleted = 0
			</CFQUERY>
		    <!--- If there are distributor groups in the program, then get this count, instead of the "distributor count" --->
		    <cfif checkGroupDistributorCount.DistGroupNumber GT 0>
	 		    <cfset Dist_Count = checkGroupDistributorCount.DistGroupNumber>
		    </cfif>
   		</cfif>

	    <!--- Divide the distributor count by 25. We want to select 25 distributors at a time --->
	    <cfset Dist_Count_Grouped = ceiling(Dist_Count / 25)>
	    <cfset Distributor_Cumulative_Count = 0>

 		<div id="distributors_list" style="display:none;">
 <span id="error_dist_list"></span>

 <!--- Search page using keyword(s). --->
 <CFINCLUDE TEMPLATE="/includes/Search_on_Page.cfm">
 			<table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>" class="maintable">
   				<tr>
     <td id="header" colspan="2">
	<b>Select <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> (25 Maximum):</b> &nbsp;

	<cfoutput>

							<!--- If it's not the default option (selectedindex = 0) selected, then pass the value of the selected option and the one before it.
	For default option, use -1,-1. We just want to unselect all checkboxes for the default option.
	--->
							<select name="Distributor_List" onChange="if(this.options[this.selectedIndex].value != 0){selectAll(this.options[this.selectedIndex-1].value,this.value)}else{selectAll(-1,-1)}">
								<option value="0">Select #application.returned_customer_setting.distributor_label_plural#</option>
								<!--- Loop through the different distributor sets (sets of 25 or less - for the last entry)). So, if we have a count of 79 distributors,
	there will be 4 sets, 3 for sets of 25 and 4 (balance) for the fourth set.
	--->
								<cfloop from="1" to="#Dist_Count_Grouped#" index="i">
									<!-- Eg: For "4th" --->
	  								<cfset Number_Appened = "th">

									<!--- Logic to change the "Number_Append" value --->
	 								<cfif Right(i,1) eq 1 AND Right(i,2) neq 11>
	  									<!-- Eg: For "1st" --->
	  									<cfset Number_Appened = "st">
	 									<cfelseif Right(i,1) eq 2 AND  Right(i,2) neq 12>
	  									<!-- Eg: For "2nd" --->
	  									<cfset Number_Appened = "nd">
										<cfelseif  Right(i,1) eq 3 AND  Right(i,2) neq 13>
	  									<!-- Eg: For "3rd" --->
	  									<cfset Number_Appened = "rd">
									</cfif>

	  								<!--- If its not the last set of distributors  OR the distributor count is 25 --->
	  								<cfif i neq Dist_Count_Grouped OR Dist_Count MOD 25 eq 0>
	    								<cfset Distributor_Count = 25>
	  									<cfelse>
	  									<!--- If its the last set of distributors, get the remainder --->
	    								<cfset Distributor_Count = Dist_Count MOD 25>
	  								</cfif>
	  								<!--- Keep a track of the cumulative distributor count --->
	  								<cfset Distributor_Cumulative_Count = Distributor_Cumulative_Count + Distributor_Count>
									<option value="#Distributor_Cumulative_Count#">
									<cfif i neq Dist_Count_Grouped>
										#i##Number_Appened#
										<cfelse>
										Last
									</cfif>
									 batch of #Distributor_Count# #lcase(application.returned_customer_setting.distributor_label_plural)#
		</option>

								</cfloop>
							</select>

	</cfoutput>
     </td>
				</tr>

   				<!--- For HTML Letters - Check whether the program has DISTRIBUTOR GROUPS --->
   				<cfif appSettings.getlettersavailable() eq 2>
					<CFQUERY NAME="checkForIsGroupDistributors" datasource="#application.datasource#">
	  SELECT TOP 1 Contract_Main_ID
	  FROM Contract_Distributors
	  WHERE	Contract_Main_ID =
					<cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
	  AND Is_Group = 1
	  AND Deleted = 0
					</CFQUERY>

					<cfset bIsGroup = checkForIsGroupDistributors.recordcount>
   				</cfif>

				<cfset recordNumber = 0>
 	<cfoutput query="checkForDistributors">
					<cfquery name="qgetDistName" datasource="#application.datasource#">
			SELECT Name, ship_to
			FROM BSA_Foodservice_Customers
			WHERE BSA_Foodservice_Customers_ID =
					<cfqueryparam value="#BSA_Foodservice_Customers_ID#" cfsqltype="cf_sql_idstamp">
					<!--- For HTML Letters --->
					<cfif appSettings.getlettersavailable() eq 2>
						<!---
					-  Get only groups, if the program has distributor groups
				  	-  Get only distributors, if the program has distributors (no groups)
			 --->
						<!--- If the program has distributor groups --->
						<cfif bIsGroup>
				 AND Ship_To = 'Group'
							<!--- If the program has distributors (no groups) --->
							<cfelse>
				 AND Ship_To != 'Group'
						</cfif>
			  		</cfif>
			  Order by Name
					</cfquery>

					<!--- For HTML Letters, not all execution of "qgetDistName" query will return a result and that is why the "recordnumber" variable is being used.
		      For non-HTML letters (Itext), we can still use "checkForDistributors.currentrow", but it is being assigned to a variable called "recordNumber",
		      so that the "recordNumber" variable can be the only variable being used.
		 --->
		 			<!--- The logic below shows distributors in a two-column format --->
					<cfif qgetDistName.recordcount GT 0>
						<cfif appSettings.getlettersavailable() eq 2>
							<cfset recordNumber = recordNumber + 1>
							<cfelse>
							<cfset recordNumber = checkForDistributors.currentrow>
						</cfif>
			<cfif recordNumber mod 2 eq 1>
						<tr></cfif>
							<td width="50%">
								<input type="checkbox" name="Dist_ID" ID="Dist_ID" value="#BSA_Foodservice_Customers_ID#">
								#qgetDistName.Name#&nbsp;(#qgetDistName.ship_to#)</td><cfif recordNumber mod 2 eq 0>
						</tr>
					</cfif>
					<cfif recordNumber mod 2 eq 1 AND checkForDistributors.recordcount eq recordNumber></tr>
					</cfif>
		</cfif>
	</cfoutput>
			</table>
		</div>
		<!--- <cfdump var="#GetSettings#" expand="true" /> --->

		<div id="button_settings" style="display:none;">
 			<table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>">
 				<!--- Dev Note: 3/25/15 Kal; D48572: Enhancement modifications to the Program Letters --->
				<tr>
					<cfif variables.qGetFreightComponentType.Freight_Component_Type[1] NEQ 0 AND variables.getSettings.include_freight_summary >
						<td width="50%" nowrap>
							<!--- <input type="checkbox" name="letter_incl_freight_pricing" id="letter_incl_freight_pricing" value="1" <cfif form.letter_incl_freight_pricing>checked</cfif>>Include Pricing with Freight  --->
							<input type="checkbox" name="bDisplayFreight" id="bDisplayFreight" value="1" checked>
							Include Pricing with Freight. &nbsp;&nbsp;&nbsp;
				Freight UOM -
							<input name="customerFreightUom" type="radio" value="Lb" <cfif form.customerFreightUom EQ 'Lb'>checked</cfif>>
							Lb
							<input name="customerFreightUom" type="radio" value="Cs" <cfif form.customerFreightUom EQ 'Cs'>checked</cfif>>
							Cs
			</td>
					</cfif>
					<!--- For "standard letters" only. --->
					<cfif appSettings.getlettersavailable() eq 1 and (GetSettings.Operator_Rebate eq 1 OR GetSettings.Distributor_Rebate eq 1) >
						<!--- Dev Note:75652 and 75743 - Look for a selected disount type (checkbox selection). Since we should only have one span for "error_discount_type",
						we are using the "cfsavecontent" technique. --->
						<cfif Not IsDefined("discountError")>
							<cfsavecontent variable="discountError"><span id="error_discount_type"></span></cfsavecontent>
							<cfoutput>#discountError#</cfoutput>
						</cfif>
						<td width="50%" nowrap  id="id_letter_incl_rebate">
							<input type="checkbox" name="letter_incl_rebate" id="letter_incl_rebate" value="1" <cfif (GetSettings.Operator_Rebate_Default eq 1 AND form.Letter_Type neq 2) OR (GetSettings.Distributor_Rebate_Default eq 1  AND form.Letter_Type neq 1)>checked</cfif>>
							Include Rebate
			</td>
					</cfif>
	</tr>
				<tr>
					<!--- For "standard letters" only. --->
					<cfif appSettings.getlettersavailable() eq 1 and (GetSettings.Operator_Fixed_Pricing eq 1 OR GetSettings.Distributor_Fixed_Pricing eq 1) >
						<!--- Dev Note:75652 and 75743 - Look for a selected disount type (checkbox selection). Since we should only have one span for "error_discount_type",
						we are using the "cfsavecontent" technique. --->
						<cfif Not IsDefined("discountError")>
							<cfsavecontent variable="discountError"><span 	id="error_discount_type"></span></cfsavecontent>
							<cfoutput>#discountError#</cfoutput>
						</cfif>
						<td width="50%" nowrap  id="id_incl_fixed_price">
							<input type="checkbox" name="letter_incl_fixed_price" id="letter_incl_fixed_price" value="1" <cfif (GetSettings.Operator_Fixed_Pricing_Default eq 1 AND form.Letter_Type neq 2) OR (GetSettings.Distributor_Fixed_Pricing_Default eq 1  AND form.Letter_Type neq 1) >checked</cfif>>
							Include Fixed Price
			</td>
					</cfif>
					<!--- For "standard letters" only. --->
					<cfif appSettings.getlettersavailable() eq 1 and (GetSettings.Operator_Lumpsum eq 1 OR GetSettings.Distributor_Lumpsum eq 1) >
						<!--- Dev Note:75652 and 75743 - Look for a selected disount type (checkbox selection). Since we should only have one span for "error_discount_type",
						we are using the "cfsavecontent" technique. --->
						<cfif Not IsDefined("discountError")>
							<cfsavecontent variable="discountError"><span id="error_discount_type"></span></cfsavecontent>
							<cfoutput>#discountError#</cfoutput>
						</cfif>
						<td width="50%" nowrap id="id_letter_incl_lumpsum">
							<input type="checkbox" name="letter_incl_lumpsum" id="letter_incl_lumpsum" value="1" <cfif (GetSettings.Operator_Lumpsum_Default eq 1 AND form.Letter_Type neq 2) OR (GetSettings.Distributor_Lumpsum_Default eq 1  AND form.Letter_Type neq 1) >checked</cfif>>
							Include Lump Sum
			</td>
					</cfif>
	</tr>
 				<!--- This additional features are only for standard letters only. These are not for HTML letters --->
 				<cfif appSettings.getlettersavailable() neq 2>
   					<tr>
     					<td width="50%" nowrap>
      						<input type="checkbox" name="bIncludeVolumePage" value="1" <cfif form.bIncludeVolumePage>checked</cfif>>
							Include Volume Summary
     </td>
						<td width="50%" nowrap>
      						<input type="checkbox" name="bInsertWatermark" value="1" <cfif form.bInsertWatermark>checked</cfif>>
							Insert Watermark
     </td>
					</tr>
   					<tr>
     					<td width="50%" nowrap id="bAddcustprodnum">
							<input type="checkbox" name="bAddCustomerProductNumbers" value="1" <cfif form.bAddCustomerProductNumbers>checked</cfif>>
							Add Customer Product Numbers </td>
						<!--- D48572: Moved the setting above and also dropped some of the conditions for displaying the freight option
	<td width="50%" nowrap>
     	<!--- D16586 [begin] id="bDisplayFreight" --->
	   					<cfif application.appSettingsGet.getshow_fixed_freight() AND variables.qGetFreightComponentType.Freight_Component_Type[1] NEQ 0 AND variables.getSettings.include_freight_summary AND variables.getSettings.freight_program>
							<input type="checkbox" name="bDisplayFreight" value="1" checked>
							Include Freight Summary
							<input name="customerFreightUom" type="radio" value="Lb" <cfif form.customerFreightUom EQ 'Lb'>checked</cfif>>
							Freight UOM - Lb
							<input name="customerFreightUom" type="radio" value="Cs" <cfif form.customerFreightUom EQ 'Cs'>checked</cfif>>
							Freight UOM - Cs
	    					<cfelse>
	    	&nbsp;
						</cfif>

      					<!--- D16586 [end] wrapped bDisplayFreight checked w/boolean condition AND added more initial requirements for a total of 5 --->
     </td>--->
   </tr>
 				</cfif>
 	<tr>
 		<td width="50%" nowrap>
			<input type="checkbox" name="IncludeInactive" value="1" <cfif form.IncludeInactive>checked</cfif>> Include Inactive Items
		</td>
	</tr>
   				<tr>
					<td width="50%" nowrap>
						<input name="notification_type" type="radio" value="1" <cfif form.notification_type EQ 1>checked</cfif>>
						Generate Letters - Send Email Notification<br>
						<input name="notification_type" type="radio" value="2" <cfif form.notification_type EQ 2 OR form.notification_type EQ 0>checked</cfif>>
						Generate Letters Now
	</td>
					<!--- Dev Note: KAL; D15961: Add new column for claim rates to letters : When to show date for claim rate in the letter generation form
			-- Program should have at least one fixed price component with claim mechanics include in claim rate = ON
			-- The letter is a distributor letter (this will decide when to show/hide or enable/disable the date field )
	--->

					<td width="50%" id="claimRateDate" nowrap>
						<cfif bShowClaimRateDate>
							<cfset DaysOfHistoricalDataForSpecialPriceList = application.appSettingsGet.getDaysOfHistoricalDataForSpecialPriceList()/>
			Claim Rate Date: <CF_EASYDATE FORMNAME="Letters" FIELDNAME="claim_rate_date" FORMAT="mm/dd/yyyy" DEFAULT="" >
						</cfif>
		&nbsp;
		<span id="error_claim_rate_date"></span>
	</td>
				</tr>
   				<tr>
  					<td colspan="2">&nbsp;</td>
				</tr>

   				<!--- "generateLettersAccess" - Only users who have "Generate_Program_Letters" profile setting are authorized to generate letters. --->

   				<!--- "generateLetters" - Since the letters are automatically being generated on approval using the coldfusion scheduled task, look for the scheduled
   file name and the program ID. If both exist in the URL of the job, then do not allow the user to generate letters. Once the job finishes, then
   enable the link to allow access.
    --->
   				<cfif generateLettersAccess eq 1>
      <cfoutput>
  						<tr>
							<td colspan="2" align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Generate Letters"
			button_action	=	"submitForm(document.Letters, 'save');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Generate Letters"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			enabled			=	"#generateLetters#"
			>
		</td>
						</tr>
						<cfif generateLetters eq 0>
     						<tr>
								<td colspan="2" align="left">
		<font color="red"><b>THE AUTOMATED LETTER GENERATION PROCESS IS CURRENTLY IN PROGRESS FOR THIS PROGRAM.<b/></font>
		</td>
							</tr>
						</cfif>
      </cfoutput>
    				<cfelse>
     				<tr>
						<td colspan="2" align="left">
		<font color="red"><b>YOUR PROFILE DOES NOT HAVE AUTHORIZATION TO GENERATE LETTERS.<b/></font>
		</td>
					</tr>
    			</cfif>
			</table>
		</div>
		<input type="hidden" name="command" value="#form.command#">
    </form>
	<cfinclude template="/common_files/jQuery.cfm">

<!--- If "operator" letters  option was turned ON on the template, and the user created that letter and then later turned OFF that option on the template.
OR
If "distributor" letters  option was turned ON on the template, and the user created that letter and then later turned OFFF that option on the template.
OR
If "distributor" letter and "operator" letter option was turned ON on the template, and the user created the letter using the "Both" option, and then later turned OFFF 
either one of the options.

In any of the above cases, set the form.Letter_Type to 0, as that particular "form.Letter_Type", be it 1 or 2 or 3, is not available anymore.
--->
<cfif (form.Letter_Type eq 1 AND GetSettings.operator_letters_required eq 0) 
	OR 
	(form.Letter_Type eq 2 AND GetSettings.distributor_letters_required eq 0)
	OR
	(
	(form.Letter_Type eq 3 AND (GetSettings.operator_letters_required eq 0 OR GetSettings.distributor_letters_required eq 0))
	)>
	<cfset form.Letter_Type = 0>
</cfif>

<script>
 function checkradiobuttons()
 {

 	if(Letters.Letter_Type)
	{

		<!--- defaulted above so always visible, isdefined("form.Letter_Type") and  --->
		<cfif form.Letter_Type NEQ 0>

			Letters.Letter_Type.value = <cfoutput>#form.Letter_Type#</cfoutput>;
			Letters.Letter_Type.checked = true;

			/* Letters.Letter_Type.value -1 below means:
			Letters.Letter_Type.value = 1 (minus 1) is operator letters which has index of 0.
			Letters.Letter_Type.value = 2 (minus 1) is distributor letters which has index of 1.
			Letters.Letter_Type.value = 3 (minus 1) is operator and distributor letters which has index of 2.
			*/
			if(document.Letters.Letter_Type[Letters.Letter_Type.value -1]){
				callfireEvent(document,document.Letters.Letter_Type[Letters.Letter_Type.value -1],'Click');
			}

		<cfelse>
			Letters.Letter_Type.checked = false;
			/* Letters.Letter_Type.value -1 below means:
			Letters.Letter_Type.value = 1 (minus 1) is operator letters which has index of 0.
			Letters.Letter_Type.value = 2 (minus 1) is distributor letters which has index of 1.
			Letters.Letter_Type.value = 3 (minus 1) is operator and distributor letters which has index of 2.
			*/
			if(document.Letters.Letter_Type[Letters.Letter_Type.value -1]){
				callfireEvent(document,document.Letters.Letter_Type[Letters.Letter_Type.value -1],'Click');
			}
		</cfif>

		if(Letters.Letter_Type.checked)
		{
			if (Letters.Letter_Type.value == 1)
			{
				showHideLayers('operator_letters','','show');
				showHideLayers('button_settings','','show');
				showHideLayers('claimRateDate','','hide');
			}
			else if(Letters.Letter_Type.value == 2)
			{
				showHideLayers('distributors_letters','','show');
				showHideLayers('button_settings','','show');
				showHideLayers('claimRateDate','','show');
			}
			else if(Letters.Letter_Type.value == 3)
			{
				showHideLayers('operator_letters','','show');
				showHideLayers('distributors_letters','','show');
				showHideLayers('button_settings','','show');
				showHideLayers('claimRateDate','','show');
			}
		}
	}
 }


// 15961 : Add Claim Rate to the PDF letters
function submitForm(thisForm, sCommand)
{
	var ErrorCount = 0;
	var NoDistributors = 0;
	var discountSelected = 0;

	<cfif bShowClaimRateDate>
		if(document.getElementById('claimRateDate').style.display != "none"){
			var minDate = new Date();
			var future_date = new Date();
			var enteredDate = document.Letters.claim_rate_date.value;
			var pgmEffStartDate = '<cfoutput>#DateFormat(CSLGetContractInfo.Effective_Start_Date,"mm/dd/yyyy")#</cfoutput>';
			var pgmEffEndDate = '<cfoutput>#DateFormat(CSLGetContractInfo.Effective_End_Date,"mm/dd/yyyy")#</cfoutput>';
		 	var daysLimit = <cfoutput>#application.appSettingsGet.getDaysOfHistoricalDataForSpecialPriceList()#</cfoutput>;
			var daysOfFutureData = <cfoutput>#val(application.oApplicationAppSettingsManager.getApplicationAppSettings().getMaxFutureDaysForClaimRatesORPricingExtract())#</cfoutput>;


			// Set the minDate to the least possible date based on appsetting
			minDate.setDate(minDate.getDate() - daysLimit);
			enteredDate = new Date(enteredDate);
			pgmEffStartDate = new Date(pgmEffStartDate);
			pgmEffEndDate = new Date(pgmEffEndDate);
			future_date.setDate(future_date.getDate() + daysOfFutureData); // get the date which is 45 days in the future


			// clear error msgs
			clearQueue(document.all.error_claim_rate_date);
			if(isNaN(enteredDate)){
				ErrorCount++;
				queueMessage("please enter a valid date for claim rate date",  document.all.error_claim_rate_date);
			}
			if (enteredDate < minDate){
				ErrorCount++;
				queueMessage("claim rate date cannot be earlier than "+ daysLimit + " days",  document.all.error_claim_rate_date);
			}
			if (enteredDate < pgmEffStartDate){
				ErrorCount++;
				queueMessage("claim rate date cannot be earlier than program effective start date",  document.all.error_claim_rate_date);
			}
			if (enteredDate > pgmEffEndDate){
				ErrorCount++;
				queueMessage("claim rate date cannot be after program effective end date",  document.all.error_claim_rate_date);
			}
			if (enteredDate > future_date){
				ErrorCount++;
				queueMessage("claim rate date cannot be over "+ daysOfFutureData + " days in future",  document.all.error_claim_rate_date);
			}
		}
	</cfif>


	/* Only if the distributor list exists on the page */
	if(document.getElementById('distributors_list').style.display != "none")
	{
		clearQueue(document.all.error_dist_list);

		var TotalSelected = 0;

		for (i=0;i<document.Letters.length;i++)
		{
			inputObj = Letters[i];
			Element_Name_ = inputObj.getAttribute('name');

				if(Element_Name_ != null){
					if (Element_Name_.indexOf('Dist_ID') != -1)
					{
						if(inputObj.checked)
						{
							TotalSelected = TotalSelected + 1;
							/* As soon as the distributor count reaches 26 and when "No Distributor" option is not selected for operator letters */
							//if(TotalSelected == 26 && NoDistributors == 0)
							if(TotalSelected == 26)
							{

								ErrorCount++;
								queueMessage("You cannot select more than 25 <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>",  document.all.error_dist_list);
							}
						}
					}
				}
		}

		/* At least one distributor should be selected and when "No Distributor" option is not selected for operator letters */
		//if(TotalSelected == 0  && NoDistributors == 0)
		if(TotalSelected == 0)
		{
			ErrorCount++;
			queueMessage("You must select at least one <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>",  document.all.error_dist_list);
		}
	}
	
	/* If "Include rebate" checkbox exists */
	if (typeof document.getElementById('letter_incl_rebate') != "undefined") {
		discountSelected = discountSelected + $("#letter_incl_rebate").is(":checked");
	}
	/* If "Include fixed price" checkbox exists */
	if (typeof document.getElementById('letter_incl_fixed_price') != "undefined") {
		discountSelected = discountSelected + $("#letter_incl_fixed_price").is(":checked");
	}
	/* If "Include fright" checkbox exists */
	if (typeof document.getElementById('bDisplayFreight') != "undefined") {
		discountSelected = discountSelected + $("#bDisplayFreight").is(":checked");
	}
	/* If "Include lumpsum" checkbox exists */
	if (typeof document.getElementById('letter_incl_lumpsum') != "undefined") {
		discountSelected = discountSelected + $("#letter_incl_lumpsum").is(":checked");
	}
	
	/* If "include discount type" option exists. eg: "Include rebate" or "include fixed price" checkbox */
	<cfif IsDefined("discountError")>
		clearQueue(document.all.error_discount_type);

		if(discountSelected == 0){
			ErrorCount++;
			queueMessage("You must select at least one dicount type",  document.all.error_discount_type);
		}
	</cfif>

	if(ErrorCount==0){
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
	else{
		showMessageWindow();
	}

}

/* Clear the selected distributors */
function ClearSelection()
{
	for (i=0;i<document.Letters.length;i++)
	{
			inputObj = Letters[i];
			Element_Name_ = inputObj.getAttribute('name');

			if(Element_Name_ != null){
				if (Element_Name_.indexOf('Dist_ID') != -1)
				{
					inputObj.checked = false;
				}
			}
	}
}

/* This works like "onPropertyChange", which has been removed from IE 11 onwards. If the selections in the following radio buttons change,
then call the functions inside the "change" function.
*/
$("input[name=Letter_Type]:radio").change(function () {showHideCustomerProductNumber();ChangeDivHeightButtonSettings();  });
$('input[name=Opr_letter_settings]:radio').change(function() {showHideCustomerProductNumber();ChangeDivHeightButtonSettings();  });
$('input[name=Distributor_Letter_Type]:radio').change(function() { showHideCustomerProductNumber();ChangeDivHeightButtonSettings(); });
</script>
 <CF_MessageWindow>
 <cfif application.programlayout EQ 1>
 </div>
 </cfif>
 </body>
 </html>