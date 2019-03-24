require "spec_helper"

RSpec.describe LessStruct::Entity::Redis do
  module TestRedis
  end

  class TestRedis::TestAutoId < LessStruct::Entity::Redis
  end

  class TestRedis::TestManualIdInteger < LessStruct::Entity::Redis
  end

  class TestRedis::TestManualIdString < LessStruct::Entity::Redis
  end

  class TestRedis::TestCrud < LessStruct::Entity::Redis
  end

  class TestRedis::TestKindByConfig < LessStruct::Entity::Redis
    def self.config_entity_kind
      "test.kind"
    end
  end

  # class TestRedis::TestJson < LessStruct::Entity::Redis
  #   # some data types such as Time cannot be restored if you use json format
  #   def self.config_redis_format_json_y
  #     true
  #   end
  # end

  before do
    # ENV["LESS_STRUCT_REDIS_URL"] = "redis://gc-ip-ane1-1:6379/15"
    redis_url = ENV["LESS_STRUCT_REDIS_URL"] || ENV["REDIS_URL"]
    Redis.current = Redis.new(url: redis_url)

    unless redis_url
      abort "[SETUP ERROR] set ENV[\"LESS_STRUCT_REDIS_URL\"] or ENV[\"REDIS_URL\"] for Redis before test"
    end

    begin
      Redis.current.get("k")
    rescue => e
      abort "[SETUP ERROR] cannot use Redis: #{e}"
    end

    unless Redis.current.keys.empty?
      abort "[SETUP ERROR] Redis test db is not empty! #{Redis.current.connection}"
    end
  end

  after do
    LessStruct::Entity::Redis.clear
    TestRedis::TestAutoId.clear
    TestRedis::TestManualIdInteger.clear
    TestRedis::TestManualIdString.clear
    TestRedis::TestKindByConfig.clear
    # TestRedis::TestJson.clear

    # Redis.current.flushdb
    # Redis.current.quit
  end

  it "passes simple check-ups" do
    expect( LessStruct::Entity::Redis.check ).to eq( true )
  end

  it "can be saved on Redis with auto set id" do
    saved_obj = TestRedis::TestAutoId.new.save
    expect( saved_obj.id.is_a?(String) ).to eq( true )
  end

  it "can be saved on Redis with manually set id" do
    integer_id = 1
    saved_obj = TestRedis::TestManualIdInteger.new(id: integer_id).save
    expect( saved_obj.id ).to eq( integer_id )

    string_id = "s1"
    saved_obj = TestRedis::TestManualIdString.new(id: string_id).save
    expect( saved_obj.id ).to eq( string_id )
  end

  it "can be found/updated/deleted" do
    saved_obj = TestRedis::TestCrud.new(name: "jo").save
    id = saved_obj.id
    name = saved_obj.name

    found_obj = TestRedis::TestCrud.find(id)

    expect( found_obj.id ).to eq( id )
    expect( found_obj.name ).to eq( saved_obj.name )

    found_obj.name = "jack"
    found_obj.save

    found_obj2 = TestRedis::TestCrud.find(id)
    expect( found_obj2.id ).to eq( id )
    expect( found_obj2.name ).to_not eq( name )

    found_obj2.delete

    found_obj3 = TestRedis::TestCrud.find(id)
    expect( found_obj3 ).to eq( nil )
  end

  it "set redis key kind manually" do
    TestRedis::TestKindByConfig

    expect(
      TestRedis::TestKindByConfig.kind
    ).to eq( "test.kind" )

    saved = TestRedis::TestKindByConfig.new(id: 100).save
    found = TestRedis::TestKindByConfig.find(saved.id)
  end

  # it "can use json as store format" do
  #   data = { name: "jo", age: 20, active_y: true}
  #   saved = TestRedis::TestJson.new(data).save
  #   found = TestRedis::TestJson.find(saved.id)
  #   expect( saved ).to eq( found )
  #   puts "found #{found}"
  # end
end
