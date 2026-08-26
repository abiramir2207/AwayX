<cfsilent>
<!---
  * ==================================================================================================== 
  *    @File: /common_Files/tabnav-css.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019-03-12 14:20:58
  * 
  * @Remarks: CSS for navigation horizontal tabs. 
  *
  *         1. Tailwind CSS (default support)
  *         ---------------------------------
                <cf_include files="/common_files/tailwind-css.cfm">

                <ul class="flex list-reset nav mx-2 -mb-px">
                    <li class="border rounded-t w-32">Edit</li>
                    <li class="border rounded-t w-32">Details</li>
                </ul>
       			:: /programs/volume/edit_volume_header.cfm

  *         2. Classic CSS
            --------------
                <div class="nav">
                    <ul class="nav">
                        <li class="active">
                            <a class="topnav" href="##">scorecard</a>
                        </li>
                        <li>
                            <a class="topnav" href="##">planner calendar</a>
                        </li>
                    </ul>
                </div>

       			:: /common_files/layout_planner.cfm
  * ==================================================================================================== 
--->
<cfsavecontent variable="tabnav">
    <style>
        <cfparam name="request.tabnav_css" default="tailwind">

        /* 1. Default support for tailwind css */
        <cfif request.tabnav_css is "tailwind">
            /* Inactive tabs */
            ul.nav > li  {
                background: #c4c5c7;
                color: #343540;
                font-weight: bold;
                height: 20px;
                line-height: 20px;
                margin: 9px 4px 0 0;
                text-align: center;
            }
                ul.nav > li:hover {
                    background: #D8D9DD;
                    color: #406be4;
                }
            /* The active tab */
            ul.nav > li.active {
                background: #FFF;
                border-bottom: 0px;
            }

        /* 2. Support classic CSS */
        <cfelse>
            div.nav {
                border-bottom: 1px solid #CCC;
                height: 34px;
                margin: 0px 0 5px 0;
                background-color2: #F2F3F5;
            }
            ul.nav {
                list-style: none;
                margin: 0;
                padding: 0 0 0 10px;
            }
            ul.nav a {
                display: block;
                text-decoration: none;
                opacity:0.7;
                border-top: #CCC;
                border-top-style: solid;
                border-top-width: thin;
                border-left-color: #CCC;
                border-left-style: solid;
                border-left-width: thin;
                border-right-color: #CCC;
                border-right-style: solid;
                border-right-width: thin;
            }
            ul.nav > li {
                float: left;
                margin: 10px 7px 0 0;
            }
            ul.nav > li > a {
                background: #EDEEF2;
                border-radius: 3px 3px 0 0;
                color: blue;
                font-size: 11px;
                font-weight: bold;
                height: 24px;
                line-height: 24px;
                padding: 0 12px;
                text-decoration: none;
            }
            ul.nav > li > a:hover {
                background: #85a6b8;
                color: white;
                text-decoration: none;
            }
            ul.nav > li.active > a, ul.nav > li > a:active > a {
                background: #406be4;
                border: 1px solid #CCC;
                border-bottom: none;
                color: white;
                font-size: 12px;
                height: 30px;
                letter-spacing: 0.5px;
                line-height: 30px;
                /* text-shadow: 4px 4px 4px #aaa; */
                opacity:1;
            }
            ul.nav > li.active {
                margin-top: 4px;
            }
        </cfif>
    </style>      
</cfsavecontent>
</cfsilent>
<cfoutput>#application.util.string.compress( tabnav )#</cfoutput>
