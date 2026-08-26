<!---------------------------------------------------------------------------------------------------------------------
      Template: C:\Work\base\AwayX\settings\Advanced_Budget\test\importActAdjustments.cfm
      Date:     Aug 22 2012
      Author:   Chris Nguyen
      Purpose:  Create actual adjustments & save in an Excel      
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="lipsum">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eget varius purus. Aliquam nunc nulla, elementum a posuere eget, vulputate et elit. Vestibulum sit amet orci eget mi molestie hendrerit sit amet at ante. In vel lectus justo. Aliquam aliquam augue vel risus iaculis et sollicitudin mauris porta. Aenean adipiscing pretium lorem, accumsan vehicula mauris blandit at. Duis feugiat ultrices nisi ac porttitor. Etiam nisi sem, consectetur et rhoncus eu, pharetra et metus. Nullam varius sem a purus vulputate eu bibendum magna congue. Duis mollis elit nec elit pretium tincidunt aliquet risus euismod. Morbi pulvinar ultricies lacus. Praesent interdum sodales arcu, vel malesuada eros egestas pretium. Donec laoreet malesuada luctus. Maecenas sit amet orci non dui volutpat molestie in sit amet massa. Sed sed vestibulum tellus. Aenean ac tortor massa.
Curabitur ut tortor a velit vehicula bibendum. Curabitur sagittis ante eget sem dapibus quis dictum nunc bibendum. Praesent arcu lorem, convallis a pulvinar ac, vulputate ac ante. Donec vulputate elementum enim vel tincidunt. Mauris ut porta urna. Cras sit amet nulla erat, ut molestie lectus. Etiam eget consequat dui. Morbi interdum neque vitae lectus vestibulum eu rhoncus dolor iaculis. In malesuada egestas risus, posuere lobortis nisl porta ut. Vivamus varius, dolor eget lobortis porttitor, nunc sem lobortis est, blandit tempus elit turpis non nulla. Nulla facilisi. Nullam molestie ornare velit, a iaculis enim mattis eu. In adipiscing sapien quis nibh egestas ultrices.
Vestibulum euismod accumsan convallis. Maecenas dolor nunc, suscipit sed scelerisque ac, rutrum ac libero. Morbi et massa non mauris congue pharetra. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Curabitur erat sapien, sodales in congue nec, scelerisque in elit. Nulla nec nunc id massa dapibus vestibulum. Donec eget leo ante, viverra eleifend dolor. Duis sit amet ante varius justo egestas hendrerit. Mauris purus elit, tempor in elementum ac, cursus vitae nunc. Nunc non sapien a massa lacinia lacinia sit amet rutrum diam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In sed enim erat. Sed pulvinar mauris vel sapien lacinia sollicitudin. Integer vestibulum purus vitae nisi laoreet eu suscipit eros tempor.
In hac habitasse platea dictumst. Phasellus dignissim dapibus nibh, ac adipiscing lorem pulvinar nec. Aliquam lectus ipsum, accumsan nec bibendum at, tincidunt nec lacus. Suspendisse euismod porta enim quis convallis. Fusce nec odio elit, vitae eleifend lacus. Cras tristique, ante a porta rhoncus, erat orci rutrum justo, a molestie enim nulla et mi. Nunc pretium magna orci. Duis ultricies ornare nisl. Pellentesque sit amet nisl eu velit egestas euismod. Sed sem mauris, commodo ac malesuada suscipit, tempus nec augue. Praesent eget tellus libero. Quisque non tristique nisl.
Phasellus et turpis eget turpis aliquam tempus vel sit amet enim. Suspendisse tincidunt vulputate nisl ac laoreet. Duis aliquam congue felis vitae vulputate. Aliquam vel consequat turpis. Nam et lectus mauris. Sed ac lorem tellus, quis tempor ligula. Sed mollis, ligula non vulputate fermentum, nibh ante lobortis elit, in sollicitudin dui sapien in odio. Suspendisse potenti. Sed lacinia tortor commodo dui molestie cursus. Praesent eu nulla eros, et dapibus sem. Nullam vitae libero id sem dictum ullamcorper at a eros. Nulla elementum magna vel mi commodo quis fermentum lectus pellentesque. Donec sit amet ipsum et sem molestie dapibus.</cfsavecontent>
<cfset maxlen = listlen(lipsum, ".")>

<!---gather programs with lump sums--->
<cfquery name="qPrograms" datasource="#application.datasource#">
	SELECT TOP 500 adj_date = Cast( Cast( GetDate() AS INT ) - 5 * Rand( Cast( Cast( NewId() AS BINARY( 8 )) AS INT ) ) AS DATETIME )
	              ,contract_number = RIGHT( cm.Contract_Number, len( cm.Contract_Number ) - 4 )
	              ,lsname.Program_Lump_Sum_Name
	              ,adj_amount = CAST( (CAST(CAST(NEWID() AS VARBINARY) AS int)) % 10000 AS FLOAT) / 3
	  FROM CONTRACT_MAIN cm
	       INNER JOIN PROGRAM_CONTROL_PANEL_OPTIONS t ON cm.ProgramType_Id = t.ProgramControl_Panel_Options_Id
	       INNER JOIN PROGRAM_LUMP_SUMS ls ON ls.Program_Id = cm.Contract_Main_Id
	                                          AND ls.Deleted = 0
	       INNER JOIN PROGRAM_LUMP_SUM_NAME lsname ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
	 WHERE cm.Deleted = 0
	       AND cm.Manual_Cancel = 0
	       AND cm.Approved = 1 
</cfquery>

<cfset QueryAddColumn(qPrograms, "adj_notes", "varchar", arrayNew(1)) />

<cfloop query="qPrograms">
	<cfset qPrograms.adj_notes = listgetat(lipsum, randrange(1,maxlen), ".")>
</cfloop>

<cfdump var="#qPrograms#">

<cfspreadsheet action="write" filename="d:\actAdjustments.xls" query="qPrograms" overwrite=true>