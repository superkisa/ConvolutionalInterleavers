module ConvolutionalInterleavers

import DataStructures: CircularBuffer

mutable struct ConvolutionalInterleaver
    # Количество линий сдвиговых регистров
    num_shift_registers::Int

    # Шаг, с которым будет изменятся количество триггеров в каждом следующем 
    # сдвиговом регистре (начиная с 0 для первого)
    reg_length_step::Int

    # Значения, которыми будут заполнены сдвиговые регистры в начальный момент времени: 
    #   - если int, то все триггеры всех сдвиговых регистров будут заполнены этим значением
    #   - если vector, то должен быть равен по длине количеству сдвиговых регистров в
    #     перемежителе, и каждое число вектора соответствует значениям, которыми будут 
    #     заполнены триггеры каждого из регистров соответственно
    init_conditions::Vector{Int}

    # Собственно, сам перемежитель: набор сдвиговых регистров
    conv_intr::Vector{CircularBuffer{Int}}

    # Набор положений ключа (для более физического представления перемежителя)
    selectors::CircularBuffer{Int}

    # Номер линии сдвигового регистра в перемежителе, на которой сейчас 
    # замкнут ключ -- одно из положений из selectors
    current_key::Int
end


# Аналог питоновского инита
function ConvolutionalInterleaver(
    num_shift_registers::Int,
    reg_length_step::Int,
    init_conditions::Union{Int, Vector{Int}} = 0,
)
    if init_conditions isa Int
        init_conditions = fill(init_conditions, num_shift_registers)
    end

    new = ConvolutionalInterleaver(
        num_shift_registers,
        reg_length_step,
        init_conditions,
        Vector{CircularBuffer{Int}}(),
        CircularBuffer{Int}(1:num_shift_registers),
        0,
    )
    restart!(new)
    return new
end

# Функция-обработчик сигнала (побитно) перемежителем
function interleaving(self::ConvolutionalInterleaver, elem::Int)::Int
    pushfirst!(self.conv_intr[self.current_key], elem)
    ret_elem = pop!(self.conv_intr[self.current_key])
    self.current_key, self.selectors = shiftleft!(self.selectors)
    return ret_elem
end

# Функция настройки/формирования/сброса перемежителя. В ней задаются атрибуты 
# с выбранными пользователем параментрами. Выделено в отдельную функция, чтобы 
# можно было сбросить или поменять параметры у уже существующего инстанса перемежителя 
# (не создавая новый)
function restart!(
    self::ConvolutionalInterleaver;
    num_shift_registers::Union{Int, Nothing} = nothing,
    reg_length_step::Union{Int, Nothing} = nothing,
    init_conditions::Union{Int, Vector{Int}, Nothing} = nothing,
)
    if num_shift_registers !== nothing
        self.num_shift_registers = num_shift_registers
    end
    if reg_length_step !== nothing
        self.reg_length_step = reg_length_step
    end
    if init_conditions !== nothing
        self.init_conditions = init_conditions
    end

    @assert length(self.init_conditions) == self.num_shift_registers "Length of the init_conditions must be the same as num_shift_registers"

    for i in self.selectors
        len_shift_reg = (i - 1) * self.reg_length_step + 1
        push!(
            self.conv_intr,
            CircularBuffer{Int}(self.init_conditions[i] for _ = 1:len_shift_reg),
        )
    end

    self.current_key, self.selectors = shiftleft!(self.selectors)

    return nothing
end

# Функция переключения ключа перемежителя между сдвиговыми регистрами
function shiftleft!(circ_buff::CircularBuffer)
    curr_key = popfirst!(circ_buff)
    push!(circ_buff, curr_key)
    return curr_key, circ_buff
end

end # module ConvolutionalInterleaver
