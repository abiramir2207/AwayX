<!-----------------------------------------------------------------------------

FILE NAME:		BBOperLocationDupChecker.cfm
DESCRIPTION:		
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
------------------------------------------------------------------------------> 
<cfparam name="URL.bbid" 			default="">
<cfparam name="URL.UserID" 			default="">
<cfparam name="URL.caller" 			default="">
<!--- Earler "URL.FromDupScreen", had a default value of 1 and was being set inside "cfparam". That has been removed and now we are using "cfset" instead.
This will make sure that this feature will work for AG Grid also.
--->
<cfset URL.FromDupScreen = 1>

<cfoutput>
	<cfscript>
	    URLString = "";
		URLString = "userID=" & #URL.UserID# & "&BBID=" & #URL.bbid# & "&source=" & #URL.caller# & "&FromDupScreen=" & #URL.FromDupScreen#;
	</cfscript>  
</cfoutput>	

<cfset BBInfo = CreateObject("component", "components.Billback.BillbackSummaryManager").getBillbackInfo(url.BBID) >
<cfset thisPayeeObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(url.BBID) >
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfset getPayeeInfo = thisPayeeObj.getPayeeInfo() />

<cfinclude template="/get_access_profile.cfm">
	
 <style>
 #rcorners2 {
    border-radius: 15px;
    border: 2px solid #FFE5BF;
    padding: 10px; 
    width: 99%;
    height: 18px; 
	color: #000000;
	background: #FFE5BF;
	font-size: 11px;
	font-weight: bold;
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
.newLink:hover, .newLink:active { 
			    background-color: #1E4DD3;
			}	


.accpLink:link, .accpLink:visited {
			    background-color: #00FA9A;
			    color: white;
			    padding: 3px 7px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border-radius: 50px;
				font-family: Arial; 
				font-size: 9pt;
			} 
.accpLink:hover, .accpLink:active { 
			    background-color: #9ACD32;
			}	

.denyLink:link, .denyLink:visited {
			    background-color: #FF0000;
			    color: white;
			    padding: 3px 7px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border-radius: 50px;
				font-family: Arial; 
				font-size: 9pt;
			} 
.denyLink:hover, .denyLink:active { 
			    background-color: #DC143C;
			}		
			
header2 {
	padding: 150px !important;
}	

 
 
								
 </style>						
<cfoutput>

<cfset TotalDollars	 = 0 />	
<cfset TotalDenied 		= 0 />
<cfset TotalAccepted	= 0 />
<cfset TotalOpen	 	= 0 />

	
<cfloop query="getBBOperLocationDups">
	<cfif (getBBOperLocationDups.Billback_ID EQ getBBOperLocationDups.Dup_Billback_ID)>
		<cfset TotalDollars		= TotalDollars + getBBOperLocationDups.Dup_Loc_Claimed_Amount />
		<cfif ((getBBOperLocationDups.denied EQ 0) AND (getBBOperLocationDups.Updated_Date EQ ""))>
			<cfset TotalOpen	 	= TotalOpen + getBBOperLocationDups.Dup_Loc_Claimed_Amount />
		<cfelseif ((getBBOperLocationDups.denied EQ 0) AND (getBBOperLocationDups.Updated_Date NEQ ""))>
			<cfset TotalAccepted	= TotalAccepted	+ getBBOperLocationDups.Dup_Loc_Claimed_Amount />
		<cfelseif ((getBBOperLocationDups.denied EQ 1) AND (getBBOperLocationDups.Updated_Date NEQ ""))>
			<cfset TotalDenied 		= TotalDenied + getBBOperLocationDups.Dup_Loc_Claimed_Amount />
		</cfif>
	</cfif> 
</cfloop>

<cfif not isDefined("Get_Profile_Settings")>
	<cfinclude template="/get_access_profile.cfm" />
</cfif>

<cfset MaxBBOprLocationLevelDupApprovalAmount = Get_Profile_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount />
<!--- Max_BB_Oper_Location_Level_Dup_Approval_Amount: <cfdump var="#Get_Profile_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount#" /> --->

