% Creado por: Luis Nieto Palacios
% UASLP, Área de Ciencias de la Computación
% Para la materia de Visión Computacional
%
% Este archivo define funciones varias.

% Le decimos a Octave que es un archivo de
% scrip, y que contiene varias funciones.
1 ;

% ----------------------------------------------
% Hace una imagen cuadrada agregando columnas o
% filas en 0 (negro) de acuerdo a la mínima dimensión
% 2D para que alcanze la máxima dimensión.
function ret_val = CuadraImagen( imagen )
  [altura,anchura] = size( imagen );
  type = 'reflect' ;
  
  if( altura > anchura )
    col_agregar = ( altura - anchura ) / 2 ;
    % Se agregan a cada lado
    imagen = padarray( imagen, [ 0 col_agregar ] );  
  elseif( anchura > altura )
    row_agregar = ( anchura - altura ) / 2 ;
    imagen = padarray( imagen, [ row_agregar 0 ] ); 
  % Si no entra a ninguno de los dos ya es cuadrada.
  endif
  ret_val = imagen ;

endfunction

% ----------------------------------------------
% Hace una imagen cuadrada agregando columnas o
% filas en 0 (negro) de acuerdo a la mínima dimensión
% 2D para que alcanze la máxima dimensión.
% Hace un padarray hasta que alcanze la dimensión
% especificada
function ret_val = CuadraImagenHasta( imagen, tam )
  imagen = CuadraImagen( imagen );
  tam_imagen = rows( imagen );
  ren = tam - tam_imagen ;
  ren_floor = floor(ren / 2);
  mod_rows = mod( ren, 2 );
  
  type = 'reflect' ;
  
  imagen = padarray( imagen, [ ren_floor, ren_floor ] );
  if( mod_rows == 1 )  
    imagen = padarray( imagen, [1,1], 'pre'); 
  endif
  ret_val = imagen ;

endfunction

% ----------------------------------------------
% Determina si un ojo está en escena comparando
% los valores adyacentes del valor máximo de la
% correlación.
% Toma como parámetros la correlación y las coordenadas
% supuestas de valor máximo.
% Si alrededor del valor máximo existe una gran
% diferencia entre este valor y los adyacentes,
% el ojo se encuentra en la imagen.
function ret_val = DiscriminaOjo( corr, xx, yy, median_val )
  clear('median_vector');
  median_vector = [];
  % Vamos a recorrer siete recuadros de 3x3; estos
  % rodean el recuadro de 3x3 del cual xx,yy es el centro.
  for i = xx-3:3:xx+3
    for j = yy-3:3:yy+3
      try
        median_of_square = double(median( corr( i-1:i+1, j-1:j+1 )(:) ));
        median_vector = [ median_of_square ; median_vector(:) ];
      catch
        % Si no se puede tomar algún recuadro, entonces 
        % inferimos con los que tenemos.
        break ;
      end_try_catch  
    endfor  
  endfor  
  
  % Si la media de todos los cuadrados es suficientemente
  % diferente al máximo valor, se encontró el ojo.
  adjacent_median = double(median( median_vector(:) ));
  ret_val = false ;
  cp = corr(xx,yy) + adjacent_median ;
  if( cp > median_val ) 
    ret_val = true ;
  endif  
endfunction

% ----------------------------------------------
% Muestra los valores del máximo valor y muestra la
% imagen donde se encontraron.
function MuestraFrame( marcos, num_frame )
  marcos( num_frame ).y
  marcos( num_frame ).x
  imshow( marcos( num_frame ).frame );
endfunction

% ------------------------------------------------
% Encuentra el promedio de la escala de grises del
% video.
function ret_val = FramesConMediaDeBlancos( nom_video )
  clear('marcos');
  video_info = aviinfo( nom_video );
  for j = 1:video_info.NumFrames
    try
      marco = rgb2gray( aviread( nom_video, j ));
      marcos(j).media = mean( marco(:) );
      marcos(j).num_marco = j ;
    catch
      % A veces no quiere leer el último marco, aunque
      % se encuentre dentro del rango.
      'EJECUCI_N COMPLETADA, PERO: El _ltimo marco no se pudo conseguir.'
      break ;
    end_try_catch
  endfor
  ret_val = marcos ;
endfunction

% ---------------------------------------------------
% Discrimina los marcos basandose en la media de su
% escala de grises,
% para que solo tomemos el inicio
% de cuando la pupila se empieza a dilatar.
function ret_val = FramesConLuz( nom_video, video )
  clear('frames');
  m = 0 ;
  for i = 1:size( video.frames, 2)
    media_marco = video.frames(i).media ;
    if( media_marco > video.media_video )
      ++m ;
      marco = double( rgb2gray( aviread( nom_video, i )));
      frames(m).imagen = marco ./ max( marco(:));
      frames(m).num_marco = i ;
    endif
  endfor
  ret_val = frames ;
endfunction
