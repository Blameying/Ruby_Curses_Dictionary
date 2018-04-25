require 'curses'
require 'io/console'

dic = {}
weight={}
searchbuffer = []
#打开文件
File.open("dic.txt","r") do |file| 
	while not file.eof
		item = file.readline.force_encoding("utf-8").split("   ")
		if(item[0] and item[1])
	 		dic[item[0]] = item[1]
			if(item[2]) then  weight[item[0]]=item[2].to_i else weight[item[0]]=10 end 
			searchbuffer<<item[0]
		end
	end 
end 



Curses.noecho

Curses.init_screen
Curses.start_color

Curses.init_pair(1,Curses::COLOR_GREEN,Curses::COLOR_RED)
Curses.init_pair(2,Curses::COLOR_GREEN,Curses::COLOR_RED)
Curses.init_pair(3,Curses::COLOR_GREEN,Curses::COLOR_RED)
Curses.init_pair(4,Curses::COLOR_RED,Curses::COLOR_YELLOW)
main_window = Curses::Window.new(10,20,0, 0)
main_window.keypad = true

def drawplant(main_window)
	main_window.attron(Curses.color_pair(1)) do 
		Curses.lines.times do |line|
			main_window.setpos(line,0)
			main_window<<' '*Curses.cols
		end 
	end 
	
	main_window.attron(Curses.color_pair(2)) do 
		main_window.setpos(2,0)
		main_window<<'='*20
	end 
	
	main_window.setpos(1,0)
	main_window.refresh
	
end

def search(str,list,weight)
	temp = []
	for item in list 
		if item.include?str.downcase then
			temp<<item 
		end 
	end
	#核心排序计算
	temp.sort_by! {|word| word.index(str.downcase)+weight[word]}
	temp[0,5]
end

str=""
list = []
flag = 100
drawplant main_window 
loop do 
	#按键输入检测
	ch=main_window.getch
	if ch == 27
		break
	else 
		if ch==127 
			str=str.chop
		elsif ch==259
			if flag==100 then 
				flag=list.size-1
			else 
				flag=(flag-1)%list.size
			end 
		elsif ch==258
			if flag==100 then 
				flag=0
			else 
				flag=(flag+1)%list.size
			end 
		elsif ch==10
		   if flag==100 then 
		   		flag=0
		   end 
   		else 
 			flag=100
			str<<ch 
		end 			

		drawplant main_window 
		main_window.attron(Curses.color_pair(3)|Curses::A_BOLD) do 
			main_window.setpos(1,0)
			main_window<<str 
		    main_window.refresh
	   		if(ch==10)
				if flag==100 and list[0]
					main_window.attron(Curses.color_pair(4)) do 
						main_window.setpos(4,0)
						print "\n\n\r",dic[list[0]]
						#更改权重
						if weight[list[0]]!=0 then weight[list[0]]-=1 end 
						main_window.refresh
						main_window.setpos(1,0)
						main_window<<list[0]
					end 
				elsif list[flag] 
					main_window.attron(Curses.color_pair(4)) do 
						main_window.setpos(4,0)
						print "\n\n\r",dic[list[flag]]
						#更改权重
						if weight[list[0]]!=0 then weight[list[flag]]-=1 end 
						main_window.refresh
						main_window.setpos(1,0)
						main_window<<list[flag]
					end
				else 
				end 
			else 
				list = search(str,searchbuffer,weight)
				list.each_index do |i|
					if(i==flag)
						main_window.attron(Curses.color_pair(4)) do 
						main_window.setpos(3+i,0)
						main_window<<list[flag]
						end
					else 
						main_window.setpos(3+i,0)
						main_window<<list[i]
					end 	
				end 
 				main_window.setpos(1,0)
				main_window<<str 
			end 
		end 
	end 
	main_window.refresh 
end 

#写回文件
File.open("dic.txt","w") do |file|
	dic.each_pair do |key,value|
		file.puts "%s   %s   %d"%[key,value.chop,weight[key]] 
	end 
end 

main_window.close
Curses.close_screen
