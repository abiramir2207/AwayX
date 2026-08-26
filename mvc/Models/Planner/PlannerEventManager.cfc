<!------------------------------------------------------------------------------------------------------------------------------
Name         :  PlannerEventManager.cfc
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  2017 October
Created By   :  KAL
Description  :  Manager for Planners
------------------------------------------------------------------------------------------------------------------------------->

<cfcomponent name="PlannerManager" displayname="PlannerManager" hint="Manager for Planner Settings">

	<cfset this.PlannerSearchManager = CreateObject("component", "mvc.Models.Planner.PlannerSearchManager") />
	<cfset this.appSettings          = this.PlannerSearchManager.appSettings />
	<cfset this.positionsBelowMe     = this.PlannerSearchManager.getPositionsBelowMe() />
	<cfset this.UserPositionList     = this.PlannerSearchManager.UserPositionList />

 	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="init" output="false" returntype="mvc.models.planner.PlannerSearchManager">
		<cfreturn this />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getEventTypes" output="false">
		<cfargument name="rowid" required="false">

		<cfquery name="local.qEventTypes" datasource="#application.datasource#">
			SELECT pet.Planner_Event_Type_ID,
				   pet.Title,
				   pet.Position,
				   pet.Customer,
				   pet.Product,
				   pet.Discount,
				   pet.Document,
				   pet.Color,
				   pet.Created_Date,
				   pet.Updated_Date,
				   u1.Name_First + ' ' + u1.Name_Last AS created_by,
				   u2.Name_First + ' ' + u2.Name_Last AS updated_by
			  FROM Planner_Event_Type pet
			  LEFT JOIN dbo._Users u1
				ON u1.User_ID = pet.Created_By
			  LEFT JOIN dbo._Users u2
				ON u2.User_ID = pet.Updated_By
			 WHERE pet.Deleted = 0
					<cfif structKeyExists(arguments, "rowid")>
						AND pet.Planner_Event_Type_ID = <cfqueryparam value="#arguments.rowid#">
					</cfif>
		</cfquery>

		<cfreturn local.qEventTypes>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="deleteEventType" output="false">
		<cfargument name="rowid" required="true">

		<cfquery name="local.qEventType" datasource="#application.datasource#">
			UPDATE Planner_Event_Type
			   SET Deleted = 1
			 WHERE Planner_Event_Type_ID = <cfqueryparam value="#arguments.rowid#">
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="updateEventType" output="false">
		<cfargument name="form" required="true">

		<cfscript>
			param name="arguments.form.positions" default="";
			param name="arguments.form.customers" default="";
			param name="arguments.form.products"  default="";
			param name="arguments.form.discounts" default="";
			param name="arguments.form.documents" default="";
		</cfscript>

		<cfquery name="local.qEventType" datasource="#application.datasource#">
			<cfif arguments.form.rowid eq "">
				INSERT INTO Planner_Event_Type
					( Title, Position, Customer, Product, Discount, Document, Color, Created_By )
				VALUES
					(	<cfqueryparam value="#arguments.form.event_title#">,
						<cfqueryparam value="#( arguments.form.positions eq 'on' ? 1 : 0 )#">,
						<cfqueryparam value="#( arguments.form.customers eq 'on' ? 1 : 0 )#">,
						<cfqueryparam value="#( arguments.form.products  eq 'on' ? 1 : 0 )#">,
						<cfqueryparam value="#( arguments.form.discounts eq 'on' ? 1 : 0 )#">,
						<cfqueryparam value="#( arguments.form.documents eq 'on' ? 1 : 0 )#">,
						<cfqueryparam value="#arguments.form.color#">,
						<cfqueryparam value="#request.AccessStructure.user_id#">
					)
			<cfelse>
				UPDATE Planner_Event_Type
				   SET Title    = <cfqueryparam value="#arguments.form.event_title#">,
					   Position = <cfqueryparam value="#( arguments.form.positions eq 'on' ? 1 : 0 )#">,
					   Customer = <cfqueryparam value="#( arguments.form.customers eq 'on' ? 1 : 0 )#">,
					   Product  = <cfqueryparam value="#( arguments.form.products  eq 'on' ? 1 : 0 )#">,
					   Discount = <cfqueryparam value="#( arguments.form.discounts eq 'on' ? 1 : 0 )#">,
					   Document = <cfqueryparam value="#( arguments.form.documents eq 'on' ? 1 : 0 )#">,
					   Color    = <cfqueryparam value="#arguments.form.color#">,
					   Updated_By = <cfqueryparam value="#request.AccessStructure.user_id#">,
					   Updated_Date = GETDATE()
				 WHERE Planner_Event_Type_ID = <cfqueryparam value="#arguments.form.rowid#">
			</cfif>
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getFiscalYear" output="false">
		<cfargument name="fiscalYear" type="string" required="false" default="" />
		<cfargument name="fiscalDate" type="date" required="false" default="1/1/1970" />

		<cfset var qGetFiscalYears = "" />
		<cfquery name="qGetFiscalYears" datasource="#application.datasource#">
			SELECT 	Fiscal_Year, Start_Date, End_Date
			FROM 	V_Fiscal_Year_List
			<cfif arguments.fiscalYear neq "">
			WHERE Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" />
			</cfif>
			<cfif arguments.fiscalDate neq "1/1/1970">
			WHERE   <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.fiscalDate#" />
					BETWEEN Start_Date AND End_Date
			</cfif>
			ORDER BY Fiscal_Year
		</cfquery>

		<cfreturn qGetFiscalYears />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getEvents" output="false">
		<cfargument name="rowid" required="false" default="" >

		<cfquery name="local.qEvents" datasource="#application.datasource#">
			SELECT 	pe.planner_event_id,
					pe.planner_event_type_id,
					pe.event_title,
					pe.fiscal_year,
					pe.event_start,
					pe.event_end,
					pe.discount_info,
					pe.document_info,
					pe.active,
					pet.title,
					pet.position,
					pet.customer,
					pet.product,
					pet.discount,
					pet.document,
					ISNULL(pe.updated_date, pe.created_date) AS Updated_Date,
					u.name_first + ' ' + u.name_last         AS Updated_By,
					isnull((select top 1 1 from Planner_Event_Positions t where t.planner_event_id = pe.planner_event_id), 0) as Event_Has_Positions,
					isnull((select top 1 1 from Planner_Event_Distributors t where t.planner_event_id = pe.planner_event_id), 0) as Event_Has_Distributors,
					isnull((select top 1 1 from Planner_Event_Products t where t.planner_event_id = pe.planner_event_id), 0) as Event_Has_Products,
					isnull((select top 1 1 from Planner_Event_Documents t where t.planner_event_id = pe.planner_event_id), 0) as Event_Has_Documents
			FROM   planner_event pe
				   INNER JOIN planner_event_type pet
						   ON pe.planner_event_type_id = pet.planner_event_type_id
							  AND pet.deleted = 0
				   LEFT JOIN dbo._users u
						  ON u.user_id = ISNULL(pe.updated_by, pe.created_by)
			WHERE  pe.deleted = 0
			<cfif len(arguments.rowid)>
				AND pe.Planner_Event_ID = <cfqueryparam value="#arguments.rowid#">
			</cfif>
		</cfquery>

		<cfreturn local.qEvents>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="deleteEvent" output="false">
		<cfargument name="rowid" required="true">

		<cfquery name="local.qEvent" datasource="#application.datasource#">
			UPDATE Planner_Event
			   SET Deleted = 1
			 WHERE Planner_Event_ID = <cfqueryparam value="#arguments.rowid#">
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="activateEvent" output="false">
		<cfargument name="rowid" required="true">

		<cfquery name="local.qEvent" datasource="#application.datasource#">
			UPDATE Planner_Event
			   SET Active = 1
			 WHERE Planner_Event_ID = <cfqueryparam value="#arguments.rowid#">
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="deactivateEvent" output="false">
		<cfargument name="rowid" required="true">

		<cfquery name="local.qEvent" datasource="#application.datasource#">
			UPDATE Planner_Event
			   SET Active = 0
			 WHERE Planner_Event_ID = <cfqueryparam value="#arguments.rowid#">
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="updateEvent" output="false">
		<cfargument name="form" required="true">

		<cfscript>
			param name="arguments.form.event_title"           default="";
			param name="arguments.form.fiscal_year"           default="";
			param name="arguments.form.event_start"           default="";
			param name="arguments.form.event_end"             default="";
			param name="arguments.form.discount_info"         default="";
			param name="arguments.form.document_info"        default="";
			param name="arguments.form.planner_event_id"      default="";
			param name="arguments.form.planner_event_type_id" default="";
			param name="arguments.form.copy_from_event_id" 		default="";
		</cfscript>

		<cfquery name="local.qEvent" datasource="#application.datasource#">
			<cfif arguments.form.rowid eq "">
				INSERT INTO Planner_Event
					( Planner_Event_Type_ID, Event_Title, Fiscal_Year, Event_Start, Event_End, Discount_Info, Created_By )
				Output Inserted.Planner_Event_ID
				VALUES
					(	<cfqueryparam value="#arguments.form.planner_event_type_id#">,
						<cfqueryparam value="#arguments.form.event_title#">,
						<cfqueryparam value="#arguments.form.fiscal_year#">,
						<cfqueryparam value="#arguments.form.event_start#">,
						<cfqueryparam value="#arguments.form.event_end#">,
						<cfqueryparam value="#arguments.form.discount_info#">,
						<cfqueryparam value="#request.AccessStructure.user_id#">
					)
			<cfelse>
				UPDATE Planner_Event
				   SET  Event_Title = <cfqueryparam value="#arguments.form.event_title#" >,
						Fiscal_Year = <cfqueryparam value="#arguments.form.fiscal_year#" >,
						Event_Start = <cfqueryparam value="#arguments.form.event_start#" >,
						Event_End = <cfqueryparam value="#arguments.form.event_end#" >,
						Discount_Info = <cfqueryparam value="#arguments.form.discount_info#" >,
					   Updated_By = <cfqueryparam value="#request.AccessStructure.user_id#">,
					   Updated_Date = GETDATE()
				 WHERE Planner_Event_ID = <cfqueryparam value="#arguments.form.rowid#">
			</cfif>
		</cfquery>

		<cfif arguments.form.rowid eq "" and arguments.form.copy_from_event_id neq "">
			<cfquery name="local.qCopyEvent" datasource="#application.datasource#">
				<!--- Copy geography --->
				insert into Planner_Event_Positions (Planner_Event_ID, User_Position_ID)
				SELECT	#local.qEvent.planner_event_id# as Planner_Event_ID, User_Position_ID
				FROM	Planner_Event_Positions
				WHERE	Planner_Event_ID = <cfqueryparam value="#arguments.form.copy_from_event_id#">

				<!--- Copy distributors --->
				insert into Planner_Event_Distributors (Planner_Event_ID, Distributor_Group_Level_ID, Distributor_Group_ID)
				SELECT	#local.qEvent.planner_event_id# as Planner_Event_ID, Distributor_Group_Level_ID, Distributor_Group_ID
				FROM	Planner_Event_Distributors
				WHERE	Planner_Event_ID = <cfqueryparam value="#arguments.form.copy_from_event_id#">

				<!--- Copy products --->
				insert into Planner_Event_Products (Planner_Event_ID, Product_Group_Level_ID, Product_Group_ID)
				SELECT	#local.qEvent.planner_event_id# as Planner_Event_ID, Product_Group_Level_ID, Product_Group_ID
				FROM	Planner_Event_Products
				WHERE	Planner_Event_ID = <cfqueryparam value="#arguments.form.copy_from_event_id#">

				<!--- Copy documents --->
				insert into Planner_Event_Documents (Planner_Event_ID, Doc_ID)
				SELECT	#local.qEvent.planner_event_id# as Planner_Event_ID, Doc_ID
				FROM	Planner_Event_Documents
				WHERE	Planner_Event_ID = <cfqueryparam value="#arguments.form.copy_from_event_id#">

			</cfquery>
		</cfif>


		<cfif arguments.form.rowid eq "">
			<cfreturn local.qEvent.planner_event_id />
		<cfelse>
			<cfreturn arguments.form.rowid />
		</cfif>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerEventPositions" access="public" returntype="query" output="no" hint="Gets consumer event positions">
		<cfargument name="plannerEventId" required="true" type="numeric" />

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT	ep.Planner_Event_ID, up.User_Positions_ID, up.Position_Label,
					CASE
					WHEN up.Service_Market_ID IS NOT NULL THEN 3
					WHEN up.Service_Region_ID IS NOT NULL THEN 2
					WHEN up.Service_Zone_ID IS NOT NULL THEN 1
					ELSE 0
					END as Position_Type,
					CASE
					WHEN up.Service_Market_ID IS NOT NULL THEN '#application.returned_customer_setting.market_label_singular#'
					WHEN up.Service_Region_ID IS NOT NULL THEN '#application.returned_customer_setting.region_label_singular#'
					WHEN up.Service_Zone_ID IS NOT NULL THEN '#application.returned_customer_setting.zone_label_singular#'
					ELSE 'Headquarters'
					END as Position_Type_Desc,
					CASE
					WHEN up.Service_Market_ID IS NOT NULL THEN m.Market_Number
					WHEN up.Service_Region_ID IS NOT NULL THEN r.Region_Number
					WHEN up.Service_Zone_ID IS NOT NULL THEN z.Zone_Number
					ELSE 'HQ'
					END as Position_ID
			FROM	Planner_Event_Positions ep
			INNER JOIN User_Positions up
			ON		up.User_Positions_ID = ep.User_position_ID
			LEFT JOIN Service_Zones z
			ON		z.Service_Zone_ID = up.Service_Zone_ID
			LEFT JOIN Service_Regions r
			ON		r.Service_Region_ID = up.Service_Region_ID
			LEFT JOIN Service_Markets m
			ON		m.Service_Market_ID = up.Service_Market_ID
			WHERE	ep.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			ORDER BY Position_Type, Position_Label
		</cfquery>

		<cfreturn local.query />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerEventDistributors" access="public" returntype="query" output="no" hint="Gets consumer event distributors">
		<cfargument name="plannerEventId" required="true" type="numeric" />

		<cfscript>

			if (! structKeyExists(request, "planner_labels")) {
				labelManager		= createObject( "component", "components.settings.Labels.Labels" ).init();
				request.planner_labels	= labelManager.plannerLabels();
			}

		</cfscript>

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT	c.Shr_Ship_To as Distributor, c.Name as Distributor_Name, '#request.planner_labels.distributor_singular#' as Record_Type,
					ed.Distributor_Group_ID as Distributor_GUID, ed.Distributor_Group_Level_ID
			FROM	Planner_Event_Distributors ed
			inner join BSA_Foodservice_Customers c
			on		c.BSA_Foodservice_Customers_ID = ed.Distributor_Group_ID
			WHERE	ed.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			and		ed.Distributor_Group_Level_ID = 0
			union
			SELECT	c.Group_Number as Distributor, c.Group_Desc as Distributor_Name, l.Group_Level_Desc as Record_Type,
					ed.Distributor_Group_ID as Distributor_GUID, ed.Distributor_Group_Level_ID
			FROM	Planner_Event_Distributors ed
			inner join Distributor_Group_Level l
			on		l.Distributor_Group_Level_ID = ed.Distributor_Group_Level_ID
			inner join All_Customer_Group_Types c
			on		c.Group_GUID = ed.Distributor_Group_ID
			WHERE	ed.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			and		ed.Distributor_Group_Level_ID != 0
			Order By ed.Distributor_Group_Level_ID Desc, Record_Type, Distributor_Name
		</cfquery>

		<cfreturn local.query />

	</cffunction>


	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerEventProducts" access="public" returntype="query" output="no" hint="Gets consumer event products">
		<cfargument name="plannerEventId" required="true" type="numeric" />

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT	i.Item as Product, i.Description as Product_Name, 'Product' as Record_Type,
					ed.Product_Group_ID as Product_GUID, ed.Product_Group_Level_ID
			FROM	Planner_Event_Products ed
			inner join BSA_Foodservice_Items_Master i
			on		i.BSA_Foodservice_Items_Master_ID = ed.Product_Group_ID
			WHERE	ed.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			and		ed.Product_Group_Level_ID = 0
			union
			SELECT	i.Group_Number as Product, i.Group_Desc as Product_Name, l.Group_Level_Desc as Record_Type,
					ed.Product_Group_ID as Product_GUID, ed.Product_Group_Level_ID
			FROM	Planner_Event_Products ed
			inner join Product_Group_Level l
			on		l.Product_Group_Level_ID = ed.Product_Group_Level_ID
			inner join All_Product_Group_Types i
			on		i.Group_GUID = ed.Product_Group_ID
			WHERE	ed.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			and		ed.Product_Group_Level_ID != 0
			Order By  ed.Product_Group_Level_ID Desc, Record_Type, Product_Name
		</cfquery>

		<cfreturn local.query />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerEventProductList" access="public" returntype="query" output="no" hint="Gets products saved on the consumer event">
		<cfargument name="plannerEventId" required="true" type="numeric" />
		<cfargument name="isGroup" required="false" type="numeric" default="-1" hint="0=Individual, 1=Group, -1=Both" />

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT	ep.Product_Group_ID as Product_GUID, ep.Product_Group_Level_ID
			FROM	Planner_Event_Products ep
			WHERE	ep.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			<cfif arguments.isGroup eq 0>
			and		ep.Product_Group_Level_ID = 0
			<cfelseif arguments.isGroup eq 1>
			and		ep.Product_Group_Level_ID != 0
			</cfif>
		</cfquery>

		<cfreturn local.query />

	</cffunction>


	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerEventDistributorList" access="public" returntype="query" output="no" hint="Gets distributors saved on the consumer event">
		<cfargument name="plannerEventId" required="true" type="numeric" />
		<cfargument name="isGroup" required="false" type="numeric" default="-1" hint="0=Individual, 1=Group, -1=Both" />

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT	ed.Distributor_Group_ID as Distributor_GUID, ed.Distributor_Group_Level_ID
			FROM	Planner_Event_Distributors ed
			WHERE	ed.Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">
			<cfif arguments.isGroup eq 0>
			and		ed.Distributor_Group_Level_ID = 0
			<cfelseif arguments.isGroup eq 1>
			and		ed.Distributor_Group_Level_ID != 0
			</cfif>
		</cfquery>

		<cfreturn local.query />

	</cffunction>

	<cffunction name="saveEventProducts" output="false">
		<cfargument name="plannerEventId" required="true" type="numeric" />
		<cfargument name="form" required="true">

		<cfscript>
			local.plannerEventId 	= arguments.plannerEventId;
			local.productList 		= form.Product_List;
			local.groupLevelId		= form.groupLevelId;
			local.productGroupList	= form.SelectedGroupProducts;
		</cfscript>

		<cfquery name="local.query" datasource="#application.datasource#">
			DELETE	Planner_Event_Products
			WHERE	Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerEventId#">

			<cfloop list="#local.productList#" index="productId">
				insert into Planner_Event_Products (Planner_Event_ID, Product_Group_Level_ID, Product_Group_ID)
				values (<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerEventId#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="0">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#productId#">
				)
			</cfloop>
			<cfloop list="#local.productGroupList#" index="productId">
				insert into Planner_Event_Products (Planner_Event_ID, Product_Group_Level_ID, Product_Group_ID)
				values (<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerEventId#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.groupLevelId#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#productId#">
				)
			</cfloop>
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getDistributorsFromList" output="false" returntype="query" hint="Gets distributor info for a list of distributors">
		<cfargument name="distList" required="true" type="string">

		<cfscript>

			if (! structKeyExists(request, "planner_labels")) {
				labelManager		= createObject( "component", "components.settings.Labels.Labels" ).init();
				request.planner_labels	= labelManager.plannerLabels();
			}

		</cfscript>

		<cfquery name="local.qDistributors" datasource="#application.datasource#">
			SELECT	c.Shr_Ship_To as Distributor, c.Name as Distributor_Name, '#request.planner_labels.distributor_singular#' as Record_Type,
					c.BSA_Foodservice_Customers_ID as Distributor_GUID, 0 as Distributor_Group_Level_ID
			FROM	BSA_Foodservice_Customers c
			WHERE	c.Ship_To != 'Group'
			<cfif arguments.distList eq "">
			AND		1 = 2
			<cfelse>
			AND		c.BSA_Foodservice_Customers_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.distList#" list="true">)
			</cfif>
			UNION
			SELECT	g.Group_Number as Distributor, g.Group_Desc as Distributor_Name, l.Group_Level_Desc as Record_Type,
					g.Group_GUID as Distributor_GUID, g.Distributor_Group_Level_ID
			FROM 	All_Customer_Group_Types g
			INNER JOIN Distributor_Group_Level l
			ON		g.Distributor_Group_Level_ID = l.Distributor_Group_Level_ID
			WHERE g.Deleted = 0
			<cfif arguments.distList eq "">
			AND		1 = 2
			<cfelse>
			AND		g.Group_GUID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.distList#" list="true">)
			</cfif>
		</cfquery>

		<cfreturn local.qDistributors />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="saveEventDistributors" output="false">
		<cfargument name="plannerEventId" required="true" type="numeric" />
		<cfargument name="form" required="true">

		<cfscript>
			local.plannerEventId 	= arguments.plannerEventId;
			local.distributorList 	= form.SelectedDistributors;
			local.groupLevelId		= form.groupLevelId;
			local.distributorGroupList	= form.SelectedGroupDistributors;
		</cfscript>

		<cfquery name="local.query" datasource="#application.datasource#">
			DELETE	Planner_Event_Distributors
			WHERE	Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerEventId#">

			<cfloop list="#local.distributorList#" index="distributorId">
				insert into Planner_Event_Distributors (Planner_Event_ID, Distributor_Group_Level_ID, Distributor_Group_ID)
				values (<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerEventId#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="0">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#distributorId#">
				)
			</cfloop>
			<cfloop list="#local.distributorGroupList#" index="distributorId">
				insert into Planner_Event_Distributors (Planner_Event_ID, Distributor_Group_Level_ID, Distributor_Group_ID)
				values (<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerEventId#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.groupLevelId#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#distributorId#">
				)
			</cfloop>
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPositions" access="public" returntype="query" output="no" hint="Gets consumer event positions">
		<cfargument name="positionList" required="true" type="string" />

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT	up.User_positions_ID, up.Position_Label,
					CASE
					WHEN up.Service_Market_ID IS NOT NULL THEN 3
					WHEN up.Service_Region_ID IS NOT NULL THEN 2
					WHEN up.Service_Zone_ID IS NOT NULL THEN 1
					ELSE 0
					END as Position_Type,
					CASE
					WHEN up.Service_Market_ID IS NOT NULL THEN '#application.returned_customer_setting.market_label_singular#'
					WHEN up.Service_Region_ID IS NOT NULL THEN '#application.returned_customer_setting.region_label_singular#'
					WHEN up.Service_Zone_ID IS NOT NULL THEN '#application.returned_customer_setting.zone_label_singular#'
					ELSE 'Headquarters'
					END as Position_Type_Desc,
					CASE
					WHEN up.Service_Market_ID IS NOT NULL THEN m.Market_Number
					WHEN up.Service_Region_ID IS NOT NULL THEN r.Region_Number
					WHEN up.Service_Zone_ID IS NOT NULL THEN z.Zone_Number
					ELSE 'HQ'
					END as Position_ID
			FROM	User_Positions up
			LEFT JOIN Service_Zones z
			ON		z.Service_Zone_ID = up.Service_Zone_ID
			LEFT JOIN Service_Regions r
			ON		r.Service_Region_ID = up.Service_Region_ID
			LEFT JOIN Service_Markets m
			ON		m.Service_Market_ID = up.Service_Market_ID
			<cfif arguments.positionList eq "">
			WHERE	1 = 2
			<cfelse>
			WHERE	up.User_positions_ID IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionList#" list="true">)
			</cfif>
			ORDER BY Position_Type, Position_Label
		</cfquery>

		<cfreturn local.query />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerEventPositions" access="public" returntype="void" output="no" hint="Saves consumer event positions">
		<cfargument name="plannerEventId" required="true" type="numeric" />
		<cfargument name="positionList" required="true" type="string" />

		<cfquery name="local.query" datasource="#application.datasource#">
			DELETE	Planner_Event_Positions
			WHERE	Planner_Event_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">

			<cfloop list="#arguments.positionList#" index="positionId">
				insert into Planner_Event_Positions (Planner_Event_ID, User_Position_ID)
				values (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerEventId#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#positionId#">
				)
			</cfloop>
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getProductsFromList" output="false" returntype="query" hint="Gets product data for a list of products">
		<cfargument name="prodList" required="true" type="string">

		<cfquery name="local.qProducts" datasource="#application.datasource#">
			SELECT	im.Item as Product,
					im.Description as Product_Name,
					'Product' as Record_Type,
					im.BSA_Foodservice_Items_Master_ID as Product_GUID,
					0 as Product_Group_Level_ID
			FROM	BSA_Foodservice_Items_Master im
			WHERE	im.Item != 'Group'
			<cfif arguments.prodList eq "">
			AND		1 = 2
			<cfelse>
			AND		im.BSA_Foodservice_Items_Master_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prodList#" list="true">)
			</cfif>
			UNION

			SELECT	pgt.Group_Number as Product,
					pgt.Group_Desc as Product_Name,
					pgl.Group_Level_Desc as Record_Type,
					pgt.Group_GUID as Product_GUID,
					pgl.Product_Group_Level_ID
			FROM	All_Product_Group_Types pgt
					inner join Product_Group_Level pgl on pgl.Product_Group_Level_ID = pgt.Product_Group_Level_ID
			WHERE	pgt.Deleted = 0
			<cfif arguments.prodList eq "">
			AND		1 = 2
			<cfelse>
			AND 	pgt.Group_GUID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prodList#" list="true">)
			</cfif>
		</cfquery>

		<cfreturn local.qProducts />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getDocuments" output="false">
		<cfargument name="rowid" required="true">

		<cfquery name="local.qDocuments" datasource="#application.datasource#">
			SELECT Document_Details.Doc_Uni_Name,
				   Document_Details.Doc_Title,
				   Document_Details.Doc_Description,
				   Document_Details.Uploaded_Date,
				   _Users.Name_First + ' ' + _Users.Name_Last AS Uploader,
				   Document_Details.Doc_File_Name,
				   Document_Details.Doc_Size,
				   Document_Details.Doc_Family,
				   Document_Details.Doc_ID
			  FROM Planner_event_documents ped
			 INNER JOIN Document_Details
				ON Document_Details.Doc_ID = ped.Doc_ID
			 INNER JOIN _Users
				ON _Users.User_ID       = Document_Details.Uploaded_By
			 WHERE ped.planner_event_id = <cfqueryparam value="#arguments.rowid#">
			   AND ped.Deleted          = 0
			 ORDER BY Document_Details.Uploaded_Date DESC
		</cfquery>

		<cfreturn local.qDocuments>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="tempEventProducts" output="false">
		<cfargument name="fiscalYear"  required="true"  type="string">

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_event_products') IS NOT NULL
				DROP TABLE ##tmp_event_products
		</cfquery>

		<cfquery name="local.create" datasource="#application.datasource#">
			CREATE TABLE ##tmp_event_products(BSA_Foodservice_Items_Master_ID UNIQUEIDENTIFIER);

			INSERT INTO  ##tmp_event_products(BSA_Foodservice_Items_Master_ID)
			--Items
		   SELECT DISTINCT
				  pep.Product_Group_ID
		   FROM     dbo.Planner_Event_Products pep
		   WHERE   pep.Product_Group_Level_ID = 0
		   and 		planner_event_Id in (
		   				Select distinct planner_event_Id
		   				from planner_event
		   				where deleted = 0
		   				and active = 1
		   				and fiscal_year = '#arguments.fiscalYear#'
		   				)
		   UNION
			-- Items from Groups
		   SELECT DISTINCT
				  apgtm.BSA_Foodservice_Items_Master_ID
		   FROM   dbo.Planner_Event_Products pep
				  INNER JOIN dbo.All_Product_Group_Type_Members apgtm
					  ON apgtm.Product_Group_Level_ID = pep.Product_Group_Level_ID
						 AND apgtm.Product_Group_ID = pep.Product_Group_ID
		   WHERE  pep.Product_Group_Level_ID != 0
		   and 		planner_event_Id in (
		   				Select distinct planner_event_Id
		   				from planner_event
		   				where deleted = 0
		   				and active = 1
		   				and fiscal_year = '#arguments.fiscalYear#'
		   				)
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getEventsCalendarProducts" output="false">
		<cfargument name="fiscalYear"             required="true"  type="string">
		<cfargument name="product_group_level_id" required="true"  type="numeric">

		<cfset tempEventProducts(arguments.fiscalYear) >

		<cfquery name="local.qEventProductGroups" datasource="#application.datasource#">
				SELECT #arguments.product_group_level_id# AS Product_Group_Level_ID,
					   '00000000-0000-0000-0000-000000000000' AS Product_GUID,
					   '' AS Product_Desc,
					   '' AS Product_Number,
					   'A' as Active_Code
				UNION
			<cfif arguments.product_group_level_id neq 0 >
				<!--- Groups --->
				SELECT DISTINCT
					   isnull(apgt.Product_Group_Level_ID, 0) AS Product_Group_Level_ID,
					   isnull(apgt.Group_GUID, p.BSA_Foodservice_Items_Master_ID) AS Product_GUID,
					   isnull(apgt.Group_Desc, '') AS Product_Desc,
					   isnull(apgt.Group_Number, '') AS Product_Number,
					   'A' AS Active_Code
				FROM   ##tmp_event_products p
					   INNER  JOIN dbo.All_Product_Group_Type_Members apgtm
						   ON p.BSA_Foodservice_Items_Master_ID = apgtm.BSA_Foodservice_Items_Master_ID
						    AND apgtm.Product_Group_Level_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_group_level_id#" />
					   INNER JOIN dbo.All_Product_Group_Types apgt
						   ON apgtm.Product_Group_Level_ID = apgt.Product_Group_Level_ID
							  AND apgtm.Product_Group_ID = apgt.Group_GUID
							  AND apgt.Deleted = 0
				ORDER BY Product_GUID
			<cfelse>
				<!--- Items --->
				SELECT DISTINCT
					   0 AS Product_Group_Level_ID,
					   isnull(bfim.BSA_Foodservice_Items_Master_ID, p.BSA_Foodservice_Items_Master_ID) AS Product_GUID,
					   isnull(bfim.Description, '') AS Product_Desc,
					   isnull(bfim.Item, '') AS Product_Number,
					   isnull(bfim.Active_Code, 'A') AS Active_Code
				FROM   ##tmp_event_products p
					   LEFT JOIN dbo.BSA_Foodservice_Items_Master bfim
						   ON p.BSA_Foodservice_Items_Master_ID = bfim.BSA_Foodservice_Items_Master_ID
							  AND bfim.Deleted = 0
				ORDER BY Product_GUID
			</cfif>
		</cfquery>

		<cfreturn local.qEventProductGroups />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- get distributors below me --->
	<cffunction name="getEventsWithDistUnderMe" returntype="string" access="remote">
		<cfargument name="PositionsBelowMe" 	required="true" type="string" />

		<cfquery name="qEventsWithDistUnderMe" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##MyEventDistributors') IS NOT NULL
				DROP TABLE ##MyEventDistributors

			CREATE  TABLE ##MyEventDistributors
			(
			  BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER
			)

			INSERT INTO ##MyEventDistributors (BSA_FoodService_Customers_ID)
			SELECT	Distinct BSA_FoodService_Customers.BSA_FoodService_Customers_ID
			FROM	BSA_FoodService_Customers
				<cfif this.appSettings.getDistributorMultiPosition()>
					INNER JOIN Market_Distributor
					ON 	Market_Distributor.Deleted = 0
					AND Market_Distributor.Distributor_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
					INNER JOIN Service_Markets
					ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
				</cfif>
				INNER JOIN BSA_Foodservice_Brokers
				<cfif this.appSettings.getDistributorMultiPosition()>
					ON BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
				<cfelse>
					ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_FoodService_Customers.BSA_Foodservice_Brokers_ID
				</cfif>
				AND BSA_Foodservice_Brokers.Deleted = 0
				INNER JOIN User_Positions
				<cfif this.appSettings.getDistributorMultiPosition()>
					ON User_Positions.Service_Market_Id  = Service_Markets.Service_Market_ID
				<cfelse>
					ON User_Positions.Service_Market_Id = bsa_FoodService_Brokers.Service_Market_Id
				</cfif>
				AND User_Positions.Deleted = 0
				WHERE User_Positions.User_Positions_ID IN ( <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.PositionsBelowMe#" list="true"> )
				AND BSA_FoodService_Customers.Deleted = 0
				AND BSA_Foodservice_Customers.Retail_Customer = 1

			<!--- groups --->
			SELECT	DISTINCT PE.Planner_Event_ID
			FROM	Planner_Event PE
					INNER JOIN Planner_Event_Distributors  PED_G
					ON PE.Planner_Event_ID = PED_G.Planner_Event_ID
					AND PE.DELETED = 0 AND PE.ACTIVE = 1
					INNER JOIN All_Customer_Group_Type_Members ACGTM
					ON PED_G.Distributor_Group_ID = ACGTM.Distributor_Group_ID
					AND ISNULL(PED_G.Distributor_Group_Level_ID, 0) = ACGTM.Distributor_Group_Level_ID
					INNER JOIN ##MyEventDistributors D
					ON ACGTM.BSA_Foodservice_Customers_ID = D.BSA_Foodservice_Customers_ID
			UNION
			<!--- customers --->
			SELECT	DISTINCT PE.Planner_Event_ID
			FROM	Planner_Event PE
					INNER JOIN Planner_Event_Distributors  PED
					ON PE.Planner_Event_ID = PED.Planner_Event_ID
					AND PE.DELETED = 0 AND PE.ACTIVE = 1
					INNER JOIN ##MyEventDistributors D
					ON PED.Distributor_Group_ID = D.BSA_Foodservice_Customers_ID
			WHERE 	ISNULL(PED.Distributor_Group_Level_ID, 0) = 0

			UNION
			<!--- events without customers --->
			SELECT	DISTINCT PE.Planner_Event_ID
			FROM	Planner_Event PE
					LEFT JOIN Planner_Event_Distributors  PED_O
					ON PE.Planner_Event_ID = PED_O.Planner_Event_ID
			WHERE 	PE.DELETED = 0 AND PE.ACTIVE = 1
					AND PED_O.Planner_Event_ID IS NULL

			UNION
			<!--- events with positions below me --->
			SELECT	DISTINCT PE.Planner_Event_ID
			FROM	Planner_Event PE
					LEFT JOIN Planner_Event_Positions  PEP
					ON PE.Planner_Event_ID = PEP.Planner_Event_ID
			WHERE 	PE.DELETED = 0 AND PE.ACTIVE = 1
					AND (
						PEP.User_Position_ID IS NULL
						OR
						PEP.User_Position_ID IN ( #listQualify(arguments.PositionsBelowMe, "'")# )
						)
		</cfquery>

		<cfreturn valueList(qEventsWithDistUnderMe.Planner_Event_ID) />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getEventsCalendarData" output="false" hint="returns the events for the calendar">
		<cfargument name="fiscalYear"             required="true"  type="string">
		<cfargument name="product_group_level_id" required="true"  type="numeric">
		<!--- <cfargument name="userId"                 required="false" type="string"> --->

		<cfset local.positionsBelowMe      = this.positionsBelowMe />
		<cfset local.eventsWithDistUnderMe = this.getEventsWithDistUnderMe(local.positionsBelowMe) />

		<cfquery name="local.qCalendarEvents" datasource="#application.datasource#">
			<!--- Items to Groups --->
			SELECT DISTINCT
				  pe.planner_event_id,
				   pe.planner_event_type_id,
				   pe.event_title,
				   pe.fiscal_year,
				   pe.event_start,
				   pe.event_end,
				   pe.discount_info,
				   pe.document_info,
				   pe.active,
				   pet.title AS type,
				   pet.color,
				   ISNULL(pe.updated_date, pe.created_date) AS Updated_Date,
				   ISNULL(Group_GUID, '00000000-0000-0000-0000-000000000000') AS Product_GUID
			FROM   planner_event pe
				   INNER JOIN planner_event_type pet
					   ON pe.planner_event_type_id = pet.planner_event_type_id
						  AND pet.deleted = 0
					 LEFT JOIN dbo.Planner_Event_Products pep
						 ON pe.Planner_Event_ID = pep.Planner_Event_ID
							AND pep.Product_Group_Level_ID = 0
					 INNER JOIN All_Product_Group_Type_Members apgtm
						 ON apgtm.BSA_Foodservice_Items_Master_ID = pep.Product_Group_ID
							AND apgtm.Product_Group_Level_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_group_level_id#" >
					 INNER JOIN dbo.All_Product_Group_Types apgt
						 ON apgtm.Product_Group_Level_ID = apgt.Product_Group_Level_ID
							AND apgtm.Product_Group_ID = apgt.Group_GUID
							AND apgt.Deleted = 0
			WHERE   pe.Deleted = 0
					AND pe.Active = 1
					AND  pe.fiscal_year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" >
					AND  pe.planner_event_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.eventsWithDistUnderMe#" list="true">)
			UNION
			<!--- Groups --->
			SELECT DISTINCT
				   pe.planner_event_id,
				   pe.planner_event_type_id,
				   pe.event_title,
				   pe.fiscal_year,
				   pe.event_start,
				   pe.event_end,
				   pe.discount_info,
				   pe.document_info,
				   pe.active,
				   pet.title AS type,
				   pet.color,
				   ISNULL(pe.updated_date, pe.created_date) AS Updated_Date,
				   ISNULL(Group_GUID, '00000000-0000-0000-0000-000000000000') AS Product_GUID
			FROM   planner_event pe
				   INNER JOIN planner_event_type pet
					   ON pe.planner_event_type_id = pet.planner_event_type_id
						  AND pet.deleted = 0
				   LEFT JOIN dbo.Planner_Event_Products pep
					   ON pe.Planner_Event_ID = pep.Planner_Event_ID
				   INNER JOIN All_Product_Group_Type_Members apgtm
					   ON apgtm.Product_Group_ID = pep.Product_Group_ID
						  AND apgtm.product_group_level_id = pep.product_group_level_id
				   INNER JOIN dbo.All_Product_Group_Type_Members apgtm2
					   ON apgtm.BSA_Foodservice_Items_Master_ID = apgtm2.BSA_Foodservice_Items_Master_ID
						  AND apgtm2.product_group_level_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_group_level_id#" >
				   INNER JOIN dbo.All_Product_Group_Types apgt
					   ON apgtm2.product_group_level_id = apgt.product_group_level_id
						  AND apgtm2.Product_Group_ID = apgt.Group_GUID
						  AND apgt.Deleted = 0
			WHERE  pe.Deleted = 0
				   AND pe.Active = 1
				   AND pep.Product_Group_Level_ID != 0
				   AND  pe.fiscal_year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" >
				   AND  pe.planner_event_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.eventsWithDistUnderMe#" list="true">)
		</cfquery>

		<cfreturn local.qCalendarEvents >

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getEventsCalendar" output="false" hint="returns the events for the calendar in json">
		<cfargument name="fiscalYear"             required="true" type="string">
		<cfargument name="product_group_level_id" required="true" type="numeric">

		<cfscript>
			local.all_rows        = [];
			local.qEvtCalData     = this.getEventsCalendarData(arguments.fiscalYear, arguments.product_group_level_id);
		</cfscript>

		<cfoutput query="local.qEvtCalData">
			<cfscript>
				local.evt                          = {};
				local.evt["active"]                = local.qEvtCalData.active;
				local.evt["color"]                 = local.qEvtCalData.color;
				local.evt["discount_info"]         = local.qEvtCalData.discount_info;
				local.evt["document_info"]         = local.qEvtCalData.document_info;
				local.evt["end_date"]              = dateFormat(local.qEvtCalData.event_end, "m/d/yyyy");
				local.evt["event_title"]           = local.qEvtCalData.event_title;
				local.evt["fiscal_year"]           = local.qEvtCalData.fiscal_year;
				local.evt["planner_event_id"]      = local.qEvtCalData.planner_event_id;
				local.evt["planner_event_type_id"] = local.qEvtCalData.planner_event_type_id;
				local.evt["product_guid"]            = local.qEvtCalData.product_guid;
				local.evt["start_date"]            = dateFormat(local.qEvtCalData.event_start, "m/d/yyyy");
				local.evt["text"]                  = local.qEvtCalData.event_title;
				local.evt["type"]                  = local.qEvtCalData.type;
				arrayAppend( local.all_rows, local.evt );
			</cfscript>
		</cfoutput>

		<cfreturn local.all_rows >

	</cffunction>

</cfcomponent>