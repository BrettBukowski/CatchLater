class UserVideoTags

  def self.build(limit_to_user)
    Video.collection.map_reduce(map, reduce, out: 'results', query: {user_id: limit_to_user})
  end


  def self.map
    <<-MAP
    function() {
      if (!this.tags) return;
        
      this.tags.forEach(function(tag) {
        emit(tag, 1);
      });
    }
    MAP
  end
  
  def self.reduce
    <<-REDUCE
    function(prev, current) {
      var count = 0, index;
      for (index in current) {
        count += current[index];
      }
      return count;
    }
    REDUCE
  end
end