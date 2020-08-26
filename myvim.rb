filename = ARGV[0]
puts filename
if(File.owned?(filename))
  exec("nvim #{filename}")
else
  exec("vim #{filename}")
end

