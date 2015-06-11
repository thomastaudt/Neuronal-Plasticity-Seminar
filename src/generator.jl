
type SparseMatrixGenerator <: AbstractGenerator
	p::Float64			  # percentage of edges taken
	gain::Real			  # gain factor for edge strength
	size::Int			    # size of the network
	num_input::Int64		# number of input channels
	num_output::Int64		# number of output channels
	feedback::Real		# strength of feedback connections

  function SparseMatrixGenerator(size::Int, p::Float64; num_input=0, num_output=1, gain::Real=1.2, feedback::Real=2)
    @assert 0 < p <= 1 "p is a connection probability, thus 0 < p <= 1"
    return new(p, gain, size, num_input, num_output, feedback)
  end
end

function SparseMatrixGenerator(size, p; num_input=0, num_output=1, gain=1.2, feedback=2)
  return SparseMatrixGenerator(size, p, num_input=num_input, num_output=num_output, gain=gain, feedback=feedback)
end

function generate(generator::SparseMatrixGenerator, seed::Int64)
	# initialize random by seed
	srand(seed)

	# convenience variable
	N = generator.size

	# internal connections: sparse, normal distributed
	ω_r = sprandn(N, N, generator.p)*generator.gain/sqrt(N * generator.p)
	# feedback connections: [-1 .. 1]
	ω_f = generator.feedback * (rand(N, generator.num_output) - 0.5)
	# output (readout) weights.
	ω_o = 1randn(generator.num_output, N)
	# input weights
	ω_i = 1randn(N, generator.num_input)

	neuron_in = 0.5randn(N)

	# should readout be consisten with neuron_in?
	output = 2randn( generator.num_output )

	# generate the network
	net     = NetworkTest( ω_r = ω_r, ω_f = ω_f, neuron_in = neuron_in, output = output, ω_o = ω_o )
end

function export_params( generator::SparseMatrixGenerator)
  parameters::Dict{String, Tuple}
  D["percentage"] = (0.0, 1.0, generator.p)
  D["gain"] = (0.0, 4.0, generator.gain)           # !TODO is this a good maximum? maybe we should specify a distribution
  D["size"] = (max(0, generator.size - 10), max(0, generator.size + 10), generator.size)          # this limits size to close to old size
                                                   # changes out of nothing
  D["feedback"] = (0.0, 4.0, generator.feedback)
  return D
end

function import_params!(generator::SparseMatrixGenerator, params::Dict{String, Tuple})
  generator.p = D["percentage"][3]
  generator.gain = D["gain"][3]
  generator.size = D["size"][3]
  generator.feedback = D["feedback"][3]
end
