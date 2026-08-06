/**
 * Modal Editor - vim-like modal editing for Pi
 *
 * - Escape: insert → normal mode (in normal mode, aborts agent)
 * - i/a: normal → insert mode
 * - hjkl: navigation in normal mode
 * - dd: delete the current line
 * - ctrl+c, ctrl+d, etc. work in both modes
 */

import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import {
	matchesKey,
	truncateToWidth,
	visibleWidth,
	type EditorTheme,
	type TUI,
} from "@earendil-works/pi-tui";

// Normal mode key mappings: key -> escape sequence (or null for mode switch)
const NORMAL_KEYS: Record<string, string | null> = {
	h: "\x1b[D", // left
	j: "\x1b[B", // down
	k: "\x1b[A", // up
	l: "\x1b[C", // right
	"0": "\x01", // line start
	$: "\x05", // line end
	x: "\x1b[3~", // delete char
	i: null, // insert mode
	a: null, // append (insert + right)
};

class ModalEditor extends CustomEditor {
	private mode: "normal" | "insert" = "insert";
	private pendingDelete = false;

	constructor(
		tui: TUI,
		theme: EditorTheme,
		keybindings: KeybindingsManager,
		private readonly modeBorderColors: Record<"normal" | "insert", (text: string) => string>,
	) {
		super(tui, theme, keybindings);
		this.updateBorderColor();
	}

	private setMode(mode: "normal" | "insert"): void {
		this.mode = mode;
		this.pendingDelete = false;
		this.updateBorderColor();
	}

	private updateBorderColor(): void {
		this.borderColor = this.modeBorderColors[this.mode];
		this.tui.requestRender();
	}

	private deleteCurrentLine(): void {
		const lines = this.getExpandedText().split("\n");
		const currentLine = this.getCursor().line;

		if (lines.length === 1) {
			this.setText("");
			return;
		}

		lines.splice(currentLine, 1);
		const targetLine = Math.min(currentLine, lines.length - 1);
		this.setText(lines.join("\n"));

		// setText leaves the cursor at the end of the buffer. Move back to the
		// deleted line's position, accounting for logical lines that wrap.
		while (this.getCursor().line > targetLine) {
			super.handleInput("\x1b[A");
		}
		super.handleInput("\x01"); // first column
	}

	handleInput(data: string): void {
		// Escape toggles to normal mode, or passes through for app handling
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") {
				this.setMode("normal");
			} else if (this.pendingDelete) {
				this.pendingDelete = false;
			} else {
				super.handleInput(data); // abort agent, etc.
			}
			return;
		}

		// Insert mode: pass everything through
		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		// Normal mode: support the dd operator.
		if (data === "d") {
			if (this.pendingDelete) {
				this.pendingDelete = false;
				this.deleteCurrentLine();
			} else {
				this.pendingDelete = true;
			}
			return;
		}
		this.pendingDelete = false;

		// Normal mode: check mapped keys
		if (data in NORMAL_KEYS) {
			const seq = NORMAL_KEYS[data];
			if (data === "i") {
				this.setMode("insert");
			} else if (data === "a") {
				this.setMode("insert");
				super.handleInput("\x1b[C"); // move right first
			} else if (seq) {
				super.handleInput(seq);
			}
			return;
		}

		// Pass control sequences (ctrl+c, etc.) to super, ignore printable chars
		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		// Add mode indicator to bottom border
		const label = this.mode === "normal" ? " NORMAL " : " INSERT ";
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) {
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + this.borderColor(label);
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		const modeBorderColors = {
			normal: (text: string) => ctx.ui.theme.fg("accent", text),
			insert: (text: string) => ctx.ui.theme.fg("success", text),
		};
		ctx.ui.setEditorComponent((tui, theme, kb) => new ModalEditor(tui, theme, kb, modeBorderColors));
	});
}
