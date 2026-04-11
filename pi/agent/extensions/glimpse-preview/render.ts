import { unified } from "unified";
import { visit } from "unist-util-visit";
import remarkParse from "remark-parse";
import remarkGfm from "remark-gfm";
import remarkMath from "remark-math";
import remarkRehype from "remark-rehype";
import rehypeKatex from "rehype-katex";
import rehypeStringify from "rehype-stringify";
import type { PreviewBlock } from "./types.ts";

type MarkdownNode = {
  type: string;
  depth?: number;
  lang?: string | null;
  alt?: string;
  value?: string;
  children?: MarkdownNode[];
  ordered?: boolean;
  start?: number | null;
  spread?: boolean;
  position?: {
    start?: { offset?: number };
    end?: { offset?: number };
  };
};

type MarkdownRoot = {
  type: "root";
  children: MarkdownNode[];
};

type BlockDescriptor = {
  sourceNode: MarkdownNode;
  renderNode: MarkdownNode;
  outlineLevel: number;
  kind?: string;
  labelNode?: MarkdownNode;
};

const markdownProcessor = unified()
  .use(remarkParse)
  .use(remarkGfm)
  .use(remarkMath);

const htmlProcessor = unified()
  .use(remarkRehype)
  .use(rehypeKatex)
  .use(rehypeStringify);

