require 'logger'

require 'helper'
require 'gooddata/model'
require 'gooddata/command'

GoodData.logger = Logger.new(STDOUT)

class TestModel < Test::Unit::TestCase
  context "GoodData model tools" do
    # Initialize a GoodData connection using the credential
    # stored in ~/.gooddata
    setup do
      GoodData::Command::connect
    end

    should "generate identifiers star  ting with letters and without ugly characters" do
      assert_equal 'fact.blah', GoodData::Model::Fact.new({ 'name' => 'blah' }, 'ds').identifier
      assert_equal 'attr.blah', GoodData::Model::Attribute.new({ 'name' => '1_2_3 blah' }, 'ds').identifier
      assert_equal 'dim.blaz', GoodData::Model::AttributeFolder.new(' b*ĺ*á#ž$').identifier
    end

    should "create a simple model in a sandbox project" do
      project = GoodData::Project.create :title => "gooddata-ruby test #{Time.new.to_i}"
      GoodData.use project
      objects = GoodData::Model.add_dataset 'Mrkev', [
          { 'type' => 'CONNECTION_POINT', 'name' => 'cp', 'title' => 'CP', 'folder' => 'test' },
          { 'type' => 'ATTRIBUTE', 'name' => 'a1', 'title' => 'A1', 'folder' => 'test' },
          { 'type' => 'ATTRIBUTE', 'name' => 'a2', 'title' => 'A2', 'folder' => 'test' },
          { 'type' => 'FACT', 'name' => 'f1', 'title' => 'F1', 'folder' => 'test' },
          { 'type' => 'FACT', 'name' => 'f2', 'title' => 'F2', 'folder' => 'test' },
        ]

      uris = objects['uris']
      assert_equal "#{project.md['obj']}/1", uris[0]
      # fetch last object (temporary objects can be placed at the begining of the list)
      GoodData.get uris[uris.length - 1]
      project.delete
    end
  end
end
