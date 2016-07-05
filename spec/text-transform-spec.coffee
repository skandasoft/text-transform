TextTransform = require '../lib/text-transform'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "TextTransform", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('text-transform')

  describe "when the text-transform:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.text-transform')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'text-transform:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.text-transform')).toExist()

        textTransformElement = workspaceElement.querySelector('.text-transform')
        expect(textTransformElement).toExist()

        textTransformPanel = atom.workspace.panelForItem(textTransformElement)
        expect(textTransformPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'text-transform:toggle'
        expect(textTransformPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.text-transform')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'text-transform:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        textTransformElement = workspaceElement.querySelector('.text-transform')
        expect(textTransformElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'text-transform:toggle'
        expect(textTransformElement).not.toBeVisible()
