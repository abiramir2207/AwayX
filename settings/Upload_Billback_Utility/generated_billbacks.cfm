<!--- Sub Section Title--->
<cfinclude template="header.cfm" />
<style>
       td.align-right  {
          text-align:right;
      }
	  td.align-center{
	  text-align:center;
	  }
	  
</style>

<cfoutput>
	<br><span class="subheading">Billbacks Created By Batch No: #url.upload_id#</span><img src="/images/clear.gif" height="1px" width="300px">
	<FONT COLOR="Red">[&nbsp;</FONT><a href="##" onclick="javascript:window.open('downloadBBList.cfm?upload_ID=#url.upload_id#&uploadTypeId=#URL.upload_type_id#','Download','450','200');" title="Download the BBs listed below as a csv file "> <b>export</b> </a><FONT COLOR="Red">&nbsp;]</FONT>
	<B><FONT COLOR="Red">[</FONT>&nbsp;<a href="billback_listing_printerfriendly.cfm?upload_id=#url.upload_id#&upload_type_id=#URL.upload_type_id#" target="winBillbackPrntPrvw"><img src="/images/printimg.gif"> printer friendly</a>&nbsp;<FONT COLOR="Red">]</FONT></B><br>
</cfoutput>

<div id="loading" width="700px">
		<img align="center" src="/Images/Animation/images/progress.gif">
</div>
<div id="paginated"></div>
<div id="markup"></div>
<script>

 YAHOO.example.ClientPagination = new function() {

 	     var uploadId = <cfoutput>#url.upload_id#</cfoutput>;
       var uploadTypeId = <cfoutput>#url.upload_type_id#</cfoutput>;
                      $.AjaxCFC({
 	                  url: "/components/billback/billbackUtilityAjax.cfc", // your CFC
 	                  method: "getRelatedBB",
 	                  data: {"upload_id":uploadId,"upload_type_id":uploadTypeId},
 	                  serialization: "json",
 	                  success: function(result){

                       this.columnHeaders = [
											  {key:"deleted",label:"Deleted",sortable:true,formatter:this.formatDelete}, 
 					  		 			      {key:"bb_code",label:"Billback",sortable:true,formatter:this.formatUrl},
										      {key:"bb_title",label:"Title",sortable:true},
											  {key:"bb_reference",label:"Billback Number",sortable:true},
											  {key:"claim_cases",label:"Cases",type:"number",sortable:true, formatter:this.formatCases, className:'align-right'},
											  {key:"bb_amount",label:"Amount",type:"number",sortable:true, formatter:YAHOO.widget.DataTable.formatCurrency, className:'align-right'},
											  {key:"bb_date",label:"Date",type:"date",sortable:true,formatter:YAHOO.widget.DataTable.formatDate, className:'align-center'},
					  		 				  {key:"vendor_id",label:"Vendor ID",sortable:true},
											  {key:"bb_status_abbreviation",label:"Status",sortable:true, className:'align-center'}
					  		 				  ];

                       // this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);

 			     this.myDataSource = new YAHOO.util.DataSource(result);
 				 				this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
 				 				this.myDataSource.responseSchema = {
 				     			resultsList: "data",
 				     			fields: [{key:"billback_id"},
 				     			         {key:"bb_code"},
 				     			         {key:"bb_title"},
 				     			         {key:"bb_reference"},
 				     			         {key:"claim_cases",parser:YAHOO.util.DataSource.parseNumber},
 				     			         {key:"bb_amount"},
 				     			         {key:"bb_date",parser:YAHOO.util.DataSource.parseDate},
 				     			         {key:"vendor_id"},
										 {key:"bb_status_abbreviation"},
										 {key:"deleted"},
										 {key:"deletedbyfullname"},
										 {key:"deleted_date"}
 				     			        ]
     			};


                   var configs = {
				                           paginated:true,
				                           paginator: {
				                           rowsPerPage: 100,
				                           dropdownOptions: [25,50,100,500]
				                           }
                };

 			     var myDataTable = new YAHOO.widget.DataTable("markup", this.columnHeaders, this.myDataSource,configs);

 				 document.all.loading.style.display = "none";
 	            //  document.all.markup.style.display = "";
                 }
 			  });


 	};

        this.formatUrl = function(elCell, oRecord, oColumn, sData)
		{
			elCell.innerHTML = "<a href='/billbacks/capture/bb_preview.cfm?BBID=" + oRecord.getData("billback_id") + "' target='_blank'>" + sData + "</a>";
		}
		

		this.formatCases = function(elCell, oRecord, oColumn, sData)
		{
  			elCell.innerHTML = toCommas(oRecord.getData("claim_cases"))

		}

   		this.formatDelete = function(elCell, oRecord, oColumn, sData)
		{
			 if (sData == '1')
			{
				// elCell.innerHTML = "<img src='/images/no_small.gif' title='Deleted by " + oRecord.getData("deletedbyfullname") + " on " + oRecord.getData("deleted_date") +  "'/>";
				elCell.innerHTML = "<div title='Deleted by " + oRecord.getData("deletedbyfullname") + " on " + oRecord.getData("deleted_date") +  "'><font color='blue'>Y</font></div>";
			}
			else
			{
				elCell.innerHTML = "<div title='Not Deleted'" +  "><font color='blue'>N</font></div>";
			}
		}	

		function toCommas(value) {
    		return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}	
	 
</script>
