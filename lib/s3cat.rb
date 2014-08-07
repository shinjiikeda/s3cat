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
      obj.read do |chunk|
        STDOUT.write(chunk)
      end
    end
  end
  
  module_function :main
end

