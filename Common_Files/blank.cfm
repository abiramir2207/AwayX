<!---------------------------------------------------------------------------------------------------------------------
      File Name:  \common_files\blank.cfm
           Date:  2016 March
         Author:  Chris Nguyen
        Purpose:  Display a placeholder page

        Remarks:  Pass the new page title to URL.Title
----------------------------------------------------------------------------------------------------------------------->

<cfmodule template="\customtags\layout-bare.cfm">
  <cfparam name="URL.Title" default="A New Page">
  <cfoutput><h2>Placeholder Page For "#URL.Title#"</h2></cfoutput>
</cfmodule>