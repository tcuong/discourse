import showModal from 'discourse/lib/show-modal';
import { popupAjaxError } from 'discourse/lib/ajax-error';

export default Ember.Route.extend({
  model() {
    return this.store.findAll('theme');
  },

  actions: {
    importModal() {
      showModal('upload-theme');
    },

    newTheme(obj) {
      obj = obj || {name: I18n.t("admin.customize.new_style")};
      const item = this.store.createRecord('site-customization');

      const all = this.modelFor('adminCustomizeCssHtml');
      const self = this;
      item.save(obj).then(function() {
        all.pushObject(item);
        self.transitionTo('adminCustomizeCssHtml.show', item.get('id'), 'css');
      }).catch(popupAjaxError);
    }
  }
});
