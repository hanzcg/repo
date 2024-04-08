ALTER PROCEDURE usp_Desencriptar (@clave varchar(50), @texto varchar(20) output)
with encryption
as
declare @key varchar(50) 
/*Una cadena de texto cualquiera que sirve para 
cambiar el valor ingresado*/

set @key = 'ColoqueAquiSuPropiaClave'

declare @i integer, @j integer -- Contadores para las repeticiones
declare @aux integer -- Apoyo para conversiones
declare @vAsc integer -- Valor Ascii de cada caracter que se extrae del 
dato ingresado
declare @posIni integer -- Apoyo para extraer caracteres de la cadena
declare @chrBin varchar(8) -- Contendra el valor binario de cada caracter 
del texto enviado
declare @strBin varchar(320) -- Contiene la cadena binaria usada
declare @strInv varchar(320) -- La cadena binaria pero invertida por cada 
caracter

--1. Recuperar la cadena encriptada oculta
set @aux = cast(substring(ltrim(rtrim(@clave)), 3, 1) + 
substring(ltrim(rtrim(@clave)), 48, 1) as integer)
set @clave = substring(ltrim(rtrim(@clave)), (len(ltrim(rtrim(@clave))) - 4) 
- (@aux * 2), (@aux * 2))

--2. Convertir la clave en una cadena de binarios
set @i = 1
set @vAsc = 0
set @strBin = ''

while @i <= len(ltrim(rtrim(@clave)))
begin
set @chrBin = ''
set @vAsc = ascii(substring(ltrim(rtrim(@clave)), @i, 1))

while @vAsc >= 2
begin
set @chrBin = ltrim(rtrim(str(@vAsc % 2))) + ltrim(rtrim(@chrBin))
set @vAsc = @vAsc / 2
end

set @chrBin = ltrim(rtrim(str(@vAsc))) + ltrim(rtrim(@chrBin))

while len(ltrim(rtrim(@chrBin))) < 8
set @chrBin = '0' + ltrim(rtrim(@chrBin))

set @strBin = ltrim(rtrim(@strBin)) + ltrim(rtrim(@chrBin))
set @i = @i + 1
end

--3. Retirar los bits sobrantes de cada byte y unir los bits validos para 
formar la cadena original
set @i = 1
set @posIni = 1
set @strInv = ''

while @i <= len(ltrim(rtrim(@clave)))
begin
set @strInv = ltrim(rtrim(@strInv)) + substring(ltrim(rtrim(@strBin)), 
@posIni, 4)

set @posIni = @posIni + 8
set @i = @i + 1
end

--4. Invertir cada byte y luego invertir la cadena completa
set @i = 1
set @posIni = 1
set @strBin = ''

while @i <= len(ltrim(rtrim(@clave)))
begin
set @chrBin = ''
set @chrBin = substring(ltrim(rtrim(@strInv)), @posIni, 8)
set @chrBin = reverse(ltrim(rtrim(@chrBin)))
set @strBin = ltrim(rtrim(@strBin)) + ltrim(rtrim(@chrBin))

set @posIni = @posIni + 8
set @i = @i + 1
end

set @strBin = reverse(ltrim(rtrim(@strBin)))

--5. Convertir la cadena binaria en una cadena de caracteres
set @i = 1
set @posIni = 1
set @chrBin = ''
set @strInv = ''
set @strInv = ltrim(rtrim(@strBin))
set @strBin = ''

while @i <= len(ltrim(rtrim(@strInv))) / 8
begin
set @j = 0
set @aux = 1
set @vAsc = 0
set @chrBin = substring(ltrim(rtrim(@strInv)), @posIni, 8)

while @j <= (len(ltrim(rtrim(@chrBin))) - 1)
begin
set @vAsc = @vAsc + (cast(substring(ltrim(rtrim(@chrBin)), 
len(ltrim(rtrim(@chrBin))) - @j, 1) as int) * @aux)

set @aux = @aux * 2
set @j = @j + 1
end

set @strBin = ltrim(rtrim(@strBin)) + ltrim(rtrim(char(@vAsc)))
set @posIni = @posIni + 8
set @i = @i + 1
end

set @texto = ltrim(rtrim(@strBin))

return 0

go