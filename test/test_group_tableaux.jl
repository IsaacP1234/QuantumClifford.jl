using Random
using QuantumClifford

# Including sizes that would test off-by-one errors in the bit encoding.
test_sizes = [1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17] # Zero function(in groupify) slows down around 2^30(n=30),eventually breaks
# Zero function(in groupify) slows down around 2^30(n=30),eventually breaks
small_test_sizes = [1, 2, 3, 4, 5, 7, 8] # Pauligroup slows around n =9

@test_set "Group Tableaux" begin
    #Test groupify
    for n in [1, test_sizes...]
        s = random_stabilizer(n)
        s_test = copy(s)
        group = groupify(s)
        @test length(group) == 2^n
        unchanged = true
        for stabilizer in group
            apply!(s, stabilizer)
            if !(s == s_test)
                unchanged = false
            end
            @test unchanged == true
        end
    end
    #Test minimal_generating_set
    for n in [1, small_test_sizes...]
        s = random_stabilizer(n)
        group = groupify(s)
        gen_set = get_generating_set(group)
        new_group = groupify(gen_set)
        canonicalize!(group)
        canonicalize!(new_group)
        @test group == new_group
        s = zero(Stabilizer, rand(1:(2*n)), n)
        for i in 1:length(s)
            s[i] = random_pauli(n)
        end
        gen_set = get_generating_set(s)
        new_group = groupify(s)
        for operator in s
            @test operator in new_group
        end
    end

    #Test normalizer
    for n in [1, small_test_sizes...] # pauligroup is very slow at n=14
        s = random_stabilizer(n)
        normalized = normalizer(s)
        stabilizers = pauligroup(n, true)
        for n_stabilizer in normalized
            for stabilizer in s
                @test comm(n_stabilizer, stabilizer) == 0x0
            end
        end
    end
    for stabilizer in stabilizers
        commutes = true
        for n_stabilizer in normalized
            if !(comm(n_stabilizer, stabilizer) == 0x0)
                commutes = false
            end
        end
        @test !commutes || stabilizer in normalized
    end
    #Test centralizer
    for n in [1, test_sizes...]
        s = random_stabilizer(n)
        c = centeralizer(s)
        for c_stabilizer in c
            for stabilizer in s
                @test comm(c_stabilizer, stabilizer) == 0x0
            end
        end
        for stabilizer in s
            commutes = true
            for stab in s
                @test comm(stab, stabilizer) == 0x0
            end
            @test !commutes || st in c
        end

    end
    #Test contract
    for n in [1, test_sizes...]
        s = random_stabilizer(n)
        g = QuantumClifford.groupify(s)
        subset = []
        for i in 1:nqubits(s) #create a random subset
            if rand(1:2) == 1 push!(subset, i) end
        end
        c = QuantumClifford.contract(s, subset)
        count = 0
        for stabilizer in g 
            contractable = true
            for i in subset
                if stabilizer[i] != (false, false) contractable = false end
            end
            if contractable count+=1 end
        end
        @test count = size(c)
        for contracted in c
            p = zero(PauliOperator, nqubits(s))
            index = 0
            for i in 1:nqubits(g)
                if !(i in subset) 
                    index+=1 
                    p[i] = contracted[index] 
                end
            end
            @test p in g 
        end
    end
end
