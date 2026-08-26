<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/Upload_Automation/index.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  20-Apr-20
Created By   :  Anand Rao
Description  :  
---------------------------------------------------------------------------------->


<cfset activeTab = 1 />
<cfset frmDelIdExisted = 0 />

<cfif (isDefined("URL.refreshScreen") AND URL.refreshScreen EQ 1)>
 <cfset clf = StructClear(FORM)>
 <cfset clu = StructClear(URL)>
</cfif>

<cfparam name="FORM.deleteUploadID" default="0" />
<cfif (isDefined("FORM.deleteUploadID") AND FORM.deleteUploadID NEQ  0)>
	<cfset URL.doAction  = "deleteRec" />
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
 <!---  <meta name="viewport" content="width=device-width, initial-scale=1"> --->
  <title>jQuery UI Accordion - Default functionality</title>
		<link rel="Stylesheet" type="text/css" href="/styles/imagePicker/css/smoothDivScroll.css" />	
	<style type="text/css">
		#makeMeScrollable
		{
			width:100%;
			height: 100px;
			position: relative;
		}
		
		#makeMeScrollable div.scrollableArea img
		{
			position: relative;
			 /*float: left; */
			margin: 5px;
            background-color: darkgray;
			padding: 1px;
			/* If you don't want the images in the scroller to be selectable, try the following
			   block of code. It's just a nice feature that prevent the images from
			   accidentally becoming selected/inverted when the user interacts with the scroller. */
			-webkit-user-select: none;
			-khtml-user-select: none;
			-moz-user-select: none;
			-o-user-select: none;
			user-select: none;
		}

		.lightbox {
			/** Default lightbox to be hidden */
			display: none;

			/** Position and style */
			position:fixed;
			z-index: 999;
			width: 100%;
			height: 100%;
			text-align: center;
			top: 5%;
			left: 0%;
			background: rgba(0,0,0,0.3);
			margin-left: auto;
			margin-right: auto 
		}

		.lightbox img {
			/** Pad the lightbox image */
			max-width: 90%;
			max-height: 80%;
			margin-top: 2%;
		}

		.lightbox:target {
			/** Remove default browser outline */
			outline: none;

			/** Unhide lightbox **/
			display: block;
		}
	
		.imgAll
		{
			display:block;
		}

		.imgFiltered
		{
			display:none;
		}
 </style>	

<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script src="https://code.jquery.com/jquery-1.10.2.js"></script> 
  	<cfinclude template="/Common_Files/jQuery.cfm">
