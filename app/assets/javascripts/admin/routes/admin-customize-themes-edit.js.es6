export default Ember.Route.extend({
  model(params) {
    const all = this.modelFor('adminCustomizeThemes');
    const model = all.findBy('id', parseInt(params.theme_id));
    return model ? { model, target: params.target, field_name: params.field_name} : this.replaceWith('adminCustomizeTheme.index');
  },

  serialize(wrapper) {
    return {theme_id: Ember.get(wrapper,'model.id'), target: "common", field_name: "scss"};
  },


  setupController(controller, wrapper) {
    controller.set("model", wrapper.model);
    controller.setTargetName(wrapper.target);
    controller.set("fieldName", wrapper.field_name);
    this.controllerFor("adminCustomizeThemes").set("editingTheme", true);
  },

});
