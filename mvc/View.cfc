<!--- 
FILE: 		BA Application - View Component 	
FILENAME:   View.cfc 				
CREATED:  	09/12/2008 - Brad Lee MMCP/ACI
EDITED:   	12/30/2008 - Brad Lee MMCP/ACI

FUNCTIONALITY: 
- This is the set of instructions that ColdFusion uses to assemble the BA View object.			
- The BA View object is THE view for BA and makes LTM requests via the Controller(s). --->						

<!--- COLDFUSION COMPONENT: View (Only the Controller extends main) --->
<cfcomponent displayname="View" hint="I am in charge of all addition, manipulation, retrieval, and removal of data to and from the BA View.">

	<!--- Set the initialization flag to "False" --->
	<cfparam name="this.bObjectInitialized" type="boolean" default=0>
	
	<!--- If the init process has not yet run... --->
	<cfif NOT this.bObjectInitialized>

		<!--- Set up the object skeleton --->
        <cfscript>
            // application.applicationname & 
            structInsert(this, 	"objName", 				uCase(application.applicationName) & " Application View");
            structInsert(this, 	"objDateTimeCreated", 	createODBCDateTime(now()));
            structInsert(this, 	"objDirectory",   		application.stMvcAppInfo.webrootMapping & "components/mvc");
			structInsert(this, 	"objParentObject",   	"Application");
			structInsert(this, 	"objParentUserID",   	"I am a Top Level Object. I am ALWAYS available but my number is unListed!");
            structInsert(this, 	"stObjectInfo",   		structNew(),true);

			this.stObjectInfo.componentPath				= application.stMvcAppInfo.componentPath;
            this.stObjectInfo.lockTimeoutSeconds		= application.stMvcAppInfo.lockTimeoutSeconds;
            this.stObjectInfo.name 						= "I am the " & Ucase(application.applicationName) & " Application VIEW Object";
            this.stObjectInfo.description 				= "I visually represent all VIEW requests from the Controller for the " & Ucase(application.applicationName) & " Application.";

            structInsert(this,	"bObjectInitialized", 	1,true);
        </cfscript>

		<!--- :::::::::::::::::::::::::::::::::::::::::::
		::::::::: View Methods getters/setters  :::::::::
		:::::::::::::::::::::::::::::::::: [ begin ] --->

		<!--- TECH NOTE: INCOMPLETE!!! The following is just a really quickly compiled skeleton of thoughts to start with...
		Brad envisions one (1) View object that utilizes divs, some floating, with a header including a topNav, a leftSideColumn including a leftNav, a footer including
		a bottomNav, and a stage that is flexible and fills any open space. There will also be Boolean values governing the visibility of 3 areas ONLY: LeftColumn, Footer, Header.
		This should be able to accomodate any scenario. --->

