if Meteor.isClient
    Router.route '/faqs', (->
        @layout 'layout'
        @render 'faqs'
        ), name:'faqs'
        
    Template.faqs.onCreated ->