<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
	<cfset actionPage ="/billbacks/Deviation/Deviation_Main.cfm">
<cfelse>
	 <cfset actionPage ="BillbackDevAppFx.cfm">
</cfif>

<form name="frmOperDupCheck" id="frmOperDupCheck" method="post" action="#actionPage#?#URLString#&Submitted=1">


<p id="rcorners2">
Operator Loc. Dup Check&nbsp;&nbsp;|&nbsp;&nbsp;#BBInfo.BB_code#&nbsp;&nbsp;|&nbsp;&nbsp;#BBInfo.BB_Title#&nbsp;&nbsp;|&nbsp;&nbsp;
#getPayeeInfo.Payee_Name# - #getPayeeInfo.Payee_ShipTo#&nbsp;&nbsp;|&nbsp;&nbsp;#Dateformat(BBInfo.BB_Start_Date,'mm/dd/yy')# to #Dateformat(BBInfo.BB_End_Date,'mm/dd/yy')#
&nbsp;&nbsp;|&nbsp;&nbsp;Total: #Dollarformat(TotalDollars)#&nbsp;&nbsp;|&nbsp;&nbsp;Denied: #Dollarformat(TotalDenied)#&nbsp;&nbsp;|&nbsp;&nbsp;Accepted: #Dollarformat(TotalAccepted)#&nbsp;&nbsp;|&nbsp;&nbsp;Open: #Dollarformat(TotalOpen)#</p>
</cfoutput> 
 
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable-ocr.css">
<cfset curRow = 0 />


<cfset CanAcceptAll = 0 />

<cfif MaxBBOprLocationLevelDupApprovalAmount EQ "*">
	<cfset CanAcceptAll = 1 />
<cfelseif MaxBBOprLocationLevelDupApprovalAmount EQ "0">	
	<cfset CanAcceptAll = 0 />
<cfelse>
	<cfloop query="getBBOperLocationDups">
		<cfif MaxBBOprLocationLevelDupApprovalAmount GTE getBBOperLocationDups.Dup_Loc_Claimed_Amount>
			<cfset CanAcceptAll = 1 />
		<cfelse>
			<cfset CanAcceptAll = 0 />
			<cfbreak />
		</cfif>
	 </cfloop>
 </cfif>	
<cfoutput> 
 <!---  <div align="right" width="100%" id="btnActive"><a href="##" onclick="javascript:submitForm(this);" class="newLink">Accept all</a> <a href="##" onclick="javascript:submitForm(this);" class="newLink">Deny all</a> <a href="/flex/billback/BillbackDevAppFx.cfm?#URLString#" class="newLink">Goto Deviations</a> <a href="##" onclick="javascript:window.close();" class="newLink">Close</a> </div> --->
<!--- 
	1) When the profile setting is set to an Amount and not '*', the variable CanAcceptAll has the value, to show the Accept button at the top.
	2) The Deviations button works like below:
		a) if the records are already accepted/denied then clicking on deviations will not change the saved value.
		b) if the records are not accepted/denied then clicking on deviations will by default accept all the records 
		   or mark the records as accepted, if the value of the profile setting is above the amounts on the records.
