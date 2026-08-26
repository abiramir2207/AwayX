<cfajaximport tags="cfdiv,cfform,cfwindow"/>
<HTML>
<HEAD>
<TITLE>Template Filters</TITLE>
	<link rel="stylesheet" href="/styles/templateFilter.css" type="text/css" /> 

<script language="javascript" type="text/javascript">
function templatefilter(s)
{
    document.DataForm.new_Selected_User.value = s;
    fnTemplateFiltersSave();
    return false;
 }
</script>

<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<!--- Label D27272 Moved this script section from frmTemplateFilter.cfm as we are nesting using nestion form and that script has previous form name START --->
<script>
	function deleteHandler(id){
		DataForm.sAction.value='Delete';
		DataForm.TemplateFiltersId.value = id;
		DataForm.tiName.value = '';
		DataForm.tiDescription.value = '';
		DataForm.submit();
		
	}
	function saveHandler(rdoFilter){
		DataForm.sAction.value='Save';
		DataForm.TemplateFiltersId.value = rdoFilter;
		document.getElementById('bContinue').value=1;
		document.getElementById('bSaveAndContinue').value=1
		//simulate the save and continue "click" so all of the Filter data is saved
		document.getElementById('sac').click();
	}
	function createHandler(){
		DataForm.sAction.value='Save';
		DataForm.submit();
	}
/*label D26730  by Dinesh  	function editHandler(n,d){
		frmTemplateFilter.tiName.value = n;
		frmTemplateFilter.tiDescription.value = d;
		frmTemplateFilter.submit();
	} label D26730  by Dinesh */
	
	<!--- label D26730  by Dinesh Added to Solved nesting form issue --->
	function editHandler(n,d){
		DataForm.tiName.value = n;
		DataForm.tiDescription.value = d;
		DataForm.submit();
	}
	<!--- label D26730  by Dinesh Added to Solved nesting form issue --->
	function openSummaryWin(TemlateFiltersId){
		myRef = window.open('/Program_Wizard/filter/templateFilterSummary.cfm?TemlateFiltersId='+TemlateFiltersId+'&TemlateId='+<cfoutput>#ID#</cfoutput>,
			'TFwin',
			'left=20,top=40,width=1000,height=800,toolbar=0,resizable=1,scrollbars=1');
	}
	
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


</script>
<!--- Label D27272 Moved this script section from frmTemplateFilter.cfm as we are nesting using nestion form and that script has previous form name END --->

</HEAD>

<!--- Vars used for header.cfm --->

<cfif IsDefined("url.ID")>
	<cfset ID = url.ID>
<cfelseif isDefined("form.ID")>
	<cfset ID = form.ID>
<cfelse>
	<cfset ID = 0>
</cfif>

<cfparam name="form.postions" default="" />


<cfset Action = "edit">
<cfset pageName = "filters">
<cfset PAGE_TITLE= "Template Filters Control Panel">
<cfset GROUP= "Control_Panel">
<cfset displayheader = 1 >
<cfset Active = 0>

<BODY>
<br>
<!--- D29688:Program Wizard Filters page START--->
<div style="margin-left:10px;">
<cfinclude template="/helpsystem/help_link.cfm">
<CFSET PAGETITLE = "PROGRAM WIZARD: SELECT FILTERS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfinclude template="header.cfm">
</div>
<!--- D29688:Program Wizard Filters page END--->
<!--- Template and TemplateManager Objects exist from Includes --->
<!--- defaults --->
<cfparam name="url.ID" default="#ID#"/>
<cfparam name="URL.tfId" default="0"/>
<cfparam name="form.rdoFilter" default="#URL.tfId#"/>
<cfparam name="URL.filterPageName" default=""/>
 <cfparam name="URL.bContinue" default="0"/>
<cfparam name="form.bContinue" default="#URL.bContinue#"/>  
<cfparam name="form.sAction" default=""/>
<cfparam name="form.TemplateFiltersId" default="#form.rdoFilter#"/>
<cfparam name="form.tiName" default=""/>
<cfparam name="form.tiDescription" default=""/>
<cfparam name="form.bSaveAndContinue" default= "0" />


