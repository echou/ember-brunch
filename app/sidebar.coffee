App = require('app')

Em = App.Ember
App.addMVCs
    SidebarController: Em.ArrayController.extend
        content: [
            {name: 'menu1', goto: 'root.sub'}
            {name: 'menu2', goto: 'main'}
            {name: 'menu3', goto: 'sub'}
            {name: 'menu4', goto: 'main'}
            {name: 'menu5', goto: 'sub2'}
        ]
    SidebarView: App.View("sidebar")

App.addRoutes
    clickSidebar: (r, e) ->
        r.sidebarController.setEach('active', false)
        Em.set(e, 'context.active', true)
        num = Em.get(e, 'context.num') ? 0
        Em.set(e, 'context.num', num + 1)
        r.transitionTo Em.get(e, 'context.goto'), undefined