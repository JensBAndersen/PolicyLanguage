package com.ffu.generator

import com.ffu.policy.Action
import com.ffu.policy.Domain
import com.ffu.policy.RoleRef
import com.ffu.policy.pResource
import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.EntityPolicy
import com.ffu.policy.OR
import com.ffu.policy.AND
import com.ffu.policy.Comparison
import com.ffu.policy.StringComparison
import com.ffu.policy.Bool
import com.ffu.policy.Add
import com.ffu.policy.Sub
import com.ffu.policy.Mul
import com.ffu.policy.Div
import com.ffu.policy.RelationalOp
import com.ffu.policy.RelEQ
import com.ffu.policy.RelLT
import com.ffu.policy.RelGT
import com.ffu.policy.RelLTE
import com.ffu.policy.RelGTE
import com.ffu.policy.IntExp
import com.ffu.policy.RelNEQ
import com.ffu.policy.StringOp
import com.ffu.policy.EntityProperty
import com.ffu.policy.Property
import org.eclipse.emf.common.util.EList
import com.ffu.policy.StringPrim

// «»

class policyHandlerGenerator{
	def static generate(Domain domain, Resource resource){
		
	'''
	package dk.nielshvid.intermediator;
	
	import java.util.HashMap;
	
	public class PolicyHandler {
	
		private static HashMap<String, HashMap<String,Boolean>> rolePolicyMap = new HashMap<String, HashMap<String, Boolean>>() {{
			«FOR _role: domain.roles»
				put("«_role.name»", new HashMap<String,Boolean>(){{
					«FOR policy: domain.rolePolicies.filter[role.roleRefs instanceof RoleRef].filter[role.roleRefs.ref.name.equals(_role.name)]»
						put("«findResource(policy.action)»/«policy.action.name»", true);
					«ENDFOR»
				}});
			«ENDFOR»
		}};
		
		private static HashMap<String, HashMap<String,Boolean>> entityPolicyMap = new HashMap<String, HashMap<String, Boolean>>() {{
			«FOR _entity: domain.entities»
				put("«_entity.name»", new HashMap<String,Boolean>(){{

				«FOR _resource: domain.resources»
					«FOR _action: _resource.actions»
					«var t = domain.entityPolicies.filter[_entity.name.equals(entity.name)].findFirst[(findResource(action) + "/" +action.name).equals(_resource.name + "/" + _action.name)]»
						put("«_resource.name»/«_action.name»", «printCondition(t)»);
					«ENDFOR»
				«ENDFOR»
				}});
			«ENDFOR»

		}};
	
	   public boolean roleAuthorize(String Role, String Action){
	       try {
	           return rolePolicyMap.get(Role).get(Action);
	       }
	       catch (Exception e){
	           return false;
	       }
	   }
	}
	'''
		
	}
	
	def static CharSequence printCondition(EntityPolicy EP){
		var returnVar = ""
		if(EP !== null){
			returnVar = EP.require.requirement.generateLogic.toString;
		} else {
			returnVar = "null"
		}
		
		return returnVar;
	}
		
	def static dispatch CharSequence generateLogic(OR x) '''(«x.left.generateLogic»||«x.right.generateLogic»)'''
	def static dispatch CharSequence generateLogic(AND x) '''(«x.left.generateLogic»&&«x.right.generateLogic»)'''
	def static dispatch CharSequence generateLogic(Comparison x) '''(«x.left.generateExp» «x.op.generateOp» «x.right.generateExp»)'''
	def static dispatch CharSequence generateLogic(Bool x) '''«x.bool»'''
	def static dispatch CharSequence generateLogic(StringPrim x) '''("«x.value»")'''
	def static dispatch CharSequence generateLogic(StringComparison x) '''«x.operator.generateStringOp»(«x.left».equals(«x.right»))'''
	
	def static dispatch CharSequence generateExp(Add x) '''(«x.left.generateExp»+«x.right.generateExp»)'''
	def static dispatch CharSequence generateExp(Sub x) '''(«x.left.generateExp»-«x.right.generateExp»)'''
	def static dispatch CharSequence generateExp(Mul x) '''(«x.left.generateExp»*«x.right.generateExp»)'''
	def static dispatch CharSequence generateExp(Div x) '''(«x.left.generateExp»/«x.right.generateExp»)'''
	def static dispatch CharSequence generateExp(IntExp x) '''«x.value»'''
	def static dispatch CharSequence generateExp(EntityProperty x) '''
«««	OracleClient.get«x.entity.name»(map.getFirst("sampleID"))«findProperty(x.property)»
	'''

	
	def static generateOp(RelationalOp op) {
		switch op {	RelEQ: '==' RelLT: '<' RelGT: '>' RelLTE: '<=' RelGTE: '>=' RelNEQ: '!=' }
	}
	
	def static generateStringOp(StringOp op) {
		switch op {	RelEQ: '' RelNEQ: '!' }
	}
	
	def static dispatch CharSequence getResourceName(pResource re){
		re.name
	}
	def static dispatch CharSequence getResourceName(Action re){
	}
	
	def static CharSequence findResource(Action action){
		action.eContainer.getResourceName
	}	
	
	def static CharSequence findProperty(EList<Property> properties){
		var returnVar = "";
		for(x: properties){
			returnVar += "." + x.name
		}
		return returnVar;
	}
}
