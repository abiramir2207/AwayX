<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>

<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- This is the code that takes care of all of the right-click needs for the menu --->
	<cfinclude template="right_click_menu_code.cfm">

	<CFPARAM NAME="group" 		DEFAULT="">
	<CFPARAM NAME="PAGE_TITLE"	DEFAULT=" ">