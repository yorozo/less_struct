require "spec_helper"

RSpec.describe LessStruct do
  it "passes simple check-ups" do
    expect( LessStruct.check ).to eq( true )
  end

  it "passes attributes read/write tests" do
    less_struct = LessStruct.new(a:1)

    expect( less_struct.a ).to eq( 1 )
    expect( less_struct[:a] ).to eq( 1 )
    expect( less_struct["a"] ).to eq( 1 )

    expect{
      less_struct.b
    }.to raise_error(NoMethodError)

    expect( less_struct[:b] ).to eq( nil )
    expect( less_struct["b"] ).to eq( nil )

    less_struct.b = 2
    expect( less_struct.b ).to eq( 2 )
  end

  it "passes marshal tests" do
    less_struct = LessStruct.new(a:1)

    dumped = Marshal.dump(less_struct)
    loaded = Marshal.load(dumped)

    expect( loaded ).to eq( less_struct )
  end

  it "passes attributes mass add/del tests" do
    less_struct = LessStruct.new(a:1)

    o = LessStruct.new(a:1, b:2)
    expect( o.to_h.keys ).to eq( ["a", "b"] )

    o.add(c: 1, d:2)
    expect( o.to_h.keys ).to eq( ["a", "b", "c", "d"] )

    o.del(:a, :d)
    expect( o.to_h.keys ).to eq( ["b", "c"] )
  end

  it "passes equality tests" do
    less_struct1 = LessStruct.new(a:1)
    less_struct2 = LessStruct.new(a:1, b:1)
    expect( less_struct1 == less_struct2 ).to eq( false )

    less_struct2.del(:b)
    expect( less_struct1 == less_struct2 ).to eq( true )
  end

  # it "has default config as follows" do
  #   expect( LessStruct.config.to_h ).to eq(
  #     {"to_h_with_string_key_y"=>true}
  #   )
  # end

  it "passes .to_h keys tests" do
    less_struct1 = LessStruct.new(a:1)
    expect( less_struct1.to_h ).to eq( {"a"=>1} )

    LessStruct.use_to_h_with_symbol_key_y = true
    less_struct2 = LessStruct.new(a:2)
    expect( less_struct2.to_h ).to eq( {:a=>2} )

    # LessStruct.config.to_h_with_string_key_y = false
    # expect( less_struct.to_h ).to eq( {:a=>1} )
    # LessStruct.config.to_h_with_string_key_y = true
  end

  # it "TEMP" do    
  #   expect( 
  #     LessStruct::Util::Hash.deep_stringify_keys({a:1})
  #   ).to eq( {"a"=>1} )

  #   {a:1}.deep_stringify_keys
  # end
end