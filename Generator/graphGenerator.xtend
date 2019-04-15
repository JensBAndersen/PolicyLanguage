package com.ffu.generator


import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.Domain
import com.ffu.policy.Organization

// «»

class graphGenerator{
	
	def static generate(Domain domain, Resource resource){
		
		'''
		digraph D {

		«OrganizationCreation(domain.organization)»

		

		«OrganizationRelation(domain.organization)»

		
		}
		'''
		
	}
	
	
	def static CharSequence OrganizationCreation(Organization org){
		var returnString = '''
			«org.name» [shape=box]
			«FOR subOrg: org.organizations»
				«OrganizationCreation(subOrg)»
			«ENDFOR»
		'''
		
		return returnString
	}
	
	def static CharSequence OrganizationRelation(Organization org){	
		var returnString = '''
			«FOR subOrg: org.organizations»
				«org.name» -> «subOrg.name» [penwidth = 1]
				«OrganizationRelation(subOrg)»
			«ENDFOR»
		'''
		
		return returnString
	}
}
