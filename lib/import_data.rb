module ImportData
  class << self
    def import model, csv_path, number_of_rows: 20, validation: true
      init_results
      serialized_columns = model.serialized_attributes

      index = 0

      ActiveRecord::Base.transaction do
        CSV.foreach(file_path, headers: true) do |row|
          begin
            data = get_data_from_row_to_hash row, serialized_columns
            id = data.delete "id"

            record = model.find_or_initialize_by(id: id)
            action = record.new_record? ? :create : :update
            record.update data
            index += 1
            next if index < number_of_rows
            record.save! validate: validation
          rescue ActiveRecord::RecordNotUnique => e
            error = e.message.to_s
            report_error(action, error, index)
            next
          end
        end
      end

      init_results
    end

    private
    def get_data_from_row_to_hash row, serialized_columns
      row_hash = row.to_h
      serialized_columns.each do |key, _serialize_obj|
        row_hash[key] = JSON.parse(row_hash[key])
      end
      row_hash
    end

    def init_results
      @results = {success: [], :error: []}
    end

    def report_error action, error, index
      message = "#{Time.now}: #{action} id_#{index} #{error}"
      results[:error] << message
    end

    def report_success action, index
      message = "#{Time.now}: #{action} id_#{index} successfully"
      results[:success] << message
    end

    # default true
    # # true, false
    # def asynchronous?
    #   true
    # end
    #
    # # default "active_job"
    # # active_job, worker
    # def async_tool
    #
    # end

    # # default : 20
    # def number_of_rows_per_import_time
    #   100
    # end
  end
end
