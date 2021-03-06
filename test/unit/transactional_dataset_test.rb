require 'test_helper'

#This class does not use transactional fixtures thus allowing to
#test functions using transactions
class TransactionalDatasetTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false


  test "creating and approving dataset then destroying should not leave any remains in the database" do

    models ="AuthorPaperproposal Cart CartDataset Category Datacolumn Datafile Datagroup
              Dataset DatasetPaperproposal Freeformat ImportCategory Paperproposal
              PaperproposalVote Project Role Sheetcell User".split(" ")
    before = {}
    models.each do |model|
      before[model] = eval("#{model}.count")
    end


    datafile = Datafile.create(:file => File.new(File.join(fixture_path, 'test_files_for_uploads',
                                                           'z2_SiteB_PLOTS 1mGIS meta_kn_for  testing.xls')))
    datafile.save
    dataset = Dataset.create(:title => 'just4testing')
    dataset.upload_spreadsheet = datafile
    dataset.save
    book = Dataworkbook.new(dataset.upload_spreadsheet)
    book.import_data
    dataset.approve_predefined_columns(users(:users_003))
    dataset.destroy

    after = {}
    models.each do |model|
      after[model] = eval("#{model}.count")
    end

    before.each do |model, count|
      assert count == after[model], "For #{model} the numbers are: #{count} -> #{after[model]}"
    end

  end

  
end