package com.ffu.generator


import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.Domain
import com.ffu.policy.RoleRef
import com.ffu.policy.Everyone

// «»

class sqlGenerator{
	
	def static generate(Domain domain, Resource resource){
		'''
		CREATE TABLE Policies(
			ID uniqueidentifier,
			Role VARCHAR(255),
			Organization VARCHAR(255),
			Actions VARCHAR(255),
			Resource VARCHAR(255),
		)
		
		«FOR policy : domain.rolePolicies.filter[role instanceof RoleRef]»
			INSERT INTO Policies (ID, Role, Actions, Resource)
			VALUES(
				NEWID(),
				'«policy.role.getPolicyName»',
				'«policy.action.name»'
			)	
		«ENDFOR»
		
		'''
	}
	
	def static dispatch CharSequence getPolicyName(RoleRef ref)'''«ref.ref.name»'''
	def static dispatch CharSequence getPolicyName(Everyone everyone)'''Everyone'''
}
