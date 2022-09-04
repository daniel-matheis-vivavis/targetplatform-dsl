/**
 * Copyright (c) 2014 Obeo and others.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *     Cedric Brun (Obeo) - initial API and implementation
 */
package org.eclipse.cbi.targetplatform.ui.handler;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.part.FileEditorInput;

/**
 * @author <a href="mailto:cedric.brun@obeo.fr">Cedric Brun</a>
 */
public class SetAsTargetPlatformFromEditor extends AbstractHandler {

	/**
	 * {@inheritDoc}
	 * 
	 * @see org.eclipse.core.commands.IHandler#execute(org.eclipse.core.commands.ExecutionEvent)
	 */
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IEditorPart editor = HandlerUtil.getActiveEditor(event);
		if (editor != null && editor.getEditorInput() instanceof FileEditorInput) {
			if (editor.isDirty()) {
				editor.doSave(null);
			}
			IFile editedFile = ((FileEditorInput) editor.getEditorInput()).getFile();
			scheduleJob(editedFile, true);
		}
		return null;
	}

	private void scheduleJob(final IFile selectedElement, boolean userJob) {
		Job job = new ConvertTargetPlatformJob("Setting target platform definition file", selectedElement, true);
		job.setUser(userJob);
		job.schedule();
	}
}
