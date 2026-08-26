<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/index.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  16-Mar-17
Created By   :  Anand Rao
Description  :  
---------------------------------------------------------------------------------->

<!---- DELETE FUNCTIONALITY --->
<cfset frmDelIdExisted = 0 />

<cfif isDefined("FORM.deleteOCRUploadID") AND FORM.deleteOCRUploadID NEQ "">

	<cfset useLakebaseForqryBBUploadID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqryBBUploadID>
	<cftry>
		<cfset qryBBUploadID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"ocr_upload_id" = "eq.#FORM.deleteOCRUploadID#",
				"deleted" = "eq.0",
				"select" = "bb_upload_id,ocr_step"
			}), "bb_upload_id,ocr_step"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryBBUploadID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryBBUploadID>
<cfquery name="qryBBUploadID" datasource="#application.datasource#">
			SELECT BB_Upload_ID,OCR_Step FROM OCR_Upload_Log 
			WHERE OCR_Upload_ID = '#FORM.deleteOCRUploadID#' AND Deleted = 0
	</cfquery>
</cfif>
	<cfif (qryBBUploadID.RecordCount NEQ 0 AND qryBBUploadID.BB_Upload_ID NEQ "" AND qryBBUploadID.OCR_Step EQ "11") >
		<cftry>
			<cfinvoke component="components.billback.billbackuploadutility" method="purge_upload">
				<cfinvokeargument name="upload_id" value="#qryBBUploadID.BB_Upload_ID#">
				<cfinvokeargument name="user_code" value="#request.accessstructure.user_code#">
			</cfinvoke>
		<cfcatch type="any">
			<cfmail to="developers@bigredflame.com" from="devenv@bigredflame.com" server="mail.bigredflame.com" subject="purge failed">
				#cfcatch.ExtendedInfo#<br>#cfcatch.Detail#
			</cfmail>
		</cfcatch>
		</cftry>
	</cfif>
	
	<cfset useLakebaseForqGetBBUploadID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqGetBBUploadID>
	<cftry>
		<cfset qGetBBUploadID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"ocr_upload_id" = "eq.#FORM.deleteOCRUploadID#",
				"deleted" = "eq.0",
				"select" = "bb_upload_id"
			}), "bb_upload_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBBUploadID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBBUploadID>
<cfquery name="qGetBBUploadID" datasource="#application.datasource#">
		SELECT BB_Upload_ID FROM OCR_Upload_Log WHERE OCR_Upload_ID = '#FORM.deleteOCRUploadID#' AND Deleted = 0
	</cfquery>
