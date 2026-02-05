using Test, TestItems, TestItemRunner

@testitem "3, 2, 0" setup = [Fixtures] begin
    input = [1, 0, 0, 1, 1, 1, 0, 0, 0]
    expected_output = [1, 0, 0, 1, 0, 0, 0, 0, 0]
    output = compute_interleaver(3, 2, 0, input)
    @test output == expected_output
end

@testitem "2, 2, 0" setup = [Fixtures] begin
    input = [1, 0, 0, 1, 1, 1, 0, 0, 0]
    expected_output = [1, 0, 0, 0, 1, 0, 0, 1, 0]
    output = compute_interleaver(2, 2, 0, input)
    @test output == expected_output
end

@testitem "3, 2, vec" setup = [Fixtures] begin
    input = [1, 0, 0, 1, 1, 1, 0, 0, 0]
    expected_output = [1, 4, 5, 1, 4, 5, 0, 0, 5]
    output = compute_interleaver(3, 2, [3, 4, 5], input)
    @test output == expected_output
end

@testitem "must throw" setup = [Fixtures] begin
    input = [1, 0, 0, 1, 1, 1, 0, 0, 0]
    @test_throws "must be the same" compute_interleaver(3, 2, [3, 4, 5, 6], input)
end

@testsnippet Fixtures begin
    import ConvolutionalInterleavers: ConvolutionalInterleaver, interleaving

    function compute_interleaver(
        num_shift_registers,
        reg_length_step,
        init_conditions,
        input,
    )
        a = ConvolutionalInterleaver(
            num_shift_registers,
            reg_length_step,
            init_conditions,
        )
        return [interleaving(a, i) for i in input]
    end
end

@run_package_tests
