
<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
<cfset BudgetManager.loadBudgetLabels() />
<cfset qGetBudgetSummaryReport = BudgetManager.getBudgetSummaryReport() />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Budget Summary Report</title>
	
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	
	<!--- Note: Include of Yahoo UI Js & CSS libraries --->
	<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/reset/reset.css">
	<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/fonts/fonts.css">
	<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/logger/assets/logger.css">
	<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/datatable/assets/datatable.css">
	<script type="text/javascript" src="/script/javascript/yui_2_2_0/yahoo/yahoo.js"></script>
	<script type="text/javascript" src="/script/javascript/yui_2_2_0/dom/dom.js"></script>
	<script type="text/javascript" src="/script/javascript/yui_2_2_0/event/event.js"></script>
	<script type="text/javascript" src="/script/javascript/yui_2_2_0/datasource/datasource-beta.js"></script>
	<script type="text/javascript" src="/script/javascript/yui_2_2_0/datatable/datatable-beta.js"></script>
	<script type="text/javascript" src="/script/javascript/yui_2_2_0/logger/logger.js"></script>
	
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<style type="text/css">   
		#mainContent table {border-collapse:collapse;border:1px solid RGB(0,0,0);width:820px;}   
		#mainContent tbody td {border:1px solid RGB(210,210,210);padding:3px;color:black;}   
		#mainContent thead td {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:center;vertical-align:bottom;padding-left:2px;color:black}
		#mainContent thead th {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:left;vertical-align:bottom;padding-left:2px;color:black}
		#mainContent thead th a {color:RGB(0,0,0);} 
		#mainContent tbody td.error {border: 3px solid RGB(255,75,75);font-weight:bold;}
	
		#markup {margin:.25em;}
		#markup table {border-collapse:collapse;border:1px solid RGB(0,0,0);width:820px}
		#markup tbody td {border:1px solid RGB(210,210,210);padding:3px;color:black;}
		#markup thead th {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:center;vertical-align:bottom;padding:2px;color:black}
		/*#markup thead th a {color:RGB(0,0,0);text-decoration:underline;} */
		#markup .yui-dt-odd {background-color:rgb(225,255,225);} /*light green*/
		#markup .yui-dt-highlight {background-color:rgb(204,204,255);}
		
		#markup .yui-dt-sortedbyasc {background-position: center right;background-image:url(/images/down_1.gif);background-repeat:no-repeat}
		#markup .yui-dt-sortedbydesc {background-position: center right;background-image:url(/images/up_1.gif);background-repeat:no-repeat}
		
		body 	{padding-left:5px;}
		thead 	{display: table-header-group;}
		
		A.tablink_back, A:Hover.tablink_back
			{
				font-family:		Arial;
				font-size :			11px; 
				font-weight:		bold;
				text-decoration:	none;
			}
		A:visited.tablink_back /* Main Color */
			{
				font-family:		Arial;
				font-size :			11px; 
				font-weight:		bold;
				text-decoration:	none;
				color: 				blue;
			}
		A.tablink_fore
			{
				color: 				black;
				font-family:		Arial;
				font-size :			11px; 
				font-weight:		bold;
				text-decoration:	none;
			}
		A:visited.tablink_fore
			{
				color: 				black;
				font-family:		Arial;
				font-size :			11px; 
				font-weight:		bold;
				text-decoration:	none;
			}
			
			.subheading
			{
					font-weight:bold;
					font-size:12px;
					text-decoration:underline;
					
			}
		  .formLabel
			{
				font-weight:bold;
				width:170px;
				display:inline;
			}	
			
		  TD.headernotselected
		  {
		   background-color 	: dddddd;
		   border-bottom		: solid 1px black;
		   cursor				: pointer;	
		   color				: Black;   
		  }
		  TD.headerselected
		  {   
		   color				: black;
		   border-left			: solid 3px black;
		   border-top			: solid 3px black;
		   border-right			: solid 3px black;
		   padding-left			: 3px;		
		   padding-right		: 3px;
		   background-color 	: RGB(255,204,120);
		   cursor				: pointer;	
		   TEXT-TRANSFORM		: uppercase;
		  }
		  TD.headerblank
		  {
		   border-bottom		: solid 1px black;
		  }
		  TD.headerspacer
		  {
		   border-bottom		: solid 1px black;
		  }
		  TD.headerlastone
		  {
		   border-left			: solid 1px black;
		  }
	</style>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

 <style type="text/css">
	.heading{ 	
		font-family: verdana,arial,helvetica; font-size: 11px;font-weight: bold;background: #FFB062;
		}
	.PageContent{ 		
		font-family:Verdana, Arial, Helvetica, sans-serif;font-size:9px;
		}
	TD.UNDERLINED{		
		border-bottom: 1px solid #7575FF;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;
		}
	TR.highlight TD.UNDERLINED{		
		background-color: #EAFFEA;
		}
	TR.nothighlight TD.UNDERLINED{  
		border-bottom: 1px solid #7575FF;
		}
	</style>
	
