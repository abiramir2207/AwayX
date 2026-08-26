<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Planning_Groups\removeMembers.cfm
      Date:     Sep 13 2012
      Author:   Chris Nguyen
      Purpose:  "Remove members from program" input label & mouse over information
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="crtip">
<script type="text/javascript" src="/script/tTip.js"></script>
<style>
.tip {font:11px
	   Arial,Helvetica,sans-serif; border:solid 1px #666666; width:350px;
	   position:absolute; z-index:100;
	   visibility:hidden; color:#333333; top:10px;
	   left:90px; background-color:#ffffcc;
	   layer-background-color:#ffffcc;} 
#t1 {font:normal 10pt Arial,Helvetica,sans-serif;
background-color:#FFFFCC; layer-background-color:#FFFFCC;} 
.tip p { padding: 5px; text-align:left; }
</style>
</cfsavecontent>
<cfoutput><cfhtmlhead text="#crtip#"></cfoutput>

<td align="right" onmouseout="popUpTip(event,'crtip');" onmouseover="popUpTip(event,'crtip');"><strong>Remove members from program &raquo; :</strong></td>
<div id="crtip" class="tip"><p>This setting controls the maintenance action for group members and programs. This setting provides flexibility to configure the planning groups when they are being used as filters on the templates. </p><p>For example, a planning group may be created to establish a list of eligible products.  The planning group is associated to a template.  Programs are created using the planning group.  When programs are created, only the members of the planning group at the time can be chosen.  Assume at a later time, a member is removed from the planning group.  Below explains what action will be done if the setting is checked vs. not checked:</p>
	<p>&#9679; When the checkbox is <b>selected (checked)</b>, members removed from the planning group will also be automatically removed from programs.</p>
	<p>&#9679; When this setting is <b>not selected (un-checked)</b>, programs already created would not be effected.  Meaning the members that were part of the planning group at the time the program was created would remain on the existing programs.</p>
</div>
  		
