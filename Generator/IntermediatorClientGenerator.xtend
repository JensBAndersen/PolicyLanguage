package com.ffu.generator


import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.Domain
import org.eclipse.emf.common.util.EList
import com.ffu.policy.QueryParam

// «»

class IntermediatorClientGenerator{
	
	def static generate(Domain domain, Resource resource){
		'''
		package dk.nielshvid.intermediator;
		
		import javax.ws.rs.client.Client;
		import javax.ws.rs.client.ClientBuilder;
		import javax.ws.rs.core.Response;
		
		public class IntermediatorClient{
		
		«FOR dResource : domain.resources»
			private static final String REST_URI_«dResource.name» = "«dResource.uri»";
		«ENDFOR»
		
		private static Client client = ClientBuilder.newClient();
		
		«FOR dResource : domain.resources»
			«FOR dAction : dResource.actions»
				
				public static Response «dAction.name»«dResource.name»(«QueryParamMapper(dAction.queryParam)»){
					
					return client.target(REST_URI_«dResource.name» + "«dAction.name»«RestParamMapper(dAction.queryParam)»).request().get();
				}
				
			«ENDFOR»
		«ENDFOR»
		}
		'''
	}
	
	def static CharSequence RestParamMapper(EList<QueryParam> qpList){
		var returnVar = '''?UserID=" + UserID + "&BoxID=" + BoxID'''
		
		for (qp : qpList){
			returnVar += ''' + "&«qp.name»=" + «qp.name»'''
		}
		
		return returnVar
	}
	
	def static CharSequence QueryParamMapper(EList<QueryParam> qpList){
		var returnVar = "String UserID, String BoxID";
		
		for (QueryParam qp: qpList){
			returnVar += ", " + paramTypeMapper(qp.type) + " " + qp.name
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
	
}