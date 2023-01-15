    #define RGBA_R( c ) ( CUInt( c ) Shr 16 And 255 )
    #define RGBA_G( c ) ( CUInt( c ) Shr  8 And 255 )
    #define RGBA_B( c ) ( CUInt( c )        And 255 )
    
    dim shared m_colors(159,199) as integer
    dim shared celle_colori(999,15) as integer
    dim shared celle_colori_norm(999,2) as integer
    dim shared colore_background as integer
    
    dim shared colors_detected(15) as integer
    
    dim shared colori(15) as integer
    colori(00) = RGB(  0,  0,  0) 
    colori(01) = RGB(255,255,255) 
    colori(02) = RGB(137, 64, 54) 
    colori(03) = RGB(122,191,199) 
    colori(04) = RGB(138, 70,174) 
    colori(05) = RGB(104,169, 65) 
    colori(06) = RGB( 62, 49,162) 
    colori(07) = RGB(208,220,113) 
    colori(08) = RGB(144, 95, 37) 
    colori(09) = RGB( 92, 71,  0) 
    colori(10) = RGB(187,119,109) 
    colori(11) = RGB( 85, 85, 85) 
    colori(12) = RGB(128,128,128) 
    colori(13) = RGB(172,234,136) 
    colori(14) = RGB(124,112,218) 
    colori(15) = RGB(171,171,171) 
    
    dim shared cell_xmax as integer
    dim shared cell_ymax as integer
    dim shared indice_cella as integer
    
    dim shared mem_hires(7999) as integer
    dim shared mem_screen(999) as integer
    dim shared mem_colors(999) as integer
    
    cell_xmax=3
    cell_ymax=7
    
    function determina_colore_background() as integer
        
        dim max_colors_detected as integer
        dim ciclo as integer
        dim col_background as integer
        
        max_colors_detected=0
        col_background=0
        
        for ciclo=0 to 15
            if colors_detected(ciclo)>max_colors_detected then
                max_colors_detected=colors_detected(ciclo)
                col_background=ciclo
            end if
        next
        
        return col_background
        
    end function
        
    function colorDistance(c1 as integer,c2 as integer) as single
	 
        dim cr as uinteger
        dim cg as uinteger
        dim cb as uinteger
        
		cr = RGBA_R(c1)-RGBA_R(c2)
		cg = RGBA_G(c1)-RGBA_G(c2)
		cb = RGBA_B(c1)-RGBA_B(c2)
		return sqr((cr*cr) + (cg*cg) + (cb*cb))
        
	end function
    
    function getClosestColorIndex(col as integer) as integer
   
        dim distance as single
        dim closestColorIndex as integer
        dim index as integer
        dim d as single
        
		distance = colorDistance(col, colori(0))
		closestColorIndex = 0

		for index = 1 to 15

            d = colorDistance(col, colori(index))
			if (d < distance) then
                distance=d
                closestColorIndex=index
            end if

		next

        colors_detected(closestColorIndex)=colors_detected(closestColorIndex)+1
		
        return closestColorIndex
	
    end function
    
    function converti(dato as string) as integer
        dim valore as integer
        dim i as integer
        dim el as string
        
        valore=0
        
        for i=8 to 1 step-1
            el=mid$(dato,i,1)
            if el="1" then 
                valore=valore+2^(i-1)
            end if
        next
        
        return valore
        
    end function
    
    private sub pre_elab
    
        dim x as integer
        dim y as integer
        dim c as integer
        
        for y=0 to 199
            for x=0 to 159
                
                c=Point(x,y)
                m_colors(x,y)=getClosestColorIndex(c)
                
            next x
        next y
        
        colore_background=determina_colore_background
    
    end sub
    
    private sub view_image()
    
    dim x as integer
    dim y as integer
    dim col as integer
        
    Screen 14, 32
    Cls
    
        for y=0 to 199
            for x=0 to 159
                col=colori((m_colors(x,y)))                
                pset(x,y),col
            next x
        next y
        
    end sub

    private sub calc_cellcolors
    
    dim y as integer
    dim x as integer
    dim xx as integer
    dim yy as integer

    indice_cella=0

    dim cl as integer
    
        for y=0 to 199 step 8
        
            for x=0 to 159 step 4
        
                for yy=y to y+cell_ymax
                    for xx=x to x+cell_xmax
                        celle_colori(indice_cella,m_colors(xx,yy))=celle_colori(indice_cella,m_colors(xx,yy))+1
                    next xx
                next yy
            
                celle_colori(indice_cella,colore_background)=0  'i punti con lo stesso colore dello sfondo
                                                                'non saranno MAI pixel colorati
                
                indice_cella=indice_cella+1
                
            next x
        next y
            
    end sub

    private function calc_max(idx_cella as integer) as integer
    
        dim mx as integer
        dim i as integer
        dim cl as integer
    
        mx=0
        cl=0
        
        for i=0 to 15
            if celle_colori(idx_cella,i)>mx then
                mx=celle_colori(idx_cella,i)
                cl=i
            end if
        next 
    
        celle_colori(idx_cella,cl)=0
        
        return cl
        
    end function

    private sub calc_cell_colors_normalized()
        
        dim i as integer
        
        dim a as integer
        dim b as integer
        dim c as integer
        
        for i=0 to 999 
            a=calc_max(i)
            b=calc_max(i)
            c=calc_max(i)
            
            
            celle_colori_norm(i,0)=a
            celle_colori_norm(i,1)=b
            celle_colori_norm(i,2)=c
        next i
    
    end sub
    
    private sub make_data
    
        dim i as integer
        dim j as integer
        
        dim y as integer
        dim x as integer
        dim yi as integer
        dim xi as integer
        dim xx as integer
        dim yy as integer
        
        dim pixels as string
        
        i=0 'indice della cella con le informazioni relative al colore del blocco 4x2
    
        for y=0 to 199 step 8
        
            for x=0 to 159 step 4
        
                for yy=y to y+cell_ymax
                    
                    pixels=""
                    
                    for xx=x to x+cell_xmax
                        
                        if m_colors(xx,yy)=celle_colori_norm(i,0) then
                            pixels="11" & pixels
                        elseif m_colors(xx,yy)=celle_colori_norm(i,1) then
                            pixels="10" & pixels
                        elseif m_colors(xx,yy)=celle_colori_norm(i,2) then
                            pixels="01" & pixels
                        else
                            
                            'Se il colore del pixel non è tra i 3 gestiti, 
                            'fisso arbitrariamente per il pixel quello più 
                            'diffuso nella cella. Altre strategie?
                            'Valutare...
                            
                            if (m_colors(xx,yy)<>celle_colori_norm(i,0)) _ 
                                and (m_colors(xx,yy)<>celle_colori_norm(i,1)) _
                                and (m_colors(xx,yy)<>celle_colori_norm(i,2)) _
                                and (m_colors(xx,yy)<>colore_background) then
                                pixels="11" & pixels
                            else
                                pixels="00" & pixels
                            end if
                            
                        end if
                        
                    next xx
                    
                    mem_hires(j)=converti(pixels)
                    j=j+1
                    
                next yy
            
                mem_screen(i)=celle_colori_norm(i,1)*16+celle_colori_norm(i,2)
                mem_colors(i)=celle_colori_norm(i,0)
                
                i=i+1
                
            next x
        next y
        
    end sub
    
    private sub write_data_old
        
        dim ciclo as integer
        
        Open "hires.dat" For Binary As #1
        
            put #1,1,chr(0)
            put #1,2,chr(32)
            
            for ciclo=0 to 7999
                Put #1, 3+ciclo, chr(mem_hires(ciclo))
            next
            
        Close #1
    
        Open "colors.dat" For Binary As #1
        
            put #1,1,chr(0)
            put #1,2,chr(216)
            
            for ciclo=0 to 999
                Put #1, 3+ciclo, chr(mem_colors(ciclo))
            next
            
        Close #1
        
        Open "screen.dat" For Binary As #1
        
            put #1,1,chr(0)
            put #1,2,chr(4)
            
            for ciclo=0 to 999
                Put #1, 3+ciclo, chr(mem_screen(ciclo))
            next
            
        Close #1
        
    end sub

    private sub write_data
        
        dim ciclo as integer
        dim idx as integer
        
        Open "image.kla" For Binary As #1
        
            put #1,1,chr(0)
            put #1,2,chr(96)    ' start address: $6000
            
            idx=3
        
            'write hires data...
            for ciclo=0 to 7999
                Put #1, idx, chr(mem_hires(ciclo))
                idx=idx+1
            next
            
            'write screen data...
            for ciclo=0 to 999
                Put #1, idx, chr(mem_screen(ciclo))
                idx=idx+1
            next
            
            'write colors data...
            for ciclo=0 to 999
                Put #1, idx, chr(mem_colors(ciclo))
                idx=idx+1
            next
            
            Put #1, idx, chr(colore_background)
            
        Close #1
    
    end sub

    '=================================================================
    '= MAIN PROGRAM
    '=
    '= By Marco Pistorio per "RetroMagazine"
    '= first version : 23/02/2019
    '= modified: 08/01/2023
    '=================================================================
    
    Screen 14, 32
    
    Cls
    
    Bload "immagine.bmp"
    
    dim ii as integer
    
    for ii=160 to 319
        line (ii,0)-(ii,199),RGB(0,0,0)
    next ii
    
    pre_elab
    view_image
    calc_cellcolors
    calc_cell_colors_normalized
    make_data
    write_data_old
    write_data
    
    sleep
    
    stop
