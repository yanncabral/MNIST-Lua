Matrix = {}
Matrix.Create = function (rows, columns)
  local matrix = {}
  local self = matrix
  
  self.rows = rows
  self.columns = columns
  self.data = {}
  
  for i = 1, rows do
    local arr = {}
    for j = 1, columns do
      table.insert(arr, 0)
    end
    table.insert(self.data, arr)
  end

  function matrix.print()
    io.write('[\n')
    for i,v in ipairs(matrix.data) do 
      io.write('[')
      for j, k in ipairs(v) do 
        io.write(k..', ')
      end
      io.write(']\n')
    end
    io.write(']\n')
  end
  
  function matrix.sum()
    local total = 0
    for i,v in ipairs(matrix.data) do 
      for j, k in ipairs(v) do 
        total = total + matrix.data[i][j]
      end
    end
    return total
  end

  function matrix.map(func)
    for i,v in ipairs(matrix.data) do 
      for j, k in ipairs(v) do 
        matrix.data[i][j] = func(k, i,j)
      end
    end
    return matrix
  end

  function matrix.add(B)
    assert(matrix.rows == B.rows and B.columns == matrix.columns, 'Matrizes incompatíveis para soma.')
    matrix.map(function(_, i,j) return matrix.data[i][j] + B.data[i][j] end)
    return matrix
  end
  
  function matrix.sub(B)
    assert(matrix.rows == B.rows and B.columns == matrix.columns, 'Matrizes incompatíveis para subtração.')
    matrix.map(function(_, i,j) return matrix.data[i][j] - B.data[i][j] end)
    return matrix
  end

  function matrix.multiply(B)
  if tonumber(B) ~= nil then
    return matrix.map(function(e,i,j) return e*B end)
  else
    assert(matrix.rows == B.rows and matrix.columns == B.columns , 'Matrizes incompatíveis para hadamard.')
    return matrix.map(function(e,i,j) return e*B.data[i][j] end)
  end
end

  function matrix.gaussian (mean, variance)
    math.randomseed(os.time())
    return matrix.map(function()
        return  math.sqrt(-2 * variance * math.log(math.max(math.random(), 0.1))) *
            math.cos(2 * math.pi * math.random()) + mean
        end)
  end
  
  function matrix.randomize()
    math.randomseed(os.time())
    matrix.map( function ()
        return math.random() * 2 - 1
      end)
    return matrix
  end
  
  return matrix
end

Matrix.transpose = function(A)
  return Matrix.Create(A.columns, A.rows)
  .map(function(_, i,j) return A.data[j][i] end)
end

Matrix.add = function(A, B)
  assert(A.rows == B.rows and B.columns == A.columns, 'Matrizes incompatíveis para soma.')
  return Matrix.Create(A.rows, A.columns)
    .map(function(_, i,j) return A.data[i][j] + B.data[i][j] end)
end

Matrix.sub = function(A, B)
  assert(A.rows == B.rows and B.columns == A.columns, 'Matrizes incompatíveis para subtração.')
  return Matrix.Create(A.rows, A.columns)
    .map(function(_, i,j) return A.data[i][j] - B.data[i][j] end)
end

Matrix.escalar_multiply = function(A, escalar)
  local matrix = Matrix.Create(A.rows, A.columns)
  matrix.map(function(value, i,j) return A.data[i][j] * escalar end)
  return matrix
end

Matrix.hadamard = function(A, B)
  assert(A.rows == B.rows and A.columns == B.columns , 'Matrizes incompatíveis para hadamard.')
  local matrix = Matrix.Create(A.rows, A.columns)
  matrix.map(function(value, i,j) return A.data[i][j] * B.data[i][j] end)
  return matrix
end

Matrix.dot = function(A, B)
  assert(A.columns == B.rows)
  local matrix = Matrix.Create(A.rows, B.columns)
  matrix.map(function(value, i,j) 
      local sum = 0
        for k = 1, A.columns do 
          local elm1 = A.data[i][k]
          local elm2 = B.data[k][j]
          sum = sum + elm1 * elm2
        end
      return sum end
      )
  return matrix
end

Matrix.multiply = function(A,B)
  if tonumber(B) ~= nil then
    return Matrix.map(A, function(e,i,j) return e*B end)
  else
    assert(A.rows == B.rows and A.columns == B.columns , 'Matrizes incompatíveis para hadamard.')
    return Matrix.map(A, function(e,i,j) return e*B.data[i][j] end)
  end
end

Matrix.map = function (A, func)
  local matrix = Matrix.Create(A.rows, A.columns)
  for i,v in ipairs(A.data) do 
    for j, k in ipairs(v) do 
      matrix.data[i][j] = func(k,i,j)
    end
  end
  return matrix
end

Matrix.arrayToMatrix = function(arr)
  return Matrix.Create(#arr, 1).map(function(e,i) return arr[i] end)
end

Matrix.matrixToArray = function(obj)
  local arr = {}
    for i,v in ipairs(obj.data) do 
      for j, k in ipairs(v) do 
        table.insert(arr, k)
      end
    end  
  return arr
end