--->
<div style="margin-top:5px; margin-bottom:5px;"><cfif (CanAcceptAll EQ 1)><button type="button" onclick="javascript:fnSubmitForm('ACCEPTALL',0);" class="button success" style="margin:0 4px;cursor:hand;">Accept</button></cfif><button type="button" onclick="javascript:fnSubmitForm('DENYALL',0);" class="button danger"  style="margin:0 4px;cursor:hand;">Deny</button><button type="button" onclick="javascript:fnSubmitForm('RESET',0);" class="button"  style="margin:0 4px;cursor:hand;">Reset</button> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button type="button" class="button" title="Goto Deviations" style="margin:0 4px;cursor:hand;" onclick="javascript:fnSubmitForm('GOTODEV',0);">Deviations</button><button type="button" onclick="javascript:window.close();" class="button" style="margin:0 4px;cursor:hand;">Close</button> </div> 
  <br>
	<table class="datagrid" cellspacing="0">
		<thead >
			<th class="header"><div align="center"><b>Action</b></div></th>
	   	 	<th class="header"><div align="center"><b>Status</b></div></th>	
			<th class="header" width="50"><div align="center"><b>Amount</b></div></th>	
			<th class="header" width="50"><div align="center"><b>Rate</b></div></th>	
			<th class="header" width="50"><div align="center"><b>Cases</b></div></th>	
			<th class="header"><b>Program</b></th>	
			<th class="header"><b>Title</b></th>	
			<th class="header"><div align="center"><b>Type</b></div></th>	 <!--- Claim Type --->
			<th class="header"><b>Pays To</b></th>	
			<th class="header"><div align="center"><nobr><b>Payable ##</b></nobr></div></th>	
			<th class="header"><div align="center"><b>Invoice</b></th>	
			<th class="header"><div align="center"><b>Start</b></div></th>	
			<th class="header"><div align="center"><b>End</b></div></th>	
			<th class="header"><b>Item</b></th>	
			<th class="header"><b>Description</b></th>	
			<th class="header"><b>Location</b></th>	
			<th class="header"><b>Location Name</b></th>	
			<th class="header"><b>Sold To</b></th>	
			<th class="header"><b>Customer Name</b></th>
			
		</thead>
	  	<tbody>
		
			<cfset curRow = 0 />
			<cfset rowGroupCounter = 0 />
			<cfloop query="getBBOperLocationDups">
				<cfif curRow NEQ  getBBOperLocationDups.Billback_Operator_Location_Detail_ID >
					<cfset curRow = getBBOperLocationDups.Billback_Operator_Location_Detail_ID />
					<cfset displayRow  = 1 />  
				</cfif>
				<cfset rowGroupCounter++ />
			
				<cfif (getBBOperLocationDups.Billback_ID NEQ getBBOperLocationDups.Dup_Billback_ID)> 
					<cfset bgSytleGray="style ='background-color: ##D8D9DD;'" />
					<cfset bgSytleGrayBlack="style ='background-color: ##D8D9DD;border-bottom: 4px solid ##000000;'" />
				<cfelse>	
					<cfset bgSytleGray = "style ='padding: 8px;'" />
				</cfif>
				<cfif ((rowGroupCounter EQ getBBOperLocationDups.Cnt_of_Dup_BB) )><!--- AND  getBBOperLocationDups.Billback_ID EQ getBBOperLocationDups.Dup_Billback_ID --->
					<cfset rowGroupCounter = 0 />
				
					<tr style="border-bottom: 4px solid ##000000;"><!--- 663300 AFB0B2 ---> 
				<cfelse>
					<tr <cfif (getBBOperLocationDups.Billback_ID EQ getBBOperLocationDups.Dup_Billback_ID)> style="border-bottom: 1px dashed ##565760;"</cfif>> 
				</cfif>	

				<cfset Maxlen = 25 /> 
				<cfset TitleMaxed = Left(getBBOperLocationDups.Dup_Payee_Name,Maxlen) />
				<cfif (len(TitleMaxed) GT Maxlen)>
					<cfset TitleMaxed &= "..." />
				</cfif>

				<cfset TitleNew = "<span align=""left"" title=""Title: #getBBOperLocationDups.Dup_Payee_Name#"" style='cursor:help;'>#TitleMaxed#</span>" />
 
				<cfset Can_Accept_Deny = 0>
				<cfif (getBBOperLocationDups.Dup_Loc_Claimed_Amount LTE Get_Profile_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount) OR (Get_Profile_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount EQ "*")>
					<cfset Can_Accept_Deny = 1>
				</cfif>	
				
				<cfif (displayRow EQ 1)>
					<td  align="center" valign="top">
							<cfif (getBBOperLocationDups.Billback_ID EQ URL.BBID)>
								<nobr><cfif ((MaxBBOprLocationLevelDupApprovalAmount EQ "*") OR (MaxBBOprLocationLevelDupApprovalAmount GTE getBBOperLocationDups.Dup_Loc_Claimed_Amount))><button type="button" onclick="javascript:fnSubmitForm('ACCEPT',#getBBOperLocationDups.Billback_Operator_Location_Detail_ID#);" class="button outline success" style="margin:0 4px;cursor:hand;">Accept</button>&nbsp;</cfif><button type="button" class="button outline danger" style="margin:0 0px;cursor:hand;" id="denyBtn"  onclick="javascript:fnSubmitForm('DENY',#getBBOperLocationDups.Billback_Operator_Location_Detail_ID#);">Deny</button></nobr><br>
