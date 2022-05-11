if Meteor.isClient
    Router.route '/logs', (->
        @layout 'layout'
        @render 'logs'
        ), name:'logs'
    Router.route '/log/:doc_id', (->
        @layout 'layout'
        @render 'log_view'
        ), name:'log_view'
    
    
    # Template.logs.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'log', ->
    Template.logs.onCreated ->
        Session.setDefault 'view_mode', 'cards'
        Session.setDefault 'sort_key', 'points'
        Session.setDefault 'sort_direction', -1
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.logs.onCreated ->
        @autorun => @subscribe 'results',
            'log'
            picked_tags.array()
            Session.get('current_query')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')

    Template.log_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->

        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.log_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.log_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->

                
    Template.logs.events
        'click .add_log': ->
            new_id = 
                Docs.insert 
                    model:'log'
            Router.go "/log/#{new_id}/edit"
    Template.log_card.events
        'click .view_log': ->
            Router.go "/log/#{@_id}"
    Template.log_item.events
        'click .view_log': ->
            Router.go "/log/#{@_id}"


            
if Meteor.isServer
    Meteor.publish 'log_count', (
        picked_ingredients
        picked_sections
        current_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'log'}
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if current_query and current_query.length > 1
            console.log 'searching current_query', current_query
            match.title = {$regex:"#{current_query}", $options: 'i'}
        Counts.publish this, 'log_counter', Docs.find(match)
        return undefined
