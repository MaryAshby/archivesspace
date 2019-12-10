module PluginHelper
  def sidebar_plugins_for(record)
    result = ''
    jsonmodel_type = record['jsonmodel_type']
    Plugins.plugins_for(jsonmodel_type).each do |plugin|
      name = Plugins.parent_for(plugin, jsonmodel_type)['name']
      next unless !(controller.action_name === 'show') || !Array(record.send(name)).empty?

      result << '<li>'
      result << "<a href='##{jsonmodel_type}_#{name}_'>"
      result << I18n.t("plugins.#{plugin}._plural")
      result << '<span class="glyphicon glyphicon-chevron-right"></span></a></li>'
    end
    result.html_safe
  end

  def show_plugins_for(record, context)
    result = ''
    jsonmodel_type = record['jsonmodel_type']
    Plugins.plugins_for(jsonmodel_type).each do |plugin|
      name = Plugins.parent_for(plugin, jsonmodel_type)['name']
      next if Array(record.send(name)).empty?

      result << render_aspace_partial(partial: "#{name}/show",
                                      locals: { name.intern => record.send(name),
                                                :context => context, :section_id => "#{jsonmodel_type}_#{name}_" })
    end
    result.html_safe
  end

  def form_plugins_for(jsonmodel_type, context)
    result = ''
    Plugins.plugins_for(jsonmodel_type).each do |plugin|
      parent = Plugins.parent_for(plugin, jsonmodel_type)

      result << render_aspace_partial(partial: 'shared/subrecord_form',
                                      locals: { form: context, name: parent['name'],
                                                cardinality: parent['cardinality'].intern, plugin: true })
    end
    result.html_safe
  end
end
