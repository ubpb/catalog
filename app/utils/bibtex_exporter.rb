class BibtexExporter

  def self.parse(record)
    if record.present?

      bibtex_representation = {}

      # mapping attributes one on one
      bibtex_representation["edition"]   = record.edition.presence
      bibtex_representation["title"]     = record.title.presence
      bibtex_representation["year"]      = record.year_of_publication.presence

      # mapping attributes from arrays
      bibtex_representation["note"]      = record.notes.presence&.join(", ")
      bibtex_representation["publisher"] = record.publication_notices.presence&.join(", ")
      bibtex_representation["keywords"]  = record.subjects.presence&.join(", ")

      # more complex mappings
      parse_author      record, bibtex_representation
      parse_identifiers record, bibtex_representation
      parse_series      record, bibtex_representation
      parse_type        record, bibtex_representation

      # move series attribute value to journal if type is article
      if bibtex_representation["bibtex_type"] == "article"
        bibtex_representation["journal"] = bibtex_representation.delete("series")
      end

      if bibtex_representation.present?
        BibTeX::Entry.new(bibtex_representation.sort.to_h.compact.symbolize_keys).to_s
      end
    end
  end

  private

  def self.parse_author(record, bibtex_representation)

    bibtex_representation["author"] =
      record.creators
      .presence
      &.map(&:name)
      &.join(" and ")
  end

  def self.parse_identifiers(record, bibtex_representation)

    # isbn
    bibtex_representation["isbn"] =
      record.additional_identifiers
      .select{ |i| i.type == :isbn }
      .presence
      &.map(&:value)
      &.join(", ")

    # issn
    bibtex_representation["issn"] =
      record.additional_identifiers
      .select{ |i| i.type == :issn }
      .presence
      &.map(&:value)
      &.join(", ")

    #doi
    doi =
      record.additional_identifiers
      .select{ |i| i.type == :doi }
      .presence
      &.first
      &.value

    if doi.present?
      bibtex_representation["doi"] = doi
      bibtex_representation["url"] = "https://dx.doi.org/#{doi}"
    end
  end

  def self.parse_series(record, bibtex_representation)

    bibtex_representation["series"] =
      record.is_part_of
      .presence
      &.map(&:label)
      &.join(", ")
  end

  def self.parse_type(record, bibtex_representation)

    bibtex_type = "misc"

    case record.resource_type
      when "article"      then bibtex_type = "article"
      when "monograph"    then bibtex_type = "book"
    end

    case record.content_type
      when "dissertation" then bibtex_type = "phdthesis"
    end

    bibtex_representation["bibtex_type"] = bibtex_type
  end

end
