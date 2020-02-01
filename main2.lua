require "nn"
local qual = 0

function love.load()

  nn = NeuralNetwork.Create(784,30,10)
  nn.loadFrom('mnist.yann')  
  --nn = require "mnist_trainning"
  mnist_data = require "load_mnist"  
  next_image()
  love.graphics.setBackgroundColor(1,1,1) 
end

function love.update(dt)
  
end

function next_image()
  if mnist_data [qual+1] ~= nil then
    qual = qual + 1
    local out = nn.predict(mnist_data[qual][1])
    guess = 0
    io.write('Tentativa: '..mnist_data[qual][2]..'; Resposta: [')
    for i = 1, 10 do
      io.write(string.format("%i: %.3f %%, ",i-1, out[i]*100))
      if out[i] >= out[guess+1] then
        mnist_data[qual][3] =  out[i]*100
        guess = i-1
      end
    end
    io.write('] ('..guess..')\n')
  end
end

function love.mousepressed()
  next_image()
end

function love.draw()
  love.graphics.setColor(0,0,0,1)
  love.graphics.print(
    string.format("Palpite: %d (%.3f%%)", guess, mnist_data[qual][3])
    , 10, 76)
  index= 0
  for i = 1, 28 do
    for j = 1, 28 do
      index = index+1
      love.graphics.setColor(0,0,0,mnist_data[qual][1][index]/255)
      love.graphics.rectangle('fill', (j-1)*28, (i-1)*28, 28,28)
    end
  end
end