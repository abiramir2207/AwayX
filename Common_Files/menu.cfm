<cfprocessingdirective suppressWhitespace="true">
<cfsilent>
<!---
  * ==================================================================================================== 
  *    @File: \common_Files\menu.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2020-01-02 11:10:05
  * 
  * @Remarks: Library function renderMenu() generates CSS only multiple levels dropdown menu
  *             Define request.menu_style when you want to use a custom menu style
  *
  * @Parameters: 1. menu - required ~ array of structures (see structure layout further down)
  *              2. submenu - optional ~ submenu indicator, boolean, default to false
  *  
  * @Example: 4 levels of dropdown menu
  *             #renderMenu([
  *                          { title:"Lorem", url:"" }
  *                          ,{ title:"Repellendus", url:"" }
  *                          ,{ title:"Laborum", url:"", children:[
  *                                                                  { title:"Lorem", url:"" }
  *                                                                  ,{ title:"Nisi", url:"" }
  *                                                                  ,{ title:"Laborum", url:"", children:[
  *                                                                                                          { title:"Lorem", url:"" }
  *                                                                                                          ,{ title:"Nisi", url:"" }    
  *                                                                                                          ,{ title:"Tenetur", url:"" }    
  *                                                                                                          ,{ title:"Laborum", url:"", children:[
  *                                                                                                                                                  { title:"Lorem", *url:"" }
  *                                                                                                                                                  ,{ title:"Nisi", *url:"" }    
  *                                                                                                                                                  ,{ title:"Tenetur", *url:"" }    
  *                                                                                                                                                  ,{ title:"Ullam", *url:"" }    
  *                                                                                                                                                  ,{ title:"Quidem", *url:"" }    
  *                                                                                                                                              ] }
  *                                                                                                      ] }
  *                                                                  ,{ title:"Ullam", url:"" }
  *                                                                  ,{ title:"Quidem", url:"" }
  *                                                              ] }
  *                          ,{ title:"Tempore", url:"" }
  *                          ,{ title:"Voluptate", url:"" }
  *                          ,{ title:"Omnis", url:"" }
  *                          ,{ title:"Sint", url:"" }
  *                      ])#
  * 
  * ============================== Generated Result ===============================
  *      <div class="container">
  *          <div class="wrapper">
  *              <nav class="nav">
  *                  <ul class='menu'>
  *                      <li class='menu-item'>
  *                          <a href="">Lorem </a>
  *                      </li>
  *                      <li class='menu-item'>
  *                          <a href="">Repellendus </a>
  *                      </li>
  *                      <li class='menu-item has-children'>
  *                          <a href="">
  *                              Laborum <span class="dropdown-icon"></span>
  *                          </a>
  *                          <ul class='sub-menu'>
  *                              <li class='menu-item'>
  *                                  <a href="">Lorem </a>
  *                              </li>
  *                              <li class='menu-item'>
  *                                  <a href="">Nisi </a>
  *                              </li>
  *                              <li class='menu-item has-children'>
  *                                  <a href="">
  *                                      Laborum <span class="dropdown-icon"></span>
  *                                  </a>
  *                                  <ul class='sub-menu'>
  *                                      <li class='menu-item'>
  *                                          <a href="">Lorem </a>
  *                                      </li>
  *                                      <li class='menu-item'>
  *                                          <a href="">Nisi </a>
  *                                      </li>
  *                                      <li class='menu-item'>
  *                                          <a href="">Tenetur </a>
  *                                      </li>
  *                                      <li class='menu-item has-children'>
  *                                          <a href="">
  *                                              Laborum <span class="dropdown-icon"></span>
  *                                          </a>
  *                                          <ul class='sub-menu'>
  *                                              <li class='menu-item'>
  *                                                  <a href="">Lorem </a>
  *                                              </li>
  *                                              <li class='menu-item'>
  *                                                  <a href="">Nisi </a>
  *                                              </li>
  *                                              <li class='menu-item'>
  *                                                  <a href="">Tenetur </a>
  *                                              </li>
  *                                              <li class='menu-item'>
  *                                                  <a href="">Ullam </a>
  *                                              </li>
  *                                              <li class='menu-item'>
  *                                                  <a href="">Quidem </a>
  *                                              </li>
  *                                          </ul>
  *                                      </li>
  *                                  </ul>
  *                              </li>
  *                              <li class='menu-item'>
  *                                  <a href="">Ullam </a>
  *                              </li>
  *                              <li class='menu-item'>
  *                                  <a href="">Quidem </a>
  *                              </li>
  *                          </ul>
  *                      </li>
  *                      <li class='menu-item'>
  *                          <a href="">Tempore </a>
  *                      </li>
  *                      <li class='menu-item'>
  *                          <a href="">Voluptate </a>
  *                      </li>
  *                      <li class='menu-item'>
  *                          <a href="">Omnis </a>
  *                      </li>
  *                      <li class='menu-item'>
  *                          <a href="">Sint </a>
  *                      </li>
  *                  </ul>
  *              </nav>
  *          </div>
  *      </div>
  * ==================================================================================================== 
