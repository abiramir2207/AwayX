<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" />
	<xsl:template match="/">
		<html>
			<head>
				<title></title>
				<style>
				a:link{color:blue;text-decoration:none;font-size:8pt;font-family:verdana;}
				a:visited{color:blue;text-decoration:none;font-size:8pt;font-family:verdana;}
				a:hover{color:blue;text-decoration:underline;font-size:8pt;font-family:verdana;}
				</style>
			</head>
		</html>
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="menu">
		<div>
			<xsl:variable name="icon">
				<xsl:choose>
					<xsl:when test="@icon">
						<xsl:value-of select="concat('/images/position_tree/',@icon)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'/images/position_tree//home.gif'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="' '" />
			<xsl:call-template name="hrefLink">
				<xsl:with-param name="hrefContents" select="@href" />
				<xsl:with-param name="linkLabel" select="@caption" />
				<xsl:with-param name="parensText" select="@parensdata" />
			</xsl:call-template>

			<xsl:value-of select="' '" />
			<xsl:call-template name="positionLabelFormat">
				<xsl:with-param name="positionLabel" select="@label" />
			</xsl:call-template>

			<xsl:apply-templates />
		</div>
	</xsl:template>
	<xsl:template match="menuItem">
		<xsl:variable name="hasChild">
			<xsl:if test="menuItem">true</xsl:if>
		</xsl:variable>
		<xsl:variable name="prefix">
			<xsl:choose>
				<xsl:when test="position()=last()">
					<xsl:text>L</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>T</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<table width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="$hasChild='true'">
							<xsl:variable name="myId" select="generate-id()" />
							<xsl:variable name="icon1">
								<xsl:choose>
									<xsl:when test="@icon">
										<xsl:value-of select="concat('/images/position_tree/',@icon)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="'/images/position_tree/folder-closed.gif'" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="style">
								<xsl:if test="position() &lt; last()">
									<xsl:text>border-left:1px dotted #978E7B;</xsl:text>
								</xsl:if>
							</xsl:variable>
							<xsl:variable name="display">
								<xsl:choose>
									<xsl:when test="@opened='true'">
										<xsl:text>block</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>none</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="img">
								<xsl:choose>
									<xsl:when test="@opened='true'">
										<xsl:text>minus</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>plus</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="bgColor">
								<xsl:choose>
									<xsl:when test="@level='II'">
										<xsl:text>#006633</xsl:text>
									</xsl:when>
									<xsl:when test="@level='III'">
										<xsl:text>#003399</xsl:text>
									</xsl:when>
									<xsl:when test="@level='B'">
										<xsl:text>#FFCC00</xsl:text>
									</xsl:when>
									<xsl:when test="@level='D'">
										<xsl:text>#CC3300</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>red</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<div onclick="toggle('{$myId}','','','{$prefix}')">
								<img src="/images/position_tree/{$prefix}{$img}.gif" border="0" align="absMiddle" id="picon{$myId}" />
								<span class="levelLabel" style="background-color:{$bgColor}"><xsl:value-of select="@level" /></span><xsl:value-of select="' '" />
								<xsl:value-of select="' '" />

								<xsl:call-template name="hrefLink">
									<xsl:with-param name="hrefContents" select="@href" />
									<xsl:with-param name="linkLabel" select="@caption" />
									<xsl:with-param name="parensText" select="@parensdata" />
								</xsl:call-template>

								<xsl:value-of select="' '" />
								<xsl:call-template name="positionLabelFormat">
									<xsl:with-param name="positionLabel" select="@label" />
								</xsl:call-template>

							</div>
							<div style="padding-left:8px;">
								<table border="0" style="{$style}" cellspacing="0" cellpadding="0">
									<tr>
										<td>
											<span id="{$myId}" style="display:{$display};padding-left:10px;">
												<xsl:apply-templates />
											</span>
										</td>
									</tr>
								</table>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="icon">
								<xsl:choose>
									<xsl:when test="@icon">
										<xsl:value-of select="concat('/images/position_tree/',@icon)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="fileIcon">
											<xsl:with-param name="ext" select="substring-after(@caption,'.')" />
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="doc">
								<xsl:choose>
									<xsl:when test="position()=last()">
										<xsl:text>/images/position_tree/l.gif</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>/images/position_tree/t.gif</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<div style="margin-left:19px">
								<xsl:if test="@action!=''">
									<xsl:attribute name="onclick">
										<xsl:text>alert('Action: </xsl:text>
										<xsl:value-of select="@action" />
										<xsl:text>')</xsl:text>
									</xsl:attribute>
								</xsl:if>
								<xsl:variable name="href">
									<xsl:choose>
										<xsl:when test="@href!=''">
											<xsl:value-of select="@href" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>#</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="bgColor">
									<xsl:choose>
										<xsl:when test="@level='II'">
											<xsl:text>#006633</xsl:text>
										</xsl:when>
										<xsl:when test="@level='III'">
											<xsl:text>#003399</xsl:text>
										</xsl:when>
										<xsl:when test="@level='B'">
											<xsl:text>#FFCC00</xsl:text>
										</xsl:when>
										<xsl:when test="@level='D'">
											<xsl:text>#CC3300</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>red</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<span class="levelLabel" style="background-color:{$bgColor}"><xsl:value-of select="@level" /></span><xsl:value-of select="' '" />
								<xsl:value-of select="' '" />
								<xsl:call-template name="hrefLink">
									<xsl:with-param name="hrefContents" select="@href" />
									<xsl:with-param name="linkLabel" select="@caption" />
									<xsl:with-param name="parensText" select="@parensdata" />
								</xsl:call-template>

								<xsl:value-of select="' '" />
								<xsl:call-template name="positionLabelFormat">
									<xsl:with-param name="positionLabel" select="@label" />
								</xsl:call-template>

							</div>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="fileIcon">
		<xsl:param name="ext" />
		<xsl:variable name="icon">
			<xsl:choose>
				<xsl:when test="$ext='doc' or $ext='rtf' ">
					<xsl:text>doc3</xsl:text>
				</xsl:when>
				<xsl:when test="$ext='htm' or $ext='html' ">
					<xsl:text>doc2</xsl:text>
				</xsl:when>
				<xsl:when test="$ext='zip'">
					<xsl:text>doc4</xsl:text>
				</xsl:when>
				<xsl:when test="$ext='tmp'">
					<xsl:text>windows</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>doc1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('/images/position_tree/',$icon,'.gif')" />
	</xsl:template>

	<xsl:template name="hrefLink">
		<xsl:param name="hrefContents" />
		<xsl:param name="linkLabel" />
		<xsl:param name="parensText" />


		<xsl:choose>
			<xsl:when test="$hrefContents!=''">
				<A href="{$hrefContents}"><xsl:value-of select="$linkLabel" /></A>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$linkLabel" />
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="$parensText!=''">  -  <b>( <xsl:value-of select="$parensText" /> )</b></xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="positionLabelFormat">
		<xsl:param name="positionLabel" />

		<xsl:choose>
			<xsl:when test="$positionLabel!=''">
				<xsl:value-of select="' '" />
				- <b><xsl:value-of select="$positionLabel" /></b>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
