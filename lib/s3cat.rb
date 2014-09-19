require "s3cat/version"

module S3cat
  require 'aws-sdk'
  require 'optparse'
    
  def main
    bucket_name = nil
    obj_prefix = nil
    access_key = nil
    secret_key = nil
    
    opt = OptionParser.new
    opt.on('--bucket bucketname') {|v| bucket_name = v }
    opt.on('--object_prefix prefix') {|v| obj_prefix = v }
    opt.on('--access_key key') {|v| access_key = v }
    opt.on('--secret_key key') {|v| secret_key = v }
    
    opt.parse!(ARGV)
    
    s3 = AWS::S3.new(
                     :access_key_id => access_key,
                     :secret_access_key => secret_key 
                     )
    
    bucket = s3.buckets[bucket_name]
    
    objs = obj_prefix ? bucket.objects.with_prefix(obj_prefix) : bucket.objects
    
    objs.each do | obj |
      #p obj
      obj_size = obj.content_length
      STDERR.puts "s3 obj: #{obj.key}"
      3.times.each do | n |
        tmpfile = Tempfile.open("s3cat-tmp")
        begin
          obj.read do |chunk|
            tmpfile.write(chunk)
          end
          if tmpfile.size != obj_size
            raise "file size error"
          end
          File.open(tmpfile.path, "r") do | io |
            while buf = io.read(65536)
              STDOUT.write(buf)
            end
          end
          break
        rescue => e
          STDERR.puts "retry."
          STDERR.puts e.to_s
          STDERR.puts e.backtrace
        ensure
          tmpfile.close!
        end
      end
    end
  end
  
  module_function :main
end

