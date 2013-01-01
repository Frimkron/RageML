
class Indenter(object):
	
	def __init__(self,indentstr="    "):
		self.indentstr = indentstr
		self.indentlev = 0
	
	def indent(self):
		self.indentlev += 1
		
	def unindent(self):
		self.indentlev -= 1
		
	def line(self,text):
		return self.indentstr * self.indentlev + text


class Seq(tuple):
	def __repr__(self):
		return "Seq%s" % tuple.__repr__(self)
		

class Cho(tuple):
	def __repr__(self):
		return "Cho%s" % tuple.__repr__(self)
		

def options(opts):
	result = []
	for i in range(len(opts)):
		item = opts[i]
		rest = list(opts)
		rest.remove(item)
		rest = tuple(rest)
		if len(rest) > 0:
			result.append(Seq((item, options(rest))))
		else:
			result.append(item)
	if len(result) > 1:
		return Cho(result)
	else:
		return result[0]


def print_xsd(subtree,indenter=None,optional=False):
	if indenter is None: indenter = Indenter()
	if isinstance(subtree,Seq):
		print indenter.line('<sequence%s>' % (' minOccurs="0"' if optional else '',))
		indenter.indent()
		for item in subtree[:-1]:
			print_xsd(item,indenter)
		print_xsd(subtree[-1],indenter,True)
		indenter.unindent()
		print indenter.line('</sequence>')
	elif isinstance(subtree,Cho):
		print indenter.line('<choice%s>' % (' minOccurs="0"' if optional else '',))
		indenter.indent()
		for item in subtree:
			print_xsd(item,indenter)
		indenter.unindent()
		print indenter.line('</choice>')
	else:
		print indenter.line('<element ref="%s" %s/>' % (subtree,
			' minOccurs="0"' if optional else ''))
		

print_xsd(options(("rg:a","rg:b","rg:c","rg:d","rg:e")))
