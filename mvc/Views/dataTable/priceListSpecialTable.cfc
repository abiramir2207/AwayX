<cfcomponent displayname="mvc.Views.dataTable.priceListSpecialTable.cfc">
	<cffunction name="getAttrs" returntype="Struct" >
		<cfscript>
			var attrs   		= structnew();
			
			attrs = createObject('component','mvc.Views.pm.dataTableAttrs');
			//required
			attrs.setArrColumns(["H.Ship_To","H.Description","H.Created_Date","Item_Number","Unit_Of_Measure","D.Fob_Indicator"]);
			attrs.setSqlData("SELECT replace(Price_List_Detail_Special_Id,'-','') AS Price_List_Detail_Special_Id, H.Ship_To,H.Description,H.Created_Date,Item_Number,Price,Unit_Of_Measure,D.Fob_Indicator FROM Price_List_Header_Special H Join Price_List_Detail_Special D ON D.Price_List_Header_Special_Id = H.Price_List_Header_Special_Id");//query to get data.  needs same columns as arrColumns
			attrs.setSqlCount("SELECT count(1) rownbr FROM Price_List_Header_Special H Join Price_List_Detail_Special D ON D.Price_List_Header_Special_Id = H.Price_List_Header_Special_Id");//replace colnames with "count(1) rownbr"
			attrs.setsIdColumn('Price_List_Detail_Special_Id');
			//required end
			attrs.setArrColumnDesc(["Ship To","Description","Created Date","Item","UOM","Fob Indicator"]);//Defaults TO setArrColumns
			attrs.setArrSearchField(["H.Ship_To","H.Description","Item_Number","Unit_Of_Measure","D.Fob_Indicator"]);//Defaults TO setArrColumns
			attrs.setArrSort(["H.Ship_To","H.Description","H.Created_Date","Item_Number","Unit_Of_Measure","D.Fob_Indicator"]);
			//attrs.setArrVisible(["ZipCode"]);  
			attrs.setbSingleSelect(1);
			attrs.setiDisplayLength(100);
			attrs.setsPaginationType('full_numbers');

			return attrs;
		</cfscript>
		
	</cffunction>
</cfcomponent>