<div align="Center" class="labelname">Budget Summary Report</div>

<br>
<div id="loading" width="700px" align="center">
		<img align="center" src="/Images/Animation/images/progress.gif">
</div>
<div id="markup" align="center">
<table align="center" class="PageContent" border="0" cellspacing="0">
	<thead>
	<cfoutput>
	<tr>
		<td>Class</td>
		<td>Budget</td>
		<td>#BudgetManager.getBudgetClassAssociationLabel()#</td>
		<td>Position</td>
		<td>#BudgetManager.getBudgetDollarLabel()#</td>
		<td>#BudgetManager.getCommittedDollarLabel()#</td>
		<td>#BudgetManager.getBudgetBalanceLabel()#</td>
		<td>#BudgetManager.getApprovedPaymentDollarLabel()#</td>
		<td>Available #BudgetManager.getBudgetDollarLabel()#</td>
	</tr>
	</cfoutput>
	</thead>
	<tbody>
	<cfoutput query="qGetBudgetSummaryReport">
	<cfset BudgetBalance = Sum_Budget_Dollar - Sum_Committed_Dollar />
	<cfset AvailableBudgetDollar = Sum_Budget_Dollar - Sum_Actual_Dollar />
	<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<td>#Simple_Budget_Class_Number# #Simple_Budget_Class_Desc#</td>
		<td>#Simple_Budget_Number# #Simple_Budget_Desc#</td>
		<td>#Simple_Budget_Class_Association_Number#</td>
		<td>#Position_Label#</td>
		<td>$#Sum_Budget_Dollar#</td>
		<td>$#Sum_Committed_Dollar#</td>		
		<td>$#BudgetBalance#</td>
		<td>$#Sum_Actual_Dollar#</td>		
		<td>$#AvailableBudgetDollar#</td>
	</tr>
	</cfoutput>
	</tbody>
</table>
</div>

<script type="text/javascript" language="JavaScript">
	YAHOO.widget.Column.formatCurrency = function(elCell, oRecord, oColumn, oData) {   
     elCell.style.color = "";
     var nAmount = oData;
     var markup;   
         if(nAmount) {   
              markup = formatDollar(nAmount, 2, 1, 3)
			  if(nAmount < 0)
			  {
			  	elCell.style.color = "red";
			  }
         }   
         else {   
             markup = "$0.00";   
         }
		 elCell.align = "right";
         elCell.innerHTML = markup;   
	}
	
	YAHOO.example.enhanceFromMarkup = function() {   
   	<cfoutput>
    this.columnHeaders = [   
         {key:"class",text:"Class",width:"300px",sortable:true},
         {key:"budget",text:"Budget",width:"300px",sortable:true},   
         {key:"budgetClassAssociation",text:"#BudgetManager.getBudgetClassAssociationLabel()#",width:"300px",sortable:true},
		 {key:"Position",text:"Position",width:"300px",sortable:true},   
         {key:"budgetDollar",text:"#BudgetManager.getBudgetDollarLabel()#",type:"currency",width:"150px",sortable:true}, 
         {key:"committedDollar",text:"#BudgetManager.getCommittedDollarLabel()#",type:"currency",width:"150px",sortable:true},   
         {key:"budgetBalance",text:"#BudgetManager.getBudgetBalanceLabel()#",type:"currency",width:"150px",sortable:true},
         {key:"actualDollar",text:"#BudgetManager.getApprovedPaymentDollarLabel()#",type:"currency",width:"150px",sortable:true},   
         {key:"availablebudgetDollar",text:"Available #BudgetManager.getBudgetDollarLabel()#",type:"currency",width:"150px",sortable:true}
    ];   
	</cfoutput>
     this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);   

     var markup = YAHOO.util.Dom.get("markup");   
     this.dataTable = new YAHOO.widget.DataTable(markup,this.columnSet,null);
	 
	 document.all.loading.style.display = "none";
	 document.all.markup.style.display = "";  
	 
	 var col0 = document.getElementById("yui-dtcol0");
	 if(col0)
	 {
	 	this.dataTable.sortedBy = {};
		this.dataTable.sortedBy.colKey = "budget";
       	this.dataTable.sortedBy.dir = "asc";
        this.dataTable.sortedBy._id = "yui-dtcol0";
		col0.className = "yui-dt-sortedbyasc";		
	 }
 	};   
   
	YAHOO.util.Event.onAvailable("markup",YAHOO.example.enhanceFromMarkup,YAHOO.example.enhanceFromMarkup,true);   
	
	
</script>

</body>
</html>
