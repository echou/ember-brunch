App = require('app')
Em = App.Ember

App.reopen
    SubController: Em.ObjectController.extend
        content: Em.Object.create()
        now: 1347076709
        icons: "beaker bell bolt briefcase cut legal sort table tasks truck github".w()
    SubView: App.View("sub")

App.addRoutes
    sub: Em.Route.extend
        route: '/sub'
        connectOutlets: (r, ctx) ->
            r.applicationController.connectOutlet 'sub'

        enter: (r) ->
            r.breadcrumbController.pushObject {name: 'sub'}
        exit: (r) ->
            r.breadcrumbController.shiftObject()
