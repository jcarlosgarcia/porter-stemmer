module Porter
  class Stemmer

    STEP_2_SUFFIX_MAPPING = {
      'ational' => 'ate',
      'tional'  => 'tion',
      'enci'    => 'ence',
      'anci'    => 'ance',
      'izer'    => 'ize',
      'bli'     => 'ble',
      'alli'    => 'al',
      'entli'   => 'ent',
      'eli'     => 'e',
      'ousli'   => 'ous',
      'ization' => 'ize',
      'ation'   => 'ate',
      'ator'    => 'ate',
      'alism'   => 'al',
      'iveness' => 'ive',
      'fulness' => 'ful',
      'ousness' => 'ous',
      'aliti'   => 'al',
      'iviti'   => 'ive',
      'biliti'  => 'ble',
      'logi'    => 'log'
    }

    STEP_2_SUFFIX_REGEXP = /(
      ational |
      tional |
      enci |
      anci |
      izer |
      bli |
      alli |
      entli |
      eli |
      ousli |
      ization |
      ation |
      ator |
      alism |
      iveness |
      fulness |
      ousness |
      aliti |
      iviti |
      biliti |
      logi)$/x

    STEP_3_SUFFIX_MAPPING = {
      'icate' => 'ic',
      'ative' => '',
      'alize' => 'al',
      'iciti' => 'ic',
      'ical'  => 'ic',
      'ful'   => '',
      'ness'  => ''
    }

    STEP_3_SUFFIX_REGEXP = /(icate|ative|alize|iciti|ical|ful|ness)$/

    STEP_4_SUFFIX_REGEXP = /(
      al |
      ance |
      ence |
      er |
      ic |
      able |
      ible |
      ant |
      ement |
      ment |
      ent |
      ou |
      ism |
      ate |
      iti |
      ous |
      ive |
      ize)$/x

    CONSONANT = "[^aeiou]" # consonant
    VOWEL = "[aeiouy]" # vowel
    CONSONANT_SEQUENCE = "#{CONSONANT}(?>[^aeiouy]*)" # consonant sequence
    VOWEL_SEQUENCE = "#{VOWEL}(?>[aeiou]*)" # vowel sequence

    # Number of consonant sequences
    MGR0 = /^(#{CONSONANT_SEQUENCE})?#{VOWEL_SEQUENCE}#{CONSONANT_SEQUENCE}/o # [cc]vvcc... is m>0
    MEQ1 = /^(#{CONSONANT_SEQUENCE})?#{VOWEL_SEQUENCE}#{CONSONANT_SEQUENCE}(#{VOWEL_SEQUENCE})?$/o # [cc]vvcc[vv] is m=1
    MGR1 = /^(#{CONSONANT_SEQUENCE})?#{VOWEL_SEQUENCE}#{CONSONANT_SEQUENCE}#{VOWEL_SEQUENCE}#{CONSONANT_SEQUENCE}/o # [cc]vvccvvcc... is m>1
    VOWEL_IN_STEM = /^(#{CONSONANT_SEQUENCE})?#{VOWEL}/o # vowel in stem

    def stem(word)
      return word if word.length < 3

      # Map initial y to Y so that the patterns never treat it as vowel
      word[0] = 'Y' if word[0] == 'y'

      word = step1(word)
      word = step2(word)
      word = step3(word)
      word = step4(word)
      word = step5(word)

      # Turn initial Y back to y
      word[0] = 'y' if word[0] == 'Y'

      return word
    end

    private

      # Gets rid of plurals and -ed or -ing. e.g.
      def step1(word)
        word = step1a(word)
        word = step1b(word)
        word = step1c(word)
      end

      def step1a(word)
        if word =~ /(ss|i)es$/ || word =~ /([^s])s$/
          word = $` + $1
        end

        return word

      end

      def step1b(word)
        if word =~ /eed$/
          word.chop! if $` =~ MGR0
        elsif word =~ /(ed|ing)$/
          stemmed_word = $`
          if stemmed_word =~ VOWEL_IN_STEM
            word = stemmed_word
            case word
              when /(at|bl|iz)$/, /^#{CONSONANT_SEQUENCE}#{VOWEL}[^aeiouwxy]$/o
                word << "e"
              when /([^aeiouylsz])\1$/
                word.chop!
            end
          end
        end

        return word

      end

      # Turns terminal y to i when there is another vowel in the stem
      def step1c(word)
        if word =~ /y$/
          stemmed_word = $`
          word = stemmed_word + "i" if stemmed_word =~ VOWEL_IN_STEM
        end

        return word
      end

      # Maps double suffices to single ones, so -ization (-ize plus -ation) maps to -ize
      def step2(word)
        map_suffices word, STEP_2_SUFFIX_REGEXP, STEP_2_SUFFIX_MAPPING
      end

      # Deals with -ic-, -full, -ness, etc.
      def step3(word)
        map_suffices word, STEP_3_SUFFIX_REGEXP, STEP_3_SUFFIX_MAPPING
      end

      def map_suffices(word, regexp, suffix_mapping)
        if word =~ regexp
          stemmed_word = $`
          suffix = $1
          if stemmed_word =~ MGR0
            word = stemmed_word + suffix_mapping[suffix]
          end
        end

        return word
      end

      # Takes off -ant, -ence etc., in context <c>vcvc<v>
      def step4(word)
        if word =~ STEP_4_SUFFIX_REGEXP
          stemmed_word = $`
        elsif word =~ /(s|t)(ion)$/
          stemmed_word = $` + $1
        end

        word = stemmed_word if defined?(stemmed_word) && stemmed_word =~ MGR1

        return word
      end

      # Removes a final -e if the number of consonant sequences is greater than 1
      def step5(word)
        if word =~ /e$/
          stemmed_word = $`
          if (stemmed_word =~ MGR1) ||
              (stemmed_word =~ MEQ1 && stemmed_word !~ /^#{CONSONANT_SEQUENCE}#{VOWEL}[^aeiouwxy]$/o)
            word = stemmed_word
          end
        end

        if word =~ /ll$/ && word =~ MGR1
          word.chop!
        end

        return word
      end

  end

  def stem_as_array
    stemmer = Stemmer.new
    stemmed_words = []
    words = self.split(/\W+/)

    words.each_index do |index|
      word = words[index]
      stemmed_words << stemmer.stem(word)
    end

    return stemmed_words
  end

  def stem
    Stemmer.new.stem self.dup
  end

end

class String
  include Porter
end
