<CFSET PAGE_TITLE="Advanced Search">

<!---Main component calls--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset appSettings = genSettingsManager.get()>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Untitled</title>
</head>

<body leftmargin="20" topmargin="0" rightmargin="20">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!---Param variables--->
<CFPARAM NAME="FORM.Item" 					DEFAULT="">
<CFPARAM NAME="FORM.DISTRIBUTOR_LIST" 		DEFAULT="">
<CFPARAM NAME="FORM.Product_LIST" 			DEFAULT="">
<CFPARAM NAME="FORM.Distributor"	 		DEFAULT="">
<CFPARAM NAME="FORM.Template_Name" 			DEFAULT="0">
<CFPARAM NAME="FORM.Status"		 			DEFAULT="-1">
<CFPARAM NAME="Selected_Distributor" 		DEFAULT="">
<CFPARAM NAME="FORM.ExistingProductList" 	DEFAULT="">

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<!---Populate drop downs--->
<!---Get templates--->

<cfset qUser = userManager.getUser(request.AccessStructure.User_ID) />
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />
<cfset rspProfileID = qUser.profiles_id >

<cfquery name="GetTemplates" datasource="#application.datasource#">
	SELECT 		DISTINCT Created_Type
	FROM 		Program_Control_Panel_Options
	WHERE 		Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
				AND Deleted = 0 
				AND Active = 1
				AND IsDominant = 1
				AND programcontrol_panel_options_id 
					<cfif forbidType EQ 1>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
					in 
					(	select 	distinct template_id 
						from 	Profile_Forbidden_Template 
						where 	Deleted = 0
								AND Forbid_Type = #forbidType#
								AND	Forbid_Access_Type = 1
								AND profile_id = #rspProfileID#
					)
	
	ORDER BY Created_Type asc
</cfquery>

<!---Get statuses--->
<cfquery name="GetStatuses" datasource="#application.datasource#">
	Select	Contract_Status_Type_ID, Contract_Status_Type_Desc
	From 	Contract_Status_Types
	Where	
		Contract_Status_Type_ID <> 3
	Order By Contract_Status_Type_ID
</cfquery>

<!---Populates distributor if defined--->
<CFIF FORM.Distributor_List NEQ "">
	<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT BSA_Foodservice_Customers_ID,Name 
		FROM BSA_Foodservice_Customers 
		WHERE
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#'
		ORDER BY Name
	</CFQUERY>
	<CFSET Selected_Distributor=Dist_Search_Result.Name>
</CFIF>

<cfif Form.Product_List NEQ "">
	<cfquery name="ProductName" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Items_Master_ID, Description, UPC, Item
	FROM BSA_Foodservice_Items_Master
	WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#Form.Product_List#'
	ORDER BY Item, UPC, Description
	</cfquery>
	<cfset ItemName = ProductName.Description>
	<cfset Item_ID 	= ProductName.BSA_Foodservice_Items_Master_ID>
</cfif>


<CFSET IFRAMEHeight = "310">

<FORM NAME="PriceVolumeSearch" ACTION="pricevolume_result.cfm" METHOD="post" TARGET="Search_Result">
<CFOUTPUT>
<!---Hidden form fields--->
<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="1">

</CFOUTPUT>

<CFSET Layer_ID = 9999>
<CF_openLayer
	Border="Yes"
	BorderSize="1"  
	BorderColor="orange"  
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="Hide Price/Volume Search Screen"  
	TitleClosed="Show Price/Volume Search Screen"  
	TitleTooltip="Click to Show/Hide Search Screen"  
	TitleFont="font"  
	TitleColor="Blue"  
	TitleSize="9"  
	IsClosed="No"  
	Width="100%"
	layerid="#Layer_ID#">
	<CFOUTPUT>
	<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" WIDTH="955">
		
		<TR>
			<TD COLSPAN="100%"><BR><FONT SIZE="2" COLOR="red"><B>Price/Volume Lookup:</B></FONT><BR><HR COLOR="navy"></TD>			
		</TR>
		<TR>
							
			<!---Item--->
			<TD><B>Item Number<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
							<cfif application.returned_customer_setting.upc_switch EQ 1>/UPC</cfif></cfif>:  </B><Font color="red"><em>required</em></FONT>
			<BR>
			<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#FORM.ExistingProductList#">
				<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#FORM.Product_List#">
			<INPUT TYPE="Text" NAME="ItemName" VALUE="#ItemName#" STYLE="WIDTH:285px;" READONLY ><A HREF="javascript: void(0);" onClick="javaScript: showProdSearchWindow();"><IMG border="0" src="/images/searchtool.gif" width="20" height="20"></A>
			</TD>
			<!---END ITEM--->
			
			<!---Distributor--->
			<TD valign="top"><B>#application.returned_customer_setting.shard_ship_to_label#:</B><BR>
			<INPUT NAME="SelectSingleSearchResultOnly" 	TYPE="Hidden" VALUE="1">		
			<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
						
			<CFOUTPUT><INPUT TYPE="Text" NAME="Distributor" VALUE="#Selected_Distributor#" STYLE="WIDTH:285px;" READONLY ><A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif" width="20" height="20"></A></CFOUTPUT>
			</TD>
			<!---END Distributor--->
			
			<!---Template--->
			<TD valign="top"><B>Template:</B><BR>
				<SELECT NAME="Template_ID" >
					<OPTION VALUE="0">**ALL** Templates</OPTION>
					<cfloop query="GetTemplates">
					<option value="#GetTemplates.Created_Type#" <cfif form.Template_Name IS GetTemplates.Created_Type>checked</cfif>>#GetTemplates.Created_Type#</option>
					</cfloop>	
				</SELECT>
				
			</TD>
			<!---END Template--->		
			
			<!---Status--->
			<TD valign="top"><B>Status:</B><BR>
				
				<SELECT NAME="Status">
					<OPTION VALUE="-1">**ALL** Status</OPTION>
					<OPTION VALUE="0">**ALL** Non-expired Status</OPTION>
					<cfloop QUERY="GetStatuses">
						<OPTION VALUE="#trim(GetStatuses.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ GetStatuses.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>
						#trim(GetStatuses.Contract_Status_Type_Desc)#
						</OPTION>
					</cfloop>
				</SELECT>
			</TD>	
			<!---END STATUS--->
			</tr>
			<tr>	
							
			<TD ALIGN="right" COLSPAN="4"><BR><BR>
			<input type="reset">
				<B>
				<FONT SIZE="2" COLOR="Red">[ </FONT><A HREF="Javascript: resetForm();">reset</A><FONT SIZE="2" COLOR="Red"> ]</FONT>&nbsp;&nbsp;
				<FONT SIZE="2" COLOR="Red">[ </FONT><A HREF="Javascript: Validate();">build report</A><FONT SIZE="2" COLOR="Red"> ]</FONT>&nbsp;&nbsp;
				</B>
			</TD>
		</TR>
	</TABLE>		
	</CFOUTPUT>
