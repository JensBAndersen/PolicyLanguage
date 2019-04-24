package com.ffu.generator


import org.eclipse.emf.ecore.resource.Resource
import com.ffu.policy.Domain
import java.util.Set
import com.ffu.policy.EntityPolicy
import com.ffu.policy.Entity
import java.util.ArrayList
import java.util.HashSet

// «»

class oracleClientGenerator{
	static Set<Entity> referencesEntities = new HashSet<Entity>(); 
	def static generate(Domain domain, Resource resource){
		for(entityPolicy: domain.entityPolicies){
			referencesEntities.add(entityPolicy.entity)
		}
		
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
		    private static int checkCounter;
		«FOR entity: referencesEntities»
			private static «entity.name» «entity.name.toLowerCase»;
		«ENDFOR»
		
«««		Methode param skal def i sprog
		«FOR entityPolicy: domain.entityPolicies»
			
			public static «entityPolicy.entity.name» get«entityPolicy.entity.name»(«entityPolicy.entity.idType» id){
				if(checkCounter == counter){
					return «entityPolicy.entity.name.toLowerCase»;
				}
				
				Response response = client.target(REST_URI_Freezer + "get«entityPolicy.entity.name»?ID=" + id).request().get();
				
				String readEntity = response.readEntity(String.class);
				
				«entityPolicy.entity.name.toLowerCase» = gson.fromJson(readEntity, «entityPolicy.entity.name».class);
				return «entityPolicy.entity.name.toLowerCase»
			}
		«ENDFOR»
		}
		'''
	}
}



