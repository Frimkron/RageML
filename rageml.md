% RageML
% Mark Frimston
% 2012-12-20

An XML markup language describing rage comics. Inspired by a stupid 
conversation over a django developer's rage comic blog post and its 
lack of indexability.

Should describe meaning rather than layout.

To be transformed by XSLT into an image. Raster if possible, svg 
otherwise, or html failing that. Ideally it should be embeddable 
in an img tag.


	<rage-comic>
		<panel>
			<trollface who="friend">Bet you can't drink a whole 
				bottle of tabasco</trollface>
		</panel>
		<panel>
			<challenge-accepted who="me"/>
		</panel>
		<panel>
			<narration>Later...</narration>
		</panel>
		<panel size="large">
			<rage who="me">FUUUUUUUUUU</rage>
		</panel>
	</rage-comic>
