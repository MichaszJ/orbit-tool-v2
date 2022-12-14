using DifferentialEquations

function two_body_propagator(t_init, t_final, mass_1, mass_2, initial_conditions; grav_constant=6.67259e-11, solver_method="rk_45", tolerance=0.2, beta=0.8)

    mu_1 = grav_constant * mass_1
    mu_2 = grav_constant * mass_2

    function differential_system(t, s)
        x_1, y_1, z_1, vx_1, vy_1, vz_1, x_2, y_2, z_2, vx_2, vy_2, vz_2 = s

        r = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2)

        return_vector = [
            vx_1,
            vy_1,
            vz_1,
            mu_2 * (x_2 - x_1) / r^3,
            mu_2 * (y_2 - y_1) / r^3,
            mu_2 * (z_2 - z_1) / r^3,
            vx_2,
            vy_2,
            vz_2,
            mu_1 * (x_1 - x_2) / r^3,
            mu_1 * (y_1 - y_2) / r^3,
            mu_1 * (z_1 - z_2) / r^3,
        ]

        return return_vector
    end

    solution_out, time_out = rk_solver(differential_system, initial_conditions, t_init, t_final, solver_method=solver_method, tolerance=tolerance, beta=beta)

    return solution_out, time_out
end;


function three_body_cr_propagator(t_init, t_final, mass_1, mass_2, r_12, initial_conditions; grav_constant=6.67259e-11, solver_method="rk_45", tolerance=0.2, beta=0.8)
    mu_1 = grav_constant * mass_1
    mu_2 = grav_constant * mass_2

    pi_1 = mass_1 / (mass_1 + mass_2)
    pi_2 = mass_2 / (mass_1 + mass_2)

    omega = sqrt(grav_constant * (mass_1 + mass_2) / r_12 ^ 3)

    function differential_system(t, s)
        x, y, z, v_x, v_y, v_z = s

        r_1 = sqrt((x + pi_2 * r_12) ^ 2 + y ^ 2 + z ^ 2)
        r_2 = sqrt((x - pi_1 * r_12) ^ 2 + y ^ 2 + z ^ 2)

        return_vector = [
            v_x,
            v_y,
            v_z,
            2 * omega * v_y + x * omega ^ 2 - (mu_1 / r_1 ^ 3) * (x + pi_2 * r_12) - (mu_2 / r_2 ^ 3) * (x - pi_1 * r_12),
            -2 * omega * v_x + y * omega ^ 2 - (mu_1 / r_1 ^ 3) * y - (mu_2 / r_2 ^ 3) * y,
            -(mu_1 / r_1 ^ 3) * z - (mu_2 / r_2 ^ 3) * z
        ]

        return return_vector
    end

    solution_out, time_out = rk_solver(differential_system, initial_conditions, t_init, t_final, solver_method=solver_method, tolerance=tolerance, beta=beta)

    return solution_out, time_out
end;

function three_body_propagator(t_init, t_final, mass_1, mass_2, mass_3, initial_conditions; grav_constant=6.67259e-11, tolerance=0.2, beta=0.8)
    mu_1 = grav_constant * mass_1
    mu_2 = grav_constant * mass_2
    mu_3 = grav_constant * mass_3

    function differential_system(t, s)
        x_1, y_1, z_1, vx_1, vy_1, vz_1, x_2, y_2, z_2, vx_2, vy_2, vz_2, x_3, y_3, z_3, vx_3, vy_3, vz_3 = s

        r_12 = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2)
        r_13 = sqrt((x_3 - x_1)^2 + (y_3 - y_1)^2 + (z_3 - z_1)^2)
        r_32 = sqrt((x_3 - x_2)^2 + (y_3 - y_2)^2 + (z_3 - z_2)^2)

        return_vector = [
            vx_1,
            vy_1,
            vz_1,
            mu_2 * (x_2 - x_1) / r_12^3 + mu_3 * (x_3 - x_1) / r_13^3,
            mu_2 * (y_2 - y_1) / r_12 ^3 + mu_3 * (y_3 - y_1) / r_13^3,
            mu_2 * (z_2 - z_1) / r_12^3 + mu_3 * (z_3 - z_1) / r_13^3,
            vx_2,
            vy_2,
            vz_2,
            mu_1 * (x_1 - x_2) / r_12^3 + mu_3 * (x_3 - x_2) / r_32^3,
            mu_1 * (y_1 - y_2) / r_12^3 + mu_3 * (y_3 - y_2) / r_32^3,
            mu_1 * (z_1 - z_2) / r_12^3 + mu_3 * (z_3 - z_2) / r_32^3,
            vx_3,
            vy_3,
            vz_3,
            mu_1 * (x_1 - x_3) / r_13^3 + mu_2 * (x_2 - x_3) / r_32^3,
            mu_1 * (y_1 - y_3) / r_13^3 + mu_2 * (y_2 - y_3) / r_32^3,
            mu_1 * (z_1 - z_3) / r_13^3 + mu_2 * (z_2 - z_3) / r_32^3
        ]

        return return_vector
    end

    solution_out, time_out = rk_solver(differential_system, initial_conditions, t_init, t_final, solver_method=solver_method, tolerance=tolerance, beta=beta)

    return solution_out, time_out
end;