<cfset datatables.version = "1.9.3">	
	<cfset jQueryUI.widgets = "full">
	<cfinclude template="/common_files/jQueryUI.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">	
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
	<script src="/script/javascript/chosen/chosen.jquery.js" type="text/javascript"></script>
	<link rel="stylesheet" type="text/css" href="/styles/chosen/chosen.css">	
	
		<style>
				  #accordion .ui-accordion-content {
		 		   max-height: 150px;
				}   
				.uploadTab
				{
					min-height:150px;
					/*max-height:600px;
					max-width: 1330px;*/
				}
				.statusTab
				{
					min-height:300px; /* was 675px */
					/*max-height:675px;
					max-width: 1330px;*/
				}
				.flow-bottom
				{
					font-family: Arial; 
					font-size: 8pt;
					color: #3e7b7b;
					font-weight: bold;
					min-width: 510px;
				}
				.flow-bottom
				{
					font-family: Arial; 
					font-size: 8pt;
					color: #3e7b7b;
					font-weight: bold;
					min-width: 510px;  /* make sure the status doesn't wrap if showing a long file name */
				}
				
				.curStep
				{
					color: #18cd38 !important;
				}
				
				.curStepRed
				{
					color: #ea0b2d !important;
				}		
				.st1 /* UPLOAD */
				{
					float:left;
					width:75px;
					text-align: center;
				}
				.tblStep {
				border: 0px solid black;
					border-spacing: 0px;
					padding: 0px;	
				}
				.tdDark {
					font-family: Arial; 
					font-size: 10pt;
					color: 3e7b7b;
					font-weight: bold;
				}
				.tdCurrent {
					font-family: Arial; 
					font-size: 10pt;
					color: 18cd38;
					font-weight: bold;
				}
				#roundedText {
		    		border-radius: 4px;
				}	

			.inputRounded
				{
			  		-moz-border-radius: 4px !important;
					border-radius: 4px;	!important;
			  	 	border:solid 1px grey  	!important;
			 	    padding:2px !important;
					font-size:14px  !important;
					width:120px  !important;
				}
			 
			.dateRounded
				{
			  		-moz-border-radius: 4px !important;
					border-radius: 4px;	!important;
			  	 	border:solid 1px grey  	!important;
			 	    padding:2px !important;
					font-size:14px  !important;
					width:100px  !important;
				} 
				
			.newLink:link, .newLink:visited {
			    background-color: #406BE4;
			    color: white;
			    padding: 7px 15px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border-radius: 50px;
				font-family: Arial; 
				font-size: 9pt;
			}

			.buttonDisabled
			{
			    background-color: #D3D3D3;
			    color: white;
			    padding: 7px 15px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border-radius: 50px;
				border: 0px;
				font-family: Arial; 
				font-size: 10pt;
			}
			.newLink:hover, .newLink:active { 
			    background-color: #1E4DD3;
			}	
			.newSecondaryLink:link, .newSecondaryLink:visited {
			    background-color: white;
			    color: #406BE4;
			    padding: 7px 10px;
				font-size: 12px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border: 1px solid #AFAFAF;
				border-radius: 50px;
			}
				
			.newSecondaryLink:hover, .newSecondaryLink:active { 
			    color: #1E4DD3;
				border-color: #1E4DD3;
			}	
			.newSecondaryLink img {
				vertical-align: middle;
			}

			.no-br {
				white-space:nowrap;
			}
				
			#rollover a 
			{
				border:none;
				text-decoration:none;
				padding: 0 0.5em 0 0.5em; /**space between icons**/
				position: relative; /**remove position rule if full size images will share the same display area. **/
			}
			
			#rollover a span 
			{
				visibility:hidden;
				background-color: #FFF;
				display:block;
				position: absolute;
				/**adjust positioning of full size images in px or %**/
				left: 0px;
				top: -140px;
				/**optional image captions**/ 
				font-size: 12px; 
				line-height: 1.2;
				color:#666;
				text-align: center;
				/**optional image borders & padding**/
				border: 5px solid orange;
				padding: 5px;
				overflow: auto;
				
			}
		
			#rollover a:hover span, #rollover a:active span, #rollover a:focus span {visibility:visible;position: relative; z-index: 2150;}
			
			#rollover a:hover, #rollover a:focus
			{visibility:visible;}
			
			.amountRight { text-align: right; }
			
			.divFilter {
			    background: #ffffff;
				/* position: relative; */
			    width: 225px;
			    display: none;
			    float: left;
			  	border-style: solid;
				border-color:#a2a2a2;
			    border-width: 1px;
				z-index: 3000;
				text-align:left;
				padding-top: 5px;
				padding-left: 0px;
				padding-bottom: 5px;
				padding-right: 0px;
				border-radius: 2px;
 			  }
  			
		</style>
 <script>
	/* Toggle between adding and removing the "active" and "show" classes when the user clicks on one of the "Section" buttons. The "active" class is used to add a background color to the current button when its belonging panel is open. The "show" class is used to open the specific accordion panel */
	var acc = document.getElementsByClassName("accordion");
	var i;
	for (i = 0; i < acc.length; i++) {
		acc[i].onclick = function(){
		};
	}
</script>

<script language="JavaScript">
	function submitForm(submitter)
	{
		var thisForm 	= document.getElementById('uploadUAFiles');
		var singleFile	= thisForm.single_file;
		var strError 	= "";
		var uploadForm   = document.uploadUAFiles;

		if(singleFile.value.length == 0)
		{
			strError = " - Select a File\n";
		}	
 
		if (strError == "")
		{
			thisForm.Submitted.value = "1";
			document.getElementById('uploadActive').style.display = 'none';
			document.getElementById('uploadInactive').style.display = 'block';
			thisForm.submit();
		}
		else
		{
			strError =   "Correct the below errors:\n\n" + strError;
			alert(strError);
		}
		return false;	 
	}		
	
	function fnAbort(UploadAutomationLogID)
	{
		var thisForm 	= document.getElementById('uploadUAFiles');
		var deleteUploadID	= document.getElementById("UploadAutomationLogID");
		var confirmation;
		document.getElementById("deleteUploadID").value= UploadAutomationLogID; 
		confirmation =confirm("Are you sure you want to remove this Upload? This will also remove the row from the Status Table? (OK = Yes   Cancel = No)");
		if (confirmation)
		{
			thisForm.submit(); 
		}
		return false;		
	}
</script>		
</head>
<body>
<cfset PageTitle="Upload Automation">
<cfinclude template="/helpsystem/help_link.cfm">
<cfinclude template="/settings/settings_title.cfm">
<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Holding_pen/holdingPen.js?ver=10"></SCRIPT>
<cfset automationUploadManager = CreateObject("component", "components.billback.AutomationUploadManager") />

