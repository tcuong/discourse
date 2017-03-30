import RestModel from 'discourse/models/rest';
import { default as computed } from 'ember-addons/ember-computed-decorators';

const Theme = RestModel.extend({

  @computed('theme_fields')
  themeFields(fields) {

    if (!fields) {
      this.set('theme_fields', []);
      return {};
    }

    let hash = {};
    if (fields) {
      fields.forEach(field=>{
        hash[field.target + " " + field.name] = field;
      });
    }
    return hash;
  },

  getField(target, name) {
    let themeFields = this.get("themeFields");
    let key = target + " " + name;
    let field = themeFields[key];
    return field ? field.value : "";
  },

  setField(target, name, value) {
    this.set("changed", true);

    let themeFields = this.get("themeFields");
    let key = target + " " + name;
    let field = themeFields[key];
    if (!field) {
      field = {name, target, value};
      this.theme_fields.push(field);
      themeFields[key] = field;
    } else {
      field.value = value;
    }
  },

  description: function() {
    return "" + this.name + (this.enabled ? ' (*)' : '');
  }.property('selected', 'name', 'enabled'),

  changed: false,

  saveChanges() {
    return this.save(
        this.getProperties("name", "theme_fields")
    ).then(() => this.set("changed", false));
  },

});

export default Theme;
