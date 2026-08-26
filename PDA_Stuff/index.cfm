<CFSET PAGE_TITLE=	"Personal Digital Assistant Support">
<CFSET GROUP=		"PDA">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	
	
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Script used to display the different models of PDAs in visible layer --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script language="JavaScript">
<!--
function show(object) {
    if (document.layers && document.layers[object])
        document.layers[object].visibility = 'visible';
    else if (document.all) {
        document.all[object].style.visibility = 'visible';
        document.all[object].style.zIndex = 100;
    }
}
function hide(object) {
    if (document.layers && document.layers[object])
        document.layers[object].visibility = 'hidden';
    else if (document.all)
        document.all[object].style.visibility = 'hidden';
}
//-->
</script>




</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>



<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_pda_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
		
		
			<DIV CLASS="title2">Export data to your PDA:</DIV>
			<BR>
			Before downloading data to your PDA, please review the <A HREF="#systemrequirements">system requirements</A> and the <A HREF="#installationnotes">installation notes</A>
			<BR><BR>
			The following data is available for download:
<BLOCKQUOTE>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="500">
	<TR BGCOLOR="e5e5e5">
		<TD><B>Database</B></TD>
		<TD ALIGN="center"><B>Download</B></TD>
		<TD><B>Date Built</B></TD>
		<TD><B>Records</B></TD>
		<TD><B>Bytes</B></TD>
	</TR>
    <tr>
      <td COLSPAN="5"><BR><B>1) Internal Information</B><HR COLOR="Orange" SIZE="1"></td>
    </tr>
    <TR>
      <td>CDFC Price Lists</td>
      <td ALIGN="center"><A HREF="td2_cdfc_price_lists.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>402</td>
      <td>74 kb</td>
    </tr>
    <TR>
      <td>CDFC Freight Rates</td>
      <td ALIGN="center"><A HREF="td2_freight_rates.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>239</td>
      <td>43 kb</td>
    </tr>
    <tr>
      <td COLSPAN="5"><BR><B>2)<cfoutput> #application.returned_customer_setting.distributor_label_singular#</cfoutput> Information</B><HR COLOR="Orange" SIZE="1"></td>
    </tr>
    <TR>
      <td>Top 100 <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput></td>
      <td ALIGN="center"><A HREF="td2_top_100_dist.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>932</td>
      <td>164 kb</td>
    </tr>
    <TR>
      <td>Leading Network Members</td>
      <td ALIGN="center"><A HREF="td2_network.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>742</td>
      <td>132 kb</td>
    </tr>
    <TR>
      <td>Top 500 Retail Wholesalers</td>
      <td ALIGN="center"><A HREF="td2_retail_dist.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>542</td>
      <td>92 kb</td>
    </tr>
    <TR>
      <td>Personnel: SYSCO</td>
      <td ALIGN="center"><A HREF="td2_sysco.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>1292</td>
      <td>252 kb</td>
    </tr>
    <TR>
      <td>Personnel: US Foodservice</td>
      <td ALIGN="center"><A HREF="td2_usf.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>1087</td>
      <td>201 kb</td>
    </tr>
    <tr>
      <td COLSPAN="5"><BR><B>3) <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Information</B><HR COLOR="Orange" SIZE="1"></td>
    </tr>
    <TR>
      <td>Top 500 Restaurant Chains</td>
      <td ALIGN="center"><A HREF="td2_500_chains.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>499</td>
      <td>110 kb</td>
    </tr>
    <TR>
      <td>Top 500 Restaurant Franchisees</td>
      <td ALIGN="center"><A HREF="td2_500_franch.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>489</td>
      <td>89 kb</td>
    </tr>
    <TR>
      <td>Top 500 Independent Restaurants</td>
      <td ALIGN="center"><A HREF="td2_500_indep.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>517</td>
      <td>73 kb</td>
    </tr>
    <TR>
      <td>Top 500 Non-traditional <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></td>
      <td ALIGN="center"><A HREF="td2_500_nontrad.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>487</td>
      <td>118 kb</td>
    </tr>
    <TR>
      <td>Top 500 C-Store Retailers</td>
      <td ALIGN="center"><A HREF="td2_cstores.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>496</td>
      <td>90 kb</td>
    </tr>
    <TR>
      <td>Top 500 Supermarket Retailers</td>
      <td ALIGN="center"><A HREF="td2_500_super.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>499</td>
      <td>99 kb</td>
    </tr>
    <TR>
      <td>Personnel: ARAMARK</td>
      <td ALIGN="center"><A HREF="td2_aramark.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>150</td>
      <td>32 kb</td>
    </tr>
    <TR>
      <td>Personnel: Compass Group</td>
      <td ALIGN="center"><A HREF="td2_compass.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>209</td>
      <td>45 kb</td>
    </tr>
    <tr>
      <td COLSPAN="5"><BR><B>4) Market Information - All <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></B><HR COLOR="Orange" SIZE="1"></td>
    </tr>
    <TR>
      <td>Market: Pacific Northwest</td>
      <td ALIGN="center"><A HREF="td2_pacific.pdb"><IMG SRC="/images/pda_transfer_icon.gif" BORDER="0" ALT="Download this database..."></A></td>
      <td>12/16/2001</td>
      <td>564</td>
      <td>115 kb</td>
    </tr>
  </table>

  <BR>