<!--- ALL [begin] --->
        
        <!--- View METHOD: getAllContent() FUNCTIONALITY: I get All content. [begin] --->
        <cffunction name="getAllContent" access="public" returntype="string" output="yes" hint="I get All content." displayname="View > getAllContent()">
        
		<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <cfargument name="stageContent" 		type="string" 	required="true" 	hint="stage HTML content.">
        
        <cfargument name="bFooterVisible" 		type="boolean" 	required="false" 	default="0" hint="footer DIV Visibility, (footer includes bottomNav).">
        <cfargument name="bHeaderVisible" 		type="boolean" 	required="false" 	default="0" hint="header DIV Visibility, (header includes topNav).">
        <cfargument name="bLeftColumnVisible" 	type="boolean" 	required="false" 	default="0" hint="leftColumn DIV Visibility, (leftColumn includes leftNav).">
        
        <cfargument name="bottomNavContent" 	type="string" 	required="false" 	default="" 	hint="bottomNav HTML content.">
        <cfargument name="footerContent" 		type="string" 	required="false" 	default="" 	hint="footer HTML content.">
        <cfargument name="headerContent" 		type="string" 	required="false" 	default="" 	hint="header HTML content.">
        <cfargument name="leftColumnContent" 	type="string" 	required="false" 	default="" 	hint="leftColumn HTML content.">
        <cfargument name="leftNavContent" 		type="string" 	required="false" 	default="" 	hint="leftNav HTML content.">
        <cfargument name="topNavContent" 		type="string" 	required="false" 	default="" 	hint="topNav HTML content.">
            
            <!--- NOTE: There will be a universal div layout here wrapped w/a cfsavecontent called var_allContent --->
           	<!--- inline CSS --->
           	<style type="text/css">
				##pageWrapper {
					background-color:##000000;
					height:100%;
					text-align:center;
					vertical-align:middle;
					width:100%;
					}
				##stage {
					background-color:##ffffff;
					height:80%;
					width:80%;
					}
			</style>
            
            <cfset var var_allContent 	= "">
            
            <cfsavecontent variable="var_allContent">
				<!--- Window div wrapping all --->
                <div id="pageWrapper">
                
					<cfif arguments.bHeaderVisible>
                        <!--- Header div wrapping topNav --->
                    
                    </cfif>
                    
                    <cfif arguments.bLeftColumnVisible>
                        <!--- LeftColumn div wrapping leftNav --->
                    
                    </cfif>
                    
                    <!--- stage div (flexible) --->
                    <div id="stage">
                         <cfinclude template="#arguments.stageContent#">
                    </div>
                    
                    <cfif arguments.bFooterVisible>
                        <!--- Footer div wrapping bottomNav --->
                    
                    </cfif>

                </div>
            </cfsavecontent>

            <!--- Return the final container to the caller --->
            <cfreturn var_allContent />  
            
        </cffunction>
        <!--- View METHOD: getAllContent() FUNCTIONALITY: I get All content. [end] --->
        
        <!--- View METHOD: setAllContent() FUNCTIONALITY: I set All content. [begin] --->
        <cffunction name="setAllContent" access="public" returntype="string" output="no" hint="I set All content." displayname="View > setAllContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bFooterVisible" type="boolean" required="true" default="0" hint="footer DIV Visibility, (footer includes bottomNav).">
            <cfargument name="bHeaderVisible" type="boolean" required="true" default="0" hint="header DIV Visibility, (header includes topNav).">
            <cfargument name="bLeftColumnVisible" type="boolean" required="true" default="0" hint="leftColumn DIV Visibility, (leftColumn includes leftNav).">
            
            <cfargument name="bottomNavContent" type="string" required="false" default="" hint="bottomNav HTML content.">
            <cfargument name="footerContent" type="string" required="false" default="" hint="footer HTML content.">
            <cfargument name="headerContent" type="string" required="false" default="" hint="header HTML content.">
            <cfargument name="leftColumnContent" type="string" required="false" default="" hint="leftColumn HTML content.">
            <cfargument name="leftNavContent" type="string" required="false" default="" hint="leftNav HTML content.">
            <cfargument name="stageContent" type="string" required="true" default="" hint="stage HTML content.">
            <cfargument name="topNavContent" type="string" required="true" default="" hint="topNav HTML content.">
            
            <!--- NOTE: There will be a universal div layout here wrapped w/a cfsavecontent called var_allContent --->
            
            <cfset var var_allContent 	= "">

            <!--- Return the final container to the caller --->
            <cfreturn var_allContent />  
            
        </cffunction>
        <!--- View METHOD: setTopNavContent() FUNCTIONALITY: I set the TopNav content. [end] --->
        
<!--- ALL [end] --->

<!--- BOTTOM NAV [begin] --->

		<!--- View METHOD: getBottomNavContent() FUNCTIONALITY: I get the BottomNav content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getBottomNavContent" access="public" returntype="string" output="yes" hint="I get the BottomNav content." displayname="View > getBottomNavContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bottomNav_url" type="string" required="true" default="" hint="URL of bottomNav content.">
            
            <cfset var var_bottomNavContent 	= "">
            
            <!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_bottomNavContent />  
            
        </cffunction>
        <!--- View METHOD: getBottomNavContent() FUNCTIONALITY: I get the BottomNav content. [end] --->
        
        <!--- View METHOD: setBottomNavContent() FUNCTIONALITY: I set the BottomNav content. [begin] --->
        <cffunction name="setBottomNavContent" access="public" returntype="string" output="no" hint="I set the BottomNav content." displayname="View > setBottomNavContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bottomNav_url" type="string" required="true" default="" hint="URL of bottomNav content.">
            
            <cfset var var_bottomNavContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_bottomNavContent />  
            
        </cffunction>
        <!--- View METHOD: setBottomNavContent() FUNCTIONALITY: I set the BottomNav content. [end] --->