<!--- <cfparam name="url.ID" type="numeric" default="#ID#"/>
<cfparam name="URL.tfId" type="numeric" default="0"/>
<cfparam name="form.rdoFilter" type="numeric" default="#URL.tfId#"/>
<cfparam name="URL.filterPageName" type="string" default=""/>
 <cfparam name="URL.bContinue" type="boolean" default="0"/>
<cfparam name="form.bContinue" type="boolean" default="#URL.bContinue#"/>  
<cfparam name="form.sAction" type="string"  default=""/>
<cfparam name="form.TemplateFiltersId" type="numeric" default="0"/>
<cfparam name="form.tiName" type="string"  default=""/>
<cfparam name="form.tiDescription" type="string"  default=""/>
 ---><!--- **************  Controller  ************** --->

<cfscript>
	
	if(form.sAction != ''){
		TemplateFilter = createObject("component", "mvc.models.Template.TemplateFilter").init(form.TemplateFiltersId);
		TemplateFilter.Name = Form.tiName;
		TemplateFilter.Desc = Form.tiDescription;
		switch(form.sAction)
	    {
	        case "Save":
	        {
				Template.saveTemplateFilter(TemplateFilter);
	            break;
	        }
	        case "Delete":
	        {
	            Template.deleteTemplateFilter(TemplateFilter);
	            break;
	        }
	        default:
	        {
	            break;
	        }
	    } //end switch
	}//end if(form.sAction)

	//Insert record for non MP Templates 1:1 relationship -> no user input
	if(!Template.MarketPrice){
		if(ArrayLen(Template.TemplateFilters) == 0){
			TemplateFilter = createObject("component", "mvc.models.Template.TemplateFilter").init();
			TemplateFilter.Name = Template.createdType;
			TemplateFilter.Desc = '';
			//save obj
			Template.saveTemplateFilter(TemplateFilter);
		}
		editTemplateFilter = Template.TemplateFilters[1];
	}
</cfscript>

<!--- **************  Display   ****************--->

	<!---The filter selection form with Show hide links --->
	<cfscript>
		if(!form.rdoFilter){
			divHideStyle = 'display:none;';
			divShowStyle = 'display:inline;';
		}
		else{
			divHideStyle = 'display:none;';
			divShowStyle = 'display:inline;';
		}
	</cfscript>


<form name="DataForm" action="template_filters.cfm" method="post" id="DataForm">
	<!--- Dev Note: drachala; D28173: Template tab called Filter, when saving a little box flashes in upper RH  START
	What I did: Replace Existing SAVE & CONTINUE with Button to invoke CFDIV on click--->
<cfif Template.MarketPrice>
		<div id="divFilterHide" style="<cfoutput>#divHideStyle#</cfoutput>">
		<CF_smallLink 
					title = "show filter list" 
					url = "##"
					parameters = "onClick=""javascript: document.getElementById('divFilterHide').style.display='none';
														document.getElementById('divFilterShow').style.display='inline';return false;""">								
		&nbsp;&nbsp;
	<cfif LockedBy_Current_User EQ 1>
		
        <span style="color: red; font-weight: bold;">[</span>
		<input type="button" name="sac" id="sac" style="width: 110px; border: none; background-color: white; font-weight: bold; color: blue;cursor: pointer;" 
		value="Save and Continue" onclick="document.getElementById('bContinue').value=1;document.getElementById('bSaveAndContinue').value=1;fnTemplateFiltersSave();return false;">
		<span style="color: red; font-weight: bold;">]</span>
			<br>&nbsp;
	</cfif>
		</div>
		<div id="divFilterShow" style="<cfoutput>#divShowStyle#</cfoutput>">
	<cfif LockedBy_Current_User EQ 1>
			<CF_smallLink 
					title = "hide filter list" 
					url = "##"
					parameters = "onClick=""javascript: document.getElementById('divFilterHide').style.display='inline';
														document.getElementById('divFilterShow').style.display='none';return false;""">
			&nbsp;&nbsp;
			 
			    <span style="color: red; font-weight: bold;">[</span>
				<input type="button" name="sac" id="sac" style="width: 110px; border: none; background-color: white; font-weight: bold; color: blue;cursor: pointer;" 
				value="Save and Continue" onclick="document.getElementById('bContinue').value=1;document.getElementById('bSaveAndContinue').value=1;fnTemplateFiltersSave();return false;">
				<span style="color: red; font-weight: bold;">]</span>
				<br>&nbsp;
			<!--- the form --->
		</cfif> <!--- END: <cfif LockedBy_Current_User EQ 1> --->
			<cfinclude template="filter/frmTemplateFilter.cfm"/>
		</div>
	<cfelse>
		<cfif LockedBy_Current_User EQ 1>
		<table width="90%" border="0">
		    <tr>
		        <td id ="submit" align="right" width="100%">
		        		<span style="color: red; font-weight: bold;">[</span>
		        		<input type="button" name="sac" id="sac" style="width: 110px; border: none; background-color: white; font-weight: bold; color: blue;cursor: pointer;" 
						value="Save and Continue" onclick="document.getElementById('bContinue').value=1;document.getElementById('bSaveAndContinue').value=1;fnTemplateFiltersSave();return false;">
		        		<span style="color: red; font-weight: bold;">]</span>
				</td>
		    </tr>
		</table>
