% Creado por: Luis Nieto Palacios
% UASLP, Área de Ciencias de la Computación
% Para la materia de Visión Computacional
% ------------------------------------------
% Este script es el main().

% *********************************************
% En esta sección el usuario puede configurar
% los valores para que se utilizen sus videos.
% ***
% Nombre de los videos
carac_videos = 'ParadoLibre';
ruta_videos = ['videos/' carac_videos '/'];
prefijo_videos = 'pl (';
sufijo_videos = ').avi';
i = 3 ;

% Por ejemplo, esta configuración:
% 
% carac_videos = 'AcostadoLibre';
% ruta_videos = ['videos/' carac_videos '/'];
% prefijo_videos = 'al (';
% sufijo_videos = ').avi';
% i = 15 ;
% 
% busca los videos en:
%
% videos/AcostadoLibre/al (i).avi
%
% y donde i es la variable para indexar
% el video.
 
% ***
% Filtro a usar.
filtro_ojo = double( imread( ['imagenes/' carac_videos '/filtro.jpg'] ));


% Esta configuración:
%
% filtro_ojo = double( imread( ['imagenes/' 
%                       carac_videos '/filtro.jpg'] ));
%
% busca un filtro en:
% imagenes/AcostadoLibre/filtro.jpg

% ***
% Ruta de las imágenes a guardar
% IMPORTANTE: ya debe de existir el directorio.
ruta_img = ['imagenes/' carac_videos '/video ('];

% Esta configuración:
%
% ruta_img = ['imagenes/' carac_videos '/video ('];
%
% guarda las imágenes resultantes en:
%
% imagenes/AcostadoLibre/video (i)
%
% *********************************************

% Cargamos paquetes
pkg load image
pkg load video

% Decimos donde están funciones varias.
funciones_p ;

% Normalizamos el filtro.
filtro_ojo = filtro_ojo ./ max( filtro_ojo(:) );
filtro = filtro_ojo ;

% Donde guardamos las medias
clear('media_videos');

% Cuantos marcos saltarse
offset = 10 ;

clear('video');
% Por cada video sacamos el promedio de la escala de grises,
% y descartamos los marcos que no estén por encima del promedio.
% clear('videos');
nom_video = [ruta_videos prefijo_videos mat2str(i) sufijo_videos]
['Inicio marcos con luz, video(' mat2str(i) ")"]
video.frames = FramesConMediaDeBlancos( nom_video );
% Calculamos la media de la media de cada marco.
video.media_video = mean( [video.frames.media] );
video.frames_con_luz = FramesConLuz( nom_video, video );
['Obtuvo marcos con luz, video(' mat2str(i) ")"]
['Inicio de procesamiento de marcos, video(' mat2str(i) ")"] 
for j = 1:offset:size(video.frames_con_luz,2)
  % Por cada marco obtenido encontramos la
  % pupila, o cerca de la misma.
  frame = video.frames_con_luz(j).imagen ;
  frame = imadjust( frame );
  %figure, imshow( frame );
  %figure, imshow( filtro );
  ['Inicio corr de frame(' mat2str(j) ') del video(' mat2str(i) ")"]  
  cc = normxcorr2( filtro, frame );
  ['Fin corr de frame(' mat2str(j) ') del video(' mat2str(i) ")"] 
  %figure, imshow( cc );
  [max_c, imax] = max(abs(cc(:)));
  [ypeak, xpeak] = ind2sub(size(cc),imax(1));

  % yy y xx son las coordenadas del objeto.  
  xx = (xpeak * 100) / size( cc, 2 );
  yy = (ypeak * 100) / size( cc, 1 ); 

  xx = floor( size( frame, 2 ) * ( xx / 100 ) );
  yy = floor( size( frame, 1 ) * ( yy / 100 ) );
  
  % Anchura de la banda a tomar
  anchura = 50 ;
  % Medias para econtrar el borde
  media_limite = 0.35 ;
  % Nos movemos hasta encontrar los bordes del ojo.
  media_left = 0.0 ;
  media_right = 0.0 ;
  offset_left = 0 ;
  offset_right = 0 ;
  left_border = false ;
  right_border = false ;
  right_limit = size( frame, 2 );
  while( !(left_border && right_border)  )
    if( (xx - offset_left) == 1 || (xx + offset_right) == right_limit - 1 )
      break ;
    endif  
    media_left = mean( frame(yy-anchura:yy+anchura,xx - offset_left) );
    media_right = mean( frame(yy-anchura:yy+anchura,xx + offset_right) );
    if( media_left > media_limite )
      left_border = true ;
    else
       ++offset_left ;
    endif
    if( media_right > media_limite )
      right_border = true ;
    else
      ++offset_right ;
    endif
  endwhile
  
  % Este es la que da las coordenadas correctas.
  frame([yy-18:yy+18],[xx-18:xx+18]) = 0 ;
  frame([yy-12:yy+12],[xx-12:xx+12]) = 1 ;
  frame([yy-3:yy+3],[xx-3:xx+3]) = 0 ;
  
  imwrite( frame, [ruta_img mat2str(i) ')/frame' mat2str(j) '.jpg']);
  imwrite( cc, [ruta_img mat2str(i) ')/cc' mat2str(j) '.jpg']);
  imwrite( frame(yy-anchura:yy+anchura,xx-offset_left:xx+offset_right),
             [ruta_img mat2str(i) ')/franja' mat2str(j) '.jpg']);
  
  ['Frame(' mat2str(j) ') del video(' mat2str(i) ') procesada']
  
  video.franja_prom(j) = mean( mean( frame(yy-anchura:yy+anchura,xx-offset_left:xx+offset_right ) ) );
endfor  
media_videos(i).franja = video.franja_prom ;
% Hacemos la gráfica
media_blancos = media_videos(i).franja ;
ultimo_marco = size( media_blancos, 2 );
% Valores mínimos y máximos de la escala de grises.
max_val = max(media_blancos(1:offset:ultimo_marco));
min_val = min(media_blancos(1:offset:ultimo_marco));
% Porcentaje de cambio.
per = 100 - (min_val / max_val * 100);
% Plot
figure, plot( [1:offset:ultimo_marco],
                      [media_blancos(1:offset:ultimo_marco)],
                         'color', 'b');
xlabel('num. de marco');
ylabel('media de grises');
title([ carac_videos '- video(' mat2str(i) ') : Porcentaje de cambio:' sprintf("%.2f",per) '%']);
ax = axis();
hold on ;
% Agregamos lineas para cada marco
for j = 1:offset:ultimo_marco
  plot( [j j],[ax(3) ax(4)], 'color', 'red');
  hold on ;
endfor

hold off ;
['Fin video(' mat2str(i) ")"]
