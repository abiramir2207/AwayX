<!------ Page_List.cfm ----->
<cfscript>
  templateManager = CreateObject("component","components.programs.template.TemplateManager").init();
  appSettings = application.appsettingsGet;

  if ( Not isDefined("template") ) {
	  template = templateManager.get(ID);
  }

  Created_Type = template.getCreatedType();
  Generic_Type = template.getGenericType();
  Active = template.getActive();
  Action = "Edit";
  bSkipPage = 0;

  if ( Generic_Type EQ "LSAutoPay" ) {
	  bSkipPage = 1;
  }

  bTemplateLevelComponentFilter = 1;
  if ( appSettings.getOperatingGroupOn() ) {
	  bTemplateLevelComponentFilter = 0;
  }

  allow_dup_programs = template.getDuplicate();
  retail_planner = template.getPlannerProgram();

  PAGE_TITLES = "";
  PAGE_URLS = "";
  PAGE_NAMES = "";

  PAGE_TITLES = ListAppend(PAGE_TITLES, "basic info", ",");
  PAGE_URLS = ListAppend(PAGE_URLS, "create_edit.cfm?id=#ID#&Generic_Type=#Generic_Type#&Action=#Action#&displayheader=1", ",");
  PAGE_NAMES = ListAppend(PAGE_NAMES, "basicinfo", ",");

  PAGE_TITLES = ListAppend(PAGE_TITLES, "details", ",");
  PAGE_URLS = ListAppend(PAGE_URLS, "secondpage.cfm?id=#ID#&Generic_Type=#Generic_Type#&Action=#Action#&Created_Type=#URLEncodedFormat(Created_Type)#", ",");
  PAGE_NAMES = ListAppend(PAGE_NAMES, "secondpage", ",");

  if (retail_planner){
  	PAGE_TITLES = ListAppend(PAGE_TITLES, "#LCase(Application.PlannerLabel)# #LCase(Application.PlannerPrgLabel)#", ",");
	PAGE_URLS = ListAppend(PAGE_URLS, "planner_program.cfm?id=#ID#&Generic_Type=#Generic_Type#&Action=#Action#&Created_Type=#URLEncodedFormat(Created_Type)#", ",");
  	PAGE_NAMES = ListAppend(PAGE_NAMES, "planner_program", ",");
  }

  PAGE_TITLES = ListAppend(PAGE_TITLES, "profiles", ",");
  PAGE_URLS = ListAppend(PAGE_URLS, "profile_settings_matrix.cfm?id=#ID#&Generic_Type=#Generic_Type#&Action=#Action#&Created_Type=#URLEncodedFormat(Created_Type)#", ",");
  PAGE_NAMES = ListAppend(PAGE_NAMES, "profile_settings_matrix", ",");

  if ( appSettings.getPullbacksOn() EQ 1 and template.getPullbacksOn() EQ 1 and template.getcorporatedeal() EQ 1 ) {
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "#appSettings.getPullbackLabel()#", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "Pullback_settings.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "Pullback_settings", ",");
  }

  if (bTemplateLevelComponentFilter) {
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "components", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "select_components.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "components", ",");
  }

  if (appSettings.getapprovalStandardOn()) {
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "approval metrics", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "Approval_Template_Add_Remove.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "approval", ",");
  }

// <!--- tab for the duplicate program definition--->
  if (allow_dup_programs EQ 1) {
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "duplicates", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "dup_program_def.cfm?id=#ID#&Generic_Type=#Generic_Type#&Action=#Action#&Created_Type=#URLEncodedFormat(Created_Type)#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "dup_program_def", ",");
  }

  if (trim(template.getGenericType()) EQ "Operator Bids") {
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "duplicates", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "bid_rules/index.cfm", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "dup_program_def", ",");
  }

  if (NOT bSkipPage) { // <!---  LSAutoPay skip page flag --->
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "clauses", ",");
// <!--- Dev Note: Milan - 19623/25647: If "simple clauses" is ON, show new clauses functionalty, else the
//       old clauses functionality (The filename has the prefix "original").
// --->
     if (appSettings.getSimpleClause() eq 1)
	  PAGE_URLS = ListAppend(PAGE_URLS, "Clause_Template_Add_Remove.cfm?id=#ID#", ",");
   else
	  PAGE_URLS = ListAppend(PAGE_URLS, "Original_Clause_Template_Add_Remove.cfm?id=#ID#", ",");

	  PAGE_NAMES = ListAppend(PAGE_NAMES, "clause", ",");
  }


  if (appSettings.getlettersavailable() AND NOT bSkipPage) { // <!---  LSAutoPay skip page flag --->
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "letters", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "Letters_Template_Add_Remove.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "letters", ",");
  }

  if (template.getRevisionNotAllowed() eq 0 AND NOT bSkipPage) { // <!---  LSAutoPay skip page flag --->
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "revision", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "revision_settings.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "revision_settings", ",");
  }

  if (appSettings.getBudgetsFunctionalityOn()) {
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "budget", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "Budget_Template_Mapping.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "budget", ",");
  }

  PAGE_TITLES = ListAppend(PAGE_TITLES, "filters", ",");
  PAGE_URLS = ListAppend(PAGE_URLS, "Template_Filters.cfm?id=#ID#", ",");
  PAGE_NAMES = ListAppend(PAGE_NAMES, "filters", ",");

// <!--- 27333 - EZ Button requires filters to be entered first, moved EZ Button tab to be after the Filters tab --->
  if (template.getEZButtonOn() EQ 1 AND NOT bSkipPage and appSettings.getappEZButtonOn()) { // <!---  LSAutoPay skip page flag --->
	  PAGE_TITLES = ListAppend(PAGE_TITLES, "EZ button", ",");
	  PAGE_URLS = ListAppend(PAGE_URLS, "EZ_button_settings.cfm?id=#ID#", ",");
	  PAGE_NAMES = ListAppend(PAGE_NAMES, "EZ_button_settings", ",");
  }
</cfscript>
