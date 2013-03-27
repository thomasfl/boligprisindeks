$(document).ready(function() {

    var margin = {top: 30, right: 20, bottom: 30, left: 50},
        width = 600 - margin.left - margin.right,
        height = 270 - margin.top - margin.bottom;

    var x = d3.time.scale().range([0, width]);
    var y = d3.scale.linear().range([height, 0]);

    var xAxis = d3.svg.axis().scale(x)
            .orient("bottom").ticks(5);

    var yAxis = d3.svg.axis().scale(y)
            .orient("left").ticks(5);

    var valueline = d3.svg.line()
            .x(function(d) { return x(d.date); })
            .y(function(d) { return y(d.close); });

    var svg = d3.select("#prisgraf").append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // Define 'div' for tooltips
    var div = d3.select("#prisgrafWrapper").append("div")       // declare the properties for the div used for the tooltips
            .attr("class", "tooltip")                               // apply the 'tooltip' class
            .style("opacity", 0);                                   // set the opacity to nil

    var formatTime = d3.time.format("%Y");                       // Format the date / time for tooltips
    var formatCurrency = d3.format(",.0f");
    var formatSquareMeterPrice = function(price){
        return "NOK " + formatCurrency(price).replace(",",".");
    };

    // Get the data
    var parseDate = d3.time.format("%Y-%m-%d").parse;

    d3.json("/data/historikk", function(error, data) {
        data.forEach(function(d) {
            d.date = parseDate(d.periode);
            d.close = +d.m2_pris;
        });

        // Scale the range of the data
        x.domain(d3.extent(data, function(d) { return d.date; }));
        y.domain([0, d3.max(data, function(d) { return d.close; })]);

        svg.append("path")      // Add the valueline path.
            .attr("d", valueline(data));

        // draw the scatterplot
        svg.selectAll("dot")
            .data(data)
            .enter().append("circle")
            .attr("r", 5)                                                                                   // Made slightly larger to make recognition easier
            .attr("cx", function(d) { return x(d.date); })
            .attr("cy", function(d) { return y(d.close); })
            .on("mouseover", function(d) {                                                      // when the mouse goes over a circle, do the following
                div.transition()                                                                        // declare the transition properties to bring fade-in div
                    .duration(200)                                                                  // it shall take 200ms
                    .style("opacity", 0.9);                                                  // and go all the way to an opacity of .9
                div     .html(formatTime(d.date) + "<br/>"  + formatSquareMeterPrice(d.close))  // add the text of the tooltip as html
                    .style("left", (d3.event.pageX) + "px")                 // move it in the x direction
                    .style("top", (d3.event.pageY + 10 ) + "px");    // move it in the y direction
            })                                                                                                      //
            .on("mouseout", function(d) {                                                   // when the mouse leaves a circle, do the following
                div.transition()                                                                        // declare the transition properties to fade-out the div
                    .duration(500)                                                                  // it shall take 500ms
                    .style("opacity", 0);                                                   // and go all the way to an opacity of nil
            });


        svg.append("g")         // Add the X Axis
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

        svg.append("g")         // Add the Y Axis
            .attr("class", "y axis")
            .call(yAxis);
    });


});
