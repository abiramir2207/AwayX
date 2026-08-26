<!-----------------------------------------------------------------------------

FILE NAME:		bid_info.cfm
DESCRIPTION:	This page will display the bid infomation and option to add 
				the line# for each products
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	08-Nov-2011 	created the page.	

------------------------------------------------------------------------------> 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Bid Info</title>
<!--- Style sheet for JQUERY data --->
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<!--- "JQuery" library files --->
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>
<!--- JS validation --->
<script type="text/javascript" src="validation.js"></script>
</head>
<body>

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "ci">
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfparam name="FORM.sort_by" 	default="IN">
<cfparam name="form.sql_Sort_By" default="Item">
<cfparam name="FORM.sort_order" 	default="ASC">
<cfparam name="URL.iDisplayStart" default="0">

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<style>
	#dr_main_container{
	margin: 0;
	width:1125px;
	height:800px;
	text-align: center;
	}
	#dr_left_side{
	width:140px;
	height:750px;
	float: left;
	}
	#dr_right_side{
	width:960px;
	height:auto;
	float: right;
	}
	#box{
	width:950px;
	background-color: #4169E1;
	font-size:14px;
	color: white;
	padding-top: 5px;
	padding-bottom: 5px;
	margin-top:2px;
    margin-bottom:2px;
	text-align: left;
	}
	#MassAppplySection{
	display: none;
	width:950px;
	margin-top:2px;
	margin-bottom:2px;
	padding-bottom:5px;
	padding-top:5px;
	height: 20px;
	font-size: 14px;
	}
	#box1{
	width: 950px;
	background-color: #C0C0C0;
	padding-bottom:5px;
	padding-top:5px;
	height: 20px;
	font-size: 12px;
	margin-top:2px;
    margin-bottom:2px;
	margin-left: -10px;
	}
    #box2{
    width: 800px;
    background-color: #C0C0C0;
    height: 20px;
    font-size: 12px;
    margin-top:2px;
    margin-bottom:2px;
    }
    #Updatebox{
	width:500px;
	background-color: #fff;
	font-size:12px;
	color: black;
	padding-top: 5px;
	padding-bottom: 5px;
	margin-top:2px;
    margin-bottom:5px;
	text-align: center;
	padding-left: 25px;
	padding-right: 25px;
	border: solid;
	border-width: 2px;
	border-color: orange;
	}
 </style>


<!---  CFQUERIES START  --->

    
<cfquery name="GetContractInfo" datasource="#application.datasource#">
    SELECT 
		Program_Control_Panel_Options.Created_Type as CreatedType,
		Program_Control_Panel_Options.Include_Competitive_Data_Tracking, 
		Program_Control_Panel_Options.Display_Bid_Info_Page, 
		Program_Control_Panel_Options.Line_Number, 		
		Program_Control_Panel_Options.*,Contract_Main.*
    FROM Contract_Main
    INNER JOIN Program_Control_Panel_Options
            ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
    WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
    and Program_Control_Panel_Options.deleted = 0
</cfquery>
<cfset programDesc = GetContractInfo.CreatedType >
<cfset MAXLENGTH = 50 >
<!--- this Query pulls title info  END--->


<!--- The queries commented below are not being used --->
<!--- THIS Query Pulls category info START --->
<!---
<cfquery name="category_info" datasource="#application.datasource#">
    SELECT  Program_Bid_Category_ID,
            Program_Bid_Category_Code,
            Program_Bid_Category_Description,
            Active,
            Deleted,
            Created_Date,
            Updated_Date,
            Updated_By
    FROM    Program_Bid_Category
    WHERE Deleted = 0  AND active = 1
    ORDER BY    Program_Bid_Category_Description
 </cfquery>
 --->
<!--- THIS Query Pulls category info END--->

<!--- THIS Query Pulls package START --->
<!---
<cfquery name="package_info" datasource="#application.datasource#">
    SELECT  Program_Bid_Package_ID,
            Program_Bid_Package_Code,
            Program_Bid_Package_Description,
            Active,
            Deleted,
            Created_Date,
            Updated_Date,
            Updated_By
    FROM    Program_Bid_Package
    WHERE Deleted = 0 AND active = 1
    ORDER BY    Program_Bid_Package_Description
 </cfquery>
 --->
 <!---
