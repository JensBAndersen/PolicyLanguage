package com.ffu.generator

import com.ffu.policy.Action
import com.ffu.policy.CapabilityAction
import com.ffu.policy.Domain
import com.ffu.policy.Everyone
import com.ffu.policy.pResource
import java.util.HashSet
import org.eclipse.emf.ecore.resource.Resource

// «»



class guardGenerator{
	static val HashSet<String> _capabilityHolder = new HashSet<String>();
	
	def static generate(Domain domain, Resource resource){

		
		for (_capability: domain.capability.capabilities){
			//_capabilityHolder.add(findResource(_capability.resource) + "/" + _capability.resource.name)
			
			for (_capabilityAction: _capability.subActions)
				addChild(_capabilityAction);
			
		}
		
		'''
		package dk.nielshvid.intermediator;
		import javax.ws.rs.WebApplicationException;
		import javax.ws.rs.core.Response;
		import java.util.HashSet;
		import java.util.UUID;
		
		public class Guard {
			private PolicyHandler policyHandler = new PolicyHandler();
			private CapabilityHandler capabilityHandler = new CapabilityHandler();
			private IdentityServiceInterface identityService;
			private static HashSet<String> rolePolicyFreeActions = new HashSet<String>() {{
				«FOR _policy: domain.rolePolicies.filter[role instanceof Everyone]»
					add("«findResource(_policy.action)»/«_policy.action.name»");
				«ENDFOR»
			}};
			
			private static HashSet<String> capabilityRequiringActions = new HashSet<String>() {{
		        «FOR capName: _capabilityHolder»
		        	add("«capName»");
		        «ENDFOR»
			}};
			
			
		
			Guard(IdentityServiceInterface identityService){
				this.identityService = identityService;
			}
			
			public UUID generateCapability(String UserID, String BoxID, String action){
				UUID userID;
				
				try { userID = UUID.fromString(UserID);
				} catch (Exception e) {
					throw new WebApplicationException("Invalid User ID", Response.Status.BAD_REQUEST);
				}

				String role = identityService.getRole(userID, BoxID);

				if(!rolePolicyFreeActions.contains(action)){
					if(!policyHandler.authorize(role, action)){
						return null;
					}
				}
				
				if(capabilityRequiringActions.contains(action)){
					return null;
				}
				
				return capabilityHandler.addCapability(userID, BoxID, action);
			}
		
			public boolean authorize(String UserID, String BoxID, UUID CapabilityID, String action){
				if(!rolePolicyFreeActions.contains(action)){
					String role;
					try {
						role = identityService.getRole(UUID.fromString(UserID), BoxID);
					} catch (Exception e){
						throw new WebApplicationException("Invalid User ID", Response.Status.BAD_REQUEST);
					}
					if(!policyHandler.authorize(role, action)){
						throw new WebApplicationException("Permission denied", Response.Status.FORBIDDEN);
					}
				}
				
				if(capabilityRequiringActions.contains(action)){
					if(!capabilityHandler.authorize(UUID.fromString(UserID), BoxID, CapabilityID, action)){
						throw new WebApplicationException("Invalid capability", Response.Status.FORBIDDEN);
					}
				}
					
				return true;
			}
		}
		'''
	}	
	
	def static dispatch CharSequence getResourceName(pResource re){
		re.name
	}
	def static dispatch CharSequence getResourceName(Action re){
	}
	
	def static CharSequence findResource(Action action){
		action.eContainer.getResourceName
	}
	
	def static CharSequence addChild2(CapabilityAction capAction){
		
		'''
		addChild(new Node<String>("«findResource(capAction.action)»/«capAction.action.name»"){{
		«FOR _subaction: capAction.nestedActions»
			«addChild(_subaction)»
		«ENDFOR»
		}});
		'''
		
	}
	
	def static void addChild(CapabilityAction CA){
		_capabilityHolder.add(findResource(CA.action) + "/" + CA.action.name)
		for(_subaction: CA.nestedActions){
			addChild(_subaction);
		}
	}
}


