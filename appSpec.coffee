describe "Rect.IsColliding", ->
    it "should return true if rectangles are colliding", ->
        r1 = new Rectangle 10, 10, 15, 15
        r2 = new Rectangle 10, 10, 16, 16
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
    

        
describe 
