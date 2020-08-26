=begin
I am doing this because of inability of neovim to save files as root
When I do w!! for a file owned by root  it doesnt prompt me for password
But vim does that
So whenever i try to open a file not owned by me itll open the right vim for me.
Hence I wont need to worry about opening root files with nvim and let this script decide
=end
filename = ARGV[0]
if(File.owned?(filename))
  exec("nvim #{filename}")
else
  exec("vim #{filename}")
end

