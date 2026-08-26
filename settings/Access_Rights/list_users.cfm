<!--- YUI Calls --->
<!-- Required CSS -->
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui/build/datatable/assets/skins/sam/datatable.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui/build/container/assets/container.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui/build/reset/reset.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui/build/fonts/fonts.css">
<link rel="stylesheet" type="text/css" href="/Script/javascript/yui/build/assets/skins/yuitest.css" >
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui/build/autocomplete/assets/skins/sam/autocomplete-skin.css">

<script type="text/javascript" src="/Script/javascript/yui/build/yahoo/yahoo-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/connection/connection-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/dom/dom-min.js" ></script>
<script type="text/javascript" src="/Script/javascript/yui/build/animation/animation-min.js" ></script>
<script type="text/javascript" src="/Script/javascript/yui/build/container/container-min.js"></script>

<!-- Dependencies -->
<script type="text/javascript" src="/Script/javascript/yui/build/autocomplete/autocomplete-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/utilities/utilities.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/datasource/datasource-beta-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/datatable/datatable-beta-min.js"></script>


<!--- AjaxCFC calls --->
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.AjaxCFC.js"></script>

<script type="text/javascript">
		// additional files
		$.AjaxCFC({require:'dDumper,DWRSyntax,jquery'});
		// more additional files
		// $.AjaxCFC({require:'jquery.fastSerialize'});

		// optional global settings
		// using these setters also automatically include dependencies
		$.AjaxCFCHelper.setDebug(false);
		$.AjaxCFCHelper.setBlockUI(false);
		$.AjaxCFCHelper.setUseDefaultErrorHandler(true);
		$.AjaxCFCHelper.setSerialization('json'); // json, wddx
	</script>
	
<style>

