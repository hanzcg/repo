CREATE PROCEDURE usp_Encriptar(@texto varchar(20), @clave varchar(50) output)

with encryption

AS

-- Una cadena de texto cualquiera que sirve para cambiar el valor ingresado
declare @key varchar(50) 

-- Contadores para las repeticiones
declare @i integer, @j integer 

-- Apoyo para conversiones
declare @aux integer 

-- Valor Ascii de cada caracter que se extrae del dato ingresado
declare @vAsc integer 

-- Apoyo para extraer caracteres de la cadena
declare @posIni integer

-- Contendra el valor binario de cada caracter del texto enviado
declare @chrBin varchar(8) 

-- Auxiliar para crear la cadena encriptada
declare @chrAux varchar(8) 

-- Contendra la cadena binaria completa del texto enviado
declare @strBin varchar(320) 

-- La cadena binaria pero invertida por cada caracter
declare @strInv varchar(320) 

-- Para armar el byte de la cadena encriptada (1 caracter = 1 byte = 8 bits)
declare @ci1 char(8), @ci2 char(8) 

set @key = 'ColoqueAquiSuPropiaClave'

--1. Convertir el texto enviado en una cadena de binarios
set @i = 1
set @vAsc = 0
set @strBin = ''

while @i &lt;= len(ltrim(rtrim(@texto)))
begin
set @chrBin = ''
set @vAsc = ascii(substring(ltrim(rtrim(@texto)), @i, 1))

while @vAsc &gt;= 2
begin
set @chrBin = ltrim(rtrim(str(@vAsc % 2))) + ltrim(rtrim(@chrBin))
set @vAsc = @vAsc / 2
end

set @chrBin = ltrim(rtrim(str(@vAsc))) + ltrim(rtrim(@chrBin))

while len(ltrim(rtrim(@chrBin))) &lt; 8
set @chrBin = '0' + ltrim(rtrim(@chrBin))

set @strBin = ltrim(rtrim(@strBin)) + ltrim(rtrim(@chrBin))
set @i = @i + 1
end

--2. Invertir la cadena binaria por cada caracter
set @i = 1
set @posIni = 1
set @strInv = ''
set @strBin = reverse(ltrim(rtrim(@strBin)))

while @i &lt;= len(ltrim(rtrim(@texto)))
begin
set @chrBin = ''
set @chrBin = substring(ltrim(rtrim(@strBin)), @posIni, 8)
set @chrBin = reverse(ltrim(rtrim(@chrBin)))
set @strInv = ltrim(rtrim(@strInv)) + ltrim(rtrim(@chrBin))

set @posIni = @posIni + 8
set @i = @i + 1
end

--3. Crear la cadena binaria del encriptado
set @i = 1
set @j = 1
set @posIni = 1
set @vAsc = 0
set @strBin = ''

while @i &lt;= len(ltrim(rtrim(@texto)))
begin
set @chrBin = ''
set @chrBin = substring(ltrim(rtrim(@strInv)), @posIni, 8)

set @ci1 = substring(ltrim(rtrim(@chrBin)), 1, 4)
set @ci2 = substring(ltrim(rtrim(@chrBin)), 5, 4)

--Descomponer en ascii la llave (@key)
set @chrAux = ''
set @vAsc = ascii(substring(ltrim(rtrim(@key)), @j, 1))
while @vAsc &gt;= 2
begin
set @chrAux = ltrim(rtrim(str(@vAsc % 2))) + ltrim(rtrim(@chrAux))
set @vAsc = @vAsc / 2
end

set @chrAux = ltrim(rtrim(str(@vAsc))) + ltrim(rtrim(@chrAux))

while len(ltrim(rtrim(@chrAux))) &lt; 8
set @chrAux = '0' + ltrim(rtrim(@chrAux))
--Fin descomponer la llave

set @ci1 = ltrim(rtrim(@ci1)) + substring(ltrim(rtrim(@chrAux)), 1, 4)
set @ci2 = ltrim(rtrim(@ci2)) + substring(ltrim(rtrim(@chrAux)), 5, 4)

set @strBin = ltrim(rtrim(@strBin)) + ltrim(rtrim(@ci1)) + ltrim(rtrim(@ci2))

set @posIni = @posIni + 8
set @i = @i + 1
end

--4. Convertir la cadena binaria en una cadena de caracteres
set @i = 1
set @posIni = 1
set @chrBin = ''
set @strInv = ''
set @strInv = ltrim(rtrim(@strBin))
set @strBin = ''

while @i &lt;= len(ltrim(rtrim(@strInv))) / 8
begin
set @j = 0
set @aux = 1
set @vAsc = 0
set @chrBin = substring(ltrim(rtrim(@strInv)), @posIni, 8)

while @j &lt;= (len(ltrim(rtrim(@chrBin))) - 1)
begin
set @vAsc = @vAsc + (cast(substring(ltrim(rtrim(@chrBin)), len(ltrim(rtrim(@chrBin))) - @j, 1) as int) * @aux)

set @aux = @aux * 2
set @j = @j + 1
end

set @strBin = ltrim(rtrim(@strBin)) + ltrim(rtrim(char(@vAsc)))
set @posIni = @posIni + 8
set @i = @i + 1
end

--5. Generar la cadena de 40 caracteres
set @i = len(ltrim(rtrim(@strBin)))
set @strInv = ''

while @i &lt; 40
begin
set @vAsc = 0
while (@vAsc &lt; 33) or (@vAsc = 39)
set @vAsc = round(rand() * 255,0)

set @strInv = ltrim(rtrim(@strInv)) + ltrim(rtrim(char(@vAsc)))
set @i = @i + 1
end

set @strBin = ltrim(rtrim(@strInv)) + ltrim(rtrim(@strBin))

--6. Agregar los flags de longitud y completar los 50 caracteres
set @aux = len(ltrim(rtrim(@texto)))
if @aux &lt; 10
begin
set @i = 0
set @j = @aux
end
else
begin
set @i = substring(ltrim(rtrim(@aux)), 1, 1)
set @j = substring(ltrim(rtrim(@aux)), 2, 1)
end

set @aux = 1
set @chrBin = ''
set @chrAux = ''

while @aux &lt;= 5
begin
set @vAsc = 0
while (@vAsc &lt; 33) or (@vAsc = 39)
set @vAsc = round(rand() * 255,0)

if @aux = 3
set @chrBin = ltrim(rtrim(@chrBin)) + ltrim(rtrim(str(@i)))
else
set @chrBin = ltrim(rtrim(@chrBin)) + ltrim(rtrim(char(@vAsc)))

set @vAsc = 0
while (@vAsc &lt; 33) or (@vAsc = 39)
set @vAsc = round(rand() * 255,0)

if @aux = 3
set @chrAux = ltrim(rtrim(@chrAux)) + ltrim(rtrim(str(@j)))
else
set @chrAux = ltrim(rtrim(@chrAux)) + ltrim(rtrim(char(@vAsc)))

set @aux = @aux + 1
end

--7. Devolver el resultado
set @clave = ltrim(rtrim(@chrBin)) + ltrim(rtrim(@strBin)) + 
ltrim(rtrim(@chrAux))

return 0

go
