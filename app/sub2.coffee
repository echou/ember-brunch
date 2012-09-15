App = require('app')
Em = App.Ember
$ = App.$

App.reopen
    Sub2Controller: Em.ObjectController.extend
        content: Em.Object.create()
        now: 1347076709
        icons: "beaker bell bolt briefcase cut legal sort table tasks truck github".w()
    Sub2View: App.View("sub2")

App.addRoutes
    sub2: Em.Route.extend
        route: '/sub2/:id'
        deserialize: (r, hash) ->
            $.ajax({url: '/yunapp/demo-sub2', dataType: 'json'})
        serialize: (r, obj) ->
            { id: 1 }
        connectOutlets: (r, obj) ->
            r.applicationController.connectOutlet 'sub2', obj