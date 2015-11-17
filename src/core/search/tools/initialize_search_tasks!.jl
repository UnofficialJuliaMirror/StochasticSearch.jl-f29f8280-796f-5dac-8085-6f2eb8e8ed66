function initialize_search_tasks!(parameters::Dict{Symbol, Any})
    cost         = parameters[:cost]
    args         = parameters[:cost_args]
    instances    = parameters[:instances]
    methods      = parameters[:methods]
    initial_x    = parameters[:initial_config]
    evaluations  = parameters[:evaluations]
    measurement  = parameters[:measurement_method]
    channel_size = parameters[:channel_size]
    next_proc    = @task chooseproc()

    instance_id  = 1
    results      = RemoteRef[]

    for i = 1:length(methods)
        for j = 1:instances[i]
            push!(results, RemoteRef(() -> Channel{Result}(channel_size)))
            reference                   = results[instance_id]
            costs                       = zeros(evaluations)
            parameters[:costs]          = costs
            initial_x                   = perturb!(initial_x)
            parameters[:initial_config] = initial_x
            parameters[:initial_cost]   = measurement(parameters, initial_x)
            remotecall(consume(next_proc), eval(methods[i]),
                       deepcopy(parameters), reference)
            instance_id += 1
        end
    end
    results
end
