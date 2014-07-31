require 'minitest/autorun'
require 'porter-stemmer'

class StemmerTest < MiniTest::Test

  include Porter

  def setup
    @input = File.read('test/input.txt')
    @expected_output = File.read('test/output.txt')
  end

  def test_stem

    input = @input.split(/\W+/)
    expected = @expected_output.split(/\W+/)
    input.each_index do |index|
      stemmed_word = input[index].stem
      expected_value = expected[index]
      assert_equal expected_value, stemmed_word, "#{stemmed_word} does not match the expected value: #{expected_value}"
    end
  end

  def test_stem_as_array
    assert_equal @expected_output.split(/\W+/), @input.stem_as_array, "Looks like some words were not stemmed as expected"
  end

end