<cfquery name="won_by" datasource="#application.datasource#">
    SELECT  Program_Bid_Won_By_ID,
            Program_Bid_Won_By_Code,
            Program_Bid_Won_By_Description,
            Active,
            Deleted,
            Created_Date,
            Updated_Date,
            Updated_By
    FROM        Program_Bid_Won_By
    WHERE Deleted = 0 AND active = 1
    ORDER BY    Program_Bid_Won_By_Description
</cfquery>
--->
 
<cfinvoke component="components.programs.bid_request.CompetitiveDataManager" method="getTemplateSettings" returnVariable="template_info">
   <cfinvokeargument name="programID" value="#trim(FORM.Contract_Main_ID)#">
</cfinvoke>
  <!---
<cfinvoke component="components.programs.bid_request.CompetitiveDataManager" method="getProgramCompetitiveProductData" returnVariable="items_info">
   <cfinvokeargument name="programID" value="#trim(FORM.Contract_Main_ID)#">
</cfinvoke>
 --->
<cfinvoke component="components.programs.bid_request.CompetitiveDataManager" method="getProgramCompetitiveData" returnVariable="title_info">
<cfinvokeargument name="programID" value="#trim(FORM.Contract_Main_ID)#">
</cfinvoke>

<cfquery name="Program_status_id" datasource="#application.datasource#">
SELECT Bid_Request_status_ID FROM Program_Bid_Request WHERE	Deleted = 0	AND	Program_ID = #trim(FORM.Contract_Main_ID)#
</cfquery>
<cfquery name="Program_status_description" datasource="#application.datasource#">
SELECT Bid_Request_Status_ID,Status_Desc FROM Bid_Request_Status WHERE Bid_Request_Status_ID = #trim(Program_status_id.Bid_Request_status_ID)# AND Deleted = 0
</cfquery>

<!--- This Variable Store Program Status START  1==Pending 2==Won 3==Split 4==Lost--->
<cfset Program_status = trim(Program_status_description.Bid_Request_Status_ID)>
<!--- This Variable Store Program Status ID END 1==Pending 2==Won 3==Split 4==Lost--->

<cfquery name="last_update_id" datasource="#application.datasource#">
SELECT Status_Changed_By FROM Program_Bid_Request WHERE program_id = #trim(FORM.Contract_Main_ID)#
</cfquery>

<cfquery name="last_update_info" datasource="#application.datasource#">
SELECT       Name_First, Name_Last, Status_Changed_Date
FROM         _Users INNER JOIN
             Program_Bid_Request ON dbo._Users.User_ID = Program_Bid_Request.Status_Changed_By
WHERE     Program_Bid_Request.Status_Changed_By = '#trim(last_update_id.Status_Changed_By)#' AND Program_Bid_Request.Program_ID = #trim(FORM.Contract_Main_ID)#
</cfquery>

<!--- CFQUERIES END --->
<cfoutput>
 		
<!---  ####################### Dynamic Width Calucation START #####################################  --->
 
<cfset Shared = template_info.shared>
<cfset Incremental = template_info.incremental>
<cfset Specd = template_info.specd>
<cfset Package = template_info.package>
<cfset Category = template_info.category>
 
<cfparam name="item_width" default="300">
<cfparam name="wl_width" default="85">
<cfparam name="Shared_width" default="70">
<cfparam name="Incremental_width" default = "80">
<cfparam name="Specd_width" default = "40">
<cfparam name="Package_width" default = "165">
<cfparam name="Category_width" default = "170">


<cfparam name="total_width" default="0">

<cfset list = "Shared,Incremental,Specd,Package,Category">
<cfset width = "70,80,40,165,170">
 
<cfset count = listlen(list)+2>
<cfset width = round(total_width/count)-1>
<cfset item_width = item_width+width>
<cfset wl_width = wl_width+width>

<cfloop list="#list#" index="list_items" delimiters=",">
	<cfset "#list_items#_width" = Evaluate('#list_items#_width') + width>
</cfloop>


