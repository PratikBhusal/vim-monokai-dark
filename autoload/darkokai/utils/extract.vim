function! s:map_highlight_group(key, val)
    if a:val[1][0] ==# 'cleared'
        return {a:val[0] : {}}
    endif

    let l:colors = {}

    " If the highlight group has any links to it, preprocess it
    if len(a:val[1]) == 2 && a:val[1][1][:3] ==# ' to '
        let colors['links'] = split(a:val[1][1])[-1]
    endif

    " If group is not strictly a link, preprocess highlight info
    if a:val[1][0] !=# 'links'
        let l:F_extract_colors = {colors -> map(
            \ map(
                \ colors,
                \ "split(v:val, '=')"
            \ ),
            \ '{v:val[0]: v:val[1]}'
        \ )}

        call map(
            \ l:F_extract_colors(
                \ split( split(split(a:val[1][0], '\slinks')[0], 'font')[0] )
            \ ),
            \ 'extend(l:colors, v:val)'
        \ )
    endif

    return {a:val[0] : l:colors}
endf

function! s:get_highlights() abort
    let l:highlights = substitute(execute('highlight'), '\n\s\+', ' ', 'g')
    let l:highlights = split(l:highlights, '\n')
    call map(l:highlights, "split(v:val, '\\s\\+xxx\\s\\+')")
    call map(l:highlights, '[copy(v:val)[0], split(copy(v:val)[1], "links\\zs")]')
    call map(l:highlights, function('s:map_highlight_group'))

    let l:highlights_dict = {}
    for val in l:highlights
        call extend(l:highlights_dict, val)
    endfor

    return l:highlights_dict
endfunction

let s:colorscheme_highlights = s:get_highlights()

function! darkokai#utils#extract#refresh_highlights()
    let s:colorscheme_highlights = s:get_highlights()

    if exists('g:darkokai#highlights#defined')
        let g:darkokai#highlights#undefined = keys(filter(
            \ copy(s:colorscheme_highlights),
            \ '!has_key(g:darkokai#highlights#defined, v:key)'
        \ ))
    endif
endfunction

function! darkokai#utils#extract#all_highlights()
    return s:colorscheme_highlights
endfunction
