export default Ember.Route.extend({

  serialize(model) {
    return {theme_id: model.get('id')};
  },

  model(params) {
    const all = this.modelFor('adminCustomizeThemes');
    const model = all.findBy('id', parseInt(params.theme_id));
    return model ?  model : this.replaceWith('adminCustomizeTheme.index');
  },

  setupController(controller, model) {
    controller.set("model", model);
    this.controllerFor("adminCustomizeThemes").set("editingTheme", false);
  }
});
