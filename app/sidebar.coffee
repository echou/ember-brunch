App = require('app')

Em = App.Ember
App.addMVCs
    SidebarController: Em.ArrayController.extend
        content: [
            {name: '菜单1', goto: 'root.sub'}
            {name: '菜单2', goto: 'main'}
            {name: '菜单3', goto: 'sub'}
            {name: '菜单4', goto: 'main'}
            {name: '菜单5', goto: 'sub2'}
        ]
    SidebarView: App.View("sidebar")

App.addRoutes
    clickSidebar: (r, e) ->
        #                    r.sidebarController.setEach('active', false)
        #                    Em.set(e, 'context.active', true)
        num = Em.get(e, 'context.num') ? 0
        Em.set(e, 'context.num', num + 1)

        r.transitionTo Em.get(e, 'context.goto'), undefined