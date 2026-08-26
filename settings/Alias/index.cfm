<CFOUTPUT>
<CFSET PAGETITLE = "PRODUCT ALIAS MANAGEMENT">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>

<cfoutput>
<TITLE>#PAGETITLE#</TITLE>
</cfoutput>

<CFPARAM NAME="form.display" 	DEFAULT="Search">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.Distributor_Level" 	DEFAULT="">


<!--- CHANGE BRELOAD TO 1 FOR TESTING. SET IT BACK TO 0 WHILE DEPLOYING --->
<cfset AliasManager = application.oController.getObject(path="mvc.Models.Alias.AliasManager",bReload= 0).init() />

<!--- Check whether the "Alias" upload process is running. If yes, use this  variable in JS and do not allow
      the user to upload another file.
--->
<cfset variables.UploadInProgress = 0>
<cfif form.display eq "UploadFile">
 <cfset variables.qgetCompletedStatus = AliasManager.getCompletedStatus()>
 <cfif variables.qgetCompletedStatus.Is_Complete eq 0 and variables.qgetCompletedStatus.Upload_Action_Status eq 1>
   <cfset variables.UploadInProgress = 1>
 </cfif>
</cfif>

<script language="javascript">
<cfoutput>
  var Upload_In_Progress = '#variables.UploadInProgress#'
</cfoutput>
</script>

<!--- Get the custom labels --->
<cfset DistributorSingularLabel = application.returned_customer_setting.distributor_label_singular />
<cfset DistributorPluralLabel = application.returned_customer_setting.distributor_label_plural /> 
<cfset FamilySingularlabel      = application.returned_customer_setting.family_name_label_singular /> 
<cfset BuyingGroupSingularlabel = application.returned_customer_setting.buying_group_label_singular />  
<cfset ShipToSingularlabel = application.returned_customer_setting.shard_ship_to_label>
<cfset ItemSingularlabel = application.returned_customer_setting.item_label>

<CF_MessageWindow>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT SRC="/common_files/Delete_Functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="alias_management.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get the distributor levels --->
<cfset variables.qgetDistributorGroupLevels = AliasManager.getDistributorGroupLevels()>

<!---****************************** START COMMANDS ***********************************--->

<!--- Add/Edit/Delete Alias --->
<cfif form.command eq "Add">
	<cfset AliasManager.AddProdAlias('#form#')>

<!--- Create file --->
<cfelseif form.command eq "Create_File">
	<cfheader name="Content-Disposition" value="attachment;filename=Alias_products.csv">
	<cfcontent type="application/vnd.ms-excel" />
		
	<cfset AllDistributors = 0>
	
	<!--- Check whether we are not doing for a specific distributor OR Family OR Buying Group --->
	<cfif form.Distributor_Level eq 0 AND ListLen(Distributor_List) GT 1>
		<cfset AllDistributors = 1>
	<cfelseif form.Distributor_Level eq 2 AND Family_Name eq 0>
		<cfset AllDistributors = 1>
	<cfelseif form.Distributor_Level eq 3 AND Buying_Group eq 0>
		<cfset AllDistributors = 1>
	</cfif>
	<!--- Get the list of products for which to create the file --->
	<cfset variables.qgetProductInfo = AliasManager.getProductInfo('#form#',DistributorSingularLabel,AllDistributors,form.Is_Alias)>
	<cfinclude template="alias_products_list_upload.cfm" />
	<cfset form.command = "" />
	<cfabort>

<!--- Upload the file to add product aliases --->
<cfelseif form.command eq "Upload_File">
	<cfinclude template="alias_products_list_upload_action.cfm" />

<!--- get search results --->
<cfelseif form.command eq "Search" OR form.command eq "Sort">
	<cfset variables.qgetSearchResults = AliasManager.getSearchResults(form.Item,form.Shr_Ship_To,form.Family_Name,form.Buying_Group,form.sort_by,form.sort_order,
	DistributorSingularLabel,FamilySingularlabel,BuyingGroupSingularlabel)>

<!--- Add distributor level ranking --->
<cfelseif form.command eq "Ranking">
	<cfset AliasManager.addDistributorLevelRanking(form.Shr_Ship_To,form.Family_Name,form.Buying_Group)>
</cfif>


<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->
<cfinclude template="alias_header.cfm" />

<!--- For upload purposes, we need "ENCTYPE='multipart/form-data'" --->
<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm"  <cfif form.display eq "UploadFile">ENCTYPE="multipart/form-data"</cfif>>

<!--switch for each action--->
<cfswitch expression="#form.display#">	
	<cfcase value="Search">
		<cfinclude template="search_alias.cfm" />
	</cfcase>
	
	<cfcase value="Add_Edit">
		<cfinclude template="add_alias.cfm" />
	</cfcase>

	<cfcase value="CreateFile">
		<cfinclude template="create_file.cfm" />
	</cfcase>
	
	<cfcase value="UploadFile">
		<cfinclude template="upload_file.cfm" />
	</cfcase>

	<cfcase value="Ranking">
		<cfinclude template="alias_ranking.cfm" />
	</cfcase>

	<cfcase value="UploadHistory">
		<cfinclude template="upload_history.cfm" />
	</cfcase>

	<cfdefaultcase>
		<cfinclude template="search_alias.cfm" />
	</cfdefaultcase>
</cfswitch>	

<!--- Reset the command --->
<!--- Do not reset "form.command" for "search" and "sort", so that when we go page by page using the paging 
      feature (links 1,2,3,4 etc), the hidden variable "command" is passed correctly. In other cases, we do 
      not need it, so that refreshing the page does not repeat the same code.
--->
<cfif form.command neq "search" AND form.command neq "sort">
	<cfset form.command = "" />
</cfif>

<!--- We need to reset "form.startrow",as when we change the search criteria, this variable continues to 
      be used unnecessarily.
--->
<cfif form.command eq "search" OR form.command eq "sort">
	<cfset form.startrow = "" />
</cfif>

<cfoutput>
<!---hidden form fields--->
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
</cfoutput>

</FORM>

</BODY>
</HTML>