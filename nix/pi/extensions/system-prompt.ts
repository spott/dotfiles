import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("system-prompt", {
		description: "Show Pi's current system prompt verbatim",
		handler: async (_args, ctx) => {
			await ctx.ui.editor("System prompt (changes are discarded)", ctx.getSystemPrompt());
		},
	});
}
