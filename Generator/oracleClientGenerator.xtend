package com.ffu.generator


import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.Domain

// «»

class oracleClientGenerator{
	
	def static generate(Domain domain, Resource resource){
		'''
		package dk.nielshvid.intermediator;
		
		import com.google.gson.Gson;
		import dk.nielshvid.intermediator.Entities.Sample;
		
		import javax.ws.rs.client.Client;
		import javax.ws.rs.client.ClientBuilder;
		import javax.ws.rs.core.Response;
		
		public class OracleClient {
«««			Det her skal også med i xtext/.pol
		    private static final String REST_URI_Freezer = "http://localhost:8082/"; 
		
		    private static Client client = ClientBuilder.newClient();
		    private static Gson gson = new Gson();
		
«««		Methode param skal def i sprog
		«FOR entityPolicy: domain.entityPolicies»
			
			public static «entityPolicy.entity.name» get«entityPolicy.entity.name»(String id){
				Response response = client.target(REST_URI_Freezer + "get«entityPolicy.entity.name»?ID=" + id).request().get();
				
				String readEntity = response.readEntity(String.class);
				
				return gson.fromJson(readEntity, «entityPolicy.entity.name».class);
			}
		«ENDFOR»
		}
		'''
	}
}