<!--- We are setting template setting to following variables to calculate width START --->
<cfset Wonby = template_info.won_by>
<cfset Wonrate = template_info.won_rate>
<cfset Wonuom = template_info.won_uom>
<cfset Deliverytype = template_info.delivery_type>
<!--- We are setting template setting to following variables to calculate width END --->

<cfparam name="Wonby_width" default="350">
<cfparam name="Wonrate_width" default="110">
<cfparam name="Wonuom_width" default="110">
<cfparam name="Deliverytype_width" default="195">
<cfparam name="inner_total_width" default="0">

<cfset inner_list = "Wonrate,Wonuom,Deliverytype">
<cfset inner_width = "110,110,195">



<cfif Wonrate EQ 0>
	<cfset at =listfind(inner_list,'Wonrate')>
	<cfset inner_list = listdeleteat(inner_list, at)>
	<cfset inner_widh = listgetat(inner_width, at)>
	<cfset inner_width = listdeleteat(inner_width, at)>
	<cfset inner_total_width = inner_total_width + inner_widh>
</cfif>

<cfif Wonuom EQ 0>
	<cfset at =listfind(inner_list,'Wonuom')>
 	<cfset inner_list = listdeleteat(inner_list, at)>
	<cfset inner_widh = listgetat(inner_width, at)>
	<cfset inner_width = listdeleteat(inner_width, at)>
	<cfset inner_total_width = inner_total_width + inner_widh>
</cfif>

<cfif Deliverytype EQ 0>
	<cfset at = listfind(inner_list,'Deliverytype')>
	<cfset inner_list = listdeleteat(inner_list, at)>
	<cfset inner_widh = listgetat(inner_width, at)>
	<cfset inner_width = listdeleteat(inner_width, at)>
	<cfset inner_total_width = inner_total_width + inner_widh>
</cfif>


<cfset inner_count = listlen(inner_list)+1>
<cfset inner_width = round(inner_total_width/inner_count)-1>
<cfset Wonby_width = Wonby_width + inner_width>


<cfloop list="#inner_list#" index="inner_list_items" delimiters=",">

<cfset "#inner_list_items#_width" = Evaluate('#inner_list_items#_width') + inner_width>

</cfloop>
  
<!--- Dynamic Width Calucation END --->
 

<div id="dr_main_container">
<div id="dr_left_side">
<CFINCLUDE TEMPLATE="../contract_status_legend.cfm">
</div>
<!--- Right Side START --->
<div id="dr_right_side">


	<!---<cfform name="thatForm" onsubmit="return Mass_apply_checker()" action="Competitive_Data_Save.cfm?type=massapply&source=bidInfoPage" method="post">--->
	<!--- title bar START--->
	<div id="box" style="background-color: ##FFC66F; color: black; margin-bottom: 5px;">
    <div style="display:inline-block; text-align: left;">
    &nbsp;&nbsp;&nbsp;Program Number: <B>#GetContractInfo.Contract_Number#</B>
    </div>
    <div style="float: right; text-align: right; padding-right: 5px;">
    Program Template: <B><cfif Len(GetContractInfo.CreatedType) GT MAXLENGTH >#Left(GetContractInfo.CreatedType,MAXLENGTH)#...<cfelse>#GetContractInfo.CreatedType#</cfif></B>
    </div>
    </div>
	<!--- title bar END--->
	<!--- Last Update Info Start--->
	<cfif #last_update_info.recordcount# GT 0>
		<div id="Updatebox">
				<B>Last updated on #dateformat(last_update_info.Status_Changed_Date, 'mm/dd/yyyy')# #timeformat(last_update_info.Status_Changed_Date, 'hh:mm:ss TT')# by #last_update_info.Name_First#&nbsp;#last_update_info.Name_Last#</B>
		</div>
	</cfif>
 		<!---<input type="hidden" name="source" 		value = "novalue" />
		<input type="hidden" name="sourcetype" 	value = "novalue" />--->
		
		
		<!---<cfif #template_info.date_source_received# NEQ 0>
		  <div style="width:330px; float:left; font-size: 12px; text-align: left; margin-bottom: 5px;">
	    	 <table style="margin-top:-4px;">
			 <tr>
			 <td style=" font-size: 12px;">Date:</td>
			 <td><CF_EASYDATE FORMNAME="thatForm" FIELDNAME="sourcedate" FORMAT="mm/dd/yyyy" DEFAULT="#left(title_info.PROGRAM_BID_SOURCE_DATE,10)#" FieldNameSize="10"></td>
			 </tr>
			 </table>
    		</div>
		 <cfelse>
   		<input type="hidden" name="sourcedate" value="#DateFormat(Now(), 'mm/dd/yyyy')#">
		 </cfif>--->
     </div>
 
    <!--- Source, Source-type, Date (titles) END --->
		<!---<input name="Contract_Main_ID" type="hidden" value="#trim(form.Contract_Main_ID)#">--->
 
	<!---</cfform>--->
	
