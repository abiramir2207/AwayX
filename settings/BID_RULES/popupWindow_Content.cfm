<!--- sessionguid defined in packet.cfm--->

<cfparam name="approval_type_name" 		default="Type Codes">
<cfparam name="tabStyle.basic" 			default="inactiveTD">
<cfparam name="tabStyle.modifiers" 		default="inactiveTD">
<cfparam name="tabStyle.type" 			default="inactiveTD">
<cfparam name="tabStyle.volumegroups" 	default="inactiveTD">
<cfparam name="tabStyle.overage" 		default="inactiveTD">
<cfparam name="tabStyle.summary" 		default="inactiveTD">
<cfparam name="tabStyle.exceptions"		default="inactiveTD">
<cfparam name="tabStyle.exceptions_list" default="inactiveTD">
<cfparam name="this.is_exception_list"	default="0">

<cfparam name="url.currentTab" 			default="basic">
<cfparam name="url.sg" 					default="">
<cfparam name="url.action" 				default="">

<cfif url.currentTab EQ "exceptions_list">
	<cfset this.is_exception_list = 1>
	<cfset tabStyle.exceptions = "activeTD">
</cfif>

<cfset "tabStyle.#url.currentTab#"	= "activeTD">

<cfset includeTemplate 				= "content_"& url.currentTab & ".cfm">

<cfif application.returned_customer_setting.approval_on_type_group EQ 1>
	<cfset approval_type_name = "Type Groups">
</cfif>


<!--- new rule is being created --->
<cfif url.sg EQ "">
	<cfinclude template="packet.cfm">
	<cfset url.sg = sessionGUID>
</cfif>
<cfif isdefined("cgi.http_referer") and isdefined("url.id")>
	<cfif trim(url.id) NEQ 0>
		<cfset tempArray = listtoarray(cgi.http_referer, "/")>
		<cfset filename = lcase(tempArray[arraylen(tempArray)])>
		<cfif filename EQ "popupwindow.cfm">
			<cfinclude template="packet.cfm">
			<cfset url.sg = sessionGUID>
			<cfinclude template="populatepacket.cfm">
		</cfif>
	</cfif>
</cfif>



<cffile action="READ" file="#Application.Doc_Path#\temp_files\WddxPackets\#url.sg#.ddx" variable="packet">
<cfwddx action="WDDX2CFML" input="#packet#" output="BidRule">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Manage Bid Rule</TITLE>
	<style type="text/css">
		 	.spacer {
				width: 3px;
		 		border-bottom-color : Black;
		 		border-bottom-style : solid;
		 		border-bottom-width : 1;			
			}
			
		 	.spacerNoWidth {
		 		border-bottom-color : Black;
		 		border-bottom-style : solid;
		 		border-bottom-width : 1;			
			}
			
			
			.activeTD {
		 		width : 100px;
		 		height : 20px;
				color: Navy;
				background-color: WhiteSMoke;
		 		border-top-color : Black;
		 		border-top-style : solid;
		 		border-top-width : 1;
		 		border-left-color : Black;
		 		border-left-style : solid;
		 		border-left-width : 1;
		 		border-right-color : Black;
		 		border-right-style : solid;
		 		border-right-width : 1;
				cursor: pointer;
				font-weight: bold;
		 	}

			.inactiveTD {
		 		width : 100px;
		 		height : 20px;
				color: White;
				background-color: Navy;
		 		border-top-color : Black;
		 		border-top-style : solid;
		 		border-top-width : 1;
		 		border-left-color : Black;
		 		border-left-style : solid;
		 		border-left-width : 1;
		 		border-right-color : Black;
		 		border-right-style : solid;
		 		border-right-width : 1;
				cursor: pointer;
				font-weight: bold;
			}
</style>

