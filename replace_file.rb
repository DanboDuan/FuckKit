

Dir[File.join(Dir.pwd,"FuckKit","**","**")].select { |e|
  File.basename(e).include?("FK")
}.select { |e| 
 e.end_with?(".h") || e.end_with?(".m") 
}.each { |e|
  puts e
  if File.file?(e)
    text = File.read(e)
    text.gsub!("RSK", "FK")
    text.gsub!("NSLog", "FKLog")
    text.gsub!("rsk", "fk")
    File.open(e, "w") { |file| file.puts text }

    # rename = e.dup
    # rename["RSK"] = "FK"

    # File.delete(rename) if File.file?(rename)
    # File.rename(e, rename)
  end
}