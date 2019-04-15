package com.ffu.generator

import com.ffu.policy.Domain
import com.ffu.policy.QueryParam
import com.ffu.policy.pResource
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource
import java.util.HashSet
import com.ffu.policy.Action

// «»

class restInterfaceGenerator{
	
	def static generate(Domain domain, Resource resource){
		
		val HashSet<String> capabilityIssuingActions = new HashSet<String>();
		
		for (_capability: domain.capability.capabilities){
			capabilityIssuingActions.add(findResource(_capability.resource) + "/" + _capability.resource.name)
		}
		
		println("capisactsize " + capabilityIssuingActions.size())
		
		'''
		package dk.nielshvid.intermediator;
		
		import javax.ws.rs.*;
		import javax.ws.rs.core.MediaType;
		import javax.ws.rs.core.Response;
		import java.util.UUID;
		
		@Path("/")
		public class RestInterface{
			private IdentityService identityService = new IdentityService();
			private Guard guard = new Guard(identityService);
		
			«FOR dResource : domain.resources»
				«FOR dAction : dResource.actions»
					@Path("«dResource.name»/«dAction.path»")
					@GET
					@Produces(MediaType.«mediaTypeMapper(dAction.product)»)
					public Response «dAction.name»«dResource.name» («QueryParamMapper(dAction.queryParam)»){
						
						«if(capabilityIssuingActions.contains(dResource.name + "/" + dAction.path)){
						'''
						// This structure can be optimized (maybe)
						UUID CapabilityID = guard.generateCapability(UserID, BoxID, "«dResource.name»/«dAction.path»");
						'''
						}»
						
						// Check policies
						if (guard.authorize(UserID, BoxID, Capability, "«dResource.name»/«dAction.path»")){
							// Forward request
							«if(capabilityIssuingActions.contains(dResource.name + "/" + dAction.path)){
								'''return Response.fromResponse(IntermediatorClient.«dAction.name»«dResource.name»(«forwardArgumentMapper(dAction.queryParam)»)).header("Capability", CapabilityID).build();'''
							} else {
								'''return IntermediatorClient.«dAction.name»«dResource.name»(«forwardArgumentMapper(dAction.queryParam)»);'''
							}»
						};
						
						throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
						
					}
					
				«ENDFOR»
			«ENDFOR»
		}
		'''
	}
	
	def static CharSequence forwardArgumentMapper(EList<QueryParam> qpList){
		
		var returnVar = "UserID, BoxID"
		
		for (QueryParam qp: qpList){
			returnVar += ", " + qp.varName
		}
		
		
		return returnVar;
	}
	
	def static CharSequence QueryParamMapper(EList<QueryParam> qpList){
		//var returnV = "@QueryParam(\"UserID\") String UserID";
		var returnVar = '''@QueryParam("UserID") String UserID, @QueryParam("Capability") UUID Capability, @QueryParam("BoxID") String BoxID'''
		
		for (QueryParam qp: qpList){
			returnVar += ", @QueryParam(\"" + qp.varName + "\") " + paramTypeMapper(qp.type) + " " + qp.varName 
			
		}
		
		return returnVar;
	}
	
	def static CharSequence paramTypeMapper(String type){
		switch(type){
			
			case "int":
				return "int"
				
			case "string":
				return "String"
				
			default:
				throw new Error("Parameter type: " + type + " unknown")
		}
	}
	
	def static CharSequence mediaTypeMapper(String pt){
		switch(pt){
			case "text":
				return "TEXT_PLAIN"

			case "json":
				return "APPLICATION_JSON"
				
			case "html":
				return "TEXT_HTML"
			
			default:
				throw new Error("Produce type: " + pt + " unknown")
		}
	}
	def static dispatch CharSequence getResourceName(pResource re){
		re.name
	}
	def static dispatch CharSequence getResourceName(Action re){
	}
	
	def static CharSequence findResource(Action action){
		action.eContainer.getResourceName
	}
}



