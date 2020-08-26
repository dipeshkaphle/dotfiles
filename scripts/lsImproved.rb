require 'optparse'
require 'ostruct'

options=OpenStruct.new

#Parser for different flags
OptionParser.new do |opt|
	opt.on("-t","--type Type","files or dirs or all"){|x| options.type=x}
	opt.on("-d","--directory Directory","Target directory"){|x| options.dir=x }
	opt.on("-l","--list","Print in listed order"){|x| options.list=x}
	opt.on("-a","--all","Print all files including hidden")	{|x| options.all=x}
end.parse!




#Handling no dir condition
if(options.dir==nil)
	options.dir=`pwd`.chomp
end

#handling no type condition
if(options.type==nil)
	options.type="all"
end


#function to create flags for ls
def make_flag(options)
	flagString=" "
	if(options.list != nil)
		flagString+=" -l"
	end
	if(options.all != nil)
		flagString+= " -a"
	end
	return flagString
end



#Functions doing all the stuff
def foo(someFunc,options,flags)
	nameArr=[]
	##Getting the file names
	cmd="ls"
	if(options.all or options.list)
		cmd+=" -a"
	end
	`#{cmd}`.each_line {
		|fname|
		nameArr<<fname.chomp
	}
	##got the filename

	i=0
	`ls #{flags} \"#{options.dir}\"`.each_line {
		|x|
		x.chomp!
		if(x.split[0]=='total')
			next
		end
		fname=nameArr[i]
		i+=1
        y=File.directory?("#{options.dir}/#{fname}") == true ? 'directory' : 'file'
		if(someFunc.(y))
			if(options.list == nil)
				len=fname.split.length
				puts (len>1)? "\'"+fname+"\'" : x
			else
				puts x
			end
		end
	}
end



#main thing
if(options.type=="all")
	system("ls #{make_flag(options)} \'#{options.dir}\' ")
elsif(options.type=="files")
	foo(->(fileType){(fileType!='directory')? true : false },options,make_flag(options))
elsif(options.type=='dirs')
	foo(->(fileType){(fileType=='directory')? true : false },options,make_flag(options))
else
	puts 'Valid --types or -t are : '
	puts '1) files'
	puts '2) dirs'
	puts '3) all(default)'
	puts ''
	puts '-d \'directory/path\' to list from a particular directory'
	puts '-a for listing all including hidden files and folders'
	puts '-l for listed format. Same way as in "ls -l" '
	puts 'use --help or -h for help'
end