<!--- BOTTOM NAV [end] --->
     
<!--- FOOTER [begin] --->

		<!--- View METHOD: getFooterContent() FUNCTIONALITY: I get the Footer content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getFooterContent" access="public" returntype="string" output="yes" hint="I get the Footer content." displayname="View > getFooterContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="footer_url" type="string" required="true" default="" hint="URL of footer content.">
            
            <!--- There will be a cfhttp wrapped w/a cfsavecontent here --->
            
            <cfset var var_footerContent 	= "">

            <!--- Return the final container to the caller --->
            <cfreturn var_footerContent />  
            
        </cffunction>
        <!--- View METHOD: getFooterContent() FUNCTIONALITY: I get the Footer content. [end] --->
        
        <!--- View METHOD: setFooterContent() FUNCTIONALITY: I set the Footer content. [begin] --->
        <cffunction name="setFooterContent" access="public" returntype="string" output="no" hint="I set the Footer content." displayname="View > setFooterContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="footer_url" type="string" required="true" default="" hint="URL of footer content.">
            
            <cfset var var_footerContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_footerContent />  
            
        </cffunction>
        <!--- View METHOD: setFooterContent() FUNCTIONALITY: I set the Footer content. [end] --->

		<!--- View METHOD: getFooterVisible() FUNCTIONALITY: I get the Footer DIV's content visiblility value. [begin] --->
        <cffunction name="getFooterVisible" access="public" returntype="boolean" output="no" hint="I get the Footer DIV's content visiblility value." displayname="View > getFooterVisible()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bFooterVisible" type="boolean" required="true" default=0 hint="Footer DIV content visibility.">
            
            <cfset var var_bFooterVisible 	= 0>

            <!--- Return the final container to the caller --->
            <cfreturn var_bFooterVisible />  
            
        </cffunction>
        <!--- View METHOD: bFooterVisible() FUNCTIONALITY: I decide IF the Footer DIV's content is visible. [end] --->

        <!--- View METHOD: setFooterVisible() FUNCTIONALITY: I decide IF the Footer DIV's content is visible. [begin] --->
        <cffunction name="setFooterVisible" access="public" returntype="boolean" output="no" hint="I decide IF the Footer DIV's content is visible." displayname="View > setFooterVisible()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bFooterVisible" type="boolean" required="true" default=0 hint="Footer DIV content visibility.">
            
            <cfset var var_bFooterVisible 	= 0>

            <!--- Return the final container to the caller --->
            <cfreturn var_bFooterVisible />  
            
        </cffunction>
        <!--- View METHOD: setFooterVisible() FUNCTIONALITY: I decide IF the Footer DIV's content is visible. [end] --->

<!--- FOOTER [end] --->     
        
