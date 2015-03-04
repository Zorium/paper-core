z = require 'zorium'

paperColors = require '../colors.json'
RipplerService = require '../services/rippler'
styles = require './index.styl'

module.exports = class Button
  constructor: ->
    styles.use()

    @state = z.state
      backgroundColor: null
      isHovered: false
      isActive: false

  getBackgroundColor: (colors, isRaised, isHovered, isActive, isDark) ->
    if isRaised
      if isActive
        colors.c700
      else if isHovered
        colors.c600
      else
        colors.c500
    else
      if isActive
        if isDark
          'rgba(204, 204, 204, 0.25)'
        else
          'rgba(153, 153, 153, 0.40)'
      else if isHovered
        if isDark
          'rgba(204, 204, 204, 0.15)'
        else
          'rgba(153, 153, 153, 0.20)'
      else
        null

  render: ({text, isDisabled, listeners, isRaised, isFullWidth,
            isShort, isDark, isFlat, colors, onclick, type}) =>
    {backgroundColor, isHovered, isActive} = @state()

    type ?= 'button'
    isRaised ?= false
    isFlat = not isRaised
    isDisabled ?= false
    isDark ?= false
    onclick ?= (-> null)
    colors ?= {}
    colors = _.defaults colors, {
      cText: if colors.ink and not isDisabled \
                   then colors.ink
                   else null
      c200: if isDark and isFlat then paperColors.$grey500 \
            else paperColors.$grey800
      c500: null
      c600: null
      c700: null
      ink: null
    }
    backgroundColor ?= @getBackgroundColor colors, isRaised, isHovered,
                                           isActive, isDark

    z '.zp-button',
      className: z.classKebab {
        isRaised
        isFlat
        isShort
        isFullWidth
        isDark
        isDisabled
      }
      ontouchstart: =>
        @state.set isActive: true
      ontouchend: =>
        @state.set isActive: false, isHovered: false
      onmouseover: =>
        @state.set isHovered: true
      onmouseout: =>
        @state.set isHovered: false
      onmouseup: =>
        @state.set isActive: false
      onclick: (e) =>
        @state.set isHovered: false
        onclick(e)

      z '.ripple-box',
        onmousedown: z.ev (e, $$el) =>
          @state.set isActive: true
          unless isDisabled
            RipplerService.ripple {
              $$el
              color: colors.ink or colors.c200
              mouseX: e.clientX
              mouseY: e.clientY
            }
        z 'input.button',
          {
            attributes:
              disabled: if isDisabled then true else undefined
              type: type
            value: text
            style:
              backgroundColor: if isDisabled then null else backgroundColor
              color: if isDisabled then null else colors.cText
          }
