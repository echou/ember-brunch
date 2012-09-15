App = require('app')
Em = App.Ember

require('templates/main')

App.reopen
    MainController: Em.ObjectController.extend
        content: Em.Object.create()
        now: 1347076709
        values: [1]
        changeRandom: ->
            newvalues = []
            for i in [1..20]
                v = Math.round(Math.random() * 100)
                newvalues.push v
            @set('values', newvalues)
    MainView: App.View("main")


App.addRoutes

    goHome: Em.Route.transitionTo 'root.index'
    gotoMain: Em.Route.transitionTo 'main'


    index: Em.Route.extend
        route: '/'
        redirectsTo: 'main'

    main: Em.Route.extend
        route: '/main'
        connectOutlets: (r) ->
            r.applicationController.connectOutlet 'main'
        gotoSub: Em.Route.transitionTo('sub')
        changeRandom: (r) ->
            r.mainController.changeRandom()
        hoverButtonClick: (r, e) ->
            console.log 'hoverButtonClick', e
