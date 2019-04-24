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
import com.ffu.policy.StringPrim
import com.ffu.policy.EntityPropertyRef
import com.ffu.policy.RolePolicy
import com.ffu.policy.rComparison
import com.ffu.policy.QueryParamRef
import com.ffu.policy.tString
import com.ffu.policy.tInt
import com.ffu.policy.tFloat
// «»

class policyHandlerGenerator{
	def static generate(Domain domain, Resource resource){
		
	'''
	package dk.nielshvid.intermediator;
	
	import java.util.HashMap;
	
	public class PolicyHandler {
		private int CheckCounter = 0;
	
		private static HashMap<String, HashMap<String, Condition>> rolePolicyMap = new HashMap<String, HashMap<String, Condition>>() {{
			«FOR _role: domain.roles»
				put("«_role.name»", new HashMap<String,Boolean>(){{
					«FOR rPolicy: domain.rolePolicies.filter[role.roleRefs instanceof RoleRef].filter[role.roleRefs.ref.name.equals(_role.name)]»
						put("«findResource(rPolicy.action)»/«rPolicy.action.name»", map -> «printCondition(rPolicy)»);
					«ENDFOR»
				}});
			«ENDFOR»
		}};
		
		rivate static HashMap<String, HashMap<String, EntityCondition>> entityPolicyMap = new HashMap<String, HashMap<String, EntityCondition>>() {{
			«FOR _entity: domain.entities»
				put("«_entity.name»", new HashMap<String,Boolean>(){{

				«FOR _resource: domain.resources»
					«FOR _action: _resource.actions»
					«var ePolicy = domain.entityPolicies.filter[_entity.name.equals(entity.name)].findFirst[(findResource(action) + "/" +action.name).equals(_resource.name + "/" + _action.name)]»
						put("«_resource.name»/«_action.name»", (map, counter) -> «printCondition(ePolicy)»);
					«ENDFOR»
				«ENDFOR»
				}});
			«ENDFOR»

		}};
	
	public boolean roleAuthorize(String Role, String Action, MultivaluedMap<String, String> map) {
		System.out.println("PolicyHandler.roleAuthorize()");
		try {
			//System.out.println("\t Authorize");
			return rolePolicyMap.get(Role).get(Action).evaluate(map);
		} catch (Exception e) {
			System.out.println("\t " + Role + " is not allowed to perform action: " + Action);
			return false;
		}
	}
	
	public boolean entityAuthorize(String Entity, String Action, MultivaluedMap<String, String> map) {
		System.out.println("PolicyHandler.entityAuthorize()");
		CheckCounter++;
		try {
			//System.out.println("\t Authorize");
			return entityPolicyMap.get(Entity).get(Action).evaluate(map, CheckCounter);
		} catch (Exception e) {
			System.out.println("\t " + Entity + " is not allowed to perform action: " + Action);
			return false;
		}
	}
	
	private interface Condition {
		boolean evaluate(MultivaluedMap<String, String> mMap); //TODO rename
	}
	private interface EntityCondition {
		boolean evaluate(MultivaluedMap<String, String> mMap, int checkCounter); //TODO rename
		}
	}
	'''
		
	}
	
	def static CharSequence printCondition(RolePolicy RP){
		var returnVar = ""
		if(RP !== null){
			returnVar = RP.require.requirement.generateLogic.toString;
		} else {
			returnVar = "null"
		}
		
		return returnVar;
	}
	
	def static CharSequence printCondition(EntityPolicy EP){
		var returnVar = ""
		if(EP !== null){
			returnVar = EP.require.requirement.rGenerateLogic.toString;
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
	OracleClient.get«x.entity.name»(map.getFirst("«x.entity.idName»"), counter)«findProperty(x.entityPropertyRef)»)
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
	
	def static CharSequence findProperty(EntityPropertyRef entityPropertyRef){
		if(entityPropertyRef === null) return ""
		return "."+ entityPropertyRef.propertyRef.name + findProperty(entityPropertyRef.ref)
	}
	
//	Role logic
	
	def static dispatch CharSequence rGenerateLogic(OR x) '''(«x.left.generateLogic»||«x.right.generateLogic»)'''
	def static dispatch CharSequence rGenerateLogic(AND x) '''(«x.left.generateLogic»&&«x.right.generateLogic»)'''
	def static dispatch CharSequence rGenerateLogic(rComparison x) '''(«x.left.generateExp» «x.op.generateOp» «x.right.generateExp»)'''
	def static dispatch CharSequence rGenerateLogic(Bool x) '''«x.bool»'''
//	def static dispatch CharSequence rGenerateLogic(StringPrim x) '''("«x.value»")'''
//	def static dispatch CharSequence rGenerateLogic(StringComparison x) '''«x.operator.generateStringOp»(«x.left».equals(«x.right»))'''
	
	def static dispatch CharSequence rGenerateExp(Add x) '''(«x.left.generateExp»+«x.right.generateExp»)'''
	def static dispatch CharSequence rGenerateExp(Sub x) '''(«x.left.generateExp»-«x.right.generateExp»)'''
	def static dispatch CharSequence rGenerateExp(Mul x) '''(«x.left.generateExp»*«x.right.generateExp»)'''
	def static dispatch CharSequence rGenerateExp(Div x) '''(«x.left.generateExp»/«x.right.generateExp»)'''
	def static dispatch CharSequence rGenerateExp(IntExp x) '''«x.value»'''
	def static dispatch CharSequence rGenerateExp(QueryParamRef x){
		switch(x.ref.type){
			case tString: '''map.getFirst("«x.ref.name»")'''
			case tInt: '''Integer.parseInt(map.getFirst("«x.ref.name»"))'''
			case tFloat: '''Integer.parseFloat(map.getFirst("«x.ref.name»"))'''
			default :'''NOT IMPLEMENTED'''
		}	
	}
}