#users table {border-collapse:collapse;width:100%;}
#users tbody td {padding:3px;color:black;}
#users thead th {font-size:10px;font-weight:bold;background-color:RGB(255,224,131);text-align:left;vertical-align:bottom;padding:2px;color:black}
#users thead th a {color:blue;} 
#users .yui-dt-odd {background-color:rgb(225,255,225);} /*light green*/
#users .yui-dt-highlight {background-color:rgb(204,204,255);}
#users  th.yui-dt-sortable { 
padding-right:5px; /* room for arrow */ 
} 
#users th.yui-dt-sortable .yui-dt-label { 
margin-right:5px; /* room for arrow */ 
} 
#users th.yui-dt-asc, 
 th.yui-dt-desc { 
} 
#users th.yui-dt-asc .yui-dt-header { 
background:url(/Script/javascript/yui/build/assets/skins/sam/dt-arrow-up.png) no-repeat right; /* sorted header gradient */ 
/*background-image: url('../img/arrow_up.gif'); background-repeat:no-repeat; background-position:right; sorted header icon */ 
} 
#users th.yui-dt-desc .yui-dt-header { 
background:url(/Script/javascript/yui/build/assets/skins/sam/dt-arrow-dn.png) no-repeat right; /* sorted header gradient */ 
/*background-image: url('../img/arrow_dn.gif'); background-repeat:no-repeat; background-position:right; /*sorted header icon */ 
}  
#autocomplete {
    width:10em; /* set width for widget here */
    padding-bottom:2em;
}
#container {
	width:40em;
	z-index:2;
}
#searchOptions
{
	position:absolute;
	top: 0;
	left:14em;
}
#autocomplete .yui-ac-content {
    max-height:15em;overflow:auto;overflow-x:hidden; /* set scrolling */
    _height:15em; /* ie6 */
}
</style>
<div id="logger"></div>
   <!-- Autocomplete container with search box -->
   <div id="autocomplete" class="yui-skin-sam">
	<label for="search">Search:<input width="35" id="search" class="yui-ac-input"  /></label>
	<div id="container" class="yui-ac-container"></div>
   </div>
	
	<div id="searchOptions">[<a href="javascript:;" onclick="document.getElementById('search').value='';getUsers('')">Show all Users</a>] [<a href="javascript:;" onclick="displayinactiveListusers()"><span id="inactiveLink">Display Inactive Users</span></a>]</div>
    <!-- Users table -->	
   <div id="users"></div>			
	 
	<script>
		 // Displays Inactive Users List. Updates Link to set 
   // back to Active Users once you have clicked on it
   
	
	
        YAHOO.util.Event.addListener(window, "load", getUserCount(0));
		var id = "";
		function displayinactiveListusers()
	{
		var type = document.getElementById('inactiveLink').innerHTML;

		if (type == 'Display Inactive Users')
		{
			getUsers('','1');
		    document.getElementById('inactiveLink').innerHTML = 'Display Active Users';
		}
		if (type == 'Display Active Users')
		{
			document.getElementById('inactiveLink').innerHTML = 'Display Inactive Users';
			getUsers('','0');
		}
	}
		
		function verifyDelete(user_name, user_id){
			if(confirm("If " + user_name + " currently has programs, deductions or billbacks, you will have an opportunity to reassign them. Otherwise the user will be immediately deactivated.")){
				document.DeleteUserForm.User_ID.value = user_id
				document.DeleteUserForm.submit();
			}
		}
		
		// login date formatter
		this.loginDate = function(sString) 
	    {
				if (sString == '' || sString == null)
				{
					return "None to Date";
				}
				else
				{
          		    var d = new Date(sString);
          		    return YAHOO.util.DataSource.convertDate(d);
				}

	    }
		
		// formatter for building url to activate users
		this.formatUrl = function(elCell, oRecord, oColumn, sData)
		{
			elCell.innerHTML = "<a href='users_create_form.cfm?activateuser=0&User_ID=" + oRecord.getData("user_id") + "' target='mainwindow'>" + sData.replace(/'/g, "&#39;") + "</a>";
		}
		
		this.authSequence = function(sData)
		{
		
			if (sData == null || sData == "")
          	{
          		return "No Authority Sequence"
          	}
          	else
          	{
          		return sData;
          	}
		}
		
		 this.getDeleteButton = function(elCell, oRecord, oColumn, sData)
          {
             var displayStr = "Activate";
             var nameLast = oRecord.getData("name_last");

                 if (sData == 0)
                 {
                  elCell.innerHTML =  "<img src=\"/images/delete.gif\" style=\"cursor: hand\"  onclick=\"verifyDelete(\'" + oRecord.getData('name_first') + ' ' + nameLast.replace(/(\')/g,'\\\'') + "','" + oRecord.getData('user_id') + "')\" />";
                 }
                 else
                 {
                  elCell.innerHTML = "<a href='users_create_form.cfm?activateuser=1&User_ID=" + oRecord.getData("user_id") + "' target='mainwindow'>" + displayStr + "</a>";
                 }
          }
          
          /*****************************************************
            gets the selected value from the autocomplete
            dropdown and sends the results to the getUserById()
            function
          *****************************************************/ 
          var getSelectedValue = function(sType, aArgs)
		  {
		  	// aArgs is returned from the itemSelectEvent handler that
		  	// is part of the Autocomplete object
		  	var searchBox = YAHOO.util.Dom.get("search");
		  	    // aArgs represents data associated with the AutoComplete instance
		  	    // aArgs[0] = the AutoComplete instance 
		  	    // aArgs[1] = the <li> element selected in the suggest container 
		  	    // aArgs[2] = array of the data for the item as returned by the DataSource
		  	    // in this case aArgs[2][0] is the first name, aArgs[2][1] is the last name
		  	    // and aArgs[2][4] is the user_id field
		  	    searchBox.value = aArgs[2][0] + " " + aArgs[2][1];
		  	    getUserById(aArgs[2][4]);
		  }
		  
		  function getUserById(userid) {
		   getUsers('',0,false,userid);
		  	
		  }
		
		// Added getUserCount() to see if we should display a message
		// letting the user know they have more than 250 records to load
		function getUserCount(type) {
		  $.AjaxCFC({
		      url: "/components/user/ajaxUserManager.cfc",
		      method: "getUserCount",
		      data: {"type":type},
              serialization: "json",
              success: function(result) {
                 if (result.data[0].recordnum > 250) {
                 	 YAHOO.namespace("example.container");
                 	 YAHOO.example.container.simpledialog1 =  
                 	 new YAHOO.widget.SimpleDialog("simpledialog1", 
			             {width: "300px",
			              fixedcenter: true,
			              visible: true,
			              draggable: false,
			              close: true,
			              text: "This may take a while, there are " + result.data[0].recordnum + " records to show",
			              icon: "",
			              constraintoviewport: true,
			              buttons: [ { text:"Okay", handler:handleOkay},{text: "Show top 250 records", handler:handleClose} ]
			             } );
                 
                      YAHOO.example.container.simpledialog1.setHeader("Take a short break!");
                      YAHOO.example.container.simpledialog1.render(document.body);

                 }
                 else {
                      getUsers('','0');
                 }
              }
		  });
		}	
		
		var handleOkay = function() {
		    getUsers('',0);
		    this.hide();
		};
		
		var handleClose = function() {
		    getUsers('',0,true);
		    this.hide();
		 };
		
		function getUsers(searchString,type,min,id)
		{
              YAHOO.namespace("example.container");
              YAHOO.example.container.wait = 
						new YAHOO.widget.Panel("wait",  
														{ width:"240px",
														  fixedcenter:true, 
														  close:false, 
														  draggable:false, 
														  modal:true,
														  visible:false,
														  effect:{effect:YAHOO.widget.ContainerEffect.FADE, duration:0.1} 
														} 
													);

				YAHOO.example.container.wait.setHeader("Loading, please wait...");
				YAHOO.example.container.wait.setBody('<img src="/images/initial_loader.gif" />');
				YAHOO.example.container.wait.render(document.body);
				YAHOO.example.container.wait.show();
				
				
			$.AjaxCFC({
                  url: "/components/user/ajaxUserManager.cfc", // your CFC
                  method: "getusersList",
                  data: {"SQL_Sort_By":"name_last","searchstring":searchString,"type":type,recordstoget:min,userid:id},
                  serialization: "json",
                  success: function(result){
				      
                      var colHeaders = [
    			        {key:"fullname",label:"First Name Last Name", sortable:true, formatter:this.formatUrl},
    			        {key:"profiles_desc",label:"Profile", sortable:true},
    			        {key:"position_label",label:"Position", sortable:true},
    			        {key:"lastlogindate",label:"Last Successful Login", formatter:YAHOO.widget.DataTable.formatDate, sortable:true},
    			        {key:"password_update_date",label:"Last Password Change", formatter:YAHOO.widget.DataTable.formatDate, sortable:true},
    			        {key:"address", label:"Address", sortable:true},
    			        {key:"phonenum", label:"Phone/Fax",sortable:true},
    			        {key:"authority_sequence_name", label:"Authority Sequence",sortable:true},
    			        {key:"deleted",label:"", formatter:this.getDeleteButton}
   			        ];
			 
			    this.myDataSource = new YAHOO.util.DataSource(result);
			    this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
			    this.myDataSource.responseSchema = {
    			     resultsList: "data",
    			     fields: [{key:"fullname"},
    				          {key:"profiles_desc"},
    				          {key:"position_label"},
    				          {key:"lastlogindate",parser:this.loginDate},
    				          {key:"password_update_date", parser:this.loginDate},
    				          {key:"address"},
    				          {key:"phonenum"},
    				          {key:"authority_sequence_name", parser:this.authSequence},
    				          {key:"deleted"},
    				          {key:"name_first"},
    				          {key:"name_last"},
    				          {key:"user_id"}
    				         ]
    			};
               
              
   			        var oConfigs = {
                        paginated:true,
                        paginator: {
                        rowsPerPage: 10,
                        dropdownOptions: [10,20,50,100]
                        }
                };
			
			         this.myDataTable = new YAHOO.widget.DataTable("users", colHeaders, this.myDataSource,oConfigs);
			          YAHOO.example.container.wait.hide();
			      }
				});
		   }
		   
                   
		   YAHOO.example.ACJson = new function(){
		   this.oACDS = new YAHOO.widget.DS_XHR("/components/user/ajaxUserManager.cfc", ["data","name_first","name_last","position_label","profiles_desc","user_id"]);
    	   this.oACDS.responseType = YAHOO.widget.DS_XHR.TYPE_JSON;
    	   this.oACDS.queryMatchContains = false;
    	   this.oACDS.scriptQueryParam = "searchstring";
    	   this.oACDS.scriptQueryAppend = "method=autoCompleteData&SQL_Sort_By=name_last"; // Needed for YWS
           
    				// Instantiate AutoComplete
    			   this.oAutoComp = new YAHOO.widget.AutoComplete("search","container", this.oACDS);
                   this.oAutoComp.useShadow = true;
                   this.oAutoComp.animVert = true;
                   this.oAutoComp.animSpeed = 0.3;
                   this.oAutoComp.alwaysShowContainer = false;
                   this.oAutoComp.maxResultsDisplayed = 100;
                   // Format the result so the Autosuggest contains
                   // Name,Position, and Profile
                   this.oAutoComp.formatResult = function(oResultItem, sQuery) {
       
           			var name = "Name: " + oResultItem[0] + " " + oResultItem[1] + " Position: " + oResultItem[2] + " Profile: " + oResultItem[3];
                    return (name);
         };
                // event listener for when an item is selected
                this.oAutoComp.itemSelectEvent.subscribe(getSelectedValue); 
                   
                   };
 </script>
		
<form name="DeleteUserForm" action="users_delete.cfm" method="post">
 <input type="hidden" name="User_ID" />
</form>