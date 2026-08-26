<!---
	Name: app_settings_7.cfm
	Copyright (c) 2007 Blacksmith Applications, Inc.                
	Description:
	Management screen for the application's Attribute Labels.
	Modified By: Ben Densmore 05/31/2007
	Purpose: Administration of Attribute labels for Product_Group_Level
	         and Distributor_Group_Level.  
--->



<style>


/* custom css*/
#grid-panel {margin:1em;}
#grid-panel table {border-collapse:collapse;}
#grid-panel th, #grid-panel td {border:1px solid blue;padding:.35em;}
#grid-panel th {background-color:#FFE083;color:blue;font-weight:bold;font:12px Arial;}
#grid-panel .yui-dt-odd {background-color:#ccffcc;} /*green*/
#grid-panel .yui-dt-even {background-color:#FFFFFF;}
#grid-panel th .yui-dt-headtext {margin-right:5px;padding-right:15px;} /*room for arrow*/
#grid-panel .yui-dt-editable.yui-dt-highlight {background-color:#BEDAFF;} /*light blue*/ 
#grid-panel .yui-dt-sortedbyasc .yui-dt-headtext {background-image: url('/images/up_1.gif'); background-repeat:no-repeat; background-position:right;}/*arrow up*/ 
#grid-panel .yui-dt-sortedbydesc .yui-dt-headtext {background-image: url('/images/down_1.gif'); background-repeat:no-repeat; background-position:right;}/*arrow down*/ 
</style>
<!-- Required CSS -->
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui_2_2_0/datatable/assets/datatable.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui_2_2_0/container/assets/container.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui_2_2_0/reset/reset.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui_2_2_0/fonts/fonts.css">

<!-- Dependencies -->
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/yahoo/yahoo.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/event/event-debug.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/dom/dom-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/logger/logger.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/dragdrop/dragdrop-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/container/container-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/animation/animation-min.js" ></script>
<!-- Source files -->
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/datasource/datasource-beta-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui_2_2_0/datatable/datatable-beta-min.js"></script>
<!--- AjaxCFC calls --->
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.AjaxCFC.js"></script>


	<script type="text/javascript">
		// additional files
		// $.AjaxCFC({require:'dDumper'});
		// more additional files
		// $.AjaxCFC({require:'jquery.fastSerialize'});

		// optional global settings
		// using these setters also automatically include dependencies
		$.AjaxCFCHelper.setDebug(false);
		$.AjaxCFCHelper.setBlockUI(false);
		$.AjaxCFCHelper.setUseDefaultErrorHandler(true);
		$.AjaxCFCHelper.setSerialization('json'); // json, wddx
	</script>

