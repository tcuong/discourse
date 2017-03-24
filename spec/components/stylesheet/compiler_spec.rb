require 'rails_helper'
require 'stylesheet/compiler'

describe Stylesheet::Compiler do
  it "can compile desktop mobile and desktop css" do
    css,_map = Stylesheet::Compiler.compile_asset("desktop")
    expect(css.length).to be > 1000

    css,_map = Stylesheet::Compiler.compile_asset("mobile")
    expect(css.length).to be > 1000
  end
end


