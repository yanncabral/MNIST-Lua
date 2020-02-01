require 'matrix'
require 'table_save'

NeuralNetwork = {}

NeuralNetwork.Create = function(i_nodes, o_nodes, df_size)
  local nn = {}
  local self = nn
  local a = 2
  h_nodes = math.floor(df_size/(a*(i_nodes+o_nodes)))
  nn.activations = {}
  
  nn.activations.sigmoid = function(x)
    return 1 / (1 + math.exp(-x))
  end

  nn.activations.dsigmoid = function(z)
    return z * (1-z)
  end

  nn.activations.dtanh = function(z)
    return (1 - z*z)
  end

  nn.activations.tanh = function(x)
    return math.tanh(x)
  end
  
  function nn.loadFrom(s)
    self = table.load(s)
  end

  if tonumber(i_nodes) ~= nil then
    self.input_nodes = i_nodes
    self.hidden_nodes = h_nodes
    self.output_nodes = o_nodes
    
    self.weights = {
      Matrix.Create(self.hidden_nodes,self.input_nodes).gaussian(0,1/math.sqrt(i_nodes*h_nodes)),
      Matrix.Create(self.output_nodes,self.hidden_nodes).gaussian(0,1/math.sqrt(h_nodes*o_nodes))  
    }

    self.bias = {
      Matrix.Create(self.hidden_nodes,1).randomize(),
      Matrix.Create(self.output_nodes,1).randomize()
      }
    
    self.learning_rate = 0.1
  else
    self = table.load(s)
  end
  
  function nn.predict(arr)
    assert(#arr == self.input_nodes, 'O número de entradas é diferente do número de neurônios.')
    local input = Matrix.arrayToMatrix(arr)
    local hidden = Matrix.dot(self.weights[1], input)
    .add(self.bias[1])
    .map(nn.activations.tanh)

    local output = Matrix.dot(self.weights[2], hidden)
    .add(self.bias[2])
    .map(nn.activations.sigmoid)

    return Matrix.matrixToArray(output), input, hidden, output
  end
  
function nn.train(arr, target)
    -- predict 
    local _, input, hidden, output = nn.predict(arr)
    
    --backpropagation
    
    -- output -> hidden
    -- Quadratic Cost
    local output_error = Matrix.arrayToMatrix(target).sub(output)

    local gradient = output.map(nn.activations.dsigmoid)
      .multiply(output_error)
      .multiply(self.learning_rate)
    -- Calculate delta weights hidden -> output
    
    local hidden_T = Matrix.transpose(hidden)
    local weights_ho_deltas = Matrix.dot(gradient, hidden_T)

    self.weights[2].add(weights_ho_deltas)

    self.bias[2].add(gradient)
    
    local weights_ho_T = Matrix.transpose(self.weights[2])
    local hidden_error = Matrix.dot(weights_ho_T, output_error)
    local d_hidden = hidden.map(nn.activations.dtanh)
    .multiply(hidden_error)
    .multiply(self.learning_rate)
    
    local input_T = Matrix.transpose(input)
    local weigths_ih_deltas = Matrix.dot(d_hidden, input_T)   
    self.weights[1].add(weigths_ih_deltas)    
    self.bias_ih = Matrix.add(self.bias[1], d_hidden)

    return _, output_error
  end
  
  function nn.saveTo(s)
    table.save(self, s)
  end
  
  return nn
end