--->
</cfsilent>

<!--- ===================================================================== --->
<!---     define style for menu when request.menu_style does not exist      --->
<!--- ===================================================================== --->
<cfif !structKeyExists(request, "menu_style")>
    <cfsavecontent variable="request.menu_style">
        <style>
            .wrapper {
                max-width: 970px;
                margin: 3em auto;
            }

            ul.menu {
                background-color: #FFECCF;
                border-radius: 13px;
            }

            .menu, .sub-menu {
                margin: 0;
                padding: 0;
            }
            .sub-menu {
                box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            }

            .menu-item, .sub-menu, .dropdown-icon {
                border: 0 solid;
            }

            .menu .menu-item {
                display: block;
            }

            .menu .menu-item.has-children, .menu .menu-item.has-children .menu-item {
                position: relative;
            }

            .menu .menu-item:not(:last-child) {
                border-width: 0 0 1px;
            }

            .menu .menu-item a {
                padding: 0.4em 1em;
                display: flex;
				justify-content: space-between;
				white-space: nowrap;
            }

            .menu > .menu-item > a {
				padding: 0 1em;
			}

            .menu .sub-menu {
                border-width: 1px 0 0;
                visibility: hidden;
                opacity: 0;
                height: 0;
                width: 0;
                transition: visibility .25s, opacity .25s ease-in-out;
            }

            .menu .sub-menu .menu-item {
                visibility: hidden;
            }

            .menu .menu-item:hover > .sub-menu, .menu .menu-item:active > .sub-menu, .menu .menu-item:focus > .sub-menu {
                opacity: 1;
                height: auto;
                width: auto;
            }

            .menu .menu-item:hover > .sub-menu, .menu .menu-item:hover > .sub-menu .menu-item, .menu .menu-item:active > .sub-menu, .menu .menu-item:active > .sub-menu .menu-item, .menu .menu-item:focus > .sub-menu, .menu .menu-item:focus > .sub-menu .menu-item {
                visibility: visible;
            }

            /* SAH */
            /* .menu .menu-item > a:hover .dropdown-icon:after, .menu .menu-item > a:active .dropdown-icon:after, .menu .menu-item > a:focus .dropdown-icon:after { transform: rotate(45deg); } */
            .menu .dropdown-icon {
                padding: 1em 1.25em;
                margin: -1em -1em -1em .5em;
                border-width: 0 0 0 1px;
            }

            .menu .dropdown-icon:after {
                content: "+";
                display: block;
                transition: transform .25s ease-in-out;
            }

            .nav--rtl {
                direction: rtl;
                unicode-bidi: bidi-override;
            }

            .nav--rtl .menu .dropdown-icon {
                margin: -1em .5em -1em -1em;
                border-width: 0 1px 0 0;
            }

            @media only screen {
                .nav .menu {
                    display: flex;
                    flex-flow: row wrap;
                }

                .nav .menu > .menu-item {
                    border-width: 0 1px 0 0;
                }

                .nav .menu > .menu-item > a .dropdown-icon {
                    padding-left: 0;
                }

                /* SAH */
                /* .nav .menu .menu-item:hover > .sub-menu, .nav .menu .menu-item:active > .sub-menu, .nav .menu .menu-item:focus > .sub-menu { width: 225px; } */
                .nav .menu .sub-menu {
                    position: absolute;
                    z-index: 3000;
                    top: 100%;
                    left: 0;
                    border-width: 0;
                }

                .nav .menu .sub-menu .sub-menu {
                    top: 0;
                    left: 100%;
                }

                .nav .menu .dropdown-icon {
                    border-width: 0;
                    padding: 1em;
                }

                .nav--rtl .menu > .menu-item > a .dropdown-icon {
                    padding-left: 1em;
                    padding-right: 0;
                }

                .nav--rtl .menu .sub-menu {
                    top: 100%;
                    left: auto;
                    right: 0;
                }

                .nav--rtl .menu .sub-menu .sub-menu {
                    left: auto;
                    right: 100%;
                }

                .nav--cen .menu {
                    justify-content: center;
                }
            }

            .nav {
                background-color: #ffedd2;
            }

            .nav .menu > .menu-item, .nav .menu > .menu-item .dropdown-icon {
                border-color: rgba(255, 255, 255, 0.1);
            }

            .nav .menu > .menu-item, .nav .menu > .menu-item > a {
                color: #343540;
            }

            .nav .menu > .menu-item > a:hover, .nav .menu > .menu-item > a:active, .nav .menu > .menu-item > a:focus {
                background-color: #406be4;
        				color: #fff;
        				text-decoration: none;
            }

            .nav .sub-menu {
                background-color: #fff;
            }

            .nav .sub-menu, .nav .sub-menu .dropdown-icon, .nav .sub-menu .menu-item, .nav .sub-menu .menu-item .dropdown-icon {
                border-color: rgba(0, 0, 0, 0.1);
            }

            .nav .sub-menu .menu-item, .nav .sub-menu .menu-item a {
                color: #343540;
            }     

            .nav .sub-menu .menu-item a:hover:not(.inactiveLink), .nav .sub-menu .menu-item a:active:not(.inactiveLink), .nav .sub-menu .menu-item a:focus:not(.inactiveLink) {
                background-color: #EDEEF2;
				color: #406be4;
				text-decoration: none;
            }

            .nav .sub-menu .menu-item .inactiveLink, .nav .sub-menu .menu-item a .inactiveLink {
                color: #cbc9c7;
                text-decoration: none;
            }

            
            <cfif structKeyExists(request, "menu_custom_style")>
                <cfoutput>#request.menu_custom_style#</cfoutput>
            </cfif>
        </style>
    </cfsavecontent>
    <cfhtmlhead  text="#application.util.string.compress( request.menu_style )#">
