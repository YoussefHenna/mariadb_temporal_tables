
class DummyAuthorClass
  def initialize
    @id = 1
  end
end

RSpec.describe "Thread.current[:mariadb_temporal_tables_current_author]" do
  context "after system_versioning_set_author called" do
    it "should include author object" do
      author = DummyAuthorClass.new
      system_versioning_set_author(author)
      expect(Thread.current[:mariadb_temporal_tables_current_author]).to equal(author)
    end
  end

end