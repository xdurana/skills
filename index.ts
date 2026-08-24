import type { PluginAPI } from '@ampcode/plugin'

export const description = 'Reusable engineering, research, writing, planning, and documentation skills.'

const skills = [
	'ask-matt',
	'code-review',
	'codebase-design',
	'diagnosing-bugs',
	'doc-coauthoring',
	'domain-modeling',
	'grill-me',
	'grill-with-docs',
	'grilling',
	'handoff',
	'implement',
	'improve-codebase-architecture',
	'prototype',
	'research',
	'resolving-merge-conflicts',
	'setup-matt-pocock-skills',
	'tdd',
	'teach',
	'to-questionnaire',
	'to-spec',
	'to-tickets',
	'triage',
	'unslop',
	'wait-what',
	'wayfinder',
	'wizard',
	'writing-for-agents',
] as const

export default async function (amp: PluginAPI) {
	for (const path of skills) {
		await amp.registerSkill({ path })
	}
}
