<!--- ---------------------------------------------------------------------------------------------------------------------------------
      Template: \common_files\tabnavFlex.cfm
          Date:  2018 July
       Purpose:  Styles for horizontal tab menu, copied from tabnav.css and altered to use Flexbox and JS

       Example:
                <div class="nav">
                    <ul class="nav">
                        <li  class="topnav" onclick="showTab(event, 'searchTab')" id="defaultTab">Search</li>
                        <li  class="topnav" onclick="showTab(event, 'listTab')">List</li>
                        <li  class="topnav" onclick="showTab(event, 'toolsTab')">Tools</li>
                    </ul>
                </div>
    ---------------------------------------------------------------------------------------------------------------------------------
 --->

<!--- Active tab color defaults to white, but if caller defines "altActiveColor", use alt color instead --->
<!--- Ex: <cfset request.altActiveColor = "true">  --->
<cfset active_tab_bgcolor = ( structKeyExists(request, "altActiveColor")? "##F5F6FA": "##FFF")>

<style>
div.nav {
    border-bottom: 1px solid #d8d9dd;
    box-sizing: content-box;
    height: 30px;
}
ul.nav {
    list-style: none;
    margin: 0;
    padding: 0 0 0 5px;
    display: flex;
    flex-wrap: wrap;
}

/* Inactive tabs */
ul.nav > li  {
    display: flex;
    flex-grow: 1;
    margin: 9px 3px 0 0;
    background: #c4c5c7;
    border: 1px solid #C4C5C7;
    border-radius: 3px 3px 0 0;
    color: #343540;
    cursor: pointer;
    font-size: 12px;
    font-weight: bold;
    height: 20px;
    line-height: 20px;
    text-decoration: none;
    /* center text within the tab */
    justify-content: center;
    align-items: center;
    align-content: center;
}
ul.nav > li:hover {
    background: #D8D9DD;
    color: #406be4;
}
ul.nav > li.hidden {
    display:none;
}
/* The active tab */
ul.nav > li.active, ul.nav > li:active {
<cfoutput>
    background: #active_tab_bgcolor#;
    border-bottom: 1px solid #active_tab_bgcolor#;
</cfoutput>
    cursor: auto;
    font-weight: bold;
    height: 22px;
    line-height: 22px;
    opacity:1;
    margin-top: 7px;
}
.tabContent {
    display: none;
}
</style>

<script>
    // Show passed in tab content & make tab look active, hide all others.
    // Use this with hidden sections on the same page
    function showTab(evt, tabContentIdToShow) {
           // Get all elements with class="tabContent" and hide them
        let tabContents = document.getElementsByClassName('tabContent');
        for (var i = 0; i < tabContents.length; i++) {
            tabContents[i].style.display = 'none';
        }

        // Get all elements with class="topnav" and remove the class "active"
        let topnavs = document.getElementsByClassName("topnav");
        for (i = 0; i < topnavs.length; i++) {
            topnavs[i].className = topnavs[i].className.replace(" active", "");
        }

        // Show the requested tab content, and add an "active" class to the tab itself
        document.getElementById(tabContentIdToShow).style.display = 'block';
        evt.currentTarget.className += " active";
    }
</script>