class Account::NotesController < Account::ApplicationController

  before_action { add_breadcrumb t("account.notes.breadcrumb"), account_watch_lists_path }
  before_action :set_note, only: [:update, :destroy]

  def index
    respond_to do |format|
      format.html {
        # For each note try to resolve a record for display.
        # This might fail, because records may be removed from the index
        # after it has been placed on the watch list. For this cases we mark
        # the record as :deleted
        arel = current_user.notes.order(updated_at: :desc).page(params[:page]).per(25)

        @page = arel.current_page
        @total_count = arel.total_count
        @per_page = arel.limit_value

        @resolved_entries = arel.map do |note|
          next unless available_search_scopes.include?(note.scope.to_sym)

          if record = SearchEngine[note.scope].get_record(note.record_id, on_campus: on_campus?)
            {note: note, record: record}
          else
            {note: note, record: :deleted}
          end
        end.compact
      }

      format.json {
        notes = current_user.notes.where(record_id: clean_record_ids)

        render json: notes, except: [:user_id, :record_id_migrated, :created_at, :updated_at]
      }
    end
  end

  def create
    @note = current_user.notes.new(permitted_params)
    if @note.save
      render json: @note, status: :created, except: [:user_id, :record_id_migrated, :created_at, :updated_at]
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(permitted_params)
      render json: @note, except: [:user_id, :record_id_migrated, :created_at, :updated_at]
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @note.destroy
      render json: {}
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def permitted_params
    params.require(:note).permit(
      :id, :record_id, :value, :scope
    )
  end

  def clean_record_ids
    (params[:record_ids] || "")
      .split(",")
      .map(&:strip)
      .map(&:presence)
      .compact
  end

end
