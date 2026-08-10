/**
 * Modal Editor - vim-like modal editing for Pi
 *
 * - Escape: insert → normal mode (in normal mode, aborts agent)
 * - i/a: normal → insert mode
 * - hjkl, w, b: navigation in normal mode
 * - dd: delete the current line
 * - dt{char}/dT{char}: delete until a character, forwards/backwards
 * - ctrl+c, ctrl+d, etc. work in both modes
 */

import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import {
	decodeKittyPrintable,
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

type PendingDelete = "operator" | "till-forward" | "till-backward" | null;
type CharacterClass = "space" | "word" | "punctuation";

const graphemeSegmenter = new Intl.Segmenter(undefined, { granularity: "grapheme" });
const WORD_CHARACTER = /[\p{L}\p{M}\p{N}_]/u;

function nextCharacterOffset(text: string, offset: number): number {
	const codePoint = text.codePointAt(offset);
	return codePoint === undefined ? text.length : offset + String.fromCodePoint(codePoint).length;
}

function previousCharacterOffset(text: string, offset: number): number {
	if (offset <= 0) return 0;
	const trailing = text.charCodeAt(offset - 1);
	return trailing >= 0xdc00 && trailing <= 0xdfff && offset >= 2 ? offset - 2 : offset - 1;
}

function characterClass(text: string, offset: number): CharacterClass {
	const codePoint = text.codePointAt(offset);
	if (codePoint === undefined) return "space";
	const character = String.fromCodePoint(codePoint);
	if (/\s/u.test(character)) return "space";
	return WORD_CHARACTER.test(character) ? "word" : "punctuation";
}

/** Find the start of the next Vim-style lowercase word. */
export function findNextWordStart(text: string, offset: number): number {
	let next = Math.max(0, Math.min(offset, text.length));
	const initialClass = characterClass(text, next);

	if (initialClass !== "space") {
		while (next < text.length && characterClass(text, next) === initialClass) {
			next = nextCharacterOffset(text, next);
		}
	}
	while (next < text.length && characterClass(text, next) === "space") {
		next = nextCharacterOffset(text, next);
	}
	return next;
}

/** Find the start of the current or previous Vim-style lowercase word. */
export function findPreviousWordStart(text: string, offset: number): number {
	if (offset <= 0) return 0;
	let previous = previousCharacterOffset(text, Math.min(offset, text.length));

	while (previous > 0 && characterClass(text, previous) === "space") {
		previous = previousCharacterOffset(text, previous);
	}
	const targetClass = characterClass(text, previous);
	while (previous > 0) {
		const candidate = previousCharacterOffset(text, previous);
		if (characterClass(text, candidate) !== targetClass) break;
		previous = candidate;
	}
	return previous;
}

function cursorOffset(lines: string[], cursor: { line: number; col: number }): number {
	let offset = 0;
	for (let line = 0; line < cursor.line; line++) offset += (lines[line]?.length ?? 0) + 1;
	return offset + cursor.col;
}

function printableCharacter(data: string): string | null {
	const printable = decodeKittyPrintable(data) ?? data;
	if (!printable || /[\u0000-\u001f\u007f]/u.test(printable)) return null;
	const graphemes = [...graphemeSegmenter.segment(printable)];
	return graphemes.length === 1 ? graphemes[0]!.segment : null;
}

function graphemeEnd(text: string, offset: number): number {
	const first = [...graphemeSegmenter.segment(text.slice(offset))][0]?.segment;
	return first === undefined ? offset : offset + first.length;
}

export class ModalEditor extends CustomEditor {
	private mode: "normal" | "insert" = "insert";
	private pendingDelete: PendingDelete = null;

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
		this.pendingDelete = null;
		this.updateBorderColor();
	}

	private updateBorderColor(): void {
		this.borderColor = this.modeBorderColors[this.mode];
		this.tui.requestRender();
	}

	private moveToOffset(targetOffset: number): void {
		const text = this.getText();
		const lines = text.split("\n");
		const target = Math.max(0, Math.min(targetOffset, text.length));
		let current = cursorOffset(lines, this.getCursor());
		let remaining = text.length + lines.length + 1;

		while (current !== target && remaining-- > 0) {
			super.handleInput(current < target ? "\x1b[C" : "\x1b[D");
			const next = cursorOffset(lines, this.getCursor());
			if (next === current) break;
			current = next;
		}
	}

	private moveWord(direction: "forward" | "backward"): void {
		const text = this.getText();
		const offset = cursorOffset(text.split("\n"), this.getCursor());
		this.moveToOffset(direction === "forward" ? findNextWordStart(text, offset) : findPreviousWordStart(text, offset));
	}

	private setTextAndCursor(text: string, targetLine: number, targetCol: number): void {
		this.setText(text);
		let remaining = text.length + 1;
		while (this.getCursor().line > targetLine && remaining-- > 0) {
			super.handleInput("\x1b[A");
		}
		super.handleInput("\x01");
		remaining = targetCol + 1;
		while (this.getCursor().col < targetCol && remaining-- > 0) {
			super.handleInput("\x1b[C");
		}
	}

	private deleteTill(target: string, direction: "forward" | "backward"): void {
		const lines = this.getExpandedText().split("\n");
		const cursor = this.getCursor();
		const line = lines[cursor.line] ?? "";

		if (direction === "forward") {
			const match = line.indexOf(target, graphemeEnd(line, cursor.col));
			if (match === -1) return;
			lines[cursor.line] = line.slice(0, cursor.col) + line.slice(match);
			this.setTextAndCursor(lines.join("\n"), cursor.line, cursor.col);
			return;
		}

		const match = line.lastIndexOf(target, cursor.col - 1);
		if (match === -1) return;
		const deleteStart = match + target.length;
		const deleteEnd = graphemeEnd(line, cursor.col);
		lines[cursor.line] = line.slice(0, deleteStart) + line.slice(deleteEnd);
		this.setTextAndCursor(lines.join("\n"), cursor.line, deleteStart);
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
				this.pendingDelete = null;
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

		// Complete dt{char}/dT{char} before interpreting the target as a command.
		if (this.pendingDelete === "till-forward" || this.pendingDelete === "till-backward") {
			const direction = this.pendingDelete === "till-forward" ? "forward" : "backward";
			this.pendingDelete = null;
			const target = printableCharacter(data);
			if (target !== null) {
				this.deleteTill(target, direction);
				return;
			}
		}

		// Normal mode: support dd, dt{char}, and dT{char}.
		if (this.pendingDelete === "operator") {
			this.pendingDelete = null;
			if (data === "d") {
				this.deleteCurrentLine();
				return;
			}
			if (data === "t" || data === "T") {
				this.pendingDelete = data === "t" ? "till-forward" : "till-backward";
				return;
			}
		}
		if (data === "d") {
			this.pendingDelete = "operator";
			return;
		}

		if (data === "w" || data === "b") {
			this.moveWord(data === "w" ? "forward" : "backward");
			return;
		}

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