<script language="JavaScript" type="text/javascript">
        // Loads Product Attribute labels by default
        // the $(document).ready() function is built into JQuery
        // it's similar to the window.load() function but much faster
        YAHOO.namespace("example.container");
				
        $(document).ready(function(){
  			getAttributes('product');
		});
        
        // Every time a cell is edited this function is called
        // to update the data in that cell.
        function myCellEditEventHandler(a)
        {
         var recordObj = new Object();
         var type = "";
         var jsonData = "";
         var methodName = "";
         
         
         if(a.newData != a.oldData)
         {
	        for(var idx in a.record)
	        {
				switch (idx)
				{
					case "product_group_level_id":
					 type = "product";
					 recordObj.id = a.record[idx];
					 break; 
					 
					case "group_internal_label":
					 recordObj.internalLabel = a.record[idx];
					 break;
					 
				    case "group_level_desc":
				     recordObj.description =   a.record[idx];
				     break;
				     
				    case "distributor_group_level_id":
				     type = "distributor";
				     recordObj.id = a.record[idx];
				     break;
				     
				     case "group_level_desc_internal":
				     recordObj.internalLabel = a.record[idx];
				     break;
				    
				}
				 
            }
             
               if (type == "product")
               {
               		jsonData = {"product_group_level_id":recordObj.id,"group_internal_label":recordObj.internalLabel,"group_level_desc":recordObj.description};
              		methodName = "updateProductAttribute";
               }
               else
               {
               		jsonData = {"distributor_group_level_id":recordObj.id,"group_level_desc_internal":recordObj.internalLabel,"group_level_desc":recordObj.description};
                	methodName = "updateDistributorAttribute";
               }
               
               
				//alert("Record =>"+a.record+" key:"+a.key+"newData="+a.newData+"oldData="+a.oldData);
				// alert("You are updating ID: " +recordObj.id + " With a new value of " + recordObj.internalLabel + "And the description is " + recordObj.description);
				$.AjaxCFC({
                  url: "/components/products/Group/AttributeManager.cfc", // your CFC
                  method: methodName,
                  data: jsonData,
                  serialization: "json",
                  success: function(result){alert("record updated"); }
				});
			   }
             }
        function getAttributes(type)
        {
        	YAHOO.example.container.wait = 
						new YAHOO.widget.Panel("wait",  
														{ width:"240px", 
														  fixedcenter:true, 
														  close:false, 
														  draggable:false, 
														  modal:false,
														  visible:false,
														  effect:{effect:YAHOO.widget.ContainerEffect.FADE, duration:0.1} 
														} 
													);

				YAHOO.example.container.wait.setHeader("Loading, please wait...");
				YAHOO.example.container.wait.setBody('<img src="/images/initial_loader.gif" />');
				YAHOO.example.container.wait.render(document.body);
				YAHOO.example.container.wait.show();
        	
        	// Define a custom formatter for the "Active" column 
			var activeFormatter = function(elCell, oRecord, oColumn, oData) 
			{ 
	    		if(oRecord["active"]) 
	    		{ 
	        		elCell.innerHTML = "<img src='/images/yes_small.gif' />";
	    		} 
	    		else
	    		{
	    			elCell.innerHTML = "<img src='/images/no_small.gif' />"
	    		}
	    			YAHOO.util.Dom.addClass(elCell.parentNode, "active"); // style the row
			}; 
	
			// Define a custom formatter for the "Search Filter" column
			var searchFormatter = function(elCell, oRecord, oColumn, oData) 
			{
				if (oRecord["search_filter_on"])
				{
					elCell.innerHTML = "Yes";
				}
				else
				{
					elCell.innerHTML = "No";
				}
		   
		  			 YAHOO.util.Dom.addClass(elCell.parentNode, "search_filter_on"); // style the row
			}
        	if (type == 'product')
        	{
        		methodCall = "getAllProductAttributes";
        		var fields = ["product_group_level_id","group_internal_label",
    					 "group_level_desc","created_date","search_filter_on","active"];
    			var colHeaders = [
    			{key:"group_internal_label",text:"BA LABEL", editor:"textbox", sortable:true},
    			{key:"group_level_desc", text:"CLIENT LABEL", editor:"textbox", sortable:true},
    			{key:"created_date", text:"DATE CREATED", sortable:true},
    			{key:"search_filter_on", text:"SEARCH FILTER ON", sortable:false, formatter:searchFormatter},
    			{key:"active", text:"ACTIVE",formatter:activeFormatter}
   			];
        	}
        	else
        	{
        		methodCall = "getAllDistributorAttributes";

        		var fields = ["distributor_group_level_id","group_level_desc_internal",
    					 "group_level_desc","created_date","search_filter_on","active"];
    			var colHeaders = [
    			{key:"group_level_desc_internal",text:"BA LABEL", editor:"textbox", sortable:true},
    			{key:"group_level_desc", text:"CLIENT LABEL", editor:"textbox", sortable:true},
    			{key:"created_date", text:"DATE CREATED", sortable:true},
    			{key:"search_filter_on", text:"SEARCH FILTER ON", sortable:false, formatter:searchFormatter},
    			{key:"active", text:"ACTIVE",formatter:activeFormatter}
   			];
        	}
        $.AjaxCFC({
            url: "/components/products/Group/AttributeManager.cfc", // your CFC
            method: methodCall,
            data: {},
            serialization: "json",
            success: function(r){ 
            document.getElementById("grid-panel").style.visibility = "visible";
            YAHOO.example.container.wait.hide();
            
			

			// Define Column headers to be displayed. Let's you enable sorting, inline editing
			var myColumnHeaders = colHeaders;

			var myColumnSet = new YAHOO.widget.ColumnSet(myColumnHeaders);

			var myDataSource = new YAHOO.util.DataSource(r);
				myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
				myDataSource.responseSchema = {
    			resultsList: "data",
    			fields: fields
    			};

			var myDataTable = new YAHOO.widget.DataTable("grid-panel", myColumnSet, myDataSource);
   			    myDataTable.subscribe("cellClickEvent",myDataTable.onEventEditCell);    	   
    		    myDataTable.subscribe("cellMouseoverEvent",myDataTable.onEventHighlightCell); 
    			myDataTable.subscribe("cellMouseoutEvent",myDataTable.onEventUnhighlightCell);         
    			myDataTable.subscribe("recordSetUpdateEvent", myCellEditEventHandler);   
            }
           }); 
          };
        
</script>
<script SRC="/Script/javascript/string_functions.js"></script>
<div id="wrapper" style="width:100%">
<input type="radio" name="labelview" id="labelview" value="product" checked="true" onclick="getAttributes('product')" />
<label for="product">Product Labels</label>
<input type="radio" name="labelview" id="labelview" value="distributor" onclick="getAttributes('distributor')" />
<label for="distributor">Distributor Labels</label>
<div id="grid-panel" style="visibility:hidden"></div>
</div>
