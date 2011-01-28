require 'redis'

module Ankusa
  class RedisStorage
    def initialize(connection)
      case connection
      when String, Hash then
        self.redis = Redis.new(connection)
      when Redis::Client then
        self.redis = connection
      end
    end

    def classnames
      redis.hkeys :doc_counts
    end

    def reset
      redis.flushdb
    end

    def get_vocabulary_sizes
      count = Hash.new 0
      words = redis.smembers :words
      words.inject(Hash.new(0)) do |hsh, word|
        classes = redis.hkeys :"words:#{word}"
        classes.each{|klass| hsh[klass] += 1}
        hsh
      end
    end

    def get_word_counts(word)
      redis.hgetall :"words:#{word}"
    end

    def get_total_word_count(klass)
      redis.hget(:word_counts, klass).to_i
    end
    
    def get_doc_count(klass)
      redis.hget(:doc_counts, klass).to_i
    end

    def incr_word_count(klass, word, count)
      redis.sadd :words, word
      redis.hincrby :"words:#{word}", klass, count
    end

    def incr_total_word_count(klass, count)
      redis.hincrby :word_counts, klass, count
    end

    def incr_doc_count(klass, count)
      redis.hincrby :doc_counts, klass, count
    end

    def doc_count_totals
      redis.hgetall :doc_counts
    end
  end
  
  module RedisStoragePipelined
    def train(klass, text)
      @storage.redis.piplined do
        super(klass, text)
      end
    end
    
    def untrain(klass, text)
      @storage.redis.piplined do
        super(klass, text)
      end
    end
  end
  
  Classifier.send(:include, RedisStoragePipelined)
end

