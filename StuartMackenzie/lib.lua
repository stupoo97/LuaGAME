--function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

lib = {};

function lib.entity()
	-- creates a table with all the basic variables of an entity
	-- helps to enforce consistency over all entities
	
	local tbl = {
		x = 0,
		y = 0,
		w = 0,
		h = 0,
		-- might need more here at some point
	};
	
	return tbl;
end

function lib.dist(obj1, obj2)
	return ((obj2.x - obj1.x) ^ 2 + (obj2.y - obj1.y) ^ 2) ^ 0.5
end

function lib.getCenter(obj)

	local cX = obj.x + obj.w / 2;
	local cY = obj.y + obj.h / 2;
	
	return cX, cY;
	-- if you wanted to return as a table:
	-- return { x = cX, y = cY };
end

--[[function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end--]]

function lib.bounding(obj1, obj2)
	-- supply with 2 entities (with x, y, w, h)
	-- returns true if they're intersecting/colliding in any way
	return  obj1.x < obj2.x + obj2.w and
			obj2.x < obj1.x + obj1.w and
			obj1.y < obj2.y + obj2.h and
			obj2.y < obj1.y + obj1.h
end

function lib.circle(obj1, obj2)
	-- supply with 2 entities
	-- returns true if the sum of the radii is less than
	-- the distance between the two entities
	local sum = obj1.w + obj2.w;
	return sum < lib.dist(obj1, obj2);
end

function lib.iterateTable(tbl)
	for key, value in pairs(tbl) do
		print(key, value)
	end		
end







