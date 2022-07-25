atom_feed(
  language: "de-DE",
  schema_date: "2015",
  url: rss_search_request_url(search_request: @search_request, format: :atom),
  root_url: rss_search_request_url(search_request: @search_request, format: :html)
) do |feed|
  feed.title "Suchergebnisse für #{@search_request.queries.map{|q| "#{q.name} = #{q.value}"}.join(", ")}"

  feed.author do
    feed.name "Universitätsbibliothek Paderborn"
  end

  if @search_result.present? && @search_result.hits.present?
    @search_result.hits.each do |hit|
      feed.entry(hit.record, url: record_url(hit.record.id, search_scope: current_search_scope)) do |entry|
        entry.title(hit.record.title.presence || "n.n.")

        add_info = []

        if (creators = hit.record.creators.map{|c| c.name}.join("; ")).present?
          add_info << "<div>#{creators}</div>"
        end

        if (edition = hit.record.edition).present?
          add_info << "<div>#{edition}</div>"
        end

        if (yop = hit.record.year_of_publication).present?
          add_info << "<div>#{yop}</div>"
        end

        entry.content(add_info.join, type: "html")
      end
    end
  end
end
