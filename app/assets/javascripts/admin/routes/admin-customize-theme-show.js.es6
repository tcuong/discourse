export default Ember.Route.extend({
  model(params) {
    const all = this.modelFor('adminCustomizeTheme');
    const model = all.findBy('id', parseInt(params.theme_id));
    return model ? { model, section: params.section } : this.replaceWith('adminCustomizeTheme.index');
  },

  setupController(controller, hash) {
    controller.setProperties(hash);
  }
});
