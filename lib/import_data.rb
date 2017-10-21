require "import_data/railtie" if defined?(Rails)

module ImportData
  extend ActiveSupport::Concern

  class_methods do
    def import_data csv_path, number_of_rows: 20, validation: true
      results = {success: [], error: []}
      serialized_columns = self.serialized_attributes

      index = 0
      records = []

      ActiveRecord::Base.transaction do
        CSV.foreach(file_path, headers: true) do |row|
          begin
            data = get_data_from_row_to_hash row, serialized_columns
            id = data.delete "id"

            record = self.new data
            # action = record.new_record? ? :create : :update
            # continue action update on ver2
            index += 1
            records << record
            next if index < number_of_rows
          rescue ActiveRecord::RecordNotUnique => e
            error = e.message.to_s
            report_error(action, error, index)
            next
          end
        end

        importer = self.import records, validate: validation
      end

      results
    end

    private
    def get_data_from_row_to_hash row, serialized_columns
      row_hash = row.to_h
      serialized_columns.each do |key, _serialize_obj|
        row_hash[key] = JSON.parse(row_hash[key])
      end
      row_hash
    end

    def report_error action, error, index
      message = "#{Time.now}: #{action} id_#{index} #{error}"
      results[:error] << message
    end

    def report_success action, index
      message = "#{Time.now}: #{action} id_#{index} successfully"
      results[:success] << message
    end
  end
end
