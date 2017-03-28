import { getOwner } from 'discourse-common/lib/get-owner';

export default Ember.Component.extend({
  router: function() {
    return getOwner(this).lookup('router:main');
  }.property(),

  active: function() {
    const id = this.get('theme.id');
    return this.get('router.url').indexOf(`/customize/themes/${id}/css`) !== -1;
  }.property('router.url', 'theme.id')
});
