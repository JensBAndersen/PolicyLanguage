package com.ffu.generator


import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.Domain
import com.ffu.policy.pResource
import com.ffu.policy.Action
import com.ffu.policy.CapabilityAction

// «»

class capabilityHandlerGenerator{
	
	def static generate(Domain domain, Resource resource){
		'''
		package dk.nielshvid.intermediator;
		import java.time.LocalTime;
		import java.util.ArrayList;
		import java.util.HashMap;
		import java.util.List;
		import java.util.UUID;
		
		public class CapabilityHandler {
		    private static HashMap<UUID, Capability> capabilities = new HashMap<>();
		    private static LocalTime lastClean = LocalTime.now();
		    private static final int CAPABILITY_LIFETIME_SECONDS = 300;
		    private HashMap<String, Node<String>> treeTemplates = new HashMap<String, Node<String>>(){{

		        «FOR _capability: domain.capability.capabilities»
		        	put("«findResource(_capability.resource)»/«_capability.resource.name»", new Node<String>("«findResource(_capability.resource)»/«_capability.resource.name»"){{
	        		«FOR _subaction: _capability.subActions»
	        			«addChild(_subaction)»
	        		«ENDFOR»
		        	}});
		        «ENDFOR»
		        
		    }}; 
		        
		        
			public UUID addCapability(UUID userID, String boxID, String key){
			
				if(!treeTemplates.containsKey(key)){
					return null;
				}
				
				Node<String> treeTemplate = treeTemplates.get(key);
				
				Capability capability = new Capability(userID, boxID, treeTemplate);
				capabilities.put(capability.getID(), capability);
				return capability.ID;
			}
			
			boolean authorize(UUID UserID, String boxID, UUID CapabilityID, String action){
				if(lastClean.plusHours(24).isBefore(LocalTime.now())){
					cleanCapabilities();
				}
			
				if(!capabilities.containsKey(CapabilityID)){
					return false;
				}
			
				boolean result =  capabilities.get(CapabilityID).useAction(UserID, boxID, action);
				if(capabilities.get(CapabilityID).delete()){
					capabilities.remove(CapabilityID);
				}
				return result;
			}
			
			private void cleanCapabilities(){
		       lastClean = LocalTime.now();
		
				ArrayList<UUID> tempUUIDList = new ArrayList<>(capabilities.keySet());
				for (UUID i : tempUUIDList){
					if (capabilities.get(i).delete()){
						capabilities.remove(i);
					}
				}
			}

			
			
			private class Capability {
				private LocalTime lastUsed;
				private Node<String> Actions;
				private UUID ID;
				private UUID userID;
				private String boxID;
				
				Capability(UUID userID,  String boxID, Node<String> Actions){
					this.userID = userID;
					this.Actions = Actions;
					this.boxID = boxID;
					
					ID = UUID.randomUUID();
					lastUsed = LocalTime.now();
				}
				
				UUID getID() {
					return ID;
				}
				
				boolean delete(){
					LocalTime temp = LocalTime.now();
					if(!temp.isBefore(lastUsed.plusSeconds(CAPABILITY_LIFETIME_SECONDS))){ // debug value
						return true;
					}
					return false;
				}
				
				boolean useAction(UUID UserID, String boxID, String action){
					LocalTime temp = LocalTime.now();
					
					if(!UserID.equals(this.userID)){
						return false;
					}
				
					if(!boxID.equals(this.boxID)){
						return false;
					}
					
					if(!temp.isBefore(lastUsed.plusSeconds(CAPABILITY_LIFETIME_SECONDS))){ // debug value
						return false;
					}
					
					Node<String> t = this.Actions.useAction(action);
					if (t != null){
						this.Actions = t;
						return true;
					}
					return false;
				}
			}
			
			private class Node<T> {
			
				private T data = null;
				private List<Node<T>> children = new ArrayList<>();
				
				Node(T data) {
					this.data = data;
				}
				
				Node<T> addChild(Node<T> child) {
					this.children.add(child);
					return child;
				}
				
				Node<T> useAction(T action){
					for (Node n : this.getChildren()){
						if (n.data == action){
							return n;
						}
					}
					return null;
				}
				
				private List<Node<T>> getChildren() {
					return children;
				}
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
	
	def static CharSequence addChild(CapabilityAction capAction){
		
		'''
		addChild(new Node<String>("«findResource(capAction.action)»/«capAction.action.name»"){{
		«FOR _subaction: capAction.nestedActions»
			«addChild(_subaction)»
		«ENDFOR»
		}});
		'''
		
	}
}



