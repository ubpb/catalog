LOCATION_LOOKUP_TABLE = YAML.load_file(
  File.join(Rails.root, "config", "location_lookup_table.yml"),
  permitted_classes: [Symbol, Range]
)
