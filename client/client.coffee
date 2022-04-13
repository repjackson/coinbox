@selected_rental_tags = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0
    #   'click .refresh_gps': ->
    #         navigator.geolocation.getCurrentPosition (position) =>
    #             console.log 'navigator position', position
    #             Session.set('current_lat', position.coords.latitude)
    #             Session.set('current_long', position.coords.longitude)
                
    #             console.log 'saving long', position.coords.longitude
    #             console.log 'saving lat', position.coords.latitude
            
    #             pos = Geolocation.currentLocation()
    #             Docs.update Router.current().params.doc_id, 
    #                 $set:
    #                     lat:position.coords.latitude
    #                     long:position.coords.longitude
 

Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me'
    # @autorun -> Meteor.subscribe 'users'
    # @autorun -> Meteor.subscribe 'users_by_role','staff'
    # @autorun -> Meteor.subscribe 'unread_messages'


$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.nav.events
    'click .add_rental': ->
        new_id = 
            Docs.insert 
                model:'rental'
        Router.go "/rental/#{new_id}/edit"
    # 'click .locate': ->
    #     navigator.geolocation.getCurrentPosition (position) =>
    #         console.log 'navigator position', position
    #         Session.set('current_lat', position.coords.latitude)
    #         Session.set('current_long', position.coords.longitude)

Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'scale'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_leftbar')
    , 2000
    Meteor.setTimeout ->
        $('.ui.rightbar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'scale'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 2000
    # Meteor.setTimeout ->
    #     $('.ui.topbar.sidebar')
    #         .sidebar({
    #             context: $('.bottom.segment')
    #             transition:'scale'
    #             mobileTransition:'scale'
    #             exclusive:true
    #             duration:200
    #             scrollLock:true
    #         })
    #         .sidebar('attach events', '.toggle_topbar')
    # , 2000
    # Meteor.setTimeout ->
    #     $('.ui.secnav.sidebar')
    #         .sidebar({
    #             context: $('.bottom.segment')
    #             transition:'scale'
    #             mobileTransition:'scale'
    #             exclusive:true
    #             duration:200
    #             scrollLock:true
    #         })
    #         .sidebar('attach events', '.toggle_leftbar')
    # , 2000
    # Meteor.setTimeout ->
    #     $('.ui.sidebar.cartbar')
    #         .sidebar({
    #             context: $('.bottom.segment')
    #             transition:'scale'
    #             mobileTransition:'scale'
    #             exclusive:true
    #             duration:200
    #             scrollLock:true
    #         })
    #         .sidebar('attach events', '.toggle_cartbar')
    # , 3000
    # Meteor.setTimeout ->
    #     $('.ui.sidebar.walletbar')
    #         .sidebar({
    #             context: $('.bottom.segment')
    #             transition:''
    #             mobileTransition:'scale'
    #             exclusive:true
    #             duration:200
    #             scrollLock:true
    #         })
    #         .sidebar('attach events', '.toggle_walletbar')
    # , 2000



Template.rightbar.events
    'click .logout': ->
        Session.set('logging_out', true)
        Meteor.logout ->
            Session.set('logging_out', false)
            
            
    
Template.rightbar.helpers
    
            
            
Template.home.events
    'click .sign_up': ->
        username = $('.username').val().trim()
        password = $('.password').val().trim()
        options = {
            username:username
            password:password
            }
        
        if username
            Meteor.call 'create_user', options, (err,res)=>
                if err
                    alert err
                else
                    console.log res
                    console.log username
                    Router.go "/user/#{username}"
            

Template.layout.events
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('slide up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fly left', 500)
    'click .fly_right': (e,t)->
        console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('fly right', 500)
        
    'click a': ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'
