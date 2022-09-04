/**
 * Copyright (c) 2012-2014 Obeo and others.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *     Mikael Barbero (Obeo) - initial API and implementation
 */
package org.eclipse.cbi.targetplatform.pde

import org.eclipse.cbi.targetplatform.model.Option
import org.eclipse.cbi.targetplatform.resolved.ResolvedLocation
import org.eclipse.cbi.targetplatform.resolved.ResolvedTargetPlatform

import static com.google.common.base.Preconditions.*

class TargetDefinitionGenerator {
	
	
	def String generate(ResolvedTargetPlatform targetPlatform, int sequenceNumber) {
		checkNotNull(targetPlatform)
		
		'''
		<?xml version="1.0" encoding="UTF-8" standalone="no"?>
		<?pde?>
		<!-- generated with https://github.com/eclipse-cbi/targetplatform-dsl -->
		<target name="«targetPlatform.name»" sequenceNumber="«sequenceNumber»">
		  «IF targetPlatform.locations !== null && !targetPlatform.locations.empty»
		  <locations>
		    «FOR location : targetPlatform.locations»
		    «generateLocation(targetPlatform, location)»
		    «ENDFOR»
		  </locations>
		  «ENDIF»
		  «IF (targetPlatform.environment !== null && 
			  	(!targetPlatform.environment.os.nullOrEmpty || 
			  	 !targetPlatform.environment.ws.nullOrEmpty || 
			  	 !targetPlatform.environment.arch.nullOrEmpty || 
			  	 !targetPlatform.environment.nl.nullOrEmpty)
		  )»
		  <environment>
		    «IF (!targetPlatform.environment.os.nullOrEmpty)»
		    <os>«targetPlatform.environment.os»</os>
		    «ENDIF»
		    «IF (!targetPlatform.environment.ws.nullOrEmpty)»
		    <ws>«targetPlatform.environment.ws»</ws>
		    «ENDIF»
		    «IF (!targetPlatform.environment.arch.nullOrEmpty)»
		    <arch>«targetPlatform.environment.arch»</arch>
		    «ENDIF»
		    «IF (!targetPlatform.environment.nl.nullOrEmpty)»
		    <nl>«targetPlatform.environment.nl»</nl>
		    «ENDIF»
		  </environment>
		  «ENDIF»
		  «IF (targetPlatform.environment !== null && !targetPlatform.environment.targetJRE.nullOrEmpty)»
		  <targetJRE path="«targetPlatform.environment.targetJRE»"/>
		  «ENDIF»
		</target>
		'''
	}
	
	private def String generateLocation(ResolvedTargetPlatform targetPlatform, ResolvedLocation location) {
		val options =
			if (!targetPlatform.options.empty) {
				targetPlatform.options
			} else {
				location.options
			}
		
		val includeMode = 'includeMode="' + (if (options.contains(Option.INCLUDE_REQUIRED)) 'planner' else 'slicer') + '"'
		val includeAllPlatforms = 'includeAllPlatforms="' + options.contains(Option.INCLUDE_ALL_ENVIRONMENTS) + '"'
		val includeSource = 'includeSource="' + options.contains(Option.INCLUDE_SOURCE) + '"'
		val includeConfigurePhase = 'includeConfigurePhase="' + options.contains(Option.INCLUDE_CONFIGURE_PHASE) + '"'
		val locationAttributes = 
				includeMode + ' ' + includeAllPlatforms +  ' ' + 
				includeSource + ' ' + includeConfigurePhase 
		 
		val repositoryAttributes = 
			'''«IF !location.ID.nullOrEmpty»id="«location.ID»" «ENDIF»location="«location.URI»"'''
			
		'''
		<location «locationAttributes» type="InstallableUnit">
		  «FOR iu : location.resolvedIUs»
		  <unit id="«iu.id»" version="«iu.version»"/>
		  «ENDFOR»
		  <repository «repositoryAttributes»/>
		</location>
		'''
	}
}
