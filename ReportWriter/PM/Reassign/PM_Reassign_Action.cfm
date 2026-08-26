<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>
 
<body>

<CFSET UnSuccess = "">
<CFSET UnAvailable = "">

<CFLOOP LIST="#FORM.PM_Item_Master_ID#" INDEX="Item">
	<cfset useLakebaseForIsCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForIsCurrentlyLocked>
	<cftry>
		<cfset IsCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pm_item_master", {
				"pm_item_master_id" = "eq.#Item#",
				"select" = "pm_locked"
			}), "pm_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsCurrentlyLocked>
<CFQUERY NAME="IsCurrentlyLocked" DATASOURCE="#Application.Datasource#">
		SELECT PM_Locked FROM PM_Item_master WHERE PM_Item_Master_ID = '#Item#'
	</CFQUERY>
</cfif>
	
	<CFIF IsCurrentlyLocked.PM_Locked EQ 0>
		
		<cfset useLakebaseForLock_Project = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForLock_Project>
	<cftry>
		<cfset application.oLakebase.updateRows("pm_item_master",
			{
				"pm_item_master_id" = "eq.#Item#"
			},
			{
				"pm_locked" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLock_Project = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLock_Project>
<CFQUERY NAME="Lock_Project" DATASOURCE="#Application.Datasource#">
			UPDATE PM_Item_master
			SET PM_Locked = 1
			WHERE PM_Item_Master_ID = '#Item#'
		</CFQUERY>
</cfif>
		
		<CFQUERY NAME="IsAvailable" DATASOURCE="#Application.Datasource#">
			SELECT * 
			FROM 		PM_ITEM_Master 
			
			WHERE		PM_Item_Master_ID = '#Item#'  						
						<CFIF FORM.From_PM_Sponsor_ID NEQ "">
							AND PM_Sponsor_ID = '#FORM.From_PM_Sponsor_ID#'
						</CFIF>
						<CFIF FORM.From_PM_Far_ID NEQ "">
							AND PM_Far_ID = '#FORM.From_PM_Far_ID#'
						</CFIF>
						<CFIF FORM.From_Owner_Position_ID NEQ "" AND FORM.Update EQ 1>
							AND EXISTS 
							(	SELECT	* 
								FROM 	PM_Owner_Position
								WHERE	User_Positions_ID = '#FORM.From_Owner_Position_ID#' AND PM_Item_Master_ID = '#Item#')
						</CFIF>
		</CFQUERY>
		
		<CFIF IsAvailable.recordcount GT 0>
			<CFIF FORM.To_PM_Sponsor_ID NEQ "">
				<cfset useLakebaseForUpdate_Sponsor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForUpdate_Sponsor>
	<cftry>
		<cfset application.oLakebase.updateRows("pm_item_master",
			{
				"pm_item_master_id" = "eq.#Item#"
			},
			{
				"pm_sponsor_id" = "#FORM.To_PM_Sponsor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Sponsor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Sponsor>
<CFQUERY NAME="Update_Sponsor" DATASOURCE="#Application.Datasource#">
					UPDATE 		PM_Item_master
					SET 		PM_Sponsor_ID = '#FORM.To_PM_Sponsor_ID#'
					
					WHERE 		PM_Item_Master_ID = '#Item#' 												
				</CFQUERY>
</cfif>				
			</CFIF>
	
			<CFIF FORM.To_PM_Far_ID NEQ "">
				<cfset useLakebaseForUpdate_FAR = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForUpdate_FAR>
	<cftry>
		<cfset application.oLakebase.updateRows("pm_item_master",
			{
				"pm_item_master_id" = "eq.#Item#"
			},
			{
				"pm_far_id" = "#FORM.To_PM_Far_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_FAR = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_FAR>
<CFQUERY NAME="Update_FAR" DATASOURCE="#Application.Datasource#">					
					UPDATE 		PM_Item_master
					SET 		PM_Far_ID = '#FORM.To_PM_Far_ID#'
					
					WHERE 		PM_Item_Master_ID = '#Item#'					
				</CFQUERY>
</cfif> 
				
			</CFIF>
			
	
			<CFIF FORM.To_Owner_Position_ID NEQ "">
				<cfset useLakebaseForIsExist_Already = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_owner_position")>
<cfif useLakebaseForIsExist_Already>
	<cftry>
		<cfset IsExist_Already = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pm_owner_position", {
				"pm_item_master_id" = "eq.#Item#",
				"user_positions_id" = "eq.#FORM.To_Owner_Position_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsExist_Already = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsExist_Already>
<CFQUERY NAME="IsExist_Already" DATASOURCE="#Application.Datasource#">					
					SELECT 	* 
					FROM 	PM_Owner_Position 
					
					WHERE 	PM_Item_Master_ID = '#Item#' AND  
							User_Positions_ID = '#FORM.To_Owner_Position_ID#'
				</CFQUERY>
</cfif>
			</CFIF>		
			
			
			
			<CFIF FORM.From_Owner_Position_ID NEQ "" AND FORM.To_Owner_Position_ID NEQ "">						
				<CFIF IsExist_Already.recordcount GT 0>
					<CFIF FORM.UPDATE EQ 1>				 
						<CFQUERY NAME="Update_Owner" DATASOURCE="#Application.Datasource#">							
							DELETE FROM PM_Owner_Position
							WHERE PM_Item_Master_ID = '#Item#' AND 
							User_Positions_ID = '#FORM.From_Owner_Position_ID#'								
						</CFQUERY>
					</CFIF>				
				<CFELSE>
					<CFIF FORM.UPDATE EQ 1>		
						<CFQUERY NAME="Update_Owner" DATASOURCE="#Application.Datasource#">							
							UPDATE 		PM_Owner_Position
							SET 		User_Positions_ID = '#FORM.To_Owner_Position_ID#'
							
							WHERE 		PM_Item_Master_ID = '#Item#' AND  
										User_Positions_ID = '#FORM.From_Owner_Position_ID#'								
						</CFQUERY>
					<CFELSEIF FORM.UPDATE EQ 0>
						<cfset useLakebaseForAdd_New_Owner = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_owner_position")>
<cfif useLakebaseForAdd_New_Owner>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_owner_position", {
			"pm_item_master_id" = "#Item#",
			"user_positions_id" = "#FORM.To_Owner_Position_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForAdd_New_Owner = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAdd_New_Owner>
<CFQUERY NAME="Add_New_Owner" DATASOURCE="#Application.Datasource#">
							INSERT INTO PM_Owner_Position (PM_Item_Master_ID,User_Positions_ID) 
							VALUES ('#Item#',#FORM.To_Owner_Position_ID#)	
						</CFQUERY>
</cfif>
					</CFIF>
				</CFIF>
			<CFELSEIF FORM.From_Owner_Position_ID EQ "" AND FORM.To_Owner_Position_ID NEQ "">	
				<CFIF IsExist_Already.recordcount EQ 0>						
					<CFQUERY NAME="Add_New_Owner" DATASOURCE="#Application.Datasource#">
						INSERT INTO PM_Owner_Position (PM_Item_Master_ID,User_Positions_ID) 
						VALUES ('#Item#',#FORM.To_Owner_Position_ID#)
					</CFQUERY>
				</CFIF>
			</CFIF>
			<CFQUERY NAME="Lock_Project" DATASOURCE="#Application.Datasource#">
				UPDATE PM_Item_master
				SET PM_Locked = 0
				WHERE PM_Item_Master_ID = '#Item#'
			</CFQUERY> 
		<CFELSE>	
			<CFSET UnAvailable = "#UnAvailable#,#Item#">
		</CFIF>
	
	<CFELSE>
		<CFSET UnSuccess = "#UnSuccess#,#Item#">  
	</CFIF>			
</CFLOOP>

<CFIF UnSuccess EQ "" AND UnAvailable EQ "">
<BR><BR><BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><FONT COLOR="Red" SIZE="3"><B>Please wait while projects are being reassigned...</B></FONT></TD>
	</TR>
</TABLE>
<CFELSEIF UnSuccess NEQ "">
	<CFSET UnSuccess = ListQualify(UnSuccess,"'",",","All")>
	<CFOUTPUT>
	<CFQUERY NAME="Unsuccess_Title" DATASOURCE="#Application.Datasource#">
		SELECT PM_Acct_Project from PM_Item_Master WHERE Pm_Item_Master_ID IN (#PreserveSingleQuotes(UnSuccess)#)
	</CFQUERY>
	<CFSET Unsuccess_Reassign = ValueList(Unsuccess_Title.PM_Acct_Project,",")> 
	</CFOUTPUT>
<CFELSEIF UnAvailable NEQ "">
	<CFSET UnAvailable = ListQualify(UnAvailable,"'",",","All")>
	<CFOUTPUT>
	<CFQUERY NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
		SELECT PM_Acct_Project from PM_Item_Master WHERE Pm_Item_Master_ID IN (#PreserveSingleQuotes(UnAvailable)#)
	</CFQUERY>
	<CFSET UnAvailable_Reassign = ValueList(Unavailable_Title.PM_Acct_Project,",")> 
	</CFOUTPUT>
</CFIF>

<SCRIPT language="JavaScript">
function Relocate()
{
	window.location.href = "PM_Reassign.cfm";
}
<CFIF UnAvailable NEQ "">
	var unAvai = "<CFOUTPUT>#UnAvailable_Reassign#</CFOUTPUT>";
	alert("Project(s) [" + unAvai + "] can't be reassigned (These projects are not available in the given source).");
	window.setTimeout('Relocate()', 0);
</CFIF>
<CFIF UnSuccess EQ "">
	window.setTimeout('Relocate()', 3000);
<CFELSE>
	var unSucc = "<CFOUTPUT>#Unsuccess_Reassign#</CFOUTPUT>";
	alert("Project(s) [" + unSucc + "] can't be reassigned (This project is currently locked by someother user).");
	window.setTimeout('Relocate()', 0);
</CFIF>
</SCRIPT>


</body>
</html>
