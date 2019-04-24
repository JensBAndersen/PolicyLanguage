/*
 * generated by Xtext 2.12.0
 */
package com.ffu.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.ffu.policy.Domain

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class PolicyGenerator extends AbstractGenerator {
	private Resource gResource;
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		if (resource.allContents.filter(Domain).size <= 0){
			return
		}

		gResource=resource
		
		val domain = resource.allContents.filter(Domain).next
		
		/** JAVA Generator **/
		fsa.generateFile('output.txt', javaGenerator.generate(domain, resource))
	
		/** SQL Generator **/
		//fsa.generateFile('SQL.txt', sqlGenerator.generate(domain, resource))
		
		//** Guard Generator **/
		fsa.generateFile('Guard.java', guardGenerator.generate(domain, resource))
		
		/** Intermediary Generator **/
		fsa.generateFile('RestInterface.java', restInterfaceGenerator.generate(domain, resource))
		
		/** CapabilityHandler Generator**/
		fsa.generateFile('CapabilityHandler.java', capabilityHandlerGenerator.generate(domain, resource))
		
		/** PolicyHandler Generator**/
		fsa.generateFile('PolicyHandler.java', policyHandlerGenerator.generate(domain, resource))
		
		/** Intermediary Client Generator **/
		fsa.generateFile('IntermediatorClient.java', IntermediatorClientGenerator.generate(domain, resource))
		
		/** Graphics Generator **/
		fsa.generateFile('graph.gv', graphGenerator.generate(domain, resource))
		
		//** Guard Generator **/
		fsa.generateFile('OracleClient.java', oracleClientGenerator.generate(domain, resource))
	}	
}