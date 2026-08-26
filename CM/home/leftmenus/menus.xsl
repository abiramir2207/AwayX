<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

<xsl:template match="/">
	<LINK REL="stylesheet" TYPE="text/css" HREF="Leftmenus/menus.css" />
	<SCRIPT LANGUAGE="JScript" SRC="Leftmenus/menus.js"></SCRIPT>

	<DIV ID="divMenuBar" STYLE="display: inline;">
	<TABLE ID="tblMenuBar" BORDER="0">
	<xsl:for-each select="//TOPICS[TOPIC]">
	<TR>
		<TD CLASS="clsMenuBarItem">
			<xsl:attribute name="ID">tdMenuBarItem<xsl:value-of select="@TYPE" /></xsl:attribute>
			<xsl:value-of select="@TYPE" />
		</TD>
	</TR>
	</xsl:for-each>
	</TABLE>
	</DIV>

	<xsl:for-each select="//TOPICS[TOPIC]">
		<DIV CLASS="clsMenu">
		<xsl:attribute name="ID">divMenu<xsl:value-of select="@TYPE" /></xsl:attribute>
			<DIV CLASS="clsMenuSpacer"></DIV>
			<xsl:for-each select="TOPIC">
			<DIV>
			<A TARGET="mainwindow" STYLE="font-family: Arial;" onclick="CloseMenu(eOpenMenu);">
				<xsl:attribute name="HREF"><xsl:value-of select="URL" /></xsl:attribute>
				<xsl:value-of select="TITLE" />
			</A>
			</DIV>
			</xsl:for-each>
		</DIV>
	</xsl:for-each>
	
</xsl:template>

</xsl:stylesheet>