<cfif isDefined("URL.lockUnlock")>
	<!--- 1 = lock; 0 = unlock --->
	<cfif URL.lockUnlock>
		<cfset temp = automationUploadManager.lockAutomationUploadPage(request.accessstructure.user_ID) />
	<cfelse>
		<cfset temp = automationUploadManager.unlockAutomationUploadPage() />
	</cfif>
</cfif>
<cfinclude template="Automation_Upload_Lock_Unlock.cfm" />
<cfinclude template="inc_UA_Actions.cfm" />

<cfquery name="qGetAutoUploadStatus" datasource="#application.datasource#">
	SELECT 	UAL.Upload_Automation_Log_ID,
			UAL.File_Name,
			U.Name_First + ' ' + U.Name_Last AS Created_User,
			UAL.File_Size,
			UAL.Upload_Date,
			UAL.Upload_Status,
			UAL.User_ID,
			USL.UA_Step,
			USL.Display_UA_Step_Desc,
			USL.Step_Bucket,
			USL.Description,
			USL.Current_Status,
			USL.Upload_3000_Link, 				/* display upload link at the top */
			USL.Generate_HLV_Report,			/* show Generate HLV report 	*/
			USL.Download_HLV_Report_Link,		/* Show Donwload HLV report link */
			USL.Update_HLV_Report_Link,			/* Upload option to upload the HV */
			USL.Process_Claims_To_Create_BB,	/* start processing the uploaded file in the update hlv report link */
			USL.Cleanup_HP,
			USL.Queued_BB_Creation,
			USL.Generate_BB_Report,
			USL.Download_BB_Report,
			USL.Enable_700_Link,
			USL.Generate_DR_AF_Report,
			USL.Download_DR_AF_Report_Link,
			USL.Developer_Assistance,
			USL.Can_Abort,
			USL.Can_user_Intervene,
			USL.User_Intervention_Required,
			USL.Display_UA_Next_Step_Desc 
	FROM 
			Upload_Automation_Log UAL
			LEFT JOIN UA_Status_Lookup USL 
				ON USL.UA_Status_Lookup_ID = UAL.Upload_Status 
			INNER JOIN _users U ON U.User_ID = UAL.User_ID
	WHERE 
			UAL.Deleted = 0	 		
</cfquery> 

<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td valign="top">
	<!---- START: STYLE 2 ---->				
<form id="uploadUAFiles" name="uploadUAFiles" method="post" action="index.cfm" ENCTYPE="multipart/form-data" ><!---  ENCTYPE="multipart/form-data" --->
	 <div style="position: relative; float: left;">
		<div id="accordion" class="accordion" style="background-color:##33ffcc;min-width:1260px;heightStyle:panel;" > 
		  	<h3  id="hdrUploadTab"><img src="/images/OCR/uploaddoc2.png" /> Upload Automation File</h3> 
				 <div  id="uploadTab" class="uploadTab ui-accordion-content" style="clearStyle:true;autoHeight:true;min-width:1100px"> <!--- ****** TO CHANGE THE HEIGHT CHANGE IT IN THE STYLE ABOVE ****** --->
					<cfinclude template = "Automation_Upload.cfm" /> 
				</div>
		  	<h3 id="hdrStatusTab"><img id="imgStatusTab" src="/images/OCR/scorecard1.png" /> Automation File Status</h3>
				<div id="statusTab" class="statusTab ui-accordion-content" style="clearStyle:true;autoHeight:true;min-width:1100px"> 
					<!--- <cfinclude template="/billbacks/OCR_Upload/UA_Steps.cfm" /> --->
					<cfinclude template = "Automation_Upload_Statusboard.cfm" /> 
			  	</div> 
			</div>
		</div>  
	</td>
</tr>
</table>
<cfoutput>
<input type="hidden" name="UploadAutomationLogID" id="UploadAutomationLogID" value="#qGetAutoUploadStatus.Upload_Automation_Log_ID#" />
<input type="hidden" name="deleteUploadID" id="deleteUploadID" value="" />  
</cfoutput>
</form>
</body>
</html>
<!--- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js" type="text/javascript"></script> --->
	<!-- jQuery UI Widget and Effects Core (custom download)
		 You can make your own at: http://jqueryui.com/download -->
	<script src="/styles/ImagePicker/js/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<!-- Latest version of jQuery Mouse Wheel by Brandon Aaron
		 You will find it here: http://brandonaaron.net/code/mousewheel/demos -->
	<script src="/styles/ImagePicker/js/jquery.mousewheel.min.js" type="text/javascript"></script>
	<!-- jQuery Kinetic - for touch -->
	<script src="/styles/ImagePicker/js/jquery.kinetic.min.js" type="text/javascript"></script>
	<!-- Smooth Div Scroll 1.3 minified -->
	<script src="/styles/ImagePicker/js/jquery.smoothdivscroll-1.3-min.js" type="text/javascript"></script>
