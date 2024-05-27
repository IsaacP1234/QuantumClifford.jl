using Random
using QuantumClifford

test_sizes = [1,2,3,4,5,7,8,9,15,16,17] # Including sizes that would test off-by-one errors in the bit encoding.
#zero function(in groupify) slows down around 2^30(n=30),eventually breaks


@test_set "Group Tableaux" begin 
    #test groupify
    for n in [1,test_sizes...]
        s = random_stabilizer(n)
        s_test = copy(s)
        group = groupify(s)
        @test length(group) == 2^n
        unchanged = true
        for stabilizer in group
            apply!(s, stabilizer)
            if !( s== s_test)
                unchanged = false
            end 
            @test unchanged == true
        end 
    end
    #test get_generating_set
    for n in [1,test_sizes...]
        s = random_stabilizer(n)
        group = QuantumClifford.groupify(s)
        gen_set = QuantumClifford.get_generating_set(group)
        new_group = QuantumClifford.groupify(gen_set)
        canonicalize!(group)
        canonicalize!(new_group)
        @test group == new_group
    end
    #test normalize
    for n in [1,test_sizes...]
        s = random_stabilizer(n)
        normalized = QuantumClifford.normalize(s)
        for n_stabilizer in normalized
            for stabilizer in normalized
                @test n_stabilizer * stabilizer == stabilzer *n_stabilizer
            end
        end
    end

end
