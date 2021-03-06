module Railshoster
  
  # == Assumptions
  # * +@project_dir+ is defined.  
  module InitGemHelpers
    
    UNSUPPORTED_DATABASE_GEMS   = %w(pq sqlite sqlite2 sqlite3)
    SUPPORTED_DATABASE_GEMS     = %w(mysql mysql2)    
    
    protected
    
    def gemfilelock_filepath
      File.join(@project_dir, "Gemfile.lock")
    end
    
    #TODO Find a better place for this method
    def get_db_gem(path_to_gemfilelock = gemfilelock_filepath)
      gemfilelock = File.open(path_to_gemfilelock).read
      p = Bundler::LockfileParser.new(gemfilelock)
      
      found_supported_db_gems     = []
      found_unsupported_db_gems   = []
      
      p.dependencies.each do |dependency|
        found_supported_db_gems << dependency if SUPPORTED_DATABASE_GEMS.include?(dependency.name)
        found_unsupported_db_gems << dependency if UNSUPPORTED_DATABASE_GEMS.include?(dependency.name)
      end
      
      unless found_unsupported_db_gems.empty? then
        puts "Attention:\nYour Gemfile.lock tells me that you are using at least one unsupported database gem:\n\n"
        puts found_unsupported_db_gems.map {|g| "* #{g.name}"}.join("\n")
        puts "\n"
      end

      if found_supported_db_gems.size == 1 then
        puts "Everything is fine. You are using: #{found_supported_db_gems.first.name}"

      elsif found_supported_db_gems.size > 1 then
        puts "You are using more than one supported database gem. Hence I cannot uniquely identify the gem your app depends on. Please change your Gemfile and perform bundle update to update your Gemfile.lock file."  
        raise("Abortet. Ambigious database gem information.")
      else
        raise('Abortet. Please update your Gemfile to with "gem mysql" or "gem mysql2" and run "bundle update" to update your Gemfile.lock.')
      end
      found_supported_db_gems.first
    end
  end
end