<!--- HEADER [begin] --->

		<!--- View METHOD: getHeaderContent() FUNCTIONALITY: I get the Header content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getHeaderContent" access="public" returntype="string" output="yes" hint="I get the Header content." displayname="View > getHeaderContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="header_url" type="string" required="true" default="" hint="URL of header content.">

            <cfset var var_headerContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_headerContent />  
            
        </cffunction>
        <!--- View METHOD: getHeaderContent() FUNCTIONALITY: I get the Header content. [end] --->
        
        <!--- View METHOD: setHeaderContent() FUNCTIONALITY: I set the Header content. [begin] --->
        <cffunction name="setHeaderContent" access="public" returntype="string" output="no" hint="I set the Header content." displayname="View > setHeaderContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="header_url" type="string" required="true" default="" hint="URL of header content.">
            
            <cfset var var_headerContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_headerContent />  
            
        </cffunction>
        <!--- View METHOD: setHeaderContent() FUNCTIONALITY: I set the Header content. [end] --->

		<!--- View METHOD: getHeaderVisible() FUNCTIONALITY: I get the Header DIV's content visiblility value. [begin] --->
        <cffunction name="getHeaderVisible" access="public" returntype="boolean" output="no" hint="I get the Header DIV's content visiblility value." displayname="View > getHeaderVisible()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bHeaderVisible" type="boolean" required="true" default=0 hint="Header DIV content visibility.">
            
            <cfset var var_bHeaderVisible 	= 0>

            <!--- Return the final container to the caller --->
            <cfreturn var_bHeaderVisible />  
            
        </cffunction>
        <!--- View METHOD: bHeaderVisible() FUNCTIONALITY: I decide IF the Header DIV's content is visible. [end] --->

        <!--- View METHOD: setHeaderVisible() FUNCTIONALITY: I decide IF the Header DIV's content is visible. [begin] --->
        <cffunction name="setHeaderVisible" access="public" returntype="boolean" output="no" hint="I decide IF the Header DIV's content is visible." displayname="View > setHeaderVisible()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bHeaderVisible" type="boolean" required="true" default=0 hint="Header DIV content visibility.">
            
            <cfset var var_bHeaderVisible 	= 0>

            <!--- Return the final container to the caller --->
            <cfreturn var_bHeaderVisible />  
            
        </cffunction>
        <!--- View METHOD: setHeaderVisible() FUNCTIONALITY: I decide IF the Header DIV's content is visible. [end] --->

<!--- HEADER [end] --->
        
<!--- LEFT COLUMN [begin] --->

		<!--- View METHOD: getLeftColumnContent() FUNCTIONALITY: I get the LeftColumn content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getLeftColumnContent" access="public" returntype="string" output="yes" hint="I get the LeftColumn content." displayname="View > getLeftColumnContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="leftColumn_url" type="string" required="true" default="" hint="URL of leftColumn content.">
            
            <cfset var var_leftColumnContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_leftColumnContent />  
            
        </cffunction>
        <!--- View METHOD: getLeftColumnContent() FUNCTIONALITY: I get the LeftColumn content. [end] --->
        
        <!--- View METHOD: setLeftColumnContent() FUNCTIONALITY: I set the LeftColumn content. [begin] --->
        <cffunction name="setLeftColumnContent" access="public" returntype="string" output="no" hint="I set the LeftColumn content." displayname="View > setLeftColumnContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="leftColumn_url" type="string" required="true" default="" hint="URL of leftColumn content.">
            
            <cfset var var_leftColumnContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_leftColumnContent />  
            
        </cffunction>
        <!--- View METHOD: setLeftColumnContent() FUNCTIONALITY: I set the LeftColumn content. [end] --->
        
        <!--- View METHOD: getLeftColumnVisible() FUNCTIONALITY: I get the LeftColumn DIV's content visiblility value. [begin] --->
        <cffunction name="getLeftColumnVisible" access="public" returntype="boolean" output="no" hint="I get the LeftColumn DIV's content visiblility value." displayname="View > getLeftColumnVisible()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bLeftColumnVisible" type="boolean" required="true" default=0 hint="LeftColumn DIV content visibility.">
            
            <cfset var var_bLeftColumnVisible 	= 0>

            <!--- Return the final container to the caller --->
            <cfreturn var_bLeftColumnVisible />  
            
        </cffunction>
        <!--- View METHOD: bLeftColumnVisible() FUNCTIONALITY: I decide IF the LeftColumn DIV's content is visible. [end] --->

        <!--- View METHOD: setLeftColumnVisible() FUNCTIONALITY: I decide IF the LeftColumn DIV's content is visible. [begin] --->
        <cffunction name="setLeftColumnVisible" access="public" returntype="boolean" output="no" hint="I decide IF the LeftColumn DIV's content is visible." displayname="View > setLeftColumnVisible()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="bLeftColumnVisible" type="boolean" required="true" default=0 hint="LeftColumn DIV content visibility.">
            
            <cfset var var_bLeftColumnVisible 	= 0>

            <!--- Return the final container to the caller --->
            <cfreturn var_bLeftColumnVisible />  
            
        </cffunction>
        <!--- View METHOD: setLeftColumnVisible() FUNCTIONALITY: I decide IF the LeftColumn DIV's content is visible. [end] --->
        
