using DifferentialEquations, StaticArrays, LinearAlgebra, DataFrames, GenieFramework

include("./src/gnc.jl");
include("./src/orbital_dynamics.jl");

@genietools

# function ground_track(orbital_elements, r_apo, r_per, t_init, t_final; num_steps=100, return_times=false, mu=398600, radius=6378, j2=1.08263e-3, body_angular_vel=7.292124e-5)
# return longitude_vec, latitude_vec

# a, e, i, asc, arg, theta = orbital_elements

lon, lat = ground_track([8350.0, 0.19760, deg2rad(60), deg2rad(270), deg2rad(45), deg2rad(230)], 0.0, 7593.5*3.25);

@handlers begin
    # orbital elements and parameters
    @in semimajor = 8350.0
    @in eccentricity = 0.19760
    @in inclination = 60
    @in ascending = 270
    @in argument = 45
    @in anomaly = 230

    # settings
    @in t_final = (7593.5*3.25) / (60.0^2)
    @in anum_steps = 100

    # plotting
    @out ground_track_plot = PlotData(x=rad2deg.(lon), y=rad2deg.(lat), plot="scatter", mode="markers")

    @out title = "Orbit Tool - Ground Tracks"

    @onchangeany semimajor, eccentricity, inclination, ascending, argument, anomaly, t_final, anum_steps begin
        longitude_vec, latitude_vec = ground_track([semimajor, eccentricity, deg2rad(inclination), deg2rad(ascending), deg2rad(argument), deg2rad(anomaly)], 0.0, t_final*60.0^2, num_steps=anum_steps)

        ground_track_plot = PlotData(x=rad2deg.(longitude_vec), y=rad2deg.(latitude_vec), plot="scatter", mode="markers")
    end
end

@page("/", "ui.jl")

Server.isrunning() || Server.up()