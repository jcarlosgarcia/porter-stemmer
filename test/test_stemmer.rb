require 'minitest/autorun'
require 'porter-stemmer'

class StemmerTest < MiniTest::Test

  extend Porter::Stemmer

  def test_that_step1_gets_rid_of_plurals_and_ed_or_ing
    testset = {
      'caresses'  =>  'caress',
      'ponies'    =>  'poni',
      'ties'      =>  'ti',
      'caress'    =>  'caress',
      'cats'      =>  'cat',
      'feed'      =>  'feed',
      'agreed'    =>  'agree',
      'disabled'  =>  'disable',
      'matting'   =>  'mat',
      'mating'    =>  'mate',
      'meeting'   =>  'meet',
      'milling'   =>  'mill',
      'messing'   =>  'mess',
      'meetings'  =>  'meet'
    }

    assert_word_was_stemmed testset, :step1
  end

  def test_that_double_suffices_are_mapped_to_single_ones
    testset = {
      'recreational' => 'recreate',
      'intentional'  => 'intention',
      'independenci' => 'independence',
      'consonanci'   => 'consonance',
      'temporizer'   => 'temporize',
      'notabli'      => 'notable',
      'normalli'     => 'normal',
      'providentli'  => 'provident',
      'pureli'       => 'pure',
      'continousli'  => 'continous',
      'immunization' => 'immunize',
      'termination'  => 'terminate',
      'conspirator'  => 'conspirate',
      'minimalism'   => 'minimal',
      'forgiveness'  => 'forgive',
      'helpfulness'  => 'helpful',
      'tediousness'  => 'tedious',
      'equaliti'     => 'equal',
      'activiti'     => 'active',
      'mutabiliti'   => 'mutable',
      'analogi'      => 'analog'
    }

    assert_word_was_stemmed testset, :step2
  end

  def test_that_step3_deals_with_suffices_like_ic_full_ness
    testset = {
      'certificate' => 'certific',
      'comparative' => 'compar',
      'pluralize' => 'plural',
      'simpliciti' => 'simplic',
      'numerical'  => 'numeric',
      'fruitful'   => 'fruit',
      'fruitfulness'  => 'fruitful'
    }

    assert_word_was_stemmed testset, :step3
  end

  def test_that_step4_takes_off_suffices_like_ant_ence
    testset = {
      'fundamental' => 'fundament',
      'governance'  => 'govern',
      'imminence'   => 'immin',
      'informer'    => 'inform',
      'realistic'   => 'realist',
      'lamentable'  => 'lament',
      'incredible'  => 'incred',
      'redundant'   => 'redund',
      'abatement'   => 'abat',
      'apartment'   => 'apart',
      'provident'   => 'provid',
      'catechism'   => 'catech',
      'alternate'   => 'altern',
      'simpliciti'  => 'simplic',
      'humongous'   => 'humong',
      'responsive'  => 'respons',
      'monetize'    => 'monet'
    }

    assert_word_was_stemmed testset, :step4
  end

  def test_that_step5_removes_final_e_if_consonant_sequences_greater_than_one
    testset = {
      'governance'  => 'governanc',
      'imminence'   => 'imminenc',
      'lamentable'  => 'lamentabl',
      'incredible'  => 'incredibl',
      'responsive'  => 'responsiv',
      'monetize'    => 'monetiz'
    }

    assert_word_was_stemmed testset, :step5
  end

  def assert_word_was_stemmed(testset, step_method)
    testset.each do |key, value|
      stemmed_word = StemmerTest.send(step_method, key.dup)
      assert_equal value, stemmed_word, "#{stemmed_word} does not match the expected value: #{value}"
    end
  end

  #def test_stemmer
  #  input = File.read('test/input.txt')
  #  expected = File.read('test/output.txt')

  #  assert_equal expected.split(/\W+/), input.stem, "Looks like some words were not stemmed as expected"
  #end

end
