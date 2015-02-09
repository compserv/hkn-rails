var OPACITY_DURATION = 500;
var DEFAULT_HEIGHT = 600;

var generateChart = function(info, loc) {
    var nodes = [];
    var prereqs = [];
    var classHash = {};
    var h = DEFAULT_HEIGHT;
    var w = loc.parent().width();
    var NODE_RADIUS = 25;
    var LEGEND_OFFSET = 6*NODE_RADIUS;
    loc = loc[0];

    var addClass = function(course) {
        name = course.name.toUpperCase();
        type = course.type.toLowerCase();
        if(course.bias_x === undefined || course.bias_x === null) {
            course.bias_x = 0;
        }
        if(course.bias_y === undefined || course.bias_y === null) {
            course.bias_y = 0;
        }
        if(course.link === undefined || course.link === null) {
            course.link = "http://hkn.eecs.berkeley.edu";
        }
        prereq = course.prereqs;
        if(prereq === undefined || prereq === null)
            prereq = [];
        if(typeof prereq == "string")
            prereq = [prereq];
        var upper = [];
        prereq.forEach(function(i) { upper.push(i.toUpperCase());});
        newclass = {
            "name": name,
            "type": type,
            radius: NODE_RADIUS,
            depth: course.depth,
            prereqs: upper,
            link: course.link,
            bias_x: course.bias_x,
            bias_y: course.bias_y
        };
        nodes.push(newclass);
        classHash[name] = newclass;
    };

    for(var i = 0; i < info.courses.length; i++) {
        addClass(info.courses[i]);
    }

    // generate link array
    nodes.forEach(function(node) {
        node.prereqs.forEach(function(prereq) {
            prereqs.push({source: classHash[prereq], target: node}); 
        });
    });
    // create svg object
    var svg = d3.select(loc)
    .append("svg")
    .attr("height",h)
    .attr("width",w);
    // create force
    var force = d3.layout.force()
    .nodes(nodes)
    .charge(-250)
    .linkDistance(function(link) {
        if(link.source.type == link.target.type) {
            return 50;
        } else {
            return 400;
        }
    })
    .size([w,h]);
    var legendMouseOver = function(d) {
        circle.style("stroke", function(course) {
            if(course.type == d.name) {
                return "black";
            }
        });
        circle.style("stroke-width", function(course) {
            if(course.type == d.name) {
                return 2;
            }
        });
    };

    // function that gets called when a node is moused over
    var classMouseOver = function(d) {
        var prereqs = [];
        var post = []; // classes that have d as a prereq
        var traverse = function(pre) {
            prereqs.push(pre.name); 
            pre.prereqs.forEach(function(p) {
                traverse(classHash[p]);
            });
        };
        traverse(d);
        nodes.forEach(function(node) {
            if(node.prereqs.indexOf(d.name) > -1) {
                post.push(node.name);
            }
        });

        edges.style("stroke-width", function(prereq) {
            if(prereqs.indexOf(prereq.target.name) > -1) {
                return 2;
            }
            return 1;
        });
        edges.style("stroke", function(prereq) {
            if(prereqs.indexOf(prereq.target.name) > -1 || (post.indexOf(prereq.target.name) > -1 && prereq.source.name == d.name)) {
                return "#000";
            }
            return "#ccc";
        });
        edges.transition().attr("opacity", function(prereq) {
            if(prereqs.indexOf(prereq.target.name) > -1 || (post.indexOf(prereq.target.name) > -1 && prereq.source.name == d.name)) {
                return 1;
            }
            return 0.2;
        }).duration(OPACITY_DURATION);
        edges.style("stroke-dasharray", function(prereq) {
            if(post.indexOf(prereq.target.name) > -1 && prereq.source.name == d.name) {
                return "5,5";
            }
        });

        circle.style("stroke", function(prereq) {
            if(prereqs.indexOf(prereq.name) > -1 || post.indexOf(prereq.name) > -1) {
                return "black";
            }
        });
        circle.style("stroke-width", function(prereq) {
            if(prereqs.indexOf(prereq.name) > -1 || post.indexOf(prereq.name) > -1) {
                return 2;
            }
        });
        circle.transition().attr("opacity", function(prereq) {
            if(prereqs.indexOf(prereq.name) > -1 || post.indexOf(prereq.name) > -1) {
                return 1;
            }
            return 0.2;
        }).duration(OPACITY_DURATION);

        texts.transition().attr("opacity", function(prereq) {
            if(prereqs.indexOf(prereq.name) > -1 || post.indexOf(prereq.name) > -1) {
                return 1;
            }
            return 0.2;
        }).duration(OPACITY_DURATION);
        arrowLegend.transition().attr("opacity", function(group) {
            return 1;
        }).duration(OPACITY_DURATION);
    };

    // function called when a course is moused off
    var classMouseOff = function(d) {
        edges.style("stroke-width", 1);
        edges.style("stroke", "#ccc");
        edges.transition().attr("opacity", 1).duration(OPACITY_DURATION);
        edges.style("stroke-width", null);
        edges.style("stroke-dasharray", null);
        texts.transition().attr("opacity", 1.0).duration(OPACITY_DURATION);
        circle.style("stroke", null);
        circle.style("stroke-width", null);
        circle.transition().attr("opacity", 1.0).duration(OPACITY_DURATION);
        arrowLegend.transition().attr("opacity", function(group) {
            return 0;
        });
    };

    // function called when node is clicked
    var classClick = function(d) {
        if (d3.event.defaultPrevented) return;
        window.open(d.link, '_blank');
    };

    // draw edges
    var edges = svg.selectAll("line")
    .data(prereqs)
    .enter()
    .append("line")
    .style("stroke", "#ccc")
    .style("stroke-width", 1)
    .attr("marker-end", "url(#end)");
    // draw arrows
    svg.append("svg:defs")
    .selectAll("marker")
    .data(["end"])
    .enter().append("svg:marker")
    .attr("id", String)
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", 0)
    .attr("refY", 0)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("markerUnits", "userSpaceOnUse")
    .attr("orient", "auto")
    .append("svg:path")
    .attr("d", "M0,-5L10,0L0,5");

    // draw nodes
    var nodeGroups = svg.selectAll("g.nodes")
    .data(nodes)
    .enter()
    .append("g")
    .attr("class", "nodes")
    .style("cursor", "pointer")
    .on("mouseover", classMouseOver)
    .on("mouseleave", classMouseOff)
    .on("click", classClick);
    var circle = nodeGroups
    .append("circle")
    .attr("r", NODE_RADIUS)
    .attr("class", "course")
    .attr("opacity", 1.0)
    .attr("id", function(d) { return d.name; })
    .style("fill", function(d) { return info.colors[d.type]; })
    .call(force.drag);

    var texts = nodeGroups
    .append("text")
    .attr("class", "courseNames")
    .attr("id", function(d) { return d.name; })
    .attr("fill", "black")
    .attr("font-family", "sans-serif")
    .attr("text-anchor", "middle")
    .attr("font-size", "12px")
    .text(function(d) { return d.name; });

    // draw the legend for colors
    var categories = [];
    var index = 0;
    for(key in info.colors) {
        categories.push({name: key, index: index, color: info.colors[key]});
        index++;
    }
    var colorLegend = svg.selectAll("circle.colorLegend")
    .data(categories)
    .enter()
    .append("circle")
    .attr("class", "colorLegend")
    .attr("cx", function(d) { return (w-3*NODE_RADIUS)*d.index/(categories.length-1) + NODE_RADIUS; })
    .attr("cy", NODE_RADIUS+5)
    .attr("r", NODE_RADIUS)
    .on("mouseover", legendMouseOver)
    .on("mouseout", classMouseOff)
    .style("fill", function(d) { return d.color; });

    var colorText = svg.selectAll("text.textLegend")
    .data(categories)
    .enter()
    .append("text")
    .attr("x", function(d) { return (w-3*NODE_RADIUS)*d.index/(categories.length-1) +NODE_RADIUS})
    .attr("y", 3*NODE_RADIUS)
    .attr("fill", "black")
    .attr("font-family", "sans-serif")
    .attr("text-anchor", "middle")
    .attr("font-size", "14px")
    .text(function(d) { return d.name;});

    // draw the legend for arrows
    var arrowLegend = svg.selectAll('g.arrowLegend').data([{ name: "Leads to", "stroke-dasharray": "5, 5"}, {name: "Prereq", "stroke-dasharray": null}])
    .enter()
    .append('g')
    .attr("class", "arrowLegend")
    .attr("opacity", 0)
    .attr("x", w-100)
    .attr("y", 25)
    .attr("height", 50)
    .attr("width", 100)
    .each(function(d, i) {
        var g = d3.select(this);
        g.append("text")
        .attr("x", w-100) 
        .attr("y", h-i*25)
        .attr("fill", "black")
        .attr("font-family", "sans-serif")
        .attr("text-anchor", "middle")
        .attr("font-size", "12px")
        .text(d.name);
        g.append("line")
        .style("stroke", "#000")
        .style("stroke-width", 2)
        .style("stroke-dasharray", d["stroke-dasharray"])
        .attr("x1", w-70)
        .attr("y1", h-i*25-4)
        .attr("x2", w-30)
        .attr("y2", h-i*25-4)
        .attr("marker-end", "url(#end)");
    });

    // turn on force
    force.on("tick", function(e) {
        edges.each(function(d) {
            var x1 = d.source.x;
            var y1 = d.source.y;
            var x2 = d.target.x;
            var y2 = d.target.y;
            // make arrows end at edge rather than center
            var angle = Math.atan(Math.abs((y2-y1)/(x2-x1)));
            x2 += (x1 < x2 ? -1 : 1) * (NODE_RADIUS+6)*Math.cos(angle);
            y2 += (y1 < y2 ? -1 : 1) * (NODE_RADIUS+6)*Math.sin(angle);
            d3.select(this).attr({
                'x1': x1,
                'y1': y1,
                'x2': x2,
                'y2': y2,
            });
        });

        var k = 0.1*e.alpha;
        nodes.forEach(function(o,i) {
            var charth = h - LEGEND_OFFSET; // amount of space to draw on not including the legend
            var targety = 0;
            var targetx = 0;
            targetx += w*info.prefLocs[o.type].x;
            targety += charth*info.prefLocs[o.type].y;
            targety += (o.depth-1)*charth/(info.maxDepth-1);
            targetx += o.bias_x;
            targety += o.bias_y;
            targety += LEGEND_OFFSET;

            o.y += (targety-o.y)*k;
            o.x += (targetx-o.x)*k;
            circle.attr("cx", function(d) {
                return d.x; 
            })
            .attr("cy", function(d) {
                return d.y;
            });
            texts.attr("transform", function(d) {
                return "translate(" + d.x + "," + d.y + ")";
            });
        });

        //collision
        var collide = function(node) {
            var r = node.radius + 16;
            nx1 = node.x - r,
            nx2 = node.x + r,
            ny1 = node.y - r,
            ny2 = node.y + r;
            return function(quad, x1, y1, x2, y2) {
                if (quad.point && (quad.point !== node)) {
                    var x = node.x - quad.point.x,
                    y = node.y - quad.point.y,
                    l = Math.sqrt(x * x + y * y),
                    r = node.radius + quad.point.radius;
                    if (l < r) {
                        l = (l - r) / l * 0.5;
                        node.x -= x *= l;
                        node.y -= y *= l;
                        quad.point.x += x;
                        quad.point.y += y;
                    }
                }
                return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
            };
        };
        var q = d3.geom.quadtree(nodes),
        j = 0,
        n = nodes.length;
        while (++j < n) {
            q.visit(collide(nodes[j]));
        }
        svg.selectAll("circle.course")
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });

    });
    force.start();
};