function normalizeWhitespace(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

function truncate(value: string, limit: number): string {
  if (value.length <= limit) return value;
  return `${value.slice(0, Math.max(0, limit - 1)).trimEnd()}…`;
}

function extractSourceMarkdown(markdown: string, node: MarkdownNode): string {
  const start = node.position?.start?.offset;
  const end = node.position?.end?.offset;
  if (typeof start !== "number" || typeof end !== "number" || end <= start) return "";
  return markdown.slice(start, end).trim();
}

function extractPlainText(node: MarkdownNode): string {
  const parts: string[] = [];

  visit(node as any, (child: any) => {
    if (child == null || typeof child !== "object") return;

    if (typeof child.value === "string" && ["text", "inlineCode", "code", "math", "html"].includes(child.type)) {
      parts.push(child.value);
      return;
    }

    if (child.type === "image" && typeof child.alt === "string" && child.alt.trim().length > 0) {
      parts.push(child.alt);
    }
  });

  return normalizeWhitespace(parts.join(" "));
}

function formatLabel(kind: string, text: string, node: MarkdownNode, index: number): string {
  switch (kind) {
    case "heading":
      return `Heading ${node.depth ?? ""}: ${truncate(text || "Untitled heading", 96)}`.replace(/\s+/g, " ").trim();
    case "list-item":
      return `Bullet: ${truncate(text || `List item ${index + 1}`, 96)}`;
    case "code":
      return node.lang ? `Code block (${node.lang})` : "Code block";
    case "math":
      return "Math block";
    case "blockquote":
      return `Quote: ${truncate(text || "Quoted block", 96)}`;
    case "table":
      return `Table: ${truncate(text || `Table block ${index + 1}`, 96)}`;
    case "thematic-break":
      return `Divider ${index + 1}`;
    case "html":
      return `HTML block ${index + 1}`;
    case "image":
      return `Image: ${truncate(text || `Image block ${index + 1}`, 96)}`;
    default:
      return truncate(text || `Block ${index + 1}`, 96);
  }
}

function getBlockKind(node: MarkdownNode): string {
  switch (node.type) {
    case "heading":
    case "paragraph":
    case "blockquote":
    case "table":
    case "code":
    case "math":
    case "html":
      return node.type;
    case "listItem":
      return "list-item";
    case "image":
      return "image";
    case "thematicBreak":
      return "thematic-break";
    default:
      return "block";
  }
}

async function renderNodeToHtml(node: MarkdownNode): Promise<string> {
  const tree: MarkdownRoot = { type: "root", children: [node] };
  const hast = await htmlProcessor.run(tree as any);
  return String(htmlProcessor.stringify(hast)).trim();
}

function toPreviewBlock(
  markdown: string,
  sourceNode: MarkdownNode,
  labelNode: MarkdownNode,
  index: number,
  html: string,
  outlineLevel: number,
  kindOverride?: string,
): PreviewBlock {
  const sourceMarkdown = extractSourceMarkdown(markdown, sourceNode);
  const kind = kindOverride ?? getBlockKind(labelNode);
  const text = extractPlainText(labelNode);
  const excerptSource = text || sourceMarkdown;

  return {
    id: `block-${index + 1}`,
    index,
    kind,
    label: formatLabel(kind, text, labelNode, index),
    excerpt: truncate(excerptSource || `Block ${index + 1}`, kind === "code" || kind === "math" ? 220 : 180),
    sourceMarkdown,
    html,
    outlineLevel,
  };
}

function cloneNode<T>(value: T): T {
  return structuredClone(value);
}

function collectListBlocks(listNode: MarkdownNode, headingDepth: number, listDepth: number): BlockDescriptor[] {
  const blocks: BlockDescriptor[] = [];
  const items = Array.isArray(listNode.children) ? listNode.children : [];

  for (const item of items) {
    const children = Array.isArray(item.children) ? item.children : [];
    const ownChildren = children.filter((child) => child?.type !== "list");

    if (ownChildren.length > 0) {
      const renderItem = cloneNode(item);
      renderItem.children = ownChildren.map((child) => cloneNode(child));

      const renderList: MarkdownNode = {
        type: "list",
        ordered: listNode.ordered,
        start: listNode.start,
        spread: false,
        children: [renderItem],
      };

      blocks.push({
        sourceNode: item,
        renderNode: renderList,
        outlineLevel: Math.min(6, Math.max(0, headingDepth - 1 + listDepth + 1)),
        kind: "list-item",
        labelNode: renderItem,
      });
    }

    for (const child of children) {
      if (child?.type === "list") {
        blocks.push(...collectListBlocks(child, headingDepth, listDepth + 1));
      }
    }
  }

  return blocks;
}

function collectBlocks(nodes: MarkdownNode[], headingDepth = 1): { blocks: BlockDescriptor[]; headingDepth: number } {
  const blocks: BlockDescriptor[] = [];
  let currentHeadingDepth = headingDepth;

  for (const node of nodes) {
    if (node == null || typeof node !== "object") continue;

    if (node.type === "heading") {
      currentHeadingDepth = typeof node.depth === "number" ? Math.max(1, node.depth) : 1;
      blocks.push({
        sourceNode: node,
        renderNode: node,
        outlineLevel: Math.max(0, currentHeadingDepth - 1),
        kind: "heading",
        labelNode: node,
      });
      continue;
    }

    if (node.type === "list") {
      blocks.push(...collectListBlocks(node, currentHeadingDepth, 0));
      continue;
    }

    blocks.push({
      sourceNode: node,
      renderNode: node,
      outlineLevel: Math.min(6, Math.max(0, currentHeadingDepth)),
      kind: getBlockKind(node),
      labelNode: node,
    });
  }

  return { blocks, headingDepth: currentHeadingDepth };
}

export async function renderMarkdownToHtml(markdown: string): Promise<string> {
  const file = await unified()
    .use(remarkParse)
    .use(remarkGfm)
    .use(remarkMath)
    .use(remarkRehype)
    .use(rehypeKatex)
    .use(rehypeStringify)
    .process(markdown);

  return String(file);
}

export async function renderMarkdownBlocks(markdown: string): Promise<PreviewBlock[]> {
  const tree = markdownProcessor.parse(markdown) as MarkdownRoot;
  const children = Array.isArray(tree.children) ? tree.children : [];
  const renderableNodes = children.filter((node) => node?.type !== "definition");

  if (renderableNodes.length === 0) {
    const html = await renderMarkdownToHtml(markdown);
    return [{
      id: "block-1",
      index: 0,
      kind: "block",
      label: "Message",
      excerpt: truncate(normalizeWhitespace(markdown), 180),
      sourceMarkdown: markdown.trim(),
      html,
      outlineLevel: 0,
    }];
  }

  const descriptors = collectBlocks(renderableNodes).blocks;
  const rendered = await Promise.all(descriptors.map(async (descriptor, index) => ({
    descriptor,
    index,
    html: await renderNodeToHtml(descriptor.renderNode),
  })));

  return rendered
    .filter((entry) => entry.html.length > 0)
    .map((entry) => toPreviewBlock(
      markdown,
      entry.descriptor.sourceNode,
      entry.descriptor.labelNode ?? entry.descriptor.sourceNode,
      entry.index,
      entry.html,
      entry.descriptor.outlineLevel,
      entry.descriptor.kind,
    ));
}
