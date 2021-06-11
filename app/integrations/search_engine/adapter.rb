class SearchEngine::Adapter < BaseAdapter

  def searchables
    options["searchables"] || []
  end

  def searchables_names
    searchables.map{|s| s["name"].presence}.compact
  end

  def searchables_fields(name)
    field  = searchables.find{|s| s["name"] == name}.try(:[], "field").presence
    fields = searchables.find{|s| s["name"] == name}.try(:[], "fields").presence || []
    ([field] + fields).compact
  end

  def aggregations
    options["aggregations"] || []
  end

  def aggregations_names
    aggregations.map{|s| s["name"].presence}.compact
  end

  def aggregations_field(name)
    aggregations.find{|s| s["name"] == name}.try(:[], "field").presence
  end

  def aggregations_type(name)
    aggregations.find{|s| s["name"] == name}.try(:[], "type").presence
  end

end
