if Meteor.isClient
    Router.route '/admin', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'


    Template.admin.onCreated ->
        @autorun => @subscribe 'model_docs', 'admin', ->
            
    Template.admin.helpers
        query_doc: ->
            Docs.findOne 
                model:'admin'
        
    Template.admin.events
        'click .run_query': ->
            qd = 
                Docs.findOne
                    model:'admin'
            if qd
                console.log 'admin doc', qd
            unless qd
                Docs.insert 
                    model:'admin'