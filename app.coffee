log = (args...) ->
    console.log(args...) if console?.log?

$ ->
    doStuff()

# have separate squares for drawing the mask and non-masking
# ones. non-masking knows the mask around it, which have to be
# resized, and calculates new masking squares, whenever new collisions
# happen.

translucentMask = (ctx, w, h) ->
    ctx.beginPath()
    ctx.rect 0, 0, w, h
    ctx.fillStyle = "rgba(0, 0, 0, 0.5)"
    ctx.fill()
    ctx

class SquareGroups
    constructor: ->
        @squares = []
    Push: (s) ->
        return if not s
        log 'pushing ', s.div[0]
        @squares.push s
    ProcessColliding: (s) ->
        for i in @squares
            do (i) ->
                if i.IsColliding(s) and i.Masking
                    log 'is colliding', s.div[0], s
                    r = i.SplitWith(s)
                    log r
                    log('j: ', j.div[0]) for j in r if j
                    
    
squares = new SquareGroups

Dragging = false            

class Square
    constructor: (@x, @y, @w, @h, @Masking=true) ->
        return null if @w == 0 or @h == 0

        @div = $('<div class="mask">')
        @splits = {}
        @.updateDiv()
        $('body').append @div

        @

    hookMouseMove: =>
        @div.mousemove @.WhileDragging

    updateDiv: =>
        @div.css(
            top: @y + 'px'
            left: @x + 'px'
            width: @w + 'px'
            height: @h + 'px'
        )
    

    Changing: ->
        [false, false, true, true]
            

    IsColliding: (s) ->
        not (
            @x + @w <= s.x  or
            @x >= s.x + s.w or
            @y + @h <= s.y  or
            @y >= s.y + s.h
        )

    intersectingRect: (s) =>
        [x, y, w, h] = [s.x, s.y, s.w, s.h]
        # get the inside square.
        [rbx, rby] = [x+w, y+h]
    
        x = if x < @x then @x else x
        y = if y < @y then @y else y
        w = if rbx > @x + @w then @x + @w - x else rbx - x
        h = if rby > @y + @h then @y + @h - y else rby - y

        [x, y, w, h]

    # f => first, m => middle, l => last, c => column, r => row, s =>
    # start, w => width, h => height
    intersectionPoints: (x, y, w, h) =>
        fcs: @x
        fcw: x - @x
        mcs: x
        mcw: w
        lcs: x + w
        lcw: @x + @w - (x + w)

        frs: @y
        frh: y - @y
        mrs: y
        mrh: h
        lrs: y + h
        lrh: @y + @h - (y + h)

    rectSplits: (p) =>
        {
            # first column
            nw: [p.fcs, p.frs, p.fcw, p.frh] 
            w: [p.fcs, p.mrs, p.fcw, p.mrh]
            sw: [p.fcs, p.lrs, p.fcw, p.lrh]

            # second column
            n: [p.mcs, p.frs, p.mcw, p.frh]
            # [p.mcs, p.mrs, p.mcw, p.mrh]
            s: [p.mcs, p.lrs, p.mcw, p.lrh]
            
            # third column
            ne: [p.lcs, p.frs, p.lcw, p.frh]
            e: [p.lcs, p.mrs, p.lcw, p.mrh]
            se: [p.lcs, p.lrs, p.lcw, p.lrh]
        }

    updateIntersections: (s) =>
        [x, y, w, h] = @.intersectingRect s

        if s.x != x or s.y != y or s.w != w or s.h != h
            log ' ----- collision '
            squares.ProcessColliding s
            # for sqr in colliding if not sqr == @
            #     log 'found colliding sqr which is not self'
            #     s.rects.push(sqr) 
                
        # log ' dragging selection square ', x, y, w, h

        splits = @.rectSplits @.intersectionPoints x, y, w, h

        updateSquare = (d, v) =>
            # log 'splits ', d, v
            return if not @splits[d]

            @splits[d].x = v[0]
            @splits[d].y = v[1]
            @splits[d].w = v[2]
            @splits[d].h = v[3]

            @splits[d].updateDiv()
    
        updateSquare(d, v) for d, v of splits
    

    SplitWith: (s) ->
        [x, y, w, h] = @.intersectingRect s

        log ' the selection square', x, y, w, h

        newSquare = (xx, yy, ww, hh) ->
            return null if x == xx and y == yy and
                w == ww and h == hh
            return null if hh == 0 or ww == 0
            new Square xx, yy, ww, hh

        @div.css 'display', 'none'
        log 'splitting', @, '  with ', s

        @Masking = false

        splits =  @.rectSplits(@.intersectionPoints(x, y, w, h))

        @splits[d] = newSquare(v...) for d, v of splits
        log(d, (v.div[0] if v)) for d, v of @splits

        s.rects.push @

        @

    Destroy: =>
        @div.remove()

    WhileDragging: (e) =>
        return if not Dragging

        if not @dragSquare
            @dragSquare = new SelectionRect e.pageX, e.pageY, 1, 1
            log 'started dragging', @dragSquare
            @.SplitWith @dragSquare
    
        @dragSquare.WhileDragging e
        @.updateIntersections @dragSquare

    StopDragging: (e) =>
        log 'stopping, and pushing all squares', @splits
        for d, n of @splits
            if n and n.w != 0 and n.h != 0
                squares.Push(n)
            else
                n?.Destroy()
            
        

# square associated with a div.
# change in square dimentions, changes the underlying div
# what happens on drag

class SelectionRect
    constructor: (@x, @y, @w, @h) ->
        @div = $('<div class="sel-rect">')
        @rects = []
        $('body').append @div
        @

    updateDiv: =>
        # log 'updating div', @x, @y, @w, @h
        @div.css(
            top: @y+'px'
            left: @x + 'px'
            width: @w + 'px'
            height: @h + 'px'
        )

    Changing: ->
        [false, false, true, true]

    WhileDragging: (e) =>
        @w = e.pageX - @x
        @h = e.pageY - @y

        # log 'drag', @x, @y, @w, @h
        r.updateIntersections(@) for r in @rects
        # @square.updateIntersections @
        @.updateDiv()

    StopDragging: (e) =>
        log 'selectionrect drag stop'
        r.StopDragging(e) for r in @rects

doStuff = ->
    [w, h] = [window.document.width, window.document.height]

    s = new Square 0, 0, w, h

    $b = $('body')

    log 'dostuff', s.div.attr('id', 'fullmask')

    $b.append s.div

    squares.Push s

    $d = $('body')

    Sels = []

    sel = null

    $d.mousedown (e) ->
        log 'start dragging %O', squares.squares
        Dragging = true
        sel = new SelectionRect e.pageX, e.pageY, 1, 1
        squares.ProcessColliding sel
        $d.mousemove sel.WhileDragging
        $d.mouseup (e) ->
            log 'stopping drag'
            sel.StopDragging(e)
            Dragging = false
            $d.off 'mousemove'
            $d.off 'mouseup'
