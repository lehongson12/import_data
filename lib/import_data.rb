require "import_data/railtie" if defined?(Rails)
require 'csv'

module ImportData
  extend ActiveSupport::Concern

  class_methods do
    def import_data csv_path, number_of_rows: 20, validation: true
      results = {success: [], error: []}
      # serialized_columns = self.serialized_attributes

      index = 0
      records = []

      ActiveRecord::Base.transaction do
        CSV.foreach(csv_path, headers: true) do |row|
          begin
            record = self.new row.to_hash
            # record.attributes = row.to_hash
            # action = record.new_record? ? :create : :update
            # continue action update on ver2
            records << record
            next if records.size < number_of_rows
            self.import records, validate: validation
            records.clear
          rescue ActiveRecord::RecordNotUnique => e
            error = e.message.to_s
            report_error(action, error, index)
            next
          end
        end
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
