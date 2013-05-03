# have separate squares for drawing the mask and non-masking
# ones. non-masking knows the mask around it, which have to be
# resized, and calculates new masking squares, whenever new collisions
# happen.

# TODO: a way to regenerate the rectangle collections and masking
# status.

# TODO: API?

log = (args...) ->
    console.log(args...) if console?.log?

# Global variable which is set to true, if mouse is being dragged.
Dragging = false

# Generates a global unique id, each time its called.
GetId = do ->
    id = 0
    -> id += 1

# Global Collection of rectangles
Rects = null

$ ->
    # initialize global collection, and the single main mask covering
    # the whole screen.
    Rects = new RectGroups
    doStuff()

# Group of rectangles, which can be checked for collision.
class RectGroups
    constructor: ->
        @rects = []

    # Whenever a new area appears on the screen, call Push to add it
    # to collection.
    Push: (s) ->
        return if not s
        log 'pushing ', s.div[0]
        @rects.push s

    # Checks which of the rectangles in the collection collide with
    # the rectangle `s` passed as parameter.
    ProcessColliding: (s) ->
        for i in @rects
            do (i) ->
                if i.IsColliding(s) and i.Masking
                    log 'is colliding', s?.id, s
                    log i.SplitWith s


class Rect
    # Masking is true if the rectangle is actually masking the screen.
    constructor: (@x, @y, @w, @h, @Masking=true) ->
        return null if @w == 0 or @h == 0

        @id = GetId()
        @splits = {}

        @div = $('<div class="mask">')
        @.updateDiv()
        $('body').append @div

        @

    updateDiv: =>
        @div.css(
            top: @y + 'px'
            left: @x + 'px'
            width: @w + 'px'
            height: @h + 'px'
        )
        @div.attr 'data-id', @id


    # Check if the Rectangle is colliding with normalized boundry of `s`
    IsColliding: (s) ->
        {x: x, y: y, w: w, h: h} = s.normalizedBoundary()

        not (
            @x + @w <= x  or
            @x >= x + w or
            @y + @h <= y  or
            @y >= y + h
        )

    intersectingRect: (s) =>
        {x: x, y: y, w: w, h: h} = s.normalizedBoundary()
        rbx = x + w
        rby = y + h

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
        if not @IsColliding(s)
            @RemoveSplits()
            return

        [x, y, w, h] = @.intersectingRect s


        # this probably needs the correct coordinates.
        # move the intersection logic to SelectionRect.
        # dont expose bare coordinates
        ns = s.normalizedBoundary()

        if ns.x != x or ns.y != y or ns.w != w or ns.h != h
            Rects.ProcessColliding s

        splits = @.rectSplits @.intersectionPoints x, y, w, h

        newRect = (xx, yy, ww, hh) ->
            return null if hh == 0 or ww == 0
            new Rect xx, yy, ww, hh

        updateRect = (d, v) =>
            @splits[d] = newRect(v...) if not @splits[d]
            return if not @splits[d]

            @splits[d].x = v[0]
            @splits[d].y = v[1]
            @splits[d].w = v[2]
            @splits[d].h = v[3]

            @splits[d].updateDiv()

        # log "- spilitting #{@id} to #{ (v?.id for _, v of @splits).join(',') }"

        updateRect(d, v) for d, v of splits


    SplitWith: (s) ->
        if not @.IsColliding s
            log 'SplitWith: no collision'
            @.RemoveSplits()
            return
        if not @Masking
            log 'div ', @, ' not visible'
            return

        [x, y, w, h] = @.intersectingRect s

        newRect = (xx, yy, ww, hh) ->
            return null if x == xx and y == yy and
                w == ww and h == hh
            return null if hh == 0 or ww == 0
            new Rect xx, yy, ww, hh

        @RemoveOrig()
        log 'splitting', @id, @, '  with ', s

        splits =  @.rectSplits @.intersectionPoints x, y, w, h

        log 'SplitWith: ', s.div, x, y, w, h

        @splits[d] = newRect(v...) for d, v of splits
        log(d, (v.div[0] if v)) for d, v of @splits

        s.rects.push @

        @

    RemoveOrig: =>
        @div.hide()
        @Masking = false

    RemoveSplits: =>
        @div.show()
        @Masking = true
        for d, v of @splits
            v?.RemoveOrig()
            v?.div.remove()
            v?.Masking = false

    StopDragging: (e) =>
        log 'stopping, and pushing all rects', @splits
        for d, n of @splits
            if n and n.w != 0 and n.h != 0
                Rects.Push(n)
            else
                n?.RemoveSplits()


# square associated with a div.
# change in square dimentions, changes the underlying div
# what happens on drag

class SelectionRect
    constructor: (@x, @y, @w, @h) ->
        @div = $('<div class="sel-rect">')
        @rects = []
        $('body').append @div
        @id = GetId()
        @
        log 'id - ', @id

    updateDiv: =>
        ns = @.normalizedBoundary()
        @div.css(
            top: ns.y+'px'
            left: ns.x + 'px'
            width: ns.w + 'px'
            height: ns.h + 'px'
        )

    # If the width/height of `s` is negative, normalize it. `x` and
    # `y` would be the coordinates of point closer to origin. And `w`
    # and `h` would be +ve.
    normalizedBoundary: =>
        [x, y, w, h] = [@x, @y, @w, @h]
        [rbx, rby] = [x+w, y+h]

        if rbx < x
            [x, rbx, w] = [rbx, x, -w]
        if  rby < y
            [y, rby, h] = [rby, y, -h]

        {x: x, y: y, w: w, h: h}


    WhileDragging: (e) =>
        @w = e.pageX - @x
        @h = e.pageY - @y

        @.updateDiv()
        r.updateIntersections(@) for r in @rects

    StopDragging: (e) =>
        r.StopDragging(e) for r in @rects

        log 'selectionrect drag stop'
        console.groupEnd()

doStuff = ->
    [w, h] = [window.document.width, window.document.height]

    s = new Rect 0, 0, w, h

    $b = $('body')

    log 'dostuff', s.div.attr('id', 'fullmask')

    $b.append s.div

    Rects.Push s

    $d = $('body')

    Sels = []

    sel = null

    $d.mousedown (e) ->
        Dragging = true

        console.group 'drag'
        log 'start dragging %O', Rects.rects

        sel = new SelectionRect e.pageX, e.pageY, 1, 1
        Rects.ProcessColliding sel
        $d.mousemove sel.WhileDragging
        $d.mouseup (e) ->
            log 'stopping drag'
            sel.StopDragging(e)
            Dragging = false
            $d.off 'mousemove'
            $d.off 'mouseup'