<!---   
<FONT COLOR="Red"><B>* Coming soon (12/18)</B></FONT>
<TABLE>
    <TR>
      <td><FONT COLOR="Red"><B>Market:  New York City</B></FONT></td>
	  <TD>&nbsp;&nbsp;&nbsp;</TD>
      <td><FONT COLOR="Red"><B>Market:  Boston</B></FONT></td>
    </tr>
    <TR>
      <td><FONT COLOR="Red"><B>Market:  Los Angeles</B></FONT></td>
	  <TD>&nbsp;&nbsp;&nbsp;</TD>
      <td><FONT COLOR="Red"><B>Market:  Miami</B></FONT></td>
    </tr>
    <TR>
      <td><FONT COLOR="Red"><B>Market:  Chicago</B></FONT></td>
	  <TD>&nbsp;&nbsp;&nbsp;</TD>
      <td><FONT COLOR="Red"><B>Market:  Atlanta</B></FONT></td>
    </tr>
    <TR>
      <td><FONT COLOR="Red"><B>Market:  San Francisco</B></FONT></td>
	  <TD>&nbsp;&nbsp;&nbsp;</TD>
      <td><FONT COLOR="Red"><B>Market:  Houston</B></FONT></td>
    </tr>
  </table>
 --->


</BLOCKQUOTE>
<!--- 
			<UL>
				<LI><A HREF="/pda_stuff/td2_halls_prices.pdb">HALLS Price list - 12/5/2001 - 50Kb</A><BR></LI>
				<LI><A HREF="/pda_stuff/TD2_FSM_Contacts.pdb">Foodservice Management Companies' Contacts -  12/13/2001 - 272Kb</A><BR></LI>
				<LI><A HREF="/pda_stuff/TD2_CDFC_PRICE_LISTS.pdb">CDFC Price List - 12/13/2001 - 74Kb</A><BR></LI>
			</UL>				
 --->			
			<DIV CLASS="title2"><A NAME="systemrequirements" STYLE="color:Navy;">System Hardware Requirements:</A></DIV>
			<BR>
			You can download data to your Personal Digital Assistant if you use one of 3 systems:<BR>
			
				<TABLE BORDER="0" CELLPADDING="15" CELLSPACING="0">  
					<TR>
						<TD VALIGN="top">
							1
							<HR COLOR="Orange" WIDTH="150">
							<B>Palm Pilot(*)</B><BR><BR>
							
							<IMG SRC="/images/palm_pda.jpg" BORDER="0" ALT="Palm Pilot"><BR><BR>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId1')" onMouseOut="hide('myId1')" STYLE="cursor:hand;">Pilot m505</SPAN><BR><div id="myId1" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_m505.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId2')" onMouseOut="hide('myId2')" STYLE="cursor:hand;">Pilot m500</SPAN><BR><div id="myId2" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_m500.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId3')" onMouseOut="hide('myId3')" STYLE="cursor:hand;">Pilot m125</SPAN><BR><div id="myId3" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_m125.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId4')" onMouseOut="hide('myId4')" STYLE="cursor:hand;">Pilot VIIx</SPAN><BR><div id="myId4" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilotl_viix.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId5')" onMouseOut="hide('myId5')" STYLE="cursor:hand;">Pilot m105</SPAN><BR><div id="myId5" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_m105.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId6')" onMouseOut="hide('myId6')" STYLE="cursor:hand;">Pilot m100</SPAN><BR><div id="myId6" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_m100.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId7')" onMouseOut="hide('myId7')" STYLE="cursor:hand;">Pilot Vx</SPAN><BR><div id="myId7" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_vx.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId8')" onMouseOut="hide('myId8')" STYLE="cursor:hand;">Pilot IIIc</SPAN><BR><div id="myId8" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Pilot_iiic.gif" BORDER="0" ALT=""></div>

							<!--- 
							No longer in production
							Pilot
							PalmPilot
							III
							IIIe
							IIIxe
							V
							VII 
							 --->
						</TD>
						<TD VALIGN="top">
							2
							<HR COLOR="Orange" WIDTH="150">
							<B>Handspring Visor(**)</B><BR><BR>

							<IMG SRC="/images/visor_pda.jpg" BORDER="0" ALT="Handspring Visor"><BR><BR>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId9')" onMouseOut="hide('myId9')" STYLE="cursor:hand;">Visor Pro</SPAN><BR><div id="myId9" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Visor_pro.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId10')" onMouseOut="hide('myId10')" STYLE="cursor:hand;">Visor Edge</SPAN><BR><div id="myId10" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Visor_edge.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId11')" onMouseOut="hide('myId11')" STYLE="cursor:hand;">Visor Prism</SPAN><BR><div id="myId11" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Visor_prism.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId12')" onMouseOut="hide('myId12')" STYLE="cursor:hand;">Visor Platinum</SPAN><BR><div id="myId12" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Visor_platinum.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId13')" onMouseOut="hide('myId13')" STYLE="cursor:hand;">Visor Deluxe</SPAN><BR><div id="myId13" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Visor_deluxe.gif" BORDER="0" ALT=""></div>
							&nbsp;&nbsp;<SPAN onMouseOver="show('myId14')" onMouseOut="hide('myId14')" STYLE="cursor:hand;">Visor Neo</SPAN><BR><div id="myId14" style="position: absolute; visibility: hidden;"><IMG SRC="/images/PDA_Images/Visor_neo.gif" BORDER="0" ALT=""></div>
						</TD>
						<TD VALIGN="top">
							3
							<HR COLOR="Orange" WIDTH="150">
							<B>Other PDAs running<BR>
							PalmOS 3.1 or later:<BR>
							Sony Clie<BR>
							Symbol<BR>
							IBM WorkPads</B>
						</TD>
					</TR>
				</TABLE>

			<DIV CLASS="title2"><A NAME="systemrequirements" STYLE="color:Navy;">System Software Requirements:</A></DIV>
			<BR>
			To be able to download data files directly from the <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT> system into your PDA 
			you must perform a one time installation of these 2 files. You <B>must</B> install the Envi.con KG PilotInstall utility first and the ThinkingBytes ThinkDB second<BR>

