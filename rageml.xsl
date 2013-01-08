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
	<variable name="NAMESPACE" select="'http://markfrimston.co.uk/rageml'" /> <!-- Namespace URI -->
	<variable name="SILENTS" select="'[derp][trollface]'" /> <!-- Face types with no implied dialogue -->
	
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
		<!-- nodes representing lines of dialogue in this panel -->
		<variable name="linenodes" select="$panelnode/*[namespace-uri()=$NAMESPACE 
			and local-name()!='narration' and ( descendant::text()
				or (not(contains($SILENTS,concat('[',local-name(),']'))) and not(descendant::silent)) )]" />
		<!-- nodes representing character presences in this panel -->
		<variable name="charnodes" select="$panelnode/*[namespace-uri()=$NAMESPACE
			and local-name()!='narration' and substring(local-name(),2)!='-reply']" />	
		
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
			<variable name="elname" select="local-name()" />
			<call-template name="character">
				<!-- placed in panel according to position in ordered set. Give each character 
					a vertical slice of the panel space -->
				<with-param name="x" select="$panelx + $PANEL_W div count($charnodes) * (position() - 1)" />
				<with-param name="y" select="$panely" />
				<with-param name="width" select="$PANEL_W div count($charnodes)" />
				<with-param name="height" select="$PANEL_H" />
				<!-- direct children of panel representing dialogue lines for character -->
				<with-param name="linenodes" select=". | $linenodes[local-name()=concat($elname,'-reply')]" />
				<with-param name="totallines" select="count($linenodes)" />
				<!-- for named characters, look up overidden face. For others, just use face name -->
				<with-param name="face">
					<choose>
						<when test="string-length($elname) = 1">
							<value-of select="substring-before(substring-after(
								$faces,concat('[',$elname,':')),']')" />
						</when>
						<otherwise>
							<value-of select="$elname" />
						</otherwise>
					</choose>
				</with-param>
				<!-- for named characters, look up overridden sex. For others, just default to male -->
				<with-param name="sex">
					<choose>
						<when test="string-length($elname) = 1">
							<value-of select="substring-before(substring-after(
								$sexes,concat('[',$elname,':')),']')" />
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

	<!-- Renders and individual character presence -->
	<template name="character">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="linenodes" />
		<param name="totallines" />
		<param name="face" />
		<param name="sex" />		

		<variable name="imgsize">
			<choose>
				<when test="$width &gt; $height * 0.75">
					<value-of select="$height * 0.75" />
				</when>
				<otherwise>
					<value-of select="$width" />
				</otherwise>
			</choose>
		</variable>
		<variable name="textheight" select="$height - $imgsize" />

		<choose>
			<!-- WIP:
				* make <silent /> valid in xsd
				* text positioning for special faces
				* clip all text to its panel
			-->
			<when test="$face = 'challenge-accepted'">
				<variable name="linepos" select="count($linenodes[1]/preceding-sibling::*[ namespace-uri()=$NAMESPACE 
					and local-name()!='narration' and ( descendant::text() 
						or (not(contains($SILENTS,concat('[',local-name(),']'))) and not(descendant::silent)) )])" />
				<variable name="textsize" select="0.25 + ($width div $PANEL_W) * 0.75" />
				<svg:image x="{$x + $width div 2 - $imgsize div 2}" y="{$y + $textheight}" 
					width="{$imgsize}" height="{$imgsize}" xlink:href="images/{$face}.png" />
				<svg:text font-family="impact,sans-serif" font-weight="bold" fill="black"
						font-size="{24 * $textsize}px" 
						y="{$y + 20 * $textsize + $textheight div $totallines * $linepos}"
						text-anchor="middle">
					<call-template name="wrap-text">
						<with-param name="x" select="$x + $width div 2" />
						<with-param name="chars" select="$width div (18 * $textsize)" />
						<with-param name="lineheight" select="28 * $textsize" />
						<with-param name="text">
							<choose>
								<when test="$linenodes[1]/descendant::text()">
									<value-of select="$linenodes[1]/descendant::text()" />
								</when>
								<when test="$linenodes[1]/descendant::silent">
								</when>
								<otherwise>
									<value-of select="'CHALLENGE ACCEPTED'" />
								</otherwise>
							</choose>
						</with-param>
					</call-template>
				</svg:text>
			</when>
			<when test="$face = 'rage'">
				<variable name="linepos" select="count($linenodes[1]/preceding-sibling::*[ namespace-uri()=$NAMESPACE 
					and local-name()!='narration' and ( descendant::text() 
						or (not(contains($SILENTS,concat('[',local-name(),']'))) and not(descendant::silent)) )])" />
				<variable name="textsize" select="0.25 + ($width div $PANEL_W) * 0.75" />
				<svg:text font-family="impact,sans-serif" font-weight="bold" fill="red" 
						font-size="{30 * $textsize}px" 
						y="{$y + 10 * $textsize + $textheight div $totallines * $linepos}">
					<call-template name="wrap-text">
						<with-param name="x" select="$x + 10 * $textsize" />
						<with-param name="chars" select="$width div (26 * $textsize)" />
						<with-param name="lineheight" select="30 * $textsize" />
						<with-param name="text">
							<choose>
								<when test="$linenodes[1]/descendant::text()">
									<value-of select="$linenodes[1]/descendant::text()" />
								</when>
								<when test="$linenodes[1]/descendant::silent">
								</when>
								<otherwise>						
									<value-of select="'FFFFFFFFFFFFFFUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU'" />
								</otherwise>
							</choose>
						</with-param>
					</call-template>
				</svg:text>
				<svg:image x="{$x}" y="{$y + $textheight}" width="{$imgsize}" 
					height="{$imgsize}" xlink:href="images/{$face}.png"/>
			</when>
			<otherwise>
				<svg:image x="{$x + $width div 2 - $imgsize div 2}" y="{$y + $textheight}" width="{$imgsize}" height="{$imgsize}" 
					xlink:href="images/{$face}.png" />
				<for-each select="$linenodes">
					<variable name="linepos" select="count(preceding-sibling::*[ namespace-uri()=$NAMESPACE 
						and local-name()!='narration' and ( descendant::text() 
								or (not(contains($SILENTS,concat('[',local-name(),']'))) and not(descendant::silent)) )])" />
					<call-template name="dialogue-text">
						<with-param name="x" select="$x + $width div 2" />
						<with-param name="y" select="$y + 20 + $textheight div $totallines * $linepos" />
						<with-param name="width" select="$width" />
						<with-param name="text" select="string(.)" />
					</call-template>
				</for-each>
			</otherwise>
		</choose>
	</template>

	<!--<template match="rage">
		<variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<variable name="panelx" select="($panelnum mod 2) * $PANEL_W + $BORDER_W" />
		<variable name="panely" select="floor($panelnum div 2) * $PANEL_H + $BORDER_H" />
		<variable name="content">
			<choose>
				<when test="text()"><value-of select="text()" /></when>
				<otherwise><value-of select="'FFFFFFUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU'" /></otherwise>
			</choose>
		</variable>
		<variable name="pathid" select="generate-id(.)" />
		<svg:image x="{ $panelx }" y="{ $panely + $PANEL_H * 0.25 }"
				width="{ $PANEL_W * 0.75 }" height="{ $PANEL_H * 0.75 }"
				xlink:href="images/rage.png" />
		<svg:path d="M{$panelx+10},{$panely+30} L{$panelx+$PANEL_W -10},{$panely+30} 
					M{$panelx+10},{$panely+60} L{$panelx+$PANEL_W -10},{$panely+60}  
					M{$panelx+10},{$panely+90}  L{$panelx+$PANEL_W -10},{$panely+90}
					M{$panelx+$PANEL_W*0.75},{$panely+120} L{$panelx+$PANEL_W -10},{$panely+120}
					M{$panelx+$PANEL_W*0.75},{$panely+150} L{$panelx+$PANEL_W -10},{$panely+150}
					M{$panelx+$PANEL_W*0.75},{$panely+180} L{$panelx+$PANEL_W -10},{$panely+180}
					M{$panelx+$PANEL_W*0.75},{$panely+210} L{$panelx+$PANEL_W -10},{$panely+210}
					M{$panelx+$PANEL_W*0.75},{$panely+240} L{$panelx+$PANEL_W -10},{$panely+240}
					M{$panelx+$PANEL_W*0.75},{$panely+270} L{$panelx+$PANEL_W -10},{$panely+270}
					M{$panelx+$PANEL_W*0.75},{$panely+300} L{$panelx+$PANEL_W -10},{$panely+300}"
				stroke="none" fill="none" id="{$pathid}" />
		<svg:text font-family="impact,sans-serif" font-weight="bold" fill="red" font-size="20pt">
			<svg:textPath xlink:href="#{$pathid}">
				<value-of select="$content" />
			</svg:textPath>
		</svg:text>
	</template>-->
	
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
		<!--<svg:text y="{ $y }" font-size="16px" font-family="courier new,courier,monospace" 
				fill="white" text-anchor="middle" stroke="white" stroke-width="8">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="18" />
				<with-param name="chars" select="round($width div 11)" />
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
			<!-- if token alone is larger than the whole line limit, render line 
				with start of token and recurse, starting a new line with remainder 
				of the token, thereby breaking the word over multiple lines  -->
			<when test="string-length($head) &gt; $chars">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="concat($line,' ',substring($head,1,$chars - (string-length($line)+1) + 1))" />
				</svg:tspan>
				<call-template name="wrap-text">
					<with-param name="x" select="$x" />
					<with-param name="chars" select="$chars" />
					<with-param name="lineheight" select="$lineheight" />
					<with-param name="text" select="concat(substring($head,$chars - (string-length($line)+1) + 2),' ',$tail)" />
					<with-param name="line" select="''" />
				</call-template>
			</when>		
			<!-- if token pushes line length over limit when appended to current line, 
				render the line without it and recurse, starting a new line.  -->
			<when test="string-length($appended) &gt; $chars">
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
