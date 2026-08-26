<cfcomponent>

	<cfproperty name="User_Positions_Id" type="numeric" default="0">
	<cfproperty name="positionLabel" type="string" default="">
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.User_Positions_Id = 0;
		this.positionLabel =  "";
	</cfscript>
	
</cfcomponent>