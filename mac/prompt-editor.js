ObjC.import('Cocoa')

function run(args) {
  const app = $.NSApplication.sharedApplication
  app.setActivationPolicy($.NSApplicationActivationPolicyRegular)
  const style = $.NSWindowStyleMaskTitled | $.NSWindowStyleMaskClosable |
    $.NSWindowStyleMaskMiniaturizable | $.NSWindowStyleMaskResizable
  const window = $.NSWindow.alloc.initWithContentRectStyleMaskBackingDefer(
    $.NSMakeRect(0, 0, 940, 650), style, $.NSBackingStoreBuffered, false)
  window.title = 'Paste system prompt'
  window.minSize = $.NSMakeSize(560, 380)
  window.releasedWhenClosed = false
  const content = window.contentView
  const label = $.NSTextField.labelWithString('Paste or edit your instructions. Formatting is preserved as plain text in AGENTS.md.')
  label.frame = $.NSMakeRect(20, 610, 900, 24)
  label.autoresizingMask = $.NSViewWidthSizable | $.NSViewMinYMargin
  content.addSubview(label)

  const scroll = $.NSScrollView.alloc.initWithFrame($.NSMakeRect(20, 65, 900, 530))
  scroll.hasVerticalScroller = true
  scroll.hasHorizontalScroller = true
  scroll.autohidesScrollers = true
  scroll.borderType = $.NSBezelBorder
  scroll.autoresizingMask = $.NSViewWidthSizable | $.NSViewHeightSizable
  const editor = $.NSTextView.alloc.initWithFrame($.NSMakeRect(0, 0, 900, 530))
  editor.richText = false
  editor.importsGraphics = false
  editor.font = $.NSFont.userFixedPitchFontOfSize(14)
  editor.automaticQuoteSubstitutionEnabled = false
  editor.automaticDashSubstitutionEnabled = false
  editor.automaticTextReplacementEnabled = false
  editor.automaticSpellingCorrectionEnabled = false
  editor.automaticLinkDetectionEnabled = false
  editor.allowsUndo = true
  editor.verticallyResizable = true
  editor.horizontallyResizable = true
  editor.minSize = $.NSMakeSize(0, 0)
  editor.maxSize = $.NSMakeSize(10000000, 10000000)
  editor.textContainer.containerSize = $.NSMakeSize(10000000, 10000000)
  editor.textContainer.widthTracksTextView = false
  scroll.documentView = editor
  content.addSubview(scroll)

  ObjC.registerSubclass({
    name: 'JBPromptEditorActions', superclass: 'NSObject', protocols: ['NSWindowDelegate'],
    methods: {
      'accept:': { types: ['void', ['id']], implementation: function () { app.stopModalWithCode(1) } },
      'cancel:': { types: ['void', ['id']], implementation: function () { app.stopModalWithCode(0) } },
      'windowShouldClose:': { types: ['bool', ['id']], implementation: function () { app.stopModalWithCode(0); return false } }
    }
  })
  const actions = $.JBPromptEditorActions.alloc.init
  window.delegate = actions
  function button(title, x, action) {
    const item = $.NSButton.alloc.initWithFrame($.NSMakeRect(x, 15, 120, 32))
    item.title = title
    item.bezelStyle = $.NSBezelStyleRounded
    item.target = actions
    item.action = action
    item.autoresizingMask = $.NSViewMinXMargin | $.NSViewMaxYMargin
    content.addSubview(item)
    return item
  }
  const cancel = button('Cancel', 670, 'cancel:')
  cancel.keyEquivalent = '\u001b'
  button('Continue', 800, 'accept:')
  // Standard shortcuts; Enter remains a newline in the editor.
  const menu = $.NSMenu.alloc.initWithTitle('Main')
  const editItem = $.NSMenuItem.alloc.initWithTitleActionKeyEquivalent('Edit', null, '')
  const editMenu = $.NSMenu.alloc.initWithTitle('Edit')
  for (const [title, action, key] of [['Undo', 'undo:', 'z'], ['Cut', 'cut:', 'x'], ['Copy', 'copy:', 'c'], ['Paste', 'pasteAsPlainText:', 'v'], ['Select All', 'selectAll:', 'a']]) {
    editMenu.addItem($.NSMenuItem.alloc.initWithTitleActionKeyEquivalent(title, action, key))
  }
  editItem.submenu = editMenu
  menu.addItem(editItem)
  app.mainMenu = menu
  if (args.indexOf('--self-test') !== -1) {
    const sample = '# Heading\n\n\tIndented ä 🎉\n' + 'Long formatted line '.repeat(1000) + '\n\n'
    editor.string = sample
    if (ObjC.unwrap(editor.string) !== sample) throw new Error('Text preservation failed')
    return 'PASS: native editor constructed; multiline, Unicode, tabs and trailing blank lines preserved.'
  }
  window.center
  window.makeKeyAndOrderFront(null)
  window.makeFirstResponder(editor)
  app.activateIgnoringOtherApps(true)
  const result = app.runModalForWindow(window)
  window.orderOut(null)
  if (Number(result) !== 1) return ''
  return ObjC.unwrap(editor.string) + '__OPENCODE_PROMPT_END_9F73__'
}