<UL>
	<LI>
		<B>Install first </B><A HREF="/pda_Stuff/Pilot Install.exe">Envi.con KG PilotInstall &copy;</A>
		<BR>
		version 3.2, size: 314125 bytes for Windows 95,98,2000,NT
		<BR>
		Instructions<BR>
		<UL>
			<LI>Click the above link</LI>
			<LI>When asked to "save" or "open", select save to your Programs Directory</LI>
			<LI>Execute "Pilot Install.exe"</LI>
			<LI>When asked if you want to make it the default tool, choose Yes</LI>
			<LI>Make sure the data port matches what you're using to transfer data: either COM, USB or IR</LI>
			<LI>Leave the speed settings as is</LI>
			<LI>In the Options menu, select "Register Filetypes"</LI>
			<LI>Press cancel<BR>Your're done!</LI>
		</UL>
	</LI>
<BR>
	<LI>
		<B>Install second </B><A HREF="/pda_Stuff/SmartListToGo.PRC">SmartList to Go &copy;</A>
		<BR>
		version 2.5, size: 527kbytes for PalmOS 3.1 and later
		<BR>
		Instructions<BR>
		<UL>
			<LI>Click the above link</LI>
			<LI>When asked to "save" or "open", select open</LI>
			<LI>PilotInstall will automatically run</LI>
			<LI>From your PDA, run the Hotsync application</LI>
		</UL>
	</LI>
</UL>



			<DIV CLASS="title2"><A NAME="installationnotes" STYLE="color:Navy;">Installation Notes:</A></DIV>
			<BR>
			<UL>
				<LI>Click the files to download</LI>
				<LI>When asked to "save" or "open", select open</LI>
				<LI>When the file has downloaded, The Pilot Install tool will open</LI>
				<LI>From your PDA, run the Hotsync application</LI>
				<LI>The Pilot Install tool will display the progress of the data transfer</LI>
				<LI>When it reaches 100%, you'r done. Click "done" to close the Pilot Install.</LI>
			</UL>


(*)
Palm OS, Palm Computing, HandFAX, HandSTAMP, HandWEB, Graffiti, HotSync, iMessenger, MultiMail, Palm.Net, PalmPak, PalmConnect, PalmGlove, PalmModem, PalmPoint, PalmPrint, and PalmSource are registered trademarks of Palm, Inc. Palm, the Palm logo, MyPalm, PalmGear, PalmPix, PalmPower, AnyDay, EventClub, HandMAIL, the HotSync logo, PalmGlove, Palm Powered, the Palm trade dress, Smartcode, Simply Palm, WeSync and Wireless Refresh are trademarks of Palm, Inc. 
<BR><BR>
(**)
Visor, Visor Pro, Visor Edge, Visor Prism, Visor Neo, Visor Platinum, Visor Deluxe, Handspring are trademarks of Handspring, Inc.

			
	
		</TD>
	</TR>
</TABLE>

</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