<!---  
 ##############################################################################################################################################################
 --->
 		
 <form name="thisForm" onsubmit="return individual_checker()"  action="bid_info_save.cfm" method="post" style="margin-top:-3px;">
 
<div align="left">
<div style="text-align:right; margin-top:15px;border:none;width:720px;display:inline-block;" >
			<cfif (GetContractInfo.Display_Bid_Info_Page EQ 1 AND GetContractInfo.Line_Number EQ 1)>
			<span style="color: red;font-size: 12px;font-weight:bold;">[</span><input type="button" value="Save" onClick="submitfrm()" style="border: none; background-color: white; font-size: 10px; color: ##515AB7;cursor:pointer;font-weight:bold"><span style="color: red;font-size: 12px;font-weight:bold;">]</span>
			<cfelse>
				<span style="color: red;font-size: 14px;">[</span>Save<span style="color: red;font-size: 14px;">]</span>
			</cfif>
			</div>
  
<cfpod name="Items" title="Items Box" headerstyle="display:none;" bodystyle="border:none;padding-left:30;" height="450" width="780" >
		<!---
		<input name="source" type="hidden" value="#trim(title_info.PROGRAM_BID_SOURCE_ID)#">
     		<input name="sourcetype" type="hidden" value="#trim(title_info.PROGRAM_BID_SOURCE_TYPE_ID)#">
		<input name="sourcedate" type="hidden" value="#trim(left(title_info.PROGRAM_BID_SOURCE_DATE,10))#">
		--->
		<input name="Contract_Main_ID" type="hidden" value="#trim(form.Contract_Main_ID)#">

<!--- this variable used to created dynamic div for cloning --->
<cfset z = 1>
<div align="left" style="padding-top:10;padding-bottom:10;">
<!--- <label for="filter">Search:</label>  <input type="text" name="filter" value="" id="filter" /> --->
</div>

<table class="datagrid" id="datagrid"  width="80%" cellpadding="3" cellspacing="0">
	<thead>
	<tr valign="bottom">
		<th>
			#application.returned_customer_setting.item_label# ##
		</th>
		<th>
			GROUP DESCRIPTION
		</th>
		
		<th>
			PRODUCT DESCRIPTION
		</th>
		<cfif GetContractInfo.Line_Number EQ 1>
		<th>
			Line ##
		</th>
		</cfif>
	</tr>
 </thead>	
 <!--- JQUERY returns data and the result is shown between the "tbody" tags below. --->
<tbody>
</tbody> 
</table>
<br>
</cfpod>
<div style="text-align: right; margin-top:15px;width:720px;display:inline-block;" >
	<cfif (GetContractInfo.Display_Bid_Info_Page EQ 1 AND GetContractInfo.Line_Number EQ 1)>
	<span style="color: red;font-size: 12px;font-weight:bold;">[</span><input type="button" value="Save" onClick="submitfrm()" style="border: none; background-color: white; font-size: 10px; color: ##515AB7;cursor:pointer;font-weight:bold"><span style="color: red;font-size: 12px;font-weight:bold;">]</span>
	<cfelse>
		<span style="color: red;font-size: 14px;">[</span>Save<span style="color: red;font-size: 14px;">]</span>
	</cfif>
	</div>
</div>
	<input type="hidden" name= "ListItemLineNumberCombo" />
</form>

 
</div>
<!--- Right Side END --->
</div>
</cfoutput>

