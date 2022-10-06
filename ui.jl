heading("{{title}}")

row([
    cell(class="st-module", [
        p("Semi-Major Axis: {{semimajor}} km")
        slider(400:10:20000, :semimajor; label=true)
    ])

    cell(class="st-module", [
        p("Eccentricity: {{eccentricity}}")
        slider(0:0.01:0.99, :eccentricity; label=true)
    ])

    cell(class="st-module", [
        p("Inclination: {{inclination}}°")
        slider(0:1:360, :inclination; label=true)
    ])
])

row([
    cell(class="st-module", [
        p("Right Ascension of Ascending Node: {{ascending}}°")
        slider(0:1:360, :ascending; label=true)
    ])

    cell(class="st-module", [
        p("Argument of Perigee: {{argument}}°")
        slider(0:1:360, :argument; label=true)
    ])

    cell(class="st-module", [
        p("True Anomaly: {{anomaly}}°")
        slider(0:1:360, :anomaly; label=true)
    ])
])

row([
    cell(class="st-module", [
        h5("Ground Track")
        plot(:ground_track_plot)
    ])
])

row([
    cell(class="st-module", [
        p("Orbit Time: {{t_final}} Hours")
        slider(0:0.25:30, :t_final; label=true)
    ])
    cell(class="st-module", [
        p("Number of Steps: {{anum_steps}}")
        slider(100:10:1000, :anum_steps; label=true)
    ])
])