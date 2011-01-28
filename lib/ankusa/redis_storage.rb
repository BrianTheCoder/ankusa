require 'redis'

module Ankusa
  class RedisStorage
    attr_accessor :redis
    
    def initialize(connection)
      case connection
      when String, Hash then
        self.redis = Redis.new(connection)
      when Redis, Redis::Client then
        self.redis = connection
      end
    end

    def classnames
      redis.hkeys :doc_counts
    end

    def reset
      redis.flushdb
    end
    
    def close
      redis.shutdown
    end

    def init_tables; end

    # TODO store words in redis sets for each klass and just do an scard for each class
    def get_vocabulary_sizes
      redis.smembers(:classes).inject(Hash.new(0)) do |hsh, klass|
        hsh.merge(klass => redis.hlen(:"#{klass}:words"))
      end
    end

    def get_word_counts(word)
      classes = redis.smembers(:classes)
      counts = classes.inject({}){|hsh, klass| hsh.merge(klass => redis.hget(:"#{klass}:words", word))}
      counts.each{|klass, count| counts[klass] = count.to_i }
    end

    def get_total_word_count(klass)
      redis.hget(:word_counts, klass).to_i
    end
    
    def get_doc_count(klass)
      redis.hget(:doc_counts, klass).to_i
    end

    def incr_word_count(klass, word, count)
      redis.sadd :words, word
      redis.sadd :classes, klass
      redis.hincrby :"#{klass}:words", word, count
    end

    def incr_total_word_count(klass, count)
      redis.hincrby :word_counts, klass, count
    end

    def incr_doc_count(klass, count)
      redis.hincrby :doc_counts, klass, count
    end

    def doc_count_totals
      counts = redis.hgetall(:doc_counts)
      counts.each{|klass, count| counts[klass] = count.to_i }
    end
  end
  
  module RedisStoragePipelined    
    def train(klass, text)
      @storage.redis.pipelined do
        super(klass, text)
      end
    end
    
    def untrain(klass, text)
      @storage.redis.pipelined do
        super(klass, text)
      end
    end
  end
  
  KLDivergenceClassifier.send(:include, RedisStoragePipelined)
  NaiveBayesClassifier.send(:include, RedisStoragePipelined)
end