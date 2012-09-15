moment = require('moment')
App = require('app')
Em = App.Em
$ = App.$

escape = (s) -> Em.Handlebars.Utils.escapeExpression(s)

HandlebarsTransformView = Em._MetamorphView.extend
    rawValue: null,
    transformFunc: null,

    value: (->
        rawValue = @get('rawValue')
        transformFunc = @get('transformFunc')
        transformFunc(rawValue)
    ).property('rawValue', 'transformFunc').cacheable()

    render: (buffer) ->
        value = @get('value');
        if value then buffer.push(value)

    needsRerender: (-> @rerender()).observes('value')

HandlebarsTransformView.helper = (context, property, transformFunc, options, isPath) ->
    if not isPath? or isPath
        if /^#/.test(property)
            isPath = false
            property = property.substr(1)
        else
            isPath = true
    if isPath
        options.hash =
            rawValueBinding: property
            transformFunc: transformFunc
    else
        options.hash =
            rawValue: property
            transformFunc: transformFunc
    Em.Handlebars.ViewHelper.helper(context, HandlebarsTransformView, options)

Em.Handlebars.registerHelper 'widget', (property, options) ->
    Em.Handlebars.ViewHelper.helper(this, 'controller.namespace.widgets.' + property, options)

Em.Handlebars.registerHelper 'moment', (property, options) ->
    transformFunc = (time) ->
        t = parseInt(time, 10)
        if isNaN(t)
            title = ''
            fromNow = Em.Handlebars.Utils.escapeExpression(time)
        else
            m = moment(t * 1000)
            title = m.format('YYYY-M-D HH:mm:ss')
            fromNow = m.fromNow()
        "<span class='moment' title='#{title}'>#{fromNow}</span>".htmlSafe()

    HandlebarsTransformView.helper(this, property, transformFunc, options)

Em.Handlebars.registerHelper 'badge', (property, options) ->
    type0 = options.hash.type ? ""
    showZero = options.hash.showZero?
    transformFunc = (value) ->
        type = type0
        if type
            type = "badge badge-#{escape(type)}"
        else
            v = parseInt(value, 10)
            if not value?
                type = undefined
            else if isNaN(v)
                type = "badge"
            else if v == 0
                type = if showZero then "badge" else undefined
            else if v < 10
                type = "badge badge-success"
            else if v < 20
                type = "badge badge-warning"
            else
                type = "badge badge-important"
        if not type?
            ""
        else
            escaped = escape("" + value)
            "<span class='#{type}'>#{escaped}</span>".htmlSafe()
    HandlebarsTransformView.helper(this, property, transformFunc, options)

Em.Handlebars.registerHelper 'icon', (property, options) ->
    transformFunc = (value) ->
        "<i class='icon-#{escape(value)}'></i>".htmlSafe()
    HandlebarsTransformView.helper(this, property, transformFunc, options, false)

Em.Handlebars.registerHelper 'icon2', (property, options) ->
    transformFunc = (value) ->
        "<i class='icon-#{escape(value)}'></i>".htmlSafe()
    HandlebarsTransformView.helper(this, property, transformFunc, options, true)

Em.Handlebars.registerHelper 'bspath', (property, options) ->
    transformFunc = (value) ->
        tags = 0
        res = ("" + value).replace(/\[([^\[\]]+)\]/g, (s, a) -> tags = tags + 1; "<span>[#{escape(a)}]</span>")
        if not tags then res = "<span>#{escape(res)}</span>"
        "<span class='tag' title='#{escape(value)}'>#{res}</span>".htmlSafe()
    HandlebarsTransformView.helper(this, property, transformFunc, options, true)

exports.pagination = Em.View.extend
    content: null
    gotoPage: null
    classNames: ['pagination'],
    template: Em.Handlebars.compile '<ul>
                              {{view view.itemView value="«"}}
                              {{#each view.seqs}}
                                    {{view view.itemView value=this}}
                              {{/each}}
                              {{view view.itemView value="»"}}
                              </ul>'
    seqs: (->
        last = @get 'content.last'
        ret = if last? then [0..last] else []
    ).property('content').cacheable()
    isVisibleBinding: 'content.visible'
    itemView: Em.View.extend
        value: null # '«','»', '...', number
        tagName: 'li'
        classNameBindings: ['disabled:disabled', 'active:active']
        template: Em.Handlebars.compile "<a>{{view.label}}</a>"
        label: (->
            value = @get('value')
            num = parseInt value, 10
            if isNaN num then value else num + 1
        ).property('value').cacheable()
        disabled: (->
            switch @get('value')
                when '«' then not @get('parentView.content.hasPrev')
                when '»' then not @get('parentView.content.hasNext')
                else
                    false
        ).property('parentView.content').cacheable()
        active: (->
            @get('value') == @get('parentView.content.cur')
        ).property('parentView.content').cacheable()
        click: (e) ->
            p = @get 'parentView.content'
            value = @get 'value'
            value = switch value
                when '«'
                    get(content, 'hasPrev') and get(content, 'prev')
                when '»'
                    get(content, 'hasNext') and get(content, 'next')
                else
                    num = parseInt value, 10
                    not isNaN(num) and num
            if value?
                @get('controller.target')?.send('changePage', value)
                # used in non-app-routing environment
                @set 'parentView.gotoPage', value


# Bootstrap ModelPane (Dialog)
modalPaneTemplate = [
    '<div class="modal-header">'
    '  <a href="#" class="close" rel="close">×</a>'
    '  {{view view.headerViewClass}}'
    '</div>'
    '<div class="modal-body">{{view view.bodyViewClass}}</div>'
    '<div class="modal-footer">'
    '  {{#if view.reject}}<a href="#" class="btn btn-danger" rel="reject">{{view.reject}}</a>{{/if}}'
    '  {{#if view.secondary}}<a href="#" class="btn btn-secondary" rel="secondary">{{view.secondary}}</a>{{/if}}'
    '  {{#if view.primary}}<a href="#" class="btn btn-primary" rel="primary">{{view.primary}}</a>{{/if}}'
    '</div>'
].join("\n")

modalPaneBackdrop = '<div class="modal-backdrop"></div>'
;

ModalPane = Ember.View.extend
    classNames: ['modal']
    defaultTemplate: Ember.Handlebars.compile(modalPaneTemplate)
    heading: null
    message: null
    primary: null
    secondary: null
    reject: null
    showBackdrop: true
    headerViewClass: Ember.View.extend
        tagName: 'h3'
        template: Ember.Handlebars.compile('{{view.parentView.heading}}')
    bodyViewClass: Ember.View.extend
        tagName: 'p',
        template: Ember.Handlebars.compile('{{{view.parentView.message}}}')

    didInsertElement: ->
        if @get('showBackdrop') then @_appendBackdrop()
        @_setupDocumentKeyHandler()
    willDestroyElement: ->
        @_backdrop?.remove()
        @_removeDocumentKeyHandler()

    keyPress: (event) ->
        if event.keyCode == 27
            @_triggerCallbackAndDestroy({ close: true }, event)

    click: (event) ->
        switch event.target.getAttribute('rel')
            when 'close' then @_triggerCallbackAndDestroy({ close: true }, event)
            when 'primary' then @_triggerCallbackAndDestroy({ primary: true }, event)
            when 'secondary' then @_triggerCallbackAndDestroy({ secondary: true }, event)
            when 'reject' then @_triggerCallbackAndDestroy({ reject: true }, event)
        return false

    _appendBackdrop: ->
        parentLayer = @$().parent()
        @_backdrop = $(modalPaneBackdrop).appendTo(parentLayer)

    _setupDocumentKeyHandler: ->
        handler = (event) => @keyPress(event)
        $(window.document).bind('keyup', handler)
        @_keyUpHandler = handler

    _removeDocumentKeyHandler: ->
        $(window.document).unbind('keyup', @_keyUpHandler)

    _triggerCallbackAndDestroy: (options, event) ->
        @callback?(options, event);
        @destroy()

ModalPane.reopenClass
    popup: (options) ->
        if not options then options = {}
        modalPane = @create(options);
        modalPane.append()
        modalPane
exports.ModalPane = ModalPane

exports.Alert = (title, message) ->
    ModalPane.popup
        heading: title
        message: message
        primary: "关闭"
        showBackdrop: false

exports.ProgressBar = Em.View.extend
    classNames: ['progress']
    classNameBindings: ['isStriped:progress-striped', 'isAnimated:active']
    template: Em.Handlebars.compile('<div class="bar"  {{bindAttr style="style"}}></div>')
    isAnimated: false
    isStriped: true
    progress: 0
    style: (->
        progress = @get('progress')
        console.log "progress #{progress}"
        "width:#{progress}%;"
    ).property("progress").cacheable()

    didInsertElement: ->
        #            style = @get('style')
        #            console.log "progress #{style}"
        true

exports.HoverButton = Em.View.extend
    tagName: 'button'
    noHoverLabel: 'no-hover-label'
    hoverLabel: 'hover-label'
    classNames: ['btn']
    classNameBindings: ['hovering:btn-primary:btn-warning']
    hovering: false
    template: Em.Handlebars.compile('{{{view.label}}}')
    label: (->
        hover = @get('hovering')
        if hover then @get('hoverLabel') else @get('noHoverLabel')
    ).property('hovering', 'hoverLabel', 'noHoverLabel').cacheable()
    didInsertElement: ->
        @$().hover((=>@set 'hovering', true), (=>@set 'hovering', false))

    click: ->
        @get('controller.target').send('hoverButtonClick')

App.widgets = exports

