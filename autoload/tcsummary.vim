
function! tcsummary#tcProcessRange(fline,lline) 
	" fline : first line
	" lline : last line
	let l:lines = getline(a:fline,a:lline)
	let l:dict = {}
	for l:l in l:lines
		" dict[label]time
		let l:i = match(l:l,'\s')
		if l:i <= 0
			continue
		endif
		if l:l[0] == "@" || l:l[0] == "!"
			let l:l = l:l[1:]
		endif
		let [l:m,l:label,l:content] = tcsummary#tcProcessLine(l:l)
		if !has_key(l:dict,l:label)
			let l:dict[l:label] = 0
		endif
		let l:dict[l:label] += l:m
	endfor
	call tcsummary#tcShow(l:dict,a:lline )
endfunction

function! tcsummary#timeToMin(time)
	let [l:hour,l:minutes] = split(a:time,":")
	let l:m = l:hour * 60 + l:minutes
	return l:m
endfunction

function! tcsummary#minToTime(min)
	let l:hour = a:min / 60
	let l:minutes = float2nr( fmod(a:min,60) )
	return l:hour . ":" . l:minutes
endfunction

function! tcsummary#timeDiff(time1,time2)
	let t1 = tcsummary#timeToMin(a:time1)
	let t2 = tcsummary#timeToMin(a:time2)
	return t2 - t1
endfunction

function! tcsummary#timeAdd(time1,time2)
	let t1 = tcsummary#timeToMin(a:time1)
	let t2 = tcsummary#timeToMin(a:time2)
	return t2 + t1
endfunction

function! tcsummary#timeRange(timerange)
	let [t1,t2] = split(a:timerange,"-")
	return tcsummary#timeDiff(t1,t2)
endfunction

function! tcsummary#tcProcessLine(line)
	let [ l:timeRange , l:label ; l:contents ] = split(a:line,'\s\+')
	let l:m = tcsummary#timeRange(l:timeRange)
	return [ l:m , l:label , join(l:contents," ") ]
endfunction

function! tcsummary#tcShow(dict,num)
	let l:t = [ "" , ".... SUMMARY ...." ]
	let l:total = 0
	for [l:k,l:v] in items(a:dict)
		let l:total += l:v
		call add(l:t,printf( "%-10s\t%d(%s)", l:k,l:v, tcsummary#minToTime(l:v) ))
	endfor
	call add(l:t,printf("TOTAL: %d" , l:total ) )
	call add(l:t,".................")
	call append(a:num,l:t)
endfunction

function! tcsummary#ceilingFiveMinutes(time)
	let l:time = a:time
	let l:time = ceil( l:time / ( 5.0 * 60 ) ) * 5 * 60
	return float2nr( l:time )
endfunction
