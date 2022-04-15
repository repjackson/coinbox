if Meteor.isClient
    Template.testimonials_widget.onCreated ->
        @autorun => @subscribe 'model_docs', 'testimonial', ->
    
    
    
    Template.testimonials_widget.helpers
        testimonial_docs: ->
            Docs.find   
                model:'testimonial'


    Router.route '/testimonials', (->
        @layout 'layout'
        @render 'testimonials'
        ), name:'testimonials'
    Router.route '/testimonial/:doc_id/edit', (->
        @layout 'layout'
        @render 'testimonial_edit'
        ), name:'testimonial_edit'
    Router.route '/testimonial/:doc_id', (->
        @layout 'layout'
        @render 'testimonial_view'
        ), name:'testimonial_view'
    Router.route '/testimonial/:doc_id/view', (->
        @layout 'layout'
        @render 'testimonial_view'
        ), name:'testimonial_view_long'
    
    
    # Template.testimonials.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'testimonial', ->
    Template.testimonials.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'member_count'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.testimonials.onCreated ->
        # @autorun => @subscribe 'model_docs', 'testimonial', ->
        @autorun => @subscribe 'testimonial_facets',
            picked_tags.array()
            # Session.get('limit')
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('view_delivery')
            # Session.get('view_pickup')
            # Session.get('view_open')

        @autorun => @subscribe 'testimonial_results',
            picked_tags.array()
            Session.get('group_title_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

    Template.testimonial_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->

        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.testimonial_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.testimonial_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.testimonials.helpers
        testimonial_docs: ->
            Docs.find {
                model:'testimonial'
            }, sort:_timestamp:-1
        tag_results: ->
            Results.find 
                model:'testimonial_tag'
        picked_testimonial_tags: -> picked_tags.array()
        
                
    Template.testimonials.events
        'click .add_testimonial': ->
            new_id = 
                Docs.insert 
                    model:'testimonial'
            Router.go "/testimonial/#{new_id}/edit"
    Template.testimonial_card.events
        'click .view_testimonial': ->
            Router.go "/testimonial/#{@_id}"

    
    Template.testimonial_edit.events
        'click .delete_testimonial': ->
            Swal.fire({
                title: "delete testimonial?"
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
                        title: 'testimonial removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/testimonial"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish testimonial?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_testimonial', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'testimonial published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish testimonial?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_testimonial', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'testimonial unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'testimonial_results', (
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
        match = {model:'testimonial'}
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
        # if testimonial_query and testimonial_query.length > 1
        #     console.log 'searching testimonial_query', testimonial_query
        #     match.title = {$regex:"#{testimonial_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        # console.log 'testimonial match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        unless Meteor.userId()
            match.private = $ne:true
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 42
            
            
    Meteor.publish 'testimonial_count', (
        picked_ingredients
        picked_sections
        testimonial_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'testimonial'}
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
        if testimonial_query and testimonial_query.length > 1
            console.log 'searching testimonial_query', testimonial_query
            match.title = {$regex:"#{testimonial_query}", $options: 'i'}
        Counts.publish this, 'testimonial_counter', Docs.find(match)
        return undefined

    Meteor.publish 'testimonial_facets', (
        picked_tags
        testimonial_query
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query

        self = @
        match = {}
        match.model = 'testimonial'
            # match.$regex:"#{testimonial_query}", $options: 'i'}
        # if testimonial_query and testimonial_query.length > 1
        #     console.log 'searching testimonial_query', testimonial_query
        #     match.title = {$regex:"#{testimonial_query}", $options: 'i'}
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
            # { $match: _id: {$regex:"#{testimonial_query}", $options: 'i'} }
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
                model:'testimonial_tag'
                # category:key
                # index: i


        self.ready()





if Meteor.isClient
    Template.testimonial_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.testimonial_card.events
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

    Template.testimonial_card.helpers
        testimonial_card_class: ->
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
            