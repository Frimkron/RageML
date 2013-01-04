<?xml version="1.0" encoding="utf-8" ?>
<stylesheet version="1.0" 
		xmlns="http://www.w3.org/1999/XSL/Transform" 
		xmlns:svg="http://www.w3.org/2000/svg" 
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:rg="http://markfrimston.co.uk/rageml">
	
	<!-- TODO: characters' dialogue lines -->

	<output method="xml" version="1.0" encoding="utf-8"/>

	<variable name="PANEL_W" select="350" /> <!-- Width of each panel -->
	<variable name="PANEL_H" select="330" /> <!-- Height of each panel -->
	<variable name="BORDER_W" select="20" /> <!-- Width of space around image -->
	<variable name="BORDER_H" select="20" /> <!-- Height of space around image -->
	
	<!-- Root template -->
	<template match="/">
		<svg:svg version="1.1" width="{ $PANEL_W * 2 + $BORDER_W * 2 }" 
				height="{ ceiling(count(rg:comic/rg:panel) div 2) * $PANEL_H + $BORDER_H * 2 }">
			<call-template name="panels">
				<with-param name="panelnode" select="rg:comic/rg:panel[1]" />
			</call-template>
		</svg:svg>
	</template>

	<!-- Renders panels recursively -->	
	<template name="panels">
	
		<param name="panelnode" />
		<param name="panelnum" select="0"/>
		<!-- default states of characters' faces as of previous panel -->
		<param name="def-faces" select="'[a:derp][b:derp][c:derp][d:derp][e:derp]'" />
		<!-- default sexes of characters as of previous panel -->
		<param name="def-sexes" select="'[a:m][b:m][c:m][d:m][e:m]'" />
		
		<!-- absolute position of panel -->
		<variable name="panelx" select="$BORDER_W + ($panelnum mod 2) * $PANEL_W" />
		<variable name="panely" select="$BORDER_H + floor($panelnum div 2) * $PANEL_H" />
		<!-- nodes representing character presences in this panel -->
		<variable name="charnodes" select="$panelnode/*[namespace-uri()=namespace-uri($panelnode) 
			and local-name()!='narration' and local-name()!='a-reply' and local-name()!='b-reply' 
			and local-name()!='c-reply' and local-name()!='d-reply' and local-name()!='e-reply']" />	
		<!-- current states of characters' faces after being overridden -->
		<variable name="faces">
			<call-template name="make-faces">
				<with-param name="charnodes" select="$charnodes" />
				<with-param name="elements" select="'abcde'" />
				<with-param name="def-faces" select="$def-faces" />
			</call-template>
		</variable>
		<!-- current sexes of characters after being overridden -->
		<variable name="sexes">
			<call-template name="make-sexes">
				<with-param name="charnodes" select="$charnodes" />
				<with-param name="elements" select="'abcde'" />
				<with-param name="def-sexes" select="$def-sexes" />
			</call-template>
		</variable>

		<!-- panel border -->
		<svg:rect x="{ $panelx }" y="{ $panely }" 
				width="{ $PANEL_W }" height="{ $PANEL_H }" stroke="black" 
				stroke-width="3" fill="white" fill-opacity="0.75" />
				
		<!-- iterate over character presences, named characters first, in name order
			i.e. the order of their visual positioning -->
		<for-each select="$charnodes">
			<sort select="concat(string(number(string-length(local-name()) &gt; 1)),local-name())" />
			<call-template name="character">
				<!-- placed in panel according to position in ordered set. Give each character 
					a vertical slice of the panel space -->
				<with-param name="x" select="$panelx + $PANEL_W div count($charnodes) * (position() - 1)" />
				<with-param name="y" select="$panely" />
				<with-param name="width" select="$PANEL_W div count($charnodes)" />
				<with-param name="height" select="$PANEL_H" />
				<with-param name="lines" select="TODO" />
				<!-- for named characters, look up overidden face. For others, just use face name -->
				<with-param name="face">
					<choose>
						<when test="string-length(local-name()) = 1">
							<value-of select="substring-before(substring-after(
								$faces,concat('[',local-name(),':')),']')" />
						</when>
						<otherwise>
							<value-of select="local-name()" />
						</otherwise>
					</choose>
				</with-param>
				<!-- for named characters, look up overridden sex. For others, just default to male -->
				<with-param name="sex">
					<choose>
						<when test="string-length(local-name()) = 1">
							<value-of select="substring-before(substring-after(
								$sexes,concat('[',local-name(),':')),']')" />
						</when>
						<otherwise>
							<value-of select="'m'" />
						</otherwise>
					</choose>
				</with-param>
			</call-template>
		</for-each>
		
		<!-- recurse to the next panel, if present -->
		<if test="$panelnode/following-sibling::rg:panel">
			<call-template name="panels">
				<with-param name="panelnode" select="$panelnode/following-sibling::rg:panel[1]" />	
				<with-param name="panelnum" select="$panelnum + 1" />
				<!-- pass overidden character properties through to next panel -->
				<with-param name="def-faces" select="$faces" />
				<with-param name="def-sexes" select="$sexes" />
			</call-template>
		</if>
		
	</template>

	<!-- Renders a character presence -->	
	<template name="character">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="lines" />
		<param name="face" />
		<param name="sex" />
		
		<svg:rect x="{$x+5}" y="{$y+5}" width="{$width - 10}" height="{$height - 10}" 
				stroke="red" fill="none" stroke-dasharray="8,8" />
		
		<svg:text x="{$x}" y="{$y +20}" font-size="8px"><value-of select="concat('x: ',$x)" /></svg:text>
		<svg:text x="{$x}" y="{$y +40}" font-size="8px"><value-of select="concat('y: ',$y)" /></svg:text>
		<svg:text x="{$x}" y="{$y +60}" font-size="8px"><value-of select="concat('width: ',$width)" /></svg:text>
		<svg:text x="{$x}" y="{$y +80}" font-size="8px"><value-of select="concat('height: ',$height)" /></svg:text>
		<svg:text x="{$x}" y="{$y+100}" font-size="8px"><value-of select="concat('lines: ',$lines)" /></svg:text>
		<svg:text x="{$x}" y="{$y+120}" font-size="8px"><value-of select="concat('face: ',$face)" /></svg:text>
		<svg:text x="{$x}" y="{$y+140}" font-size="8px"><value-of select="concat('sex: ',$sex)" /></svg:text>
		
	</template>
	
	<!-- Prepares character face data for the given named character elements by
		overriding the given defaults with any face change specified in the 
		character nodes -->
	<template name="make-faces">
		<param name="charnodes" />
		<param name="def-faces" />
		<param name="elements" />
		<param name="curr-faces" select="''"/>
		<!-- current named character element name -->
		<variable name="el" select="substring($elements,1,1)" />
		<!-- if character node contains an element, override with this face,
				otherwise look up default -->
		<variable name="faces">
			<value-of select="concat($curr-faces,'[',$el,':')" />
			<choose>
				<when test="$charnodes[local-name()=$el]/*">
					<value-of select="local-name($charnodes[local-name()=$el]/*)" />
				</when>
				<otherwise>
					<value-of select="substring-before(substring-after(
						$def-faces,concat('[',$el,':')),']')" />
				</otherwise>
			</choose>
			<value-of select="']'" />
		</variable>
		<!-- Recurse to process next named character element, or output result if at end -->
		<choose>
			<when test="string-length($elements) &gt; 1">
				<call-template name="make-faces">
					<with-param name="charnodes" select="$charnodes" />
					<with-param name="def-faces" select="$def-faces" />
					<with-param name="elements" select="substring($elements,2)" />
					<with-param name="curr-faces" select="$faces" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$faces" />
			</otherwise>
		</choose>
	</template>
	
	<!-- Prepares character sex data for the given named character elements by
		overriding the given defaults with any sex specified in the character nodes -->
	<template name="make-sexes">
		<param name="charnodes" />
		<param name="def-sexes" />
		<param name="elements" />
		<param name="curr-sexes" select="''" />
		<!-- current named character element name -->
		<variable name="el" select="substring($elements,1,1)" />
		<!-- if character node has sex attribute, override with this sex,
				otherwise look up default -->
		<variable name="sexes">
			<value-of select="concat($curr-sexes,'[',$el,':')" />
			<choose>
				<when test="$charnodes[local-name()=$el]/@sex">
					<value-of select="$charnodes[local-name()=$el]/@sex" />
				</when>
				<otherwise>
					<value-of select="substring-before(substring-after(
						$def-sexes,concat('[',$el,':')),']')" />
				</otherwise>
			</choose>
			<value-of select="']'" />
		</variable>
		<!-- Recurse to process next named character element, or output result if at end -->
		<choose>
			<when test="string-length($elements) &gt; 1">
				<call-template name="make-sexes">
					<with-param name="charnodes" select="$charnodes" />
					<with-param name="def-sexes" select="$def-sexes" />
					<with-param name="elements" select="substring($elements,2)" />
					<with-param name="curr-sexes" select="$sexes" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$sexes" />
			</otherwise>	
		</choose>
	</template>
	
	<!-- Renders the given text as character dialogue, attempting to wrap to
		the given width -->
	<template name="dialogue-text">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="text" />
		<!--<svg:text y="{ $y }" font-size="18px" font-family="courier new,courier,monospace" 
				fill="white" text-anchor="middle" stroke="white" stroke-width="6">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="20" />
				<with-param name="chars" select="round($width div 12)" />
				<with-param name="text" select="normalize-space($text)"/>
			</call-template>
		</svg:text>-->
		<svg:text y="{ $y }" font-size="16px" font-family="courier new,courier,monospace" 
				fill="black" text-anchor="middle" stroke="none">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="18" />
				<with-param name="chars" select="round($width div 11)" />
				<with-param name="text" select="normalize-space($text)"/>
			</call-template>
		</svg:text>
	</template>
	
	<!-- Renders the given text on multiple lines by limiting each line to the 
		given number of characters. Recurses to handle one token at a time -->
	<template name="wrap-text">
		<param name="x" />
		<param name="chars"/>
		<param name="lineheight" />
		<param name="text" />
		<param name="line" select="''" />
		
		<!-- The next token -->
		<variable name="head">
			<choose><when test="contains($text,' ')"><value-of select="substring-before($text,' ')"/></when>
				<otherwise><value-of select="$text" /></otherwise></choose>
		</variable>
		<!-- The rest of the tokens -->
		<variable name="tail">
			<choose><when test="contains($text,' ')"><value-of select="substring-after($text,' ')"/></when>
				<otherwise><value-of select="''" /></otherwise></choose>
		</variable>
		<!-- The current line with new token added -->
		<variable name="appended">
			<choose><when test="string-length($line) &gt; 0"><value-of select="concat($line,' ',$head)"/></when>
				<otherwise><value-of select="$head" /></otherwise></choose>
		</variable>
		
		<choose>
			<!-- if token pushes line length over limit, render the line without it and 
				recurse, starting a new line. But don't do this if the first token on the 
				line is itself longer than the line limit - we accept this line despite 
				its length and don't wrap until the next token -->
			<when test="string-length($appended) &gt; $chars and string-length($line) &gt; 0">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="$line" />
				</svg:tspan>
				<call-template name="wrap-text">
					<with-param name="x" select="$x" />
					<with-param name="chars" select="$chars" />
					<with-param name="lineheight" select="$lineheight" />
					<with-param name="text" select="$text" />
					<with-param name="line" select="''" />
				</call-template>
			</when>
			<!-- if there are no more tokens, render the remaining line and stop -->
			<when test="string-length($tail) = 0">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="$appended" />
				</svg:tspan>
			</when>
			<!-- Otherwise, recurse to the next token on the current line -->
			<otherwise>
				<call-template name="wrap-text">
					<with-param name="x" select="$x" />
					<with-param name="chars" select="$chars" />
					<with-param name="lineheight" select="$lineheight" />
					<with-param name="text" select="$tail" />
					<with-param name="line" select="$appended" />
				</call-template>
			</otherwise>
		</choose>
	</template>
	
	<!-- Find the combined lengths of the text nodes contained in the given nodes -->
	<template name="sum-lengths">
		<param name="nodes" />
		<param name="accumulated" select="0"/>
		<variable name="val" select="$accumulated + string-length($nodes/text())" />
		<choose>
			<when test="$nodes/following-sibling::*">
				<call-template name="sum-lengths"> 
					<with-param name="nodes" select="$nodes/following-sibling::*" />
					<with-param name="accumulated" select="$val" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$val" />
			</otherwise>
		</choose>
	</template>
	
</stylesheet>
