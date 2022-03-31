if Meteor.isClient
    Router.route '/faqs', (->
        @layout 'layout'
        @render 'faqs'
        ), name:'faqs'
    Router.route '/about', (->
        @layout 'layout'
        @render 'about'
        ), name:'about'
    Router.route '/testimonials', (->
        @layout 'layout'
        @render 'testimonials'
        ), name:'testimonials'
        
    Template.faqs.onCreated ->
