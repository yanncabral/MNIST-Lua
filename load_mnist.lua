require 'nn'
local images = assert(io.open('test_images.mnist', 'rb'))
local labels = assert(io.open('test_labels.mnist', 'rb'))

local mnist_data = {}
local n_data = 1000
--local nn = require 'mnist_trainning'
--nn = NeuralNetwork.Create(1,1,1)
--nn.loadFrom('mnist.yann')
images:read(16)
labels:read(8)


for item = 1, n_data do
  table.insert(mnist_data, {{}})
  for i = 1, 28*28 do
    table.insert(mnist_data[#mnist_data][1], string.byte(images:read(1)))
  end
  table.insert(mnist_data[#mnist_data], string.byte(labels:read(1)))
  
  print(string.format("Concluído: %.3f%%", (item)*100/n_data))
end
 
--[[
local correct_ans = 0
for k,v in ipairs(mnist_data) do
  local out = nn.predict(v[1])
  local guess = 0
  io.write('Tentativa: '..v[2]..'; Resposta: [')
  for i = 1, 10 do
    io.write(string.format("%i: %.3f %%, ",i-1, out[i]*100))
    if out[i] > out[guess+1] then
      guess = i-1
    end
  end
  io.write('] ('..guess..')\n')
  if guess == v[2] then
    correct_ans = correct_ans + 1
  end
end

print(string.format("Porcentagem de acertos: %.3f%%",correct_ans/10))
]]
images:close()
labels:close()
return mnist_data