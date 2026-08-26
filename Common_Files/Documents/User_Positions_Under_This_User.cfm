
<CFSET GP_Supplied_Position = createobject("component", "components.user.userManager").getPositionId(request.AccessStructure.user_id, 0, 1)>

<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">