<!--- LEFT COLUMN [end] --->
        
<!--- LEFT NAV [begin] --->
        
		<!--- View METHOD: getLeftNavContent() FUNCTIONALITY: I get the leftNav content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getLeftNavContent" access="public" returntype="string" output="yes" hint="I get the leftNav content." displayname="View > getLeftNavContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="leftNav_url" type="string" required="true" default="" hint="URL of leftNav  content.">
            
            <cfset var var_leftNavContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_leftNavContent />  
            
        </cffunction>
        <!--- View METHOD: getleftNavContent() FUNCTIONALITY: I get the leftNav content. [end] --->
        
        <!--- View METHOD: setleftNavContent() FUNCTIONALITY: I set the leftNav content. [begin] --->
        <cffunction name="setLeftNavContent" access="public" returntype="string" output="no" hint="I set the leftNav content." displayname="View > setLeftNavContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="leftNav_url" type="string" required="true" default="" hint="URL of leftNav content.">
            
            <cfset var var_leftNavContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_leftNavContent />  
            
        </cffunction>
        <!--- View METHOD: setLeftNavContent() FUNCTIONALITY: I set the leftNav content. [end] --->

<!--- LEFT NAV [end] --->
        
<!--- STAGE [begin] --->

		<!--- View METHOD: getStageContent() FUNCTIONALITY: I get the Stage content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getStageContent" access="public" returntype="string" output="yes" hint="I get the Stage content." displayname="View > getStageContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="stage_url" type="string" required="true" default="" hint="URL of stage content.">
            
            <cfset var var_stageContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_stageContent />  
            
        </cffunction>
        <!--- View METHOD: getStageContent() FUNCTIONALITY: I get the Stage content. [end] --->
        
        <!--- View METHOD: setStageContent() FUNCTIONALITY: I set the Stage content. [begin] --->
        <cffunction name="setStageContent" access="public" returntype="string" output="no" hint="I set the Stage content." displayname="View > setStageContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="stage_url" type="string" required="true" default="" hint="URL of stage content.">
            
            <cfset var var_stageContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_stageContent />  
            
        </cffunction>
        <!--- View METHOD: setStageContent() FUNCTIONALITY: I set the Stage content. [end] --->
        
<!--- STAGE [end] --->
        
<!--- TOP NAV [begin] --->
        
        <!--- View METHOD: getTopNavContent() FUNCTIONALITY: I get the TopNav content. [begin] --->
        <!--- ACTION: To change to private --->
        <cffunction name="getTopNavContent" access="public" returntype="string" output="yes" hint="I get the TopNav content." displayname="View > getTopNavContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="topNav_url" type="string" required="true" default="" hint="URL of topNav content.">
            
            <cfset var var_topNavContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_topNavContent />  
            
        </cffunction>
        <!--- View METHOD: getTopNavContent() FUNCTIONALITY: I get the TopNav content. [end] --->
        
        <!--- View METHOD: setTopNavContent() FUNCTIONALITY: I set the TopNav content. [begin] --->
        <cffunction name="setTopNavContent" access="public" returntype="string" output="no" hint="I set the TopNav content." displayname="View > setTopNavContent()">
        
            <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") ---> 
            <cfargument name="topNav_url" type="string" required="true" default="" hint="URL of topNav content.">
            
            <cfset var var_topNavContent 	= "">

			<!--- There will be a cfhttp wrapped w/a cfsavecontent here --->

            <!--- Return the final container to the caller --->
            <cfreturn var_topNavContent />  
            
        </cffunction>
        <!--- View METHOD: setTopNavContent() FUNCTIONALITY: I set the TopNav content. [end] --->
        
<!--- TOP NAV [end] --->

		<!--- :::::::::::::::::::::::::::::::::::::::::
		:::::::: View Methods getters/setters  ::::::::
		:::::::::::::::::::::::::::::::::: [ end ] --->

	</cfif>

</cfcomponent>