<!--- -Make JQUERY calls to load data --->
<!--- "iDisplayStart" default is 0 and is normally not needed to be set below, but since we have paging with the "save"
functionality, the user needs to be redirected to the page from where the page was saved. So, "iDisplayStart" is reset
only when the user saves the data.
--->
<script>  
/*Initilaize these vars outside any function. */
var arrayProductGUIDAndValue = [];
var hiddenVarList  = '';

var grid = $('table#datagrid').dataTable({
	     "bServerSide": true
	    ,"bProcessing": true
	    ,"bSortClasses": false
	    ,"bAutoWidth": false
	    ,"iDisplayStart": <cfoutput>#URL.iDisplayStart#</cfoutput>
	    ,"iDisplayLength": 100
	    ,"oLanguage": {"sSearch": "<b>Search:</b>"} 
	    ,"fnDrawCallback": function () {setProductListNumber()} 
	    ,"sAjaxSource": "Ajax/Bid_Info_Search_Qry.cfm?Contract_Main_ID=<cfoutput>#Form.Contract_Main_ID#</cfoutput>"
	    ,"sDom": "fprti"
	    ,"aaSorting": []
	    ,"aoColumns": [  {"bSearchable": true,  "bSortable":true}
				  ,{"bSearchable": true, "bSortable":true}
				  ,{"bSearchable": false, "bSortable":true}
				  ,{"bSearchable": false, "bSortable":true}
		          ]
	} ).fnSetFilteringDelay();


/* I AM SENDING DATA THROUGH THE URL ABOVE. BELOW IS THE CODE TO SEND IT THROUGH A FORM.
   I HAVE COMMENTED THE CODE AS I AM NOT USING IT. 
 */
/*
var grid = $('table#datagrid').dataTable({     
"bServerSide": true,   
"bProcessing": true,      
"bSortClasses": false,
"bAutoWidth": false,
"aLengthMenu": [],
"oLanguage": {"sSearch": "<b>Search:</b>"},
"fnDrawCallback": function () {setProductListNumber()},
"sAjaxSource": "Ajax/Bid_Info_Search_Qry.cfm?Contract_Main_ID=<cfoutput>#Form.Contract_Main_ID#</cfoutput>",
 "iDisplayStart": <cfoutput>#URL.iDisplayStart#</cfoutput>,
 "iDisplayLength": 100,
"fnServerData": function ( sSource, aoData, fnCallback, oSettings ) {  
						// SEND SPECIFIC FORM VALUE
						aoData.push( { "name": "ListItemLineNumberCombo", "value": thisForm.ListItemLineNumberCombo.value } );

oSettings.jqXHR = $.ajax( {      
"dataType": 'json',          
"type": "POST",         
"url": sSource,        
"data": aoData,         
	    "sDom": "fprti",
	    "aaSorting": [],
	    "aoColumns": [  {"bSearchable": true,  "bSortable":true}
				  ,{"bSearchable": true, "bSortable":true}
				  ,{"bSearchable": false, "bSortable":true}
				  ,{"bSearchable": false, "bSortable":true}
		          ],
"success": fnCallback   

} );    
}   
} ); 
*/


