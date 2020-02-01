require "nn"
local qual = 0
local is_painting = false
local guess = 0
local center_of_mass = {}
local lines = {}

local function clear_grid()
  grid = {}
  lines = {}
  for i = 1, 784 do
    table.insert(grid, 0)
    guess = "???"
  end
end

function love.load()
  clear_grid()
  
  nn = NeuralNetwork.Create(784,30,10)
  nn.loadFrom('mnist.yann')  
  --nn = require "mnist_trainning"
  --mnist_data = require "load_mnist"  
  --next_image()
  canvas = love.graphics.newCanvas(784,784)
  love.graphics.setLineWidth(5)
end

function grid_move(c_m)
  local centered_grid = {}
  -- difença entre o centro de massa e o centro da grid
  cm = {math.floor(c_m[1] - 14),
        math.floor(c_m[2] - 14)}
  for i = 1, 784 do
    --movendo tudo pro centro da grid
    centered_grid[i] = grid[i+cm[1]+(28*cm[2])] or 0
  end
  --retornando grid centralizada
  return centered_grid
end

function love.mousepressed(x,y,key)
  --next_image()
  if key == 1 then
    is_painting = true
  elseif key == 2 then
    clear_grid()
  end
end

function getGuess(grid)
  --calculando atual centro de massa
  center_of_mass[1], center_of_mass[2] = getMassCenter(grid) 
  --movendo o centro de massa pro centro da grid
  local new_grid = grid_move(center_of_mass)
  --tentando identificar a partir da grid centralizada
  local out = nn.predict(new_grid)
  guess = 0
  for i = 1, 10 do
    if out[i] >= out[guess+1] then
      guess = i-1 -- procurando a maior porcentagem
    end
  end
end

function love.mousereleased(x,y,k)
  if k == 1 then 
    is_painting = false
    getGuess(grid)
  end
end

function getMassCenter(grid)
  --centro de massa é C = (E (mk*dk) from k = 1 to n)/m_total
  --aprendi em Física I com prof. Quiroga
  local x_center, y_center = 0, 0
  local intensity = 0
  for k, v in ipairs(grid) do
    intensity = intensity + v
    x_center = x_center + ((k%28)*v )
    y_center = y_center + ((math.floor(k/28)+1)*v )
  end
  x_center = x_center / intensity
  y_center = y_center / intensity
  return x_center, y_center
end

function love.draw()
  love.graphics.setColor(1,1,1,1)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBackgroundColor(1,1,1,1)
  love.graphics.setColor(0,0,0,1)
  love.graphics.print("Palpite: "..guess, 10,10)
  love.graphics.print("Desenhe com o botão esquerdo.", 10,22)
  love.graphics.print("Limpe o quadro com o botão direito.", 10,34)
  local index= 0
  if #lines > 4 then
    love.graphics.line(lines)
  end
  love.graphics.setCanvas()
  love.graphics.draw(canvas)
  if is_painting then
    love.graphics.setColor(1,0,0,1)
    local x,y = love.mouse.getPosition()
    love.graphics.circle('fill', x,y, 10)
    grid[ math.floor(x/28) + math.floor(y/28)*28+1 ] = 1
    if not(lines[#lines] == math.floor(y/28)*28+1 and lines[#lines] == math.floor(x/28)) then
      table.insert(lines, x)
      table.insert(lines, y)
    end
  end  
end