</CF_openLayer>	
</FORM>
<CFOUTPUT>

<IFRAME ID="Search_Result" NAME="Search_Result" SRC="pricevolume_result.cfm" WIDTH="950" HEIGHT="1" FRAMEBORDER="0" style="border: 0px none ##000000;Dispaly:None;"></IFRAME>
</CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>


<SCRIPT language="JavaScript">

function showProdSearchWindow() 
{				
	document.all.Form_Submitted.value=0;		
	document.PriceVolumeSearch.target = "_self";
	document.PriceVolumeSearch.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
	NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=PriceVolumeSearch&SelectSingleSearchResultOnly=1", "prodwindow", 800, 600, "yes", "yes")
}

function showDistSearchWindow() 
{				
	document.all.Form_Submitted.value=0;		
	document.PriceVolumeSearch.target = "_self";
	document.PriceVolumeSearch.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
	NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=PriceVolumeSearch", "searchwindow", 800, 600, "yes", "yes")
}

function Validate()
{
	
		document.PriceVolumeSearch.submit();

}

<CFPARAM NAME="FORM.Item" 				DEFAULT="">
<CFPARAM NAME="FORM.DISTRIBUTOR_LIST" 	DEFAULT="">
<CFPARAM NAME="FORM.Template_Name" 		DEFAULT="0">
<CFPARAM NAME="FORM.Status"		 		DEFAULT="-1">

function resetForm()
	{
		document.all.Item.value = "";
		document.all.DISTRIBUTOR_LIST.value = "";		
		resetSelect("Template_Name");
		resetSelect("Status");
	}
	
	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			sObj.fireEvent('onchange');
		}
	}
	
</SCRIPT>


<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
 
<SCRIPT>



 <!-- 
		function switchLayer(lyrID, title, titleclosed, borderwidth, imageA,imageB, colorA,colorB) 
		{ 
			if (document.all) 
			{ 
				var iFrameOBj = document.all.Search_Result;
				
				// Determine if the layer is currently expanded or collapsed: 
				var tmpStatus; 
				eval("tmpStatus = document.all.lyrGroup_"+ lyrID +".style.display"); 
				// OK, then now expand or collapse it... 
				if (tmpStatus == 'none') 
				{ 
					eval("document.all.lyrGroup_"+ lyrID +".style.display='block';"); 
					eval("document.all.border_"+ lyrID +".style.borderWidth='"+borderwidth+"';"); 
					eval("document.all.title_"+ lyrID +".innerHTML='"+title+"';"); 
					tmpImage = imageA; 
					tmpColor = colorA; 
					<!------ show ----->
					<!------ 2. hide the search result ----->					
					iFrameOBj.style.display = "none";
				} 
				else 
				{ 
					eval("document.all.lyrGroup_"+ lyrID +".style.display='none'"); 
					eval("document.all.border_"+ lyrID +".style.borderWidth='0';"); 
					eval("document.all.title_"+ lyrID +".innerHTML='"+titleclosed+"';"); 
					tmpImage = imageB; 
					tmpColor = colorB; 
					<!------ hide ----->
					<!------ 2. show the search result ----->
					iFrameOBj.style.height = "470";
					iFrameOBj.style.display = "";
					
				} 
				// If an image is used as the click-control, switch it... 
				if ((tmpImage != null) && (imageA != imageB)) 
				{ 
					eval("document.all.image_"+ lyrID +".src='"+tmpImage+"'"); 
				} 
				// If different title-colors are used, switch them... 
				if (tmpColor != '') 
				{ 
					eval("document.all.title_"+ lyrID +".style.color='"+tmpColor+"'"); 
				}
				
			} 	   
		} 
	  
     //--> 
</SCRIPT>




</body>
</html>