$('table#datagrid tr').hover (
  function() { 
  $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);

/* If the user does not save the line number before searching, sorting or
   visiting another page, then the line number is lost. The Objective here is
   to show the modified line number's on the form. This modified value overwrites
   any value from the db (if any).
*/
function setProductListNumber(){

	/* loop though the form. */
	for (i=0;i<thisForm.length;i++){
		
		/* if it is the "line number" textbox. */
		if(thisForm[i].name.indexOf('line_number') != -1){
		
		/* Extract the product GUID from the input name. */
		var productGUID = ExtractProductNumber(thisForm[i]);

			/* If line number of any product has been modified, then that product will be in the
			"arrayProductGUIDAndValue" array.
			*/
			for(j=0;j<arrayProductGUIDAndValue.length;j++){
			
			/*"arrayProductGUIDAndValue" array is a combination of product GUID and Line number. 
			   Extract the product GUID below.
			*/
			var productGUIDInArray = arrayProductGUIDAndValue[j].substring(0,36);

			/* Extract the line number below. */
			var LineNumberInArray = arrayProductGUIDAndValue[j].substring(37,arrayProductGUIDAndValue[j].length);

			/* The objective here is to populate the line number from this array as the user has added/edited
			line numbers for products. If the user does not save the line number before searching, sorting or
			visiting another page, then the line number is lost. "arrayProductGUIDAndValue" stores the line number
			for every modified line number.			
			*/
			/* If the line number exists in the array, populate the line number textbox's value from the array. */
				if(productGUID == productGUIDInArray){
					thisForm[i].value = LineNumberInArray;

				}
			}
		}	
	}
}

/* The objective here is to store line number (Prod GUID and Line Number combo) in an array, 
whenever a user modifies (adds/edits)line number for any product.
*/
function addProductListNumber(inputObj)
{
	var str = '';
	var addHiddenVar = 1;
	
	/* Extract the product GUID from the input name. */
	var productGUID = ExtractProductNumber(inputObj);

	 /* "hiddenVarList" stores the form variables (line number and some other hidden variables from 
	 "Bid_Info_Search_Qry.cfm"), whenever a product's line number is modified. Here we are checking
	 whether the line number and hidden vars already exist for a product.
	 */
	 for (i=0;i<arrayProductGUIDAndValue.length;i++){
		if(arrayProductGUIDAndValue[i].indexOf(productGUID) != -1){
			addHiddenVar = 0;
			break;
		}
	 }
	
	/* If the product's variables - line number and hidden vars already exist in "hiddenVarList", 
	then do not add it again.
	Note: Even though "hiddenVarList" will have the hidden variable for "line number", we do not use
	this hidden var's value to update the db. Instead, on the action page, we update the line number
	from the updated value on "ListItemLineNumberCombo" array.
	*/
	if(addHiddenVar){

		for (i=0;i<thisForm.length;i++){

			if(thisForm[i].name.indexOf(productGUID) != -1){

				hiddenVarList  = hiddenVarList + ' ' + document.getElementById(thisForm[i].name).outerHTML;
			}
		}
	}
	
	var inputValue = inputObj.value;

	/* product guid and value combo */
	var productGUIDAndValue = productGUID + '_' + inputValue;
	
	/* If the user updates the line number more than once, then delete the earlier prod guid 
	and line number combo.
	*/
	if(arrayProductGUIDAndValue){
		for (i=0;i<arrayProductGUIDAndValue.length;i++){
			if(arrayProductGUIDAndValue[i].indexOf(productGUID) != -1){
				arrayProductGUIDAndValue.splice(i,1);
			}
		}
	   /* Add the  prod guid and line number combo.*/
	   arrayProductGUIDAndValue.push(productGUIDAndValue);
	}

/* Set it to a form value. This is useful in the action page as we update only those products which have 
been modified, i.e. the products in this form variable.
*/
thisForm.ListItemLineNumberCombo.value = arrayProductGUIDAndValue;
}


/* get the product GUID from the input name containing the product GUID. */
function ExtractProductNumber(inputObj){

  /* get the input name. */
  var inputName = inputObj.name;

  /* reverse the name. */
  var reverseInputName = inputName.split('').reverse().join('');

  /* Extract the GUID. This is the reversed GUID. */
  var reverseProductGUID = reverseInputName.substring(12,48);

  /* Reverse it again to get the product GUID. */
  var productGUID = reverseProductGUID.split('').reverse().join('');

return productGUID
}

/* call when the user clicks on "save". */
function submitfrm(){

/* The objective here is to add the hidden variables to the form.
   These variables store the line numbers added/modified by the user .
*/
  /* create a new DIV element. */
  var newdiv = document.createElement('div');

  /* The hidden vars are now a part of the DIV element. */
  newdiv.innerHTML = hiddenVarList;

  /* When the form is submitted on "save", the "line number" textboxes modified on the screen appear twice
  and so we do not want to see duplicate textboxes.
  */
  newdiv.style.display = 'none'

  /* Add the DIV element to the form. */
  thisForm.appendChild(newdiv);

  thisForm.submit();
}

</script>

</body>
</html>