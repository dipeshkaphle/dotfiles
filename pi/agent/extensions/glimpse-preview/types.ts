export interface AssistantMessage {
  index: number;
  markdown: string;
  preview: string;
  timestamp?: string;
}

export interface PreviewBlock {
  id: string;
  index: number;
  kind: string;
  label: string;
  excerpt: string;
  sourceMarkdown: string;
  html: string;
  outlineLevel: number;
}

export type PreviewPageBlock = Pick<
  PreviewBlock,
  "id" | "index" | "kind" | "label" | "excerpt" | "sourceMarkdown"
>;

export interface PreviewPageData {
  blocks: PreviewPageBlock[];
}

export interface PreviewComment {
  blockId: string;
  blockIndex: number;
  blockKind: string;
  blockLabel: string;
  excerpt: string;
  sourceMarkdown: string;
  body: string;
}

export interface PreviewSubmitPayload {
  type: "submit";
  overallComment: string;
  comments: PreviewComment[];
}

export interface PreviewCancelPayload {
  type: "cancel" | "done";
}

export type PreviewWindowMessage = PreviewSubmitPayload | PreviewCancelPayload;
