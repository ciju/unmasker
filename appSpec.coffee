describe "Rectangle.IsColliding", ->
    it "should return true if rectangles are colliding", ->
        r1 = new Rectangle 10, 10, 15, 15
        r2 = new Rectangle 10, 10, 6, 6
        s = new SelectionRect 15, 15, 5, 5
        expect( r1.IsColliding s ).toBe true
        expect( r2.IsColliding s ).toBe true

    it "should return false if rectangle is not colliding", ->
        r1 = new Rectangle 0, 0, 5, 5
        r2 = new Rectangle 15, 15, 5, 5
        r3 = new Rectangle 15, 5, 5, 5
        r4 = new Rectangle 5, 5, 5, 10
        r5 = new Rectangle 10, 5, 5, 5
        s = new SelectionRect 10, 10, 5, 5

        expect( r1.IsColliding s ).toBe false
        expect( r2.IsColliding s ).toBe false
        expect( r3.IsColliding s ).toBe false
        expect( r4.IsColliding s ).toBe false
        expect( r5.IsColliding s ).toBe false
    

        
describe "Rectangle.intersectingRect", ->
    it "should give the intersection between the rectangle and selection area", ->
        r1 = new Rectangle 10, 10, 15, 15
        r2 = new Rectangle 10, 10, 6, 6
        r3 = new Rectangle 19, 15, 5, 5
        s = new SelectionRect 15, 15, 5, 5
        expect(r1.intersectingRect s).toEqual [15, 15, 5, 5]
        expect(r2.intersectingRect s).toEqual [15, 15, 1, 1]
        expect(r3.intersectingRect s).toEqual [19, 15, 1, 5]

    it "should normalize if selection rect has -ve width/height"
        r1 = new Rectangle 10, 10, 15, 15
        r2 = new Rectangle 10, 10, 6, 6
        r3 = new Rectangle 19, 15, 5, 5
        s = new SelectionRect 20, 20, -5, -5
        expect(r1.intersectingRect s).toEqual [15, 15, 5, 5]
        expect(r2.intersectingRect s).toEqual [15, 15, 1, 1]
        expect(r3.intersectingRect s).toEqual [19, 15, 1, 5]


