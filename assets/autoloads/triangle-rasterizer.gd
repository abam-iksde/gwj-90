class_name TriangleRasterizer
extends Object


static func draw_triangle(
	image: Image,
	a: Vector2i,
	b: Vector2i,
	c: Vector2i,
	color: Color,
	left: bool,
	top: bool,
	pixel_predicate: Callable
) -> bool:
	var edges = [
		sort_edge([a, b]),
		sort_edge([b, c]),
		sort_edge([c, a])
	]
	var max_length := 0
	var long_edge := 0
	
	for i in len(edges):
		var edge = edges[i]
		var length = edge[1].y - edge[0].y
		if length > max_length:
			max_length = length
			long_edge = i
	
	var short_edge1 := (long_edge + 1) % 3
	var short_edge2 := (long_edge + 2) % 3
	
	return (
		draw_spans_between_edges(image, edges[long_edge], edges[short_edge1], color, left, top, pixel_predicate)
		and draw_spans_between_edges(image, edges[long_edge], edges[short_edge2], color, left, top, pixel_predicate)
	)


static func draw_spans_between_edges(image: Image, edge1, edge2, color: Color, left: bool, top: bool, pixel_predicate: Callable) -> bool:
	var e1ydiff := float(edge1[1].y - edge1[0].y)
	if e1ydiff == 0.0:
		e1ydiff = 1.0
		if top:
			edge1[0].y -= 1
		else:
			edge1[1].y += 1
	
	var e2ydiff := float(edge2[1].y - edge2[0].y)
	if e2ydiff == 0.0:
		e2ydiff = 1.0
		if top:
			edge2[0].y -= 1
		else:
			edge2[1].y += 1
	
	var e1xdiff := float(edge1[1].x - edge1[0].x)
	var e2xdiff := float(edge2[1].x - edge2[0].x)
	
	var factor1 := float(edge2[0].y - edge1[0].y) / e1ydiff
	var factor_step1 := 1.0 / e1ydiff
	var factor2 := 0.0
	var factor_step2 := 1.0 / e2ydiff
	
	var succeeded := true
	
	var y := edge2[0].y as int
	while y < edge2[1].y:
		if not draw_span(
				image,
				y,
				edge1[0].x + int(e1xdiff * factor1),
				edge2[0].x + int(e2xdiff * factor2),
				color,
				left,
				pixel_predicate
			):
				succeeded = false
		factor1 += factor_step1
		factor2 += factor_step2
		y += 1
	return succeeded


static func sort_edge(edge):
	if edge[0].y < edge[1].y:
		return edge
	return [edge[1], edge[0]]


static func draw_span(
	image: Image,
	y: int,
	x1: int,
	x2: int,
	color: Color,
	left: bool,
	pixel_predicate: Callable
) -> bool:
	if x1 > x2:
		var temp = x1
		x1 = x2
		x2 = temp
	var xdiff = x2 - x1
	if xdiff == 0:
		xdiff = 1
		if left:
			x1 -= 1
		else:
			x2 += 1
	var x := x1
	var succeeded := true
	while x < x2:
		if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
			if pixel_predicate.call(x, y):
				image.set_pixel(x, y, color)
			else:
				succeeded = false
		x += 1
	return succeeded