<script>

function resizeAccordion(){
	var accordionWidth = 700;
	var accordionHeight = 200;
	var windowWidth = $( window ).width() - 20 ;
	var windowHeight = $(window).height() - 35;
	//alert(windowHeight);
	if( windowWidth > accordionWidth ){
		accordionWidth = windowWidth;
	}
	if( windowHeight > accordionHeight ){
		accordionHeight = windowHeight;
	}
	//alert(windowWidth);
	var hdrTabWidth = accordionWidth - 25;
	var divWidth = accordionWidth - 45;
	$('#accordion').width(accordionWidth);
	$('#uploadTab').width(divWidth);
	$('#statusTab').width(divWidth);
	$('#hdrUploadTab').width(hdrTabWidth);
	$('#hdrStatusTab').width(hdrTabWidth);
	$('#makeMeScrollable').width(divWidth);

	$('#accordion').height(accordionHeight);
	$('#uploadTab').height(accordionHeight -75);
	$('#statusTab').height(accordionHeight - 75);
$(".ui-accordion-content").show(); 
	//$(".dataTables_scrollHeadInner").width("100%"); // Class of div added by DataTables, contains the header table. });
}

 $(document).ready(function() {
 	resizeAccordion();
//	$(".ui-accordion-content").show();
	$( function() {
			$( "#accordion" ).accordion({
				 active: <cfoutput>#activeTab#</cfoutput>,
				 heightStyle: "fill",
				 collapsible: true,
				 autoHeight:true
			});

			$("#hdrStatusTab").click(function() {
				resizeAccordion();
			});

			$("#hdrUploadTab").click(function() {
				resizeAccordion();
			});
$(".ui-accordion-content").show();			
	} );

$( window ).resize(function() {
  resizeAccordion();
//   $(".ui-accordion-content").show();
});
 
    /*	$("#accordion").show().accordion({
        autoHeight: false
    	});*/
$( ".selector" ).accordion({ active: 1 });
    	$("#accordion div").css({ 'height': 'auto' });
		var max_fields 		= 25;	
		var wrapper         = $(".input_fields_wrap"); //Fields wrapper
   		var add_button      = $(".add_field_button"); //Add button ID
		var tbl_main 		= $(".tblDivAmount");
		var wrapper2        = $(".divInvAmount");
		// var trCount			= document.getElementById("curTRCount").value;
						
		$(add_button).click(function(e){ //on add input button click
        	e.preventDefault();
			trCount			= document.getElementById("curTRCount").value;
			valtoAdd 		= parseInt(trCount) + 1;
        	if (trCount < max_fields){ //max input box allowed
				txtAmtName= "Amount_" + valtoAdd;
				txtInvName= "Invoice_" + valtoAdd;
				$(tbl_main).append('<tr class="trDynamic" id="tr'+ valtoAdd +'"><td>' + valtoAdd +'.</td><td><input type="text" class="inputRounded" name="' + txtInvName + '"/></td><td><input type="text" class="inputRounded" name="' + txtAmtName + '"/></td><td></td><td></td><td></td></tr>'); //add input box  width="30%" // id="remove_field" <a href="#" class="remove_field">Remove</a>
				trCount++;
        	}
			else
			{
				alert('Max invoice amount reached!!');
			}
			document.getElementById("curTRCount").value = trCount;
	    });
 
  
		$(tbl_main).on("click",".remove_field", function(e){ //user click on remove text
        	e.preventDefault(); 
		//	alert('fn');
			$(".trDynamic").remove();
			trCount = 1;
			document.getElementById("curTRCount").value = trCount;
		 })
		
	}); 

/*****        CODE TO HANDLE FOR IMAGE PREVIEW ON TYPE DROP DOWN CHANGE COMMENTED FOR NOW           *******/ 	   
</script>
<cfif frmDelIdExisted EQ "1">
	<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script>
 	noty({
                text: "Upload ID: <cfoutput>#FORM.deleteUploadID# </cfoutput>has been deleted.",
                layout: "topCenter",
                type: 'success',
                timeout:3500  });
	</script>
</cfif>	

