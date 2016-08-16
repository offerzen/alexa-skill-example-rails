require "google_drive"

class GoogleDriveService

  # https://docs.google.com/spreadsheets/d/1HHkMUo97gVGhG9Rs_zOIGPG5DqB2P8dPVtVgEgsbu0s/edit#gid=0
  SHEED_ID = "1HHkMUo97gVGhG9Rs_zOIGPG5DqB2P8dPVtVgEgsbu0s"

  def initialize
    @session = GoogleDrive::Session.from_config("config.json")
    @spreadsheet = @session.spreadsheet_by_key(SHEED_ID).worksheets[0]
  end

  def write_sheet(value, row, column)
    @spreadsheet[row, column] = value
    @spreadsheet.save
    @spreadsheet.reload
  end

  def read_sheet(row, column)
    @spreadsheet[row, column]
  end

end