</cfif>
	<cfif qGetBBUploadID.RecordCount EQ 1 AND qGetBBUploadID.BB_Upload_ID NEQ "">
		<cfset useLakebaseForqUpdBBUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForqUpdBBUploadLog>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_upload_log",
			{
				"upload_id" = "eq.#qGetBBUploadID.BB_Upload_ID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1",
				"deleted_by" = "#Request.AccessStructure.User_ID#",
				"deleted_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdBBUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdBBUploadLog>
<cfquery name="qUpdBBUploadLog" datasource="#application.datasource#">
			UPDATE 
				BB_Upload_Log
			SET 
				Deleted = 1,
				Deleted_By = '#Request.AccessStructure.User_ID#',
				Deleted_Date = getDate()
			WHERE Upload_ID = '#qGetBBUploadID.BB_Upload_ID#' AND Deleted = 0
		</cfquery>
</cfif>
	</cfif>
	
	<cfset useLakebaseForqUpdOCRUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqUpdOCRUploadLog>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#FORM.deleteOCRUploadID#",
				"deleted" = "eq.0"
			},
			{
				"ocr_step" = "404",
				"deleted" = "1",
				"deleted_by" = "#Request.AccessStructure.User_ID#",
				"deleted_date" = "#now()#",
				"ocr_upload_status" = "OCR Upload Deleted by user"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdOCRUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdOCRUploadLog>
<cfquery name="qUpdOCRUploadLog" datasource="#application.datasource#">
		UPDATE 
			OCR_Upload_Log
		SET 
			OCR_Step = '404',
			Deleted = 1,
			Deleted_By = '#Request.AccessStructure.User_ID#',
			Deleted_Date = getDate(),
			OCR_Upload_Status = 'OCR Upload Deleted by user'
		WHERE OCR_Upload_ID = '#FORM.deleteOCRUploadID#' AND Deleted = 0
	</cfquery>
</cfif>
	
<!--- 	
	<div id="sb"><p align="center"><strong><img src="/images/Exclamation_Triangle.gif"/> &nbsp;&nbsp; Upload ID: <cfoutput>#FORM.deleteOCRUploadID# </cfoutput>has been deleted.</strong></p></div> --->
<!--- 	<button onclick="showDel()">Show Snackbar</button> --->
	<cfset frmDelIdExisted = 1 />	
</cfif>
<cfset activeTab = 1 />
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
			height: 200px;
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
<!---    <link href="/styles/imagePicker/css/styles.css" rel="stylesheet">	  --->

 <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  <!--- <link rel="stylesheet" href="/resources/demos/style.css"> --->
  <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
  <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
 
 <!---  <script>
  $( function() {
    $( "input" ).checkboxradio();
  } );
  </script>	 --->
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
				/*  #accordion .ui-accordion-content {
		 		   max-height: 150px;
				} */
				.uploadTab
				{
					min-height:600px;
					/*max-height:600px;
					max-width: 1330px;*/
				}
				.statusTab
				{
					min-height:600px; /* was 675px */
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
				.st2 /* SOURCE */
				{
				float:left;
				width:72px;
				text-align: center;
				}
				.st3 /* INVOICE */
				{
				float:left;
				width:70px;
				text-align: center;
				}
				.st4 /* ALIAS */
				{
				float:left;
				width:78px;
				text-align: center;
				}
				.st5 /* AMOUNT */
				{
				float:left;
				width:74px;
				text-align: center;
				}
				.st6 /* VALID */
				{
				float:left;
				width:70px;
				text-align: center;		
				}
				.st7 /* CREATED */
				{
				float:left;
				width:70px;
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
			<!--- colors: blue: #406BE4, hover-blue: #1E4DD3 dk-gray: #343540 md-gray: #7c7c7c lt-gray: #D8D8D8 off-white: #EDEEF2 lt-red: #BF1D38 dk-red: #88272d  --->

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
		//this.classList.toggle("active");
		// this.nextElementSibling.classList.toggle("show");
		};
	}
</script>

<script language="JavaScript">
	function submitForm(submitter)
	{
		var thisForm 	= document.getElementById('uploadOCRFiles');
		var singleFile	= thisForm.single_file;
		var source 		= thisForm.selSource.selectedIndex;
		var amount 		= thisForm.Amount.value;
		var strError 	= "";
		var uploadForm   = document.uploadOCRFiles;

		var divAmt = document.getElementById('divAmount'); //divInvAmount
		var divInvAmt = document.getElementById('divInvAmount'); //divInvAmount*/
 		var recLength	= document.getElementById('curTRCount').value;
		var bInvEntered = 0;;
		var typePickedLen = thisForm.selType.length;
		var bChecked = 0;
		if (typeof typePickedLen !== "undefined" )
		{
			if (typePickedLen >= 1)
			{
				var i;
				for(i=0;i<typePickedLen;i++)
				{
					if (thisForm.selType[i].checked)
					{
						bChecked = 1;
					}
				}
			}
		}	
		else
		{
			bChecked = 1;
		}
		if(singleFile.value.length == 0)
		{
			strError = " - Select a File\n";
		}	
		
		if (source == "")
		{
			strError = strError + " - Select a source\n";
		}
		if (bChecked == 0)
		{
			strError = strError + " - Pick a Type\n";
		}
		
		if(divAmt.style.display != 'none')
		{
			if (amount == "")
			{
				strError = strError + " - Enter an Amount";
			} 	
			bInvEntered = 1;
		}
		else if(divInvAmt.style.display != 'none')
		{
		 
			bInvEntered = 1;
		}
		
		if (bInvEntered == 0)
		{
			strError = strError + " - Enter atleaset one Invoice and Amount";
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
	
	function fnAbort(OCRUploadID)
	{
		var thisForm 	= document.getElementById('OCRForm');
		var delField	= document.getElementById("deleteOCRUploadID");
		var confirmation;
		/* document.getElementById("deleteOCRUploadID")= OCRUploadID; */
		delField.value = OCRUploadID;
		confirmation =confirm("Are you sure you want to remove this Upload? This will also remove the row from the Status Table? (OK = Yes   Cancel = No)");
		if (confirmation)
		{
			thisForm.submit(); 
			}
		return false;		
	}
</script>		
</head>
<body><!---  <cfif frmDelIdExisted EQ "1"> onload="showDel();"</cfif> --->
<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td valign="top">
	<!---- START: STYLE 2 ---->				
	 <!--- <form id="uploadOCRFiles" name="uploadOCRFiles" method="post" action="index.cfm" > --->
	<div style="position: relative; float: left;">
		<div id="accordion" class="accordion" style="background-color:##33ffcc;min-width:1260px;heightStyle:panel;" > 
		  	<h3  id="hdrUploadTab"><img src="/images/OCR/uploaddoc2.png" /> Upload Invoice</h3> 
				 <div  id="uploadTab" class="uploadTab" style="clearStyle:true;autoHeight:true;min-width:1180px"> <!--- ****** TO CHANGE THE HEIGHT CHANGE IT IN THE STYLE ABOVE ****** --->
					<cfinclude template = "/billbacks/OCR_Upload/OCR_Upload.cfm" /> 
				</div>
		  	<h3 id="hdrStatusTab"><img id="imgStatusTab" src="/images/OCR/scorecard1.png" /> Manage Status</h3>
				<div id="statusTab" class="statusTab" style="clearStyle:true;autoHeight:true;min-width:1180px"> 
					<cfinclude template = "/billbacks/OCR_Upload/OCR_Upload_Statusboard.cfm" /> 
			  	</div> 
			</div>
		</div> 
	</td>
</tr>
</table>
<form id="OCRForm" name="OCRForm" method="post" action="index.cfm"> 
	<input type="hidden" name="deleteOCRUploadID" id="deleteOCRUploadID" value="" />
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
	var accordionWidth = 1260;
	var accordionHeight = 600;
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

	//$(".dataTables_scrollHeadInner").width("100%"); // Class of div added by DataTables, contains the header table. });
}

 $(document).ready(function() {
 	resizeAccordion();
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
	} );

$( window ).resize(function() {
  resizeAccordion();
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
		var trCount			= document.getElementById("curTRCount").value;
						
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
 		
	  $("#selSource").chosen()
	 
	  
		 $( "#selSource" ).change( function( ){
	       		$.ajax( {
						type: "POST",
						url: "/components/Billback/OCRUploadSettingsManager.cfc?method=getOCRSettingsOnXref&ReturnFormat=json",
						data: ({	BBClaimSourceXrefID: $(this).val()}),
						dataType: 'json',
						success: function(response)
						{
						  var tbl_type		= $(".tblType");
						 
							  $('.trType').show();
							
							  $('.tblType').empty();
							  $('.tblType').append('<tr class="imgDisp">');
							 
						      for (var i = 0; i < response.DATA.length; i++)
						      {
						      		//$('#selType').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
								  $('.imgDisp').append('<td valign="bottom"><a href="#img' + response.DATA[i][0] + '" title="' + response.DATA[i][4] + '"><img src="/images/OCR/' + response.DATA[i][2] + '_Thumb.png" class="thumbnail"></a><a href="#_" class="lightbox" id="img' + response.DATA[i][0] + '"><img src="' + response.DATA[i][3] + '"></a></td>');  
						      } 
							  						  
							 
							$('.tblType').append('</tr><tr class="txtDisp">');
							for (var i = 0; i < response.DATA.length; i++)
							{
								if (response.DATA.length == 1 )
								{
							  		$('.txtDisp').append('<td align="center"><label><input type="radio" id="rdo_'+ response.DATA[i][0] +'" class="selType" name="selType" value="' + response.DATA[i][0] +' " checked="checked"/>'+ response.DATA[i][5] + '</label></td>');
									// $('#selType').trigger('change');
								}
								else
								{
							  		$('.txtDisp').append('<td align="center"><label><input type="radio" id="rdo_'+ response.DATA[i][0] +'" class="selType" name="selType" value="' + response.DATA[i][0] +' "/>'+ response.DATA[i][5] + '</label></td>');
								}
							}  
							$('.tblType').append('</tr>');		 
							$('#divAmount').hide(); 
							$('#divNumAmt').hide();
							$('#divInvAmount').hide();
							$('#divInvNum').hide();
							$('#divInvoiceDateOnly').hide();

								//alert($('#makeMeScrollable').width());
								//$('#makeMeScrollable').smoothDivScroll("recalculateScrollableArea");
								//$('#makeMeScrollable').hide().fadeIn('fast');
								

							 
/********** START: RADIO BUTTON CHANGE FUNCTION  ************/
$("input[name=selType]:radio").change( function( ){ 
	$.ajax( {
						type: "POST",
						url: "/components/Billback/OCRUploadSettingsManager.cfc?method=getOCRSettingsOnID&ReturnFormat=json",
						data: ({	OCRTemplateSettingsID: $(this).val()}),
						dataType: 'json',
						success: function(response)
						{
							var wrapper         = $(".input_fields_wrap"); //Fields wrapper
   							var add_button      = $(".add_field_button"); //Add button ID
							var tbl_main 		= $(".tblDivAmount");
							
							var OCRTemplateSettingsID 			= response.DATA[0][0];
							var OCRImagePath					= response.DATA[0][1];
							var OCRUserInputRequired			= response.DATA[0][2];
							var InvoiceNumberAmountRequired		= response.DATA[0][3];
							var InvoiceDateRequired				= response.DATA[0][4];
							var InvoiceStartDateRequired		= response.DATA[0][5];
							var InvoiceEndDateRequired			= response.DATA[0][6];
							var AllowedInvoiceRowsCount			= response.DATA[0][7];
							var OCRTemplateName					= response.DATA[0][8];
							var OCRCode							= response.DATA[0][9];
							var OCRImageHelptext				= response.DATA[0][10];
							var OCRTemplateDescription			= response.DATA[0][11];
							var strHeaderText					= '';
							
							 $(".trDynamic").remove();
							 $(".divInvDateInner").remove();
							 $('#divStartDate').html('<strong>Start Date:</strong>'); //reset since Sodexo only uses invoice date we overwrite the value
							 $('#divInvNum').html('<strong>Invoice Number:</strong>');
							 $('#divNumAmt').html('<strong>Invoice Amount:</strong>');
							 $('#divStartDate').html('<strong>Start Date:</strong>');
							 $('#divEndDate').html('<strong>End Date:</strong>');
							 
							 trCount = 0;
							 document.getElementById("curTRCount").value = trCount;
							
							$('#divNumAmt').hide();
							$('#divInvNum').hide();
							$('#divStartDate').hide();
							$('#divEndDate').hide();
							$('#divInvoiceDate').hide();
							$('#divAddAnother').hide();
							$('#divInvoiceDateOnly').hide();

							
							strHeaderText  = 'The "' + OCRTemplateDescription +  '" format requires additional information. Please enter at least one invoice.';
								$('#divTemplateName').text(strHeaderText);
								
							// SCENARIO FOR OCR_CODE = "PFG_OT11" & OT1 
							if (OCRUserInputRequired == 1 && InvoiceNumberAmountRequired == 1 && InvoiceStartDateRequired == 0 && InvoiceEndDateRequired == 0 && InvoiceDateRequired == 0)
							{
								$('#divAmount').hide(); 
								$('#divNumAmt').show();
								$('#divInvNum').show();
								$('#divInvAmount').show();
								rowCount=AllowedInvoiceRowsCount;
								/***** IF rowCount is 0 then show 1 row atlest instead of no row *****/
								if (rowCount == 0)
								{
									rowCount = 1;
								}
								for (var staticX = 1; staticX <= rowCount; staticX++) 
								{
									txtAmtName= "Amount_" + staticX;
									txtInvName= "Invoice_" + staticX;
									txtToClense = ".0123456789";
									$(tbl_main).append('<tr class="trDynamic" id="tr'+ staticX +'"><td>' + staticX +'.</td><td><input type="text" class="inputRounded"  name="' + txtInvName + '"/></td><td><input type="text" class="inputRounded" name="' + txtAmtName + '" onKeyUp="clenseText(this, ' + txtToClense + ');" /></td><td></td><td></td><td></td></tr>'); //add input box width="30%" // id="remove_field" <a href="#" class="remove_field">Remove</a>
									// staticX++;
									trCount++;
								}
								
								$('#divAddAnother').show(); 
								document.getElementById("curTRCount").value = trCount;
							}
							
							// SCENARIO FOR OCR_CODE = "PFG_OT9"
						 
							if (OCRUserInputRequired == 1 && InvoiceNumberAmountRequired == 1 && InvoiceStartDateRequired == 1 && InvoiceEndDateRequired && InvoiceDateRequired == 1)
							{
								$('#divAmount').hide(); 
								$('#divInvAmount').show();
								$('#divNumAmt').show();
								$('#divInvNum').show();
								 
								$('#divStartDate').show();
								$('#divEndDate').show();
								$('#divInvoiceDate').show();
								$('#divAddAnother').hide();
								txtToClense = ".0123456789";
								
								$(tbl_main).append('<tr class="trDynamic" id="tr1"><td></td><td><input type="text" class="inputRounded" name="Invoice_1" id="Invoice_1"/></td><td><input type="text" class="inputRounded" onKeyUp="clenseText(this, ' + txtToClense + ');"  name="Amount_1" id="Amount_1"/></td><td><input type="text" class="dateRounded"  name="startDate_1" id="startDate_1"></td><td><input type="text" class="dateRounded" name="endDate_1" id="endDate_1"></td><td><input type="text" class="dateRounded" name="invoiceDate_1" id="invoiceDate_1"></td></tr>'); //add input box width="30%" // id="remove_field" <a href="#" class="remove_field">Remove</a>
								$(function(){ $( "#startDate_1" ).datepicker(); });
								$(function(){ $( "#endDate_1" ).datepicker(); });
								$(function(){ $( "#invoiceDate_1" ).datepicker(); });																
							
							}
							 
							// SCENARIO FOR OCR_CODE = "PFG_OT6" 
							if (OCRUserInputRequired == 1 && InvoiceNumberAmountRequired == 1  && InvoiceStartDateRequired == 1 && InvoiceEndDateRequired == 1 && InvoiceDateRequired == 0)
							{
								$('#divAmount').hide(); 
								$('#divInvAmount').show();
								$('#divNumAmt').show();
								$('#divInvNum').show();
								$('#divStartDate').show();
								$('#divEndDate').show();
								$('#divInvoiceDate').hide();
								$('#divAddAnother').hide();
								txtToClense = ".0123456789";
								$(tbl_main).append('<tr class="trDynamic" id="tr1"><td></td><td><input type="text" class="inputRounded" name="Invoice_1" id="Invoice_1"/></td><td><input type="text" class="inputRounded" onKeyUp="clenseText(this, ' + txtToClense + ');"  name="Amount_1" id="Amount_1"/></td><td><input type="text" class="dateRounded" name="startDate_1" id="startDate_1"></td><td><input type="text"  class="dateRounded" name="endDate_1" id="endDate_1"></td><td>&nbsp;</td></tr>'); //add input box width="30%" // id="remove_field" <a href="#" class="remove_field">Remove</a>
							 	$(function(){ $( "#startDate_1" ).datepicker(); });
								$(function(){ $( "#endDate_1" ).datepicker(); });
							}  

							// SCENARIO FOR OCR_CODE = "Foodbuy_OT1"
						 
							if (OCRUserInputRequired == 1 && InvoiceNumberAmountRequired == 0 && InvoiceStartDateRequired == 0 && InvoiceEndDateRequired == 0 && InvoiceDateRequired == 1)
							{
								$('#divAmount').show(); 
								$('#divInvoiceDateOnly').show();
								$('#divInvAmount').hide();
								$('#divNumAmt').hide();
								$('#divInvNum').hide();
								 
								$('#divStartDate').hide();
								$('#divEndDate').hide();
								$('#divInvoiceDate').hide();
								$('#divAddAnother').hide();
								txtToClense = ".0123456789";
								
								$(".divInvoiceDateOnly").append('<div class="divInvDateInner"><input type="text" class="dateRounded" name="invoiceDate_1" id="invoiceDate_1"></div>'); //add input box width="30%" // id="remove_field" <a href="#" 
								$(function(){ $( "#invoiceDate_1" ).datepicker(); });
							}

							// SCENARIO FOR OCR_CODE = "Sodexo_OT1" 
							if (OCRUserInputRequired == 1 && InvoiceNumberAmountRequired == 1  && InvoiceStartDateRequired == 0 && InvoiceEndDateRequired == 0 && InvoiceDateRequired == 1)
							{
								$('#divAmount').hide(); 
								$('#divInvAmount').show();
								$('#divNumAmt').show();
								$('#divInvNum').show();
								$('#divStartDate').show();
								$('#divStartDate').html('<strong>Invoice Date:</strong>');
								$('#divEndDate').hide();
								$('#divInvoiceDate').hide();
								$('#divAddAnother').hide();
								txtToClense = ".0123456789";
								$(tbl_main).append('<tr class="trDynamic" id="tr1"><td></td><td><input type="text" class="inputRounded" name="Invoice_1" id="Invoice_1"/></td><td><input type="text" class="inputRounded" onKeyUp="clenseText(this, ' + txtToClense + ');"  name="Amount_1" id="Amount_1"/></td><td><input type="text" class="dateRounded" name="invoiceDate_1" id="invoiceDate_1"></td><td></td><td></td></tr>'); //add input box width="30%" // id="remove_field" <a href="#" class="remove_field">Remove</a>
							 	$(function(){ $( "#invoiceDate_1" ).datepicker(); });
							}  

							// SCENARIO FOR OCR_CODE = "Sodexo_OT2" 
						 
							if (OCRUserInputRequired == 1 && InvoiceNumberAmountRequired == 0 && InvoiceStartDateRequired == 1 && InvoiceEndDateRequired && InvoiceDateRequired == 1)
							{
								
								$('#divInvNum').html('<strong>Invoice Amount:</strong>');
								$('#divNumAmt').html('<strong>Start Date:</strong>');
								$('#divStartDate').html('<strong>End Date:</strong>');
								$('#divEndDate').html('<strong>Invoice Date:</strong>');

								$('#divAmount').hide(); 
								$('#divInvAmount').show();
								$('#divNumAmt').show();
								$('#divInvNum').show();

								$('#divStartDate').show();
								$('#divEndDate').show();
								$('#divInvoiceDate').hide();
								$('#divAddAnother').hide();
								txtToClense = ".0123456789";
								
								$(tbl_main).append('<tr class="trDynamic" id="tr1"><td></td><td><input type="text" class="inputRounded" onKeyUp="clenseText(this, ' + txtToClense + ');"  name="Amount_1" id="Amount_1"/></td><td><input type="text" class="dateRounded"  name="startDate_1" id="startDate_1"></td><td><input type="text" class="dateRounded" name="endDate_1" id="endDate_1"></td><td><input type="text" class="dateRounded" name="invoiceDate_1" id="invoiceDate_1"></td></tr>'); //add input box width="30%" // id="remove_field" <a href="#" class="remove_field">Remove</a>
								$(function(){ $( "#startDate_1" ).datepicker(); });
								$(function(){ $( "#endDate_1" ).datepicker(); });
								$(function(){ $( "#invoiceDate_1" ).datepicker(); });																
							
							}
							
							if (OCRUserInputRequired == 0) /* NO USER INPUT IS REQURIED FOR INVOICE,AMOUNT,START END AND INVOICE DATES */ 
							{
								$('#divInvAmount').hide();
								$('#divAmount').show();
							}
							
							/* 
							onKeyUp="clenseText(this, '.0123456789');"
							*/
						},
						error: function(xhr, textStatus, errorThrown){ 
							alert('request failed 1');
						}
					});
});	  

/********** END: RADIO BUTTON CHANGE FUNCTION  ************/
					$("div#makeMeScrollable").smoothDivScroll({});
					/******** TRIGGER ON CHANGE ******/
					if (response.DATA.length == 1 )
					{	
						$("input[name=selType]:radio").trigger('change');
					}
					/******** TRIGGER ON CHANGE ******/		
		      		// $('#selType').trigger("chosen:updated");
						},
						error: function(xhr, textStatus, errorThrown){ 
						/* The below code was added to reset the type when the source is selected to "Select a Source" */
						 	$('.tblType').empty();
							$('#divAmount').show(); 
							$('#divNumAmt').hide();
							$('#divInvAmount').hide();
							$('.trType').hide();
							// alert('request failed 2');
						}
					});
			});	   
	   
/*****        CODE TO HANDLE FOR IMAGE PREVIEW ON TYPE DROP DOWN CHANGE COMMENTED FOR NOW           *******/ 	   
</script>
<cfif frmDelIdExisted EQ "1">
	<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script>
 	noty({
                text: "Upload ID: <cfoutput>#FORM.deleteOCRUploadID# </cfoutput>has been deleted.",
                layout: "topCenter",
                type: 'success',
                timeout:3500  });
	</script>
</cfif>	
