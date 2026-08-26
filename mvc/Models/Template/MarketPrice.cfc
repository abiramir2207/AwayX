<cfcomponent displayname="MarketPrice">

	<cfproperty name="Market_Price_List_Id" type="numeric" default="0">
	<cfproperty name="Template_Filters_Id" type="numeric" default="0">
	<cfproperty name="Start_Date" type="date"  default="">
	<cfproperty name="End_Date" type="date"  default="">
	<cfproperty name="Status" type="numeric" default="0">
	<cfproperty name="CreatedUserId" type="guid">
	<cfproperty name="UpdatedUserId" type="guid">
	<cfproperty name="UpdatedUserName" type="string">
	<cfproperty name="UpdatedDate" type="date"  default="#Now()#">
	<!--- array of ProdRate Obj's --->
	<cfproperty name="arrProdRate" type="array">
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.Market_Price_List_Id = 0;
		this.Template_Filters_Id = 0;
		this.Start_Date = "";
		this.End_Date = "";
		this.Status =  "";
		this.CreatedUserId = "";
		this.UpdatedUserName = "";
		this.UpdatedDate = now();
		this.arrProdRate = arrayNew(1);
	</cfscript>

	<cffunction name="init" output="false" >
		<cfreturn this>
	</cffunction>

	<cffunction name="z" hint="func">
			<cfargument name="x" type="string" required="true"/>
			
	</cffunction>


</cfcomponent>