<!--- End Dev Note: drachala; D28173: Template tab called Filter, when saving a little box flashes in upper RH  --->
		</cfif> <!--- END: <cfif LockedBy_Current_User EQ 1> --->
		

        	<cfoutput>
					<input type="hidden" id="tiDescription" name="tiDescription" />
					<input type="hidden" id="tiName" name="tiName" />
					<input type="hidden" id="ID" name="ID" value="#ID#"/>
					<input type="hidden" id="sAction" name="sAction" value=""/>
					<input type="hidden" id="bContinue" name="bContinue" value="0"/>
					<input type="hidden" name="postions" value="#form.postions#">
			</cfoutput>

	<div id="divFilterHide" style="<cfoutput>#divHideStyle#</cfoutput>">
		
	</div>
</cfif> <!--- END: <cfif Template.MarketPrice>  --->


<!--- Caputres Newly Slected users for this position  START--->
<cfoutput>
<input type="hidden" name="new_Selected_User" value="#form.postions#">
<input type="hidden" id="bSaveAndContinue" name= "bSaveAndContinue" value="0" />
</cfoutput>
<!--- Caputres Newly Slected users for this position  END --->




<cfif (form.rdoFilter OR NOT Template.MarketPrice) > <!--- AND NOT Form.bContinue --->
	<!---Filter Tabs--->
  <cfset FirstParentID = Template.FIRSTPARENTID />  
  <cfset AllowOperators = Template.Specify_Operators />
  <cfset AllowProductGroupSearch = Template.Allow_Product_Group_Search />
  <!--- If appsetting is on [Template Drives Multiple Product Attribute Groups], and the Template is Active then Disable Allow_In_Group_Search --->
  <cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND Template.Active EQ 1>
  	<cfset AllowProductGroupSearch = 0 />
  </cfif>
  <cfset AllowDistributorGroupSearch = Template.Allow_Distributor_Group_Search />
	
<!--- 	<cfif LockedBy_Current_User EQ 1> --->
 
			<cfinclude template="/Program_Wizard/filter/customerFilter.cfm"/>
		<br>
		<!--- D29688:Program Wizard Filters page START--->
			<!--- <div style="margin-left:10px;"> --->
			<cfinclude template="/Program_Wizard/filter/itemFilter.cfm"/>
			<!--- </div> --->
		<!--- D29688:Program Wizard Filters page END--->
		<br>
		<cfif (Template.Specify_Operators EQ 1)>	
			<cfinclude template="/Program_Wizard/filter/operatorFilter.cfm"/>
		</cfif>
		<br>
		 	
		<cfoutput>
			<input type="hidden" id="bSubmit" name="bSubmit" value="0" />
			<cfif (NOT Template.MarketPrice) >
				<input type="hidden" name="TemplateFiltersID" <cfif isDefined("Template_Filters_ID") AND Template_Filters_ID NEQ "">value="#Template_Filters_ID#"<cfelse>value=""</cfif> />
			</cfif>
			<input type="hidden" name="TemplateID" <cfif isDefined("Template_ID") AND Template_ID NEQ "">value="#Template_ID#"<cfelse>value=""</cfif> />				
		</cfoutput>		
		</form>
	
<!--- label D26730  by Dinesh --->


<cfset positionManager_dr = CreateObject("component", "components.geography.position").init() />
<cfset MainQuery_dr = positionManager_dr.getPositions(sortBy = 'Zone_Name',ignoreDeletedFlag = 0) />

<!--- Checks wheather there are any new selected users AND Update START --->
<cfif isdefined("form.new_Selected_User") AND len(form.new_Selected_User) NEQ 0>
	
	
<!--- The following two line code is to remove Comma at send of list Start --->
<cfset total_new_selected_users = #len(form.new_Selected_User)# - 1>
<cfset new_selected_users = left(new_Selected_User, total_new_selected_users)>
<!--- The above two line code is to remove Comma at send of list END --->


<!--- Invocking UserPositionFilterManager Component to update table in DB with new Selected Users START --->
<cfinvoke component="MVC.Models.Template.UserPositionFilterManager" method="setUserPositionFilterList" returnvariable="allCustomers">
 <cfinvokeargument name="Template_Filters_Id" value="#editTemplateFilter.Template_Filters_Id#">
 <cfinvokeargument name="userPositionsList" value="#new_selected_users#">
</cfinvoke>
<!--- Invocking UserPositionFilterManager Component to update table in DB with new Selected Users END --->	

</cfif> 
<!--- Checks wheather there are any new selected users END --->

	<!--- This Pull Currently Selected Users from DB table Start --->	
		<cfscript>
			objPositionFilterManager_dr = CreateObject("component","mvc.Models.Template.UserPositionFilterManager");
			theList_dr = objPositionFilterManager_dr.getUserPositionFilterList(editTemplateFilter.Template_Filters_Id);
		</cfscript>
   <!--- This Pull Currently Selected Users from DB table END --->
		
<CFQUERY NAME="Selected_List" DBTYPE="query">
	Select		Position_Label
	From		MainQuery_dr
	Where		
				1=2
				<CFIF Len(theList_dr) Gt 0>
				OR
				User_Positions_ID IN (#theList_dr#)
				</CFIF>
</CFQUERY>


<cfoutput>
<script type="text/javascript">
function Positions() {
window.open( "/Program_Wizard/filter/positionFilter.cfm?Template_Filters_Id=#editTemplateFilter.Template_Filters_Id#&id=#ID#&Locked=#LockedBy_Current_User#", "myWindow", "status = 1, height = 800, width = 1000, resizable = 0" )
}
</script>
</cfoutput>
<!--- D29688:Program Wizard Filters page START--->
<div style="margin-left:10px;">
	<table width="90%"  cellpadding="2" cellspacing="0" bordercolor="93BEE2"><!---  a85400  --->
		<tr bgcolor="FFCE8">
			<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b>Currently Selected User Position(s)</strong></b>
			&nbsp;&nbsp;<input type="button" onClick="Positions()" value="Edit" style="width:50px; font-weight: bold;"></td>
		</tr>
	</table>


			<CFIF Selected_List.recordcount GT 0>
				<TABLE border="0" cellspacing="1" cellpadding="2" align="left" WIDTH="685" BGCOLOR="white">
					<TR><CFoutput QUERY="Selected_List">
						<TD NOWRAP BGCOLOR="eeeeee">#Position_Label#</TD>
		 				<CFIF Selected_List.currentrow mod 3><CFELSE></TR><TR></CFIF>
					</CFoutput>	
					</TR>
				</TABLE>
			<CFELSE>
				NONE
			</CFIF>
</div>
<!--- D29688:Program Wizard Filters page END --->
<br><br><br><br>
<div style="width:90%; height: 5px;">&nbsp;</div>

				
<cfif Template.MarketPrice>
			<Iframe src="<cfoutput>/Program_Wizard/filter/marketPrice.cfm?ID=#ID#&tfId=#editTemplateFilter.Template_Filters_Id#</cfoutput>" name="mpIframe" id="mpIframe" width="100%" height="80%" frameborder="0">
			</Iframe>
</cfif>
<!--- label D26730  by Dinesh--->	

			<cfif LockedBy_Current_User EQ 1>
				<center>
					<div align="right" style="margin-right:10%;">
						<span style="color: red; font-weight: bold;">[</span>
						<input type="button" name="sac" style="width: 110px; border: none; background-color: white; font-weight: bold; color: blue;cursor: pointer;" value="Save and Continue" onclick="document.getElementById('bContinue').value=1;document.getElementById('bSaveAndContinue').value=1;fnTemplateFiltersSave();return false;">
						<span style="color: red; font-weight: bold;">]</span>
					</div>
			 	</center>
			</cfif>

	</cfif>
<cfif FORM.bSaveAndContinue>
	<cfinclude template="Next_Page.cfm" />
</cfif>


<cfparam name="form.allow_filters" default="0" >
<cfoutput>
	<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START--->
	
	<!--- Dev Note: drachala; D28173: Template tab called Filter, when saving a little box flashes in upper RH  START
	What I did: Instead of opening Javascript window, adding Filters ID to a form field and passing into CFDIV--->
	<script language="javascript">
	// this function open a pop-up to check weather filters are selected or not
	function fnTemplateFiltersSave()
		{
			var Customer_filters = "";
			var Item_filters = "";
			for(i=0; i<document.DataForm.elements.length; i++)
			{
				if((document.DataForm.elements[i].type=="checkbox") && (document.DataForm.elements[i].ID2=="Customer") && (document.DataForm.elements[i].checked==true))
				{
					Customer_filters = Customer_filters.concat(document.DataForm.elements[i].value);
					Customer_filters = Customer_filters.concat(",");
					//alert(Customer_filters);
					document.getElementById('Customer_filters').value = Customer_filters;
				}
				if((document.DataForm.elements[i].type=="checkbox") && (document.DataForm.elements[i].ID2=="Customer") && (document.DataForm.elements[i].checked==false))
				{
					document.getElementById('Customer_filters').value = Customer_filters.replace(document.DataForm.elements[i].value,"");
				}
				if((document.DataForm.elements[i].type=="checkbox") && (document.DataForm.elements[i].ID2=="Item") && (document.DataForm.elements[i].checked==true))
				{
					Item_filters = Item_filters.concat(document.DataForm.elements[i].value);
					Item_filters = Item_filters.concat(",");
					document.getElementById('Item_filters').value = Item_filters;
				}
				if((document.DataForm.elements[i].type=="checkbox") && (document.DataForm.elements[i].ID2=="Item") && (document.DataForm.elements[i].checked==false))
				{
                    document.getElementById('Item_filters').value = Item_filters.replace(document.DataForm.elements[i].value,"");
				}
			}
			document.getElementById('check').value = 1;
		}
		<!--- End Dev Note: drachala; D28173: Template tab called Filter, when saving a little box flashes in upper RH  --->
   function filters(s, filters){
   	if (s == 0) {
   		var actionFrm = document.DataForm;
   		actionFrm.bSubmit.value = "1";
   		actionFrm.submit();  
   	}
   	else {
   		var filters = filters.replace(/,/gi, '\n')
   		alert("Please select filters for following attribute(s)\n" + filters);
   		document.getElementById('check').value = 0;
   	}
   }
	
	<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected END--->
		function checkAll(argID2, name, bChecked){
			var oChk = document.getElementsByTagName("input");
			for(var i = 0; i < oChk.length; i++)
			{

				if(oChk[i].type == "checkbox" && oChk[i].group == argID2){
					
						if(oChk[i].name.substring(0, name.length) == name)
						{
		 	                oChk[i].checked = bChecked;
		 	                
						}
				
				}
			}

		}
   </script>

<!--- Dev Note: drachala; D28173: Template tab called Filter, when saving a little box flashes in upper RH  START --->

	<input type="hidden" name="Customer_filters" value="" id="Customer_filters">
	<input type="hidden" name="Item_filters" value="" id="Item_filters">
    <input type="hidden" name="check" value="0" id="check">
	
<cfif LockedBy_Current_User EQ 1 AND (form.rdoFilter OR NOT Template.MarketPrice)>
   <cfdiv bind="url:check_filters.cfm?vals={sac@click}&check={check}&TemplateID=#FirstParentID#&TemplateFiltersID=#editTemplateFilter.Template_Filters_Id#&DistributorGroupLevelID={Customer_filters}&ItemGroupLevelID={Item_filters}"/>
</cfif>
<!--- End Dev Note: drachala; D28173: Template tab called Filter, when saving a little box flashes in upper RH  --->
</cfoutput>

</BODY>
</HTML>
