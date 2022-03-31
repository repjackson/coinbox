if Meteor.isClient
    Router.route '/charities', (->
        @layout 'layout'
        @render 'orgs'
        ), name:'orgs'
    Router.route '/org/:doc_id/edit', (->
        @layout 'layout'
        @render 'org_edit'
        ), name:'org_edit'
    Router.route '/org/:doc_id', (->
        @layout 'layout'
        @render 'org_view'
        ), name:'org_view'
    Router.route '/org/:doc_id/view', (->
        @layout 'layout'
        @render 'org_view'
        ), name:'org_view_long'
    
    
    # Template.orgs.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'org', ->
    Template.orgs.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'member_count'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.orgs.onCreated ->
        # @autorun => @subscribe 'model_docs', 'org', ->
        @autorun => @subscribe 'org_facets',
            picked_tags.array()
            # Session.get('limit')
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('view_delivery')
            # Session.get('view_pickup')
            # Session.get('view_open')

        @autorun => @subscribe 'org_results',
            picked_tags.array()
            Session.get('group_title_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

    Template.org_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->

        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.org_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.org_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.orgs.helpers
        org_docs: ->
            Docs.find {
                model:'org'
            }, sort:_timestamp:-1
        tag_results: ->
            Results.find 
                model:'org_tag'
        picked_org_tags: -> picked_tags.array()
        
                
    Template.orgs.events
        'click .add_org': ->
            new_id = 
                Docs.insert 
                    model:'org'
            Router.go "/org/#{new_id}/edit"
    Template.org_card.events
        'click .view_org': ->
            Router.go "/org/#{@_id}"
    Template.org_item.events
        'click .view_org': ->
            Router.go "/org/#{@_id}"

    Template.org_view.events
        'click .add_org_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    org_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.org_edit.events
        'click .delete_org': ->
            Swal.fire({
                title: "delete org?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'org removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/org"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish org?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_org', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'org published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish org?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_org', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'org unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'org_results', (
        )->
        # console.log picked_ingredients
        # if doc_limit
        #     limit = doc_limit
        # else
        limit = 42
        # if doc_sort_key
        #     sort_key = doc_sort_key
        # if doc_sort_direction
        #     sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'org'}
        # if picked_ingredients.length > 0
        #     match.ingredients = $all: picked_ingredients
        #     # sort = 'price_per_serving'
        # if picked_sections.length > 0
        #     match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        # match.published = true
            # match.source = $ne:'wikipedia'
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if org_query and org_query.length > 1
        #     console.log 'searching org_query', org_query
        #     match.title = {$regex:"#{org_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        # console.log 'org match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        unless Meteor.userId()
            match.private = $ne:true
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 42
            
            
    Meteor.publish 'org_count', (
        picked_ingredients
        picked_sections
        org_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'org'}
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
        if org_query and org_query.length > 1
            console.log 'searching org_query', org_query
            match.title = {$regex:"#{org_query}", $options: 'i'}
        Counts.publish this, 'org_counter', Docs.find(match)
        return undefined

    Meteor.publish 'org_facets', (
        picked_tags
        org_query
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query

        self = @
        match = {}
        match.model = 'org'
            # match.$regex:"#{org_query}", $options: 'i'}
        # if org_query and org_query.length > 1
        #     console.log 'searching org_query', org_query
        #     match.title = {$regex:"#{org_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        if picked_tags.length > 0
            match.tags = $all: picked_tags
        # # console.log 'match for tags', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            # { $match: _id: {$regex:"#{org_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'org_tag'
                # category:key
                # index: i


        self.ready()





if Meteor.isClient
    Template.org_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.org_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.org_card.helpers
        org_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            