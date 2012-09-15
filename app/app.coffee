jq = $.noConflict(true)

get = Em.get
set = Em.set

RootRoute = Em.Route.extend

    loading: Em.State.extend {}

    goto: (r, e) ->
        r.transitionTo e.context

    navigateAway: (r) ->
        # 初始化全局的outlets
        c = r.applicationController
        if r.get('sidebarController')?
            c.connectOutlet 'sidebar', 'sidebar'
        if r.get('breadcrumbController')?
            c.connectOutlet 'breadcrumb', 'breadcrumb'
        if r.get('noticeController')?
            c.connectOutlet 'notice', 'notice'

# 主程序


App = Ember.Application.create()
App.$ = App.jQuery = jq
App.Em = App.Ember = Ember
App.addRoutes = (opts) -> RootRoute.reopen(opts)
App.addMVCs = (opts) -> App.reopen(opts)
App.View = (templateName, opts) ->
    V = Em.View.extend {templateName: require("templates/#{templateName}")}
    if opts? then V.reopen(opts)
    return V

App.reopen
    ApplicationController: Em.Controller.extend {}
    ApplicationView: App.View("application")
    Router: Em.Router.extend
        enableLogging: true
        root: RootRoute

App.reopen
    BreadcrumbController: Em.ArrayController.extend
        content: Em.A()
        assign: (items...) ->  @set 'content.[]', Em.A(items)
    BreadcrumbView: App.View("breadcrumb")

App.reopen
    NoticeController: Em.Controller.extend
        notices: Em.A()
        add: (message, type, removeAfter) ->
            id = @incrementProperty 'notice_id'
            @get('notices').pushObject Em.Object.create({id: id, type: type, message: message})
            if removeAfter > 0
                Em.run.later((=>
                    obj = @get('notices').findProperty('id', id)
                    if obj then @get('notices').removeObject(obj)
                ), removeAfter)
    NoticeView: Em.CollectionView.extend
        contentBinding: 'notices'
        #      classNames: ['well', 'well-small']
        itemViewClass: Em.View.extend
            classNames: ['alert']
            classNameBindings: ['alertType']
            template: Em.Handlebars.compile '{{message}}'
            alertType: (-> "alert-" + @get('type')).property('type').cacheable()


module.exports = App