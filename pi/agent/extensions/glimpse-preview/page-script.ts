export const previewPageScript = String.raw`
  const dataElement = document.getElementById('preview-data');
  const pageData = JSON.parse(dataElement && dataElement.textContent ? dataElement.textContent : '{"blocks":[]}');
  const blocks = Array.isArray(pageData.blocks) ? pageData.blocks : [];
  const blockMap = new Map(blocks.map((block) => [block.id, block]));

  const state = {
    overallComment: '',
    comments: [],
    selectedBlockId: blocks[0] ? blocks[0].id : null,
  };

  const overallCommentEl = document.getElementById('overall-comment');
  const commentsListEl = document.getElementById('comments-list');
  const emptyStateEl = document.getElementById('empty-state');
  const commentCountEl = document.getElementById('comment-count');
  const feedbackCountEl = document.getElementById('feedback-count');
  const submitButton = document.getElementById('submit-button');
  const closeButton = document.getElementById('close-button');
  const previewBlocks = Array.from(document.querySelectorAll('.preview-block'));

  function getComment(blockId) {
    return state.comments.find((comment) => comment.blockId === blockId) || null;
  }

  function sortComments() {
    state.comments.sort((left, right) => {
      const leftIndex = blockMap.get(left.blockId)?.index ?? 0;
      const rightIndex = blockMap.get(right.blockId)?.index ?? 0;
      return leftIndex - rightIndex;
    });
  }

  function hasFeedback() {
    return state.overallComment.trim().length > 0 || state.comments.some((comment) => comment.body.trim().length > 0);
  }

  function countFilledComments() {
    return state.comments.filter((comment) => comment.body.trim().length > 0).length;
  }

  function getSelectedIndex() {
    return blocks.findIndex((block) => block.id === state.selectedBlockId);
  }

  function scrollToBlock(blockId, smooth) {
    const blockEl = document.querySelector('.preview-block[data-block-id="' + blockId + '"]');
    if (!(blockEl instanceof HTMLElement)) return;
    blockEl.scrollIntoView({ behavior: smooth ? 'smooth' : 'auto', block: 'center' });
  }

  function syncBlockStyles() {
    previewBlocks.forEach((element) => {
      if (!(element instanceof HTMLElement)) return;
      const blockId = element.dataset.blockId || '';
      const comment = getComment(blockId);
      const hasDraft = comment != null;
      const hasBody = hasDraft && comment.body.trim().length > 0;
      element.classList.toggle('has-comment', hasDraft);
      element.classList.toggle('comment-filled', hasBody);
      element.classList.toggle('is-selected', state.selectedBlockId === blockId);
    });
  }

  function updateSummary() {
    const total = state.comments.length;
    const filled = countFilledComments();
    const drafts = total - filled;
    const label = filled === 1 ? '1 comment ready' : filled + ' comments ready';
    commentCountEl.textContent = String(total);
    feedbackCountEl.textContent = drafts > 0 ? label + ' • ' + drafts + ' draft' + (drafts === 1 ? '' : 's') : label;
    submitButton.disabled = !hasFeedback();
    syncBlockStyles();
  }

  function selectBlock(blockId, scroll) {
    if (!blockMap.has(blockId)) return;
    state.selectedBlockId = blockId;
    syncBlockStyles();
    if (scroll) scrollToBlock(blockId, true);
  }

  function flashBlock(blockId) {
    const blockEl = document.querySelector('.preview-block[data-block-id="' + blockId + '"]');
    if (!(blockEl instanceof HTMLElement)) return;
    blockEl.classList.add('is-active');
    scrollToBlock(blockId, true);
    setTimeout(() => blockEl.classList.remove('is-active'), 1200);
  }

  function moveSelection(delta) {
    if (blocks.length === 0) return;
    const currentIndex = getSelectedIndex();
    const nextIndex = currentIndex < 0
      ? 0
      : Math.min(blocks.length - 1, Math.max(0, currentIndex + delta));
    const nextBlock = blocks[nextIndex];
    if (nextBlock) selectBlock(nextBlock.id, true);
  }

  function ensureComment(blockId) {
    const existing = getComment(blockId);
    if (existing) return existing;
    const comment = { blockId, body: '' };
    state.comments.push(comment);
    sortComments();
    return comment;
  }

  function focusComment(blockId) {
    const textarea = commentsListEl.querySelector('textarea[data-block-id="' + blockId + '"]');
    if (!(textarea instanceof HTMLTextAreaElement)) return;
    textarea.focus();
    const end = textarea.value.length;
    textarea.setSelectionRange(end, end);
  }

  function removeComment(blockId) {
    state.comments = state.comments.filter((comment) => comment.blockId !== blockId);
    renderComments();
  }

  function renderComments() {
    sortComments();
    commentsListEl.innerHTML = '';
    emptyStateEl.hidden = state.comments.length > 0;

    for (const comment of state.comments) {
      const block = blockMap.get(comment.blockId);
      if (!block) continue;

      const card = document.createElement('section');
      card.className = 'comment-card';

      const title = document.createElement('div');
      title.className = 'comment-card-title';
      title.textContent = block.label || 'Block';

      const excerpt = document.createElement('p');
      excerpt.className = 'comment-excerpt';
      excerpt.textContent = block.sourceMarkdown || block.excerpt || 'No text available.';

      const textarea = document.createElement('textarea');
      textarea.dataset.blockId = block.id;
      textarea.placeholder = 'What should change here?';
      textarea.value = comment.body;
      textarea.addEventListener('focus', () => selectBlock(block.id, true));
      textarea.addEventListener('input', () => {
        comment.body = textarea.value;
        updateSummary();
      });

      const actions = document.createElement('div');
      actions.className = 'comment-actions';

      const showButton = document.createElement('button');
      showButton.type = 'button';
      showButton.textContent = 'Show';
      showButton.addEventListener('click', () => {
        selectBlock(block.id, true);
        flashBlock(block.id);
      });

      const removeButton = document.createElement('button');
      removeButton.type = 'button';
      removeButton.className = 'danger-button';
      removeButton.textContent = 'Remove';
      removeButton.addEventListener('click', () => removeComment(block.id));

      actions.appendChild(showButton);
      actions.appendChild(removeButton);

      card.appendChild(title);
      card.appendChild(excerpt);
      card.appendChild(textarea);
      card.appendChild(actions);
      commentsListEl.appendChild(card);
    }

    updateSummary();
  }

  function openComment(blockId) {
    selectBlock(blockId, true);
    ensureComment(blockId);
    renderComments();
    flashBlock(blockId);
    requestAnimationFrame(() => focusComment(blockId));
  }

  function buildSubmitPayload() {
    return {
      type: 'submit',
      overallComment: state.overallComment.trim(),
      comments: state.comments
        .map((comment) => {
          const block = blockMap.get(comment.blockId);
          if (!block) return null;
          return {
            blockId: block.id,
            blockIndex: block.index,
            blockKind: block.kind,
            blockLabel: block.label,
            excerpt: block.excerpt,
            sourceMarkdown: block.sourceMarkdown,
            body: comment.body.trim(),
          };
        })
        .filter((comment) => comment && comment.body.length > 0),
    };
  }

  function closeWindow(type) {
    try { window.glimpse.send({ type }); } catch {}
    try { window.glimpse.close(); } catch {}
  }

  function submitFeedback() {
    if (!hasFeedback()) return;
    try { window.glimpse.send(buildSubmitPayload()); } catch {}
    try { window.glimpse.close(); } catch {}
  }

  function isEditableTarget(target) {
    return target instanceof HTMLElement
      && (target.tagName === 'TEXTAREA' || target.tagName === 'INPUT' || target.isContentEditable);
  }

  overallCommentEl.addEventListener('input', () => {
    state.overallComment = overallCommentEl.value;
    updateSummary();
  });

  closeButton.addEventListener('click', () => closeWindow('done'));
  submitButton.addEventListener('click', () => submitFeedback());

  previewBlocks.forEach((element) => {
    if (!(element instanceof HTMLElement)) return;
    element.addEventListener('click', () => {
      const blockId = element.dataset.blockId || '';
      if (!blockId) return;
      if (state.selectedBlockId === blockId) {
        openComment(blockId);
      } else {
        selectBlock(blockId, false);
      }
    });
  });

  document.addEventListener('keydown', (event) => {
    if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
      if (!submitButton.disabled) {
        event.preventDefault();
        submitFeedback();
      }
      return;
    }

    if (isEditableTarget(event.target)) return;

    const key = String(event.key || '').toLowerCase();
    if (!event.metaKey && !event.ctrlKey && !event.altKey && key === 'd') {
      event.preventDefault();
      closeWindow('done');
      return;
    }
    if (!event.metaKey && !event.ctrlKey && !event.altKey && (key === 'c' || key === 'enter')) {
      if (state.selectedBlockId) {
        event.preventDefault();
        openComment(state.selectedBlockId);
      }
      return;
    }
    if (!event.metaKey && !event.ctrlKey && !event.altKey && (key === 'arrowdown' || key === 'j')) {
      event.preventDefault();
      moveSelection(1);
      return;
    }
    if (!event.metaKey && !event.ctrlKey && !event.altKey && (key === 'arrowup' || key === 'k')) {
      event.preventDefault();
      moveSelection(-1);
      return;
    }
    if (key === 'escape') {
      event.preventDefault();
      closeWindow('cancel');
    }
  }, true);

  renderComments();
  syncBlockStyles();
`;