<div style="padding:5px;font-size:10px;">
<cfif ((getBBOperLocationDups.denied EQ 0) AND (getBBOperLocationDups.Updated_Date EQ ""))>No Selection <cfelseif ((getBBOperLocationDups.denied EQ 0) AND (getBBOperLocationDups.Updated_Date NEQ ""))>Accepted
<cfelseif ((getBBOperLocationDups.denied EQ 1) AND (getBBOperLocationDups.Updated_Date NEQ ""))>Denied</cfif></div>
							</cfif>
						</td>
				<cfelseif ((displayRow EQ 2) AND (getBBOperLocationDups.Billback_ID NEQ getBBOperLocationDups.Dup_Billback_ID)) >
				<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>
					&nbsp;
				</td>
				</cfif>
				
					<td align="center" #bgSytleGray#><nobr>#getBBOperLocationDups.Dup_BB_Status_Description#</nobr></td> 									<!--- Approve --->
					<td align="center" #bgSytleGray#>#dollarformat(getBBOperLocationDups.Dup_Loc_Claimed_Amount)#</td>  						<!--- Amount($'s) --->
					<td align="center" #bgSytleGray#><nobr>#dollarformat(getBBOperLocationDups.Dup_Loc_Claimed_Rate)#</nobr></td> 			<!--- Rate  ---> 
					<td align="center" #bgSytleGray#><nobr>#getBBOperLocationDups.Dup_Loc_Claimed_Qty#</nobr></td> 							<!--- Cases ---> 
					<td align="center" #bgSytleGray#>#getBBOperLocationDups.Dup_Payee_ID#</td>	 											<!--- Program ---> 
					<td #bgSytleGray#>#TitleNew#</td> 																						<!--- Title ---> 
					<td align="center" #bgSytleGray#>#getBBOperLocationDups.Dup_Claim_Type#</td> 												<!--- Claim Type ---> 
					<td #bgSytleGray#>#getBBOperLocationDups.Dup_Payee_Type#<!--- Operator ---></td> 																							<!--- Pays To ---> 
					<td align="center" #bgSytleGray#>#Replace(Replace(getBBOperLocationDups.Dup_BB_Code,'BB-','','ALL'),'-00','','ALL')#</td>	<!--- Billback ---> 
					<td #bgSytleGray#>#getBBOperLocationDups.Dup_BB_Reference#</td> 	 														<!--- Invoice ---> 	
					<td align="center" #bgSytleGray#>&nbsp;#DateFormat(getBBOperLocationDups.Dup_BB_Start_Date,'mm/dd/yyyy')#&nbsp;</td> 		<!--- Start ---> 
					<td align="center" #bgSytleGray#>&nbsp;#DateFormat(getBBOperLocationDups.Dup_BB_End_Date,'mm/dd/yyyy')#&nbsp;</td> 		<!--- End ---> 
					<cfif ((displayRow EQ 2) AND (getBBOperLocationDups.Billback_ID NEQ getBBOperLocationDups.Dup_Billback_ID)) >
						<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>#getBBOperLocationDups.Item#</td>	 				<!--- Item ---> 				
						<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>#getBBOperLocationDups.Description#</td> 			<!--- Description ---> 
						<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>#getBBOperLocationDups.Loc_Legacy_ID#</td> 			<!--- Location  ---> 
						<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>#getBBOperLocationDups.Loc_Operator_Name#</td> 		<!--- Location Name ---> 
						<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>#getBBOperLocationDups.Ship_to#</td> 				<!--- Sold To ---> 
						<td rowspan="#getBBOperLocationDups.Cnt_of_Dup_BB - 1#" #bgSytleGrayBlack#>#getBBOperLocationDups.Name#</td> 					<!--- Customer Name ---> 
					<cfelseif (displayRow EQ 1)>
						<td colspan="6">&nbsp;</td>
					</cfif>
				</tr>
				<cfset displayRow++ />
			</cfloop>
		</tbody>
	</table> 

 <br>
  <!--- <a id="saveLink" >#application.util.string.actionLinkFormat2("save")#</a> --->
  <!--- <div style="margin-top:5px; margin-bottom:5px;"><button type="button" onclick="javascript:submitForm(this);" class="button" style="margin:0 4px;cursor:hand;">Accept all</button><button type="button" onclick="javascript:submitForm(this);" class="Button Danger"  style="margin:0 4px;cursor:hand;">Deny all</button><button type="button"   onclick="window.location.href = '/flex/billback/BillbackDevAppFx.cfm?#URLString#'"   class="button recommended" title="Accept all and Goto Deviations" style="margin:0 4px;cursor:hand;">Goto Deviations</button><button type="button" onclick="javascript:window.close();" class="button" style="margin:0 4px;cursor:hand;">Close</button> </div> --->
