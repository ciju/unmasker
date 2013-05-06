// Generated by CoffeeScript 1.6.2
(function() {
  var Dragging, GetId, Rects, Selections, log,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  log = function() {
    var args;

    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if ((typeof console !== "undefined" && console !== null ? console.log : void 0) != null) {
      return console.log.apply(console, args);
    }
  };

  Dragging = false;

  GetId = (function() {
    var id;

    id = 0;
    return function() {
      return id += 1;
    };
  })();

  Rects = [];

  window.RectGroups = (function() {
    function RectGroups() {
      this.rects = [];
    }

    RectGroups.prototype.Push = function(s) {
      if (!s) {
        return;
      }
      log('pushing ', s.div[0]);
      return this.rects.push(s);
    };

    RectGroups.prototype.ProcessColliding = function(s) {
      var i, _i, _len, _ref, _results;

      _ref = this.rects;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push((function(i) {
          if (i.IsColliding(s) && i.Masking) {
            log('is colliding', s != null ? s.id : void 0, s);
            return log(i.SplitWith(s));
          }
        })(i));
      }
      return _results;
    };

    return RectGroups;

  })();

  window.Rectangle = (function() {
    function Rectangle(x, y, w, h, Masking) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.Masking = Masking != null ? Masking : true;
      this.StopDragging = __bind(this.StopDragging, this);
      this.RemoveSplits = __bind(this.RemoveSplits, this);
      this.RemoveOrig = __bind(this.RemoveOrig, this);
      this.updateIntersections = __bind(this.updateIntersections, this);
      this.rectSplits = __bind(this.rectSplits, this);
      this.intersectionPoints = __bind(this.intersectionPoints, this);
      this.intersectingRect = __bind(this.intersectingRect, this);
      this.updateDiv = __bind(this.updateDiv, this);
      if (this.w === 0 || this.h === 0) {
        return null;
      }
      this.id = GetId();
      this.splits = {};
      this.div = $('<div class="mask">');
      this.updateDiv();
      $('body').append(this.div);
      this;
    }

    Rectangle.prototype.updateDiv = function() {
      this.div.css({
        top: this.y + 'px',
        left: this.x + 'px',
        width: this.w + 'px',
        height: this.h + 'px'
      });
      return this.div.attr('data-id', this.id);
    };

    Rectangle.prototype.IsColliding = function(s) {
      var h, w, x, y, _ref;

      _ref = s.NormalizedBoundary(), x = _ref.x, y = _ref.y, w = _ref.w, h = _ref.h;
      return !(this.x + this.w <= x || this.x >= x + w || this.y + this.h <= y || this.y >= y + h);
    };

    Rectangle.prototype.intersectingRect = function(s) {
      var h, rbx, rby, w, x, y, _ref;

      _ref = s.NormalizedBoundary(), x = _ref.x, y = _ref.y, w = _ref.w, h = _ref.h;
      rbx = x + w;
      rby = y + h;
      x = x < this.x ? this.x : x;
      y = y < this.y ? this.y : y;
      w = rbx > this.x + this.w ? this.x + this.w - x : rbx - x;
      h = rby > this.y + this.h ? this.y + this.h - y : rby - y;
      return [x, y, w, h];
    };

    Rectangle.prototype.intersectionPoints = function(x, y, w, h) {
      return {
        fcs: this.x,
        fcw: x - this.x,
        mcs: x,
        mcw: w,
        lcs: x + w,
        lcw: this.x + this.w - (x + w),
        frs: this.y,
        frh: y - this.y,
        mrs: y,
        mrh: h,
        lrs: y + h,
        lrh: this.y + this.h - (y + h)
      };
    };

    Rectangle.prototype.rectSplits = function(p) {
      return {
        nw: [p.fcs, p.frs, p.fcw, p.frh],
        w: [p.fcs, p.mrs, p.fcw, p.mrh],
        sw: [p.fcs, p.lrs, p.fcw, p.lrh],
        n: [p.mcs, p.frs, p.mcw, p.frh],
        s: [p.mcs, p.lrs, p.mcw, p.lrh],
        ne: [p.lcs, p.frs, p.lcw, p.frh],
        e: [p.lcs, p.mrs, p.lcw, p.mrh],
        se: [p.lcs, p.lrs, p.lcw, p.lrh]
      };
    };

    Rectangle.prototype.updateIntersections = function(s) {
      var d, h, newRect, ns, splits, updateRect, v, w, x, y, _ref, _results,
        _this = this;

      if (!this.IsColliding(s)) {
        this.RemoveSplits();
        return;
      }
      _ref = this.intersectingRect(s), x = _ref[0], y = _ref[1], w = _ref[2], h = _ref[3];
      ns = s.NormalizedBoundary();
      if (ns.x !== x || ns.y !== y || ns.w !== w || ns.h !== h) {
        Rects.ProcessColliding(s);
      }
      splits = this.rectSplits(this.intersectionPoints(x, y, w, h));
      newRect = function(xx, yy, ww, hh) {
        if (hh === 0 || ww === 0) {
          return null;
        }
        return new Rectangle(xx, yy, ww, hh);
      };
      updateRect = function(d, v) {
        if (!_this.splits[d]) {
          _this.splits[d] = newRect.apply(null, v);
        }
        if (!_this.splits[d]) {
          return;
        }
        _this.splits[d].x = v[0];
        _this.splits[d].y = v[1];
        _this.splits[d].w = v[2];
        _this.splits[d].h = v[3];
        return _this.splits[d].updateDiv();
      };
      _results = [];
      for (d in splits) {
        v = splits[d];
        _results.push(updateRect(d, v));
      }
      return _results;
    };

    Rectangle.prototype.SplitWith = function(s) {
      var d, h, newRect, splits, v, w, x, y, _ref, _ref1;

      if (!this.IsColliding(s)) {
        log('SplitWith: no collision');
        this.RemoveSplits();
        return;
      }
      if (!this.Masking) {
        log('div ', this, ' not visible');
        return;
      }
      _ref = this.intersectingRect(s), x = _ref[0], y = _ref[1], w = _ref[2], h = _ref[3];
      newRect = function(xx, yy, ww, hh) {
        if (x === xx && y === yy && w === ww && h === hh) {
          return null;
        }
        if (hh === 0 || ww === 0) {
          return null;
        }
        return new Rectangle(xx, yy, ww, hh);
      };
      this.RemoveOrig();
      log('splitting', this.id, this, '  with ', s);
      splits = this.rectSplits(this.intersectionPoints(x, y, w, h));
      log('SplitWith: ', s.div, x, y, w, h);
      for (d in splits) {
        v = splits[d];
        this.splits[d] = newRect.apply(null, v);
      }
      _ref1 = this.splits;
      for (d in _ref1) {
        v = _ref1[d];
        log(d, (v ? v.div[0] : void 0));
      }
      s.rects.push(this);
      return this;
    };

    Rectangle.prototype.RemoveOrig = function() {
      this.div.hide();
      return this.Masking = false;
    };

    Rectangle.prototype.RemoveSplits = function() {
      var d, v, _ref, _results;

      this.div.show();
      this.Masking = true;
      _ref = this.splits;
      _results = [];
      for (d in _ref) {
        v = _ref[d];
        if (v != null) {
          v.RemoveOrig();
        }
        if (v != null) {
          v.div.remove();
        }
        _results.push(v != null ? v.Masking = false : void 0);
      }
      return _results;
    };

    Rectangle.prototype.StopDragging = function() {
      var d, n, _ref, _results;

      log('stopping, and pushing all rects', this.splits);
      _ref = this.splits;
      _results = [];
      for (d in _ref) {
        n = _ref[d];
        if (n && n.w !== 0 && n.h !== 0) {
          _results.push(Rects.Push(n));
        } else {
          _results.push(n != null ? n.RemoveSplits() : void 0);
        }
      }
      return _results;
    };

    return Rectangle;

  })();

  Selections = [];

  window.SelectionRect = (function() {
    function SelectionRect(x, y, w, h) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.StopDragging = __bind(this.StopDragging, this);
      this.WhileDragging = __bind(this.WhileDragging, this);
      this.NormalizedBoundary = __bind(this.NormalizedBoundary, this);
      this.updateDiv = __bind(this.updateDiv, this);
      this.div = $('<div class="sel-rect">');
      this.rects = [];
      $('body').append(this.div);
      Selections.push(this);
      this.id = GetId();
      this.updateDiv();
      this;
    }

    SelectionRect.prototype.updateDiv = function() {
      var ns;

      ns = this.NormalizedBoundary();
      return this.div.css({
        top: ns.y + 'px',
        left: ns.x + 'px',
        width: ns.w + 'px',
        height: ns.h + 'px'
      });
    };

    SelectionRect.prototype.NormalizedBoundary = function() {
      var h, rbx, rby, w, x, y, _ref, _ref1, _ref2, _ref3;

      _ref = [this.x, this.y, this.w, this.h], x = _ref[0], y = _ref[1], w = _ref[2], h = _ref[3];
      _ref1 = [x + w, y + h], rbx = _ref1[0], rby = _ref1[1];
      if (rbx < x) {
        _ref2 = [rbx, x, -w], x = _ref2[0], rbx = _ref2[1], w = _ref2[2];
      }
      if (rby < y) {
        _ref3 = [rby, y, -h], y = _ref3[0], rby = _ref3[1], h = _ref3[2];
      }
      return {
        x: x,
        y: y,
        w: w,
        h: h
      };
    };

    SelectionRect.prototype.WhileDragging = function(e) {
      var r, _i, _len, _ref, _results;

      this.w = e.pageX - this.x;
      this.h = e.pageY - this.y;
      this.updateDiv();
      _ref = this.rects;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        r = _ref[_i];
        _results.push(r.updateIntersections(this));
      }
      return _results;
    };

    SelectionRect.prototype.StopDragging = function() {
      var r, _i, _len, _ref;

      _ref = this.rects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        r = _ref[_i];
        r.StopDragging();
      }
      log('selectionrect drag stop');
      return console.groupEnd();
    };

    SelectionRect.prototype.String = function() {
      return "{x: " + this.x + ", y: " + this.y + ", w: " + this.w + ", h: " + this.h + "}";
    };

    return SelectionRect;

  })();

  window.doStuff = function() {
    var $b, $d, Sels, h, j, s, sel, sels, w, _fn, _i, _len, _ref;

    _ref = [window.document.width, window.document.height], w = _ref[0], h = _ref[1];
    Rects = new window.RectGroups;
    s = new Rectangle(0, 0, w, h);
    $b = $('body');
    log('dostuff', s.div.attr('id', 'fullmask'));
    $b.append(s.div);
    Rects.Push(s);
    $d = $('body');
    Sels = [];
    sel = null;
    sels = [
      {
        x: 369,
        y: 45,
        w: 204,
        h: 78
      }, {
        x: 812,
        y: 203,
        w: -287,
        h: -110
      }, {
        x: 342,
        y: 197,
        w: 419,
        h: 80
      }
    ];
    _fn = function(j) {
      s = new SelectionRect(j.x, j.y, j.w, j.h);
      Rects.ProcessColliding(s);
      return s.StopDragging();
    };
    for (_i = 0, _len = sels.length; _i < _len; _i++) {
      j = sels[_i];
      _fn(j);
    }
    return $d.mousedown(function(e) {
      Dragging = true;
      console.group('drag');
      log('start dragging %O', Rects.rects);
      sel = new SelectionRect(e.pageX, e.pageY, 1, 1);
      Rects.ProcessColliding(sel);
      $d.mousemove(sel.WhileDragging);
      return $d.mouseup(function(e) {
        var i;

        log('stopping drag');
        sel.StopDragging();
        Dragging = false;
        $d.off('mousemove mouseup');
        return log(((function() {
          var _j, _len1, _results;

          _results = [];
          for (_j = 0, _len1 = Selections.length; _j < _len1; _j++) {
            i = Selections[_j];
            _results.push(i.String());
          }
          return _results;
        })()).join(','));
      });
    });
  };

}).call(this);