</cfif>


<!--- ===================================================================== --->
<!---      Generate menu html elements based on CF array of structures      --->
<!--- ===================================================================== --->
<cffunction name="renderMenu" output="false">
    <cfargument name="menu" required="true" type="array">
    <cfargument name="submenu" required="false" default="false">

    <!--- ===================================================================== --->
    <!---                  structure for menu array parameter                   --->
    <!--- ===================================================================== --->

    <!---
        [ 
            { title:"", url:"" }
            ,{ title:"", url:"", children:[{ title:"", url:"" }] }
            ...
        ]
    --->

    <cfoutput>
    <cfsavecontent variable="local.html">
        <ul class='#(arguments.submenu ? "sub-menu" : "menu")#'>

            <cfloop from="1" to="#arrayLen(arguments.menu)#" index="local.index">
				<cfset local.has_children = structKeyExists(arguments.menu[ local.index ], "children") ? true : false>
				<cfset local.has_url = len(arguments.menu[ local.index ].url)>

                <li class='menu-item#(local.has_children ? " has-children" : "")#'>
                    <cfparam name="arguments.menu[ local.index ].class" type="string" default="" />
                    <cfparam name="arguments.menu[ local.index ].id" type="string" default="" />
                    <cfset sId = ''>
                    <cfif arguments.menu[ local.index ].id NEQ ''>
                        <cfset sId = ' id="#arguments.menu[ local.index ].id#" '>
                    </cfif>
                    <a class="#arguments.menu[ local.index ].class#" href="#arguments.menu[ local.index ].url#" #(local.has_url ? "" : "onclick='return false;'")# #sId# >#arguments.menu[ local.index ].title# 

					<!--- If no url then ensure click will do nothing --->
					<!--- <a href="#arguments.menu[ local.index ].url#" #(local.has_url ? "" : "onclick='return false;'")#>#arguments.menu[ local.index ].title#  --->

                        <cfif local.has_children>
                            <span class="dropdown-icon"></span>
                        </cfif>
                    </a>

                    <!--- ===================================================================== --->
                    <!---                      render submenu recursively                       --->
                    <!--- ===================================================================== --->
                    <cfif local.has_children>
                        #renderMenu(arguments.menu[ local.index ].children, true)#
                    </cfif>
                </li>
            </cfloop>
        </ul>                
    </cfsavecontent>
    </cfoutput>

    <cfreturn application.util.string.compress( local.html )>
</cffunction>

</cfprocessingdirective>