function diffeq_two_body(initial_conditions, time_span, params; solver_args...)
	function differential_system!(du, u, p, t)
		# unpacking initial conditions and parameters
		x_1, y_1, z_1, vx_1, vy_1, vz_1, x_2, y_2, z_2, vx_2, vy_2, vz_2 = u
		grav_constant, mass_1, mass_2 = p
	
		# defining helpful constants
		??_1 = grav_constant * mass_1
		??_2 = grav_constant * mass_2
		r = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2)
	
		# defining differentials
		du[1] = vx_1
		du[2] = vy_1
		du[3] = vz_1
		du[4] = ??_2 * (x_2 - x_1) / r^3
		du[5] = ??_2 * (y_2 - y_1) / r^3
		du[6] = ??_2 * (z_2 - z_1) / r^3
		du[7] = vx_2
		du[8] = vy_2
		du[9] = vz_2
		du[10] = ??_1 * (x_1 - x_2) / r^3
		du[11] = ??_1 * (y_1 - y_2) / r^3
		du[12] = ??_1 * (z_1 - z_2) / r^3 
	end

	problem = ODEProblem(differential_system!, initial_conditions, time_span, params)
	solution = solve(problem; solver_args...)
	
	return solution
end;

function diffeq_two_body_simple(initial_conditions, time_span, params; solver_args...)
    function differential_system(u, p, t)
        x, y, z, vx, vy, vz = u
        ?? = p

        r = sqrt(x^2 + y^2 + z^2)

        return SA[
            vx,
            vy,
            vz,
            -?? * x / r^3,
            -?? * y / r^3,
            -?? * z / r^3
        ]
    end

    problem = ODEProblem(differential_system, initial_conditions, time_span, params)
    solution = solve(problem; solver_args...)

    return solution
end

function diffeq_three_body(initial_conditions, time_span, params; solver_args...)
	function differential_system!(du, u, p, t)
        # unpacking initial conditions and parameters
        x_1, y_1, z_1, vx_1, vy_1, vz_1, x_2, y_2, z_2, vx_2, vy_2, vz_2, x_3, y_3, z_3, vx_3, vy_3, vz_3 = u
		grav_constant, mass_1, mass_2, mass_3 = p

		# defining helpful constants
        ??_1 = grav_constant * mass_1
        ??_2 = grav_constant * mass_2
        ??_3 = grav_constant * mass_3

        r_12 = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2)
        r_13 = sqrt((x_3 - x_1)^2 + (y_3 - y_1)^2 + (z_3 - z_1)^2)
        r_32 = sqrt((x_3 - x_2)^2 + (y_3 - y_2)^2 + (z_3 - z_2)^2)
        
		# defining differentials
        du[1] = vx_1
        du[2] = vy_1
        du[3] = vz_1
        du[4] = ??_2 * (x_2 - x_1) / r_12^3 + ??_3 * (x_3 - x_1) / r_13^3
        du[5] = ??_2 * (y_2 - y_1) / r_12^3 + ??_3 * (y_3 - y_1) / r_13^3
        du[6] = ??_2 * (z_2 - z_1) / r_12^3 + ??_3 * (z_3 - z_1) / r_13^3
        du[7] = vx_2
        du[8] = vy_2
        du[9] = vz_2
        du[10] = ??_1 * (x_1 - x_2) / r_12^3 + ??_3 * (x_3 - x_2) / r_32^3
        du[11] = ??_1 * (y_1 - y_2) / r_12^3 + ??_3 * (y_3 - y_2) / r_32^3
        du[12] = ??_1 * (z_1 - z_2) / r_12^3 + ??_3 * (z_3 - z_2) / r_32^3
        du[13] = vx_3
        du[14] = vy_3
        du[15] = vz_3
        du[16] = ??_1 * (x_1 - x_3) / r_13^3 + ??_2 * (x_2 - x_3) / r_32^3
        du[17] = ??_1 * (y_1 - y_3) / r_13^3 + ??_2 * (y_2 - y_3) / r_32^3
        du[18] = ??_1 * (z_1 - z_3) / r_13^3 + ??_2 * (z_2 - z_3) / r_32^3
	end

	problem = ODEProblem(differential_system!, initial_conditions, time_span, params)
	solution = solve(problem; solver_args...)
	
	return solution
end;

function diffeq_three_body_cr(initial_conditions, time_span, params; solver_args...)
	function differential_system!(du, u, p, t)
		# unpacking initial conditions and parameters
		x, y, z, v_x, v_y, v_z = u
		grav_constant, mass_1, mass_2, r_12 = p
	
		# defining helpful constants
		??_1 = grav_constant * mass_1
		??_2 = grav_constant * mass_2
        
        ??_1 = mass_1 / (mass_1 + mass_2)
        ??_2 = mass_2 / (mass_1 + mass_2)

        ?? = sqrt(grav_constant * (mass_1 + mass_2) / r_12 ^ 3)

        r_1 = sqrt((x + ??_2 * r_12)^2 + y^2 + z^2)
        r_2 = sqrt((x - ??_1 * r_12)^2 + y^2 + z^2)
	
		# defining differentials
        du[1] = v_x
        du[2] = v_y
        du[3] = v_z
        du[4] = 2 * ?? * v_y + x * ?? ^ 2 - (??_1 / r_1 ^ 3) * (x + ??_2 * r_12) - (??_2 / r_2 ^ 3) * (x - ??_1 * r_12)
        du[5] = -2 * ?? * v_x + y * ?? ^ 2 - (??_1 / r_1 ^ 3) * y - (??_2 / r_2 ^ 3) * y
        du[6] = -(??_1 / r_1 ^ 3) * z - (??_2 / r_2 ^ 3) * z
	end

	problem = ODEProblem(differential_system!, initial_conditions, time_span, params)
	solution = solve(problem; solver_args...)
	
	return solution
end;