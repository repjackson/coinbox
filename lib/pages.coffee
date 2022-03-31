if Meteor.isClient
    Router.route '/faqs', (->
        @layout 'layout'
        @render 'faqs'
        ), name:'faqs'
    Router.route '/about', (->
        @layout 'layout'
        @render 'about'
        ), name:'about'
    Router.route '/charities', (->
        @layout 'layout'
        @render 'charities'
        ), name:'charities'
        
    Template.faqs.onCreated ->
