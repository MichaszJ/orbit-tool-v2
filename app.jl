using DifferentialEquations, StaticArrays, LinearAlgebra, DataFrames, GenieFramework

include("./src/gnc.jl");
include("./src/orbital_dynamics.jl");

@genietools


orbital_elements_init = [8350.0, 0.19760, deg2rad(60), deg2rad(270), deg2rad(45), deg2rad(230)]

lon, lat  = ground_track(orbital_elements_init, 0.0, 7593.5*3.25);
pos_geo, vel_geo = geocentric_state_vector_transform(sqrt(orbital_elements_init[1] * 398600 * (1 - orbital_elements_init[2]^2)), orbital_elements_init[2:end])

initial_conditions = SA[pos_geo[1], pos_geo[2], pos_geo[3], vel_geo[1], vel_geo[2], vel_geo[3]]
params = 398600.0
time_span = SA[0.0, 7593.5*3.25]

sol = diffeq_two_body_simple(initial_conditions, time_span, params);

n_points = 1000
times = LinRange(0, 7593.5*3.25, n_points);
sol_interp = sol(times)

sat_x = sol_interp[1, 1:end];
sat_y = sol_interp[2, 1:end];
sat_z = sol_interp[3, 1:end];


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
    @in app_num_steps = 100

    # plotting
    @out ground_track_plot = PlotData(lon=rad2deg.(lon), lat=rad2deg.(lat), plot="scattergeo", mode="markers")

    @out orbit_plot = PlotData(x=sat_x, y=sat_y, z=sat_z, plot="scatter3d")

    @out title = "Orbit Tool - Ground Tracks"

    @onchangeany semimajor, eccentricity, inclination, ascending, argument, anomaly, t_final, app_num_steps begin
        longitude_vec, latitude_vec = ground_track([semimajor, eccentricity, deg2rad(inclination), deg2rad(ascending), deg2rad(argument), deg2rad(anomaly)], 0.0, t_final*60.0^2, num_steps=app_num_steps)
        ground_track_plot = PlotData(lon=rad2deg.(longitude_vec), lat=rad2deg.(latitude_vec), plot="scattergeo", mode="markers")

        pos_geo, vel_geo = geocentric_state_vector_transform(sqrt(semimajor * 398600 * (1 - eccentricity^2)), [eccentricity, inclination, ascending, argument, anomaly])
        initial_conditions = SA[pos_geo[1], pos_geo[2], pos_geo[3], vel_geo[1], vel_geo[2], vel_geo[3]]
        params = 398600.0
        time_span = SA[0.0, t_final*60.0^2]

        sol = diffeq_two_body_simple(initial_conditions, time_span, params);

        n_points = 1000
        times = LinRange(0, t_final*60.0^2, n_points);
        sol_interp = sol(times)

        sat_x = sol_interp[1, 1:end];
        sat_y = sol_interp[2, 1:end];
        sat_z = sol_interp[3, 1:end];

        orbit_plot = PlotData(x=sat_x, y=sat_y, z=sat_z, plot="scatter3d")
    end
end

@page("/", "ui.jl")

Server.isrunning() || Server.up()