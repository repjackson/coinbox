if Meteor.isClient
    Router.route '/faqs', (->
        @layout 'layout'
        @render 'faqs'
        ), name:'faqs'
    Router.route '/about', (->
        @layout 'layout'
        @render 'about'
        ), name:'about'
    Router.route '/contact', (->
        @layout 'layout'
        @render 'contact'
        ), name:'contact'
    Router.route '/get_started', (->
        @layout 'layout'
        @render 'get_started'
        ), name:'get_started'
        
    Template.faqs.onCreated ->
    Template.page.onCreated ->
        @autorun => @subscribe 'page_doc', @data.key, ->
            
    Template.page.events
        'click .create_doc': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    key:@key
            Router.go "/post/#{new_id}/edit"
            
            
    Template.page.helpers
        page_doc: ->
            Docs.findOne 
                model:'post'
                key:@key
            
if Meteor.isServer
    Meteor.publish 'page_doc', (key)->
        Docs.find 
            model:'post'
            key:key
