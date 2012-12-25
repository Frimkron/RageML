<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:output method="xml" version="1.0" encoding="utf-8"/>

	<xsl:variable name="PANEL_W" select="350" />
	<xsl:variable name="PANEL_H" select="330" />
	<xsl:variable name="BORDER_W" select="20" />
	<xsl:variable name="BORDER_H" select="20" />
	
	<xsl:template match="/">
		<svg version="1.1" width="{ $PANEL_W * 2 + $BORDER_W * 2 }" 
				height="{ ceiling(count(/rage-comic/panel) div 2) * $PANEL_H + $BORDER_H * 2}">
			<xsl:apply-templates select="/rage-comic/panel" />
		</svg>
	</xsl:template>
	
	<xsl:template match="panel">
		<xsl:variable name="panelnum" select="position() - 1" />
		<rect x="{ ($panelnum mod 2) * $PANEL_W + $BORDER_W }" 
				y="{ floor($panelnum div 2) * $PANEL_H + $BORDER_H }" 
				width="{ $PANEL_W }" height="{ $PANEL_H }" stroke="black" stroke-width="3" fill="white" fill-opacity="0.75"/>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="trollface">
		<xsl:variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<image x="{ ($panelnum mod 2) * $PANEL_W + $BORDER_W }"
				y="{ floor($panelnum div 2) * $PANEL_H + $BORDER_H }"
				width="{ $PANEL_W }" height="{ $PANEL_H }"
				xlink:href="images/trollface.png" />
	</xsl:template>
	
	<xsl:template match="challenge-accepted">
		<xsl:variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<image x="{ ($panelnum mod 2) * $PANEL_W + $BORDER_W }" 
				y="{ floor($panelnum div 2) * $PANEL_H + $BORDER_H }" 
				width="{ $PANEL_W }" height="{ $PANEL_H }" 
				xlink:href="images/challenge_accepted.png"/>
	</xsl:template>
	
	<xsl:template match="rage">
		<xsl:variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<image x="{ ($panelnum mod 2) * $PANEL_W + $BORDER_W }"
				y="{ floor($panelnum div 2) * $PANEL_H + $BORDER_H }"
				width="{ $PANEL_W }" height="{ $PANEL_H }"
				xlink:href="images/rage.png" />
	</xsl:template>
	
	<xsl:template match="narration">
		<xsl:variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<text x="{ ($panelnum mod 2) * $PANEL_W + $BORDER_W + $PANEL_W div 2 }"
				y="{ floor($panelnum div 2) * $PANEL_H + $BORDER_H + $PANEL_H div 2}"
				width="{ $PANEL_W }" height="{ $PANEL_H }" font-size="20pt"
				font-family="sans-serif">
			<xsl:value-of select="." />		
		</text>
	</xsl:template>
	
</xsl:stylesheet>
