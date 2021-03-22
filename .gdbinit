target remote localhost:1234
break *0x7c00
def ni
	nexti
	info reg $eax $ebx $ecx $edx $esi $edi $ebp $pc
	x/i $pc
	end
def si
	stepi
	info reg $eax $ebx $ecx $edx $esi $edi $ebp $pc
	x/i $pc
	end
continue