<cfoutput>
<script>
	var basic_valid 			= #bidrule.basic.validdata#;
	var type_valid 				= #bidrule.type.validdata#;
	var volumegroups_valid 		= #bidrule.volumegroups.validdata#;
	var avail_reason			= "";
	var avail_reason_display 	= 0;
	
	
	var startClassName = "";
	function toggleColor(oTD, onoffflag) {
		if(onoffflag) {
			startClassName = oTD.className;
			oTD.className = "activeTD";
		}
		else {
			if(startClassName != "activeTD") {
				oTD.className = "inactiveTD";
			}
		}
	}
	
	function tdClick(oTD) {
		avail_reason_display 	= false;
		avail_reason			= "";
		
		
		allowRelocate = true;

		if("#url.currentTab#" == "modifiers") {
			navigateAway = 1;
			if(!verifyData()) {
				allowRelocate = 0;
				avail_reason_display = 0;
			}
			navigateAway = 0;
		}
		
		if("#url.currentTab#" == "exceptions") {
			navigateAway = 1;
			if(!verifyData()) {
				allowRelocate = 0;
				avail_reason_display = 0;
			}
			navigateAway = 0;
		}		


		switch(oTD.id){
			case "basic":
				
			break;
		
			case "modifiers":

			break;
		
			case "type":

			break;
		
			case "volumegroups":
				if(!basic_valid) {
					allowRelocate = false;
					avail_reason_display  = true;
					avail_reason = "Please complete the \"Basic Info\" tab first!";
				}
			break;
		
			case "overage":
				if(!type_valid) {
					allowRelocate = false;
					avail_reason_display  = true;
					avail_reason = "Please complete the \"#lcase(approval_type_name)#\" tab first!";
				}
				else {
					if(!volumegroups_valid) {
						allowRelocate = false;
						avail_reason_display  = true;
						avail_reason = "Please complete the \"Volume Groups\" tab first!";
					}				
				}
			break;
		}
		if(allowRelocate) window.location.href = "popupWindow_Content.cfm?currentTab=" + oTD.id + "&sg=#url.sg#"; 
		if(avail_reason_display) alert(avail_reason);
		
<!--- 		if(confirm("You are about to navigate away from this page without saving. Press OK to save you data or press CANCEL to proceed without saving")) {
			document.all.MyForm.nextTab.value = oTD.id;
			document.all.MyForm.action = "packet_modifier.cfm";
			document.all.MyForm.submit();
			return;
		} --->		
	}
</script>
</cfoutput>

<cfif URL.ACTION EQ 3>
	<cfset tabStyle.basic 	= "inactiveTD" >
	<cfset tabStyle.summary = "activeTD" >
	<cfset includeTemplate 	= "content_summary.cfm" >
</cfif>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- <cfdump var="#application#"> --->
	<TABLE WIDTH="100%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
		<cfoutput>
		<tr>
			<td class="spacerNoWidth" width="25">&nbsp;</td>
			
			<td id="basic" class="#tabStyle.basic#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)">Basic Info</td>
			
			<td class="spacer">&nbsp;</td>

			<td id="type" class="#tabStyle.type#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)"><cfoutput>#approval_type_name#</cfoutput></td>
						
			<td class="spacer">&nbsp;</td>
			
			<td id="exceptions" class="#tabStyle.exceptions#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)">Exceptions</td>
			
			<td class="spacer">&nbsp;</td>

			<td id="modifiers" class="#tabStyle.modifiers#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)">Modifiers</td>
			
			<td class="spacer">&nbsp;</td>
			
			<td id="volumegroups" class="#tabStyle.volumegroups#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)">Volume Groups</td>
			
			<td class="spacer">&nbsp;</td>
			
			<td id="overage" class="#tabStyle.overage#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)">Overage</td>
			
			<td class="spacer">&nbsp;</td>
			
			<td id="summary" class="#tabStyle.summary#" onmouseover="toggleColor(this, 1)" onmouseout="toggleColor(this, 0)" onclick="tdClick(this)">Summary</td>
			
			<td class="spacerNoWidth">&nbsp;</td>
		</tr>
		</cfoutput>
	</table>
	
	<cfinclude template="#includeTemplate#">

	
	<cfset thisDebug = 0>
	<cfif thisDebug EQ 1>
 	<a href="javascript: history.back()">back</a>
	<hr color="#ff0000">
	<cfdump var="#bidrule#">

	
	<h1>URL</h1>
	<cfdump var="#url#">
	<h1>FORM</h1>
	<cfdump var="#form#">
	<h1>APPLICATION</h1>
	<cfdump var="#application#">
	</cfif>
		

</BODY>
</HTML>