<div style="margin-top:5px; margin-bottom:5px;"><cfif (CanAcceptAll EQ 1)><button type="button" onclick="javascript:fnSubmitForm('ACCEPTALL',0);" class="button success" style="margin:0 4px;cursor:hand;">Accept</button></cfif><button type="button" onclick="javascript:fnSubmitForm('DENYALL',0);" class="button danger"  style="margin:0 4px;cursor:hand;">Deny</button><button type="button" onclick="javascript:fnSubmitForm('RESET',0);" class="button"  style="margin:0 4px;cursor:hand;">Reset</button> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button type="button" class="button" title="Goto Deviations" style="margin:0 4px;cursor:hand;" onclick="javascript:fnSubmitForm('GOTODEV',0);">Deviations</button><button type="button" onclick="javascript:window.close();" class="button" style="margin:0 4px;cursor:hand;">Close</button> </div>
  
  
<input type="hidden" name="submitted">  
<input type="hidden" name="BillbackOperatorLocationDetailID">
<input type="hidden" name="actionType"> <!--- Values set are ACCEPT, DENY, ACCEPTALL, DENYALL, GOTODEV --->
  
</form>   
</cfoutput>
 <!---  <script type="text/javascript" src="/Script/javascript/dataTables.fixedColumns.min.js"></script> --->
<script>
/*
var oTable = $('table#datagrid').DataTable({
    "bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"bFilter": false
    ,"aoColumns": [   
    									{"bSortable":true, "bSearchable":true }
    									<cfloop from="1" to="#getBBOperLocationDups.recordcount#" index='item'>
                    , {"bSortable":true,  "bSearchable":false}
                    	</cfloop>
                    ]
		,"scrollY": Math.floor(jQuery(window).height()) - 150
		,"scrollX": true
		,"scrollCollapse": true
  })

 */

 
 
function  fnSubmitForm(argActionType,argBillbackOperatorLocationDetailID)
{
	var thisForm 	= document.getElementById('frmOperDupCheck');
	// var singleFile	= thisForm.single_file;
	
	thisForm.submitted.value =  1;
	thisForm.actionType.value = argActionType;
	thisForm.BillbackOperatorLocationDetailID.value = argBillbackOperatorLocationDetailID;
	
	thisForm.submit();
}
</script>