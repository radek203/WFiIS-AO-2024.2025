clear; clc; close all;

im = imread('zubr.jpg');
im = double(im) / 255;
im = rgb2gray(im);

figure;
subplot(2,2,1);
imshow(im);
title('Oryginalne zdjecie');

% sasiedztwo gdzie wspolna krawedz - Von Neuman'a
% sasiedztwo gdzie wspolny wierzcholek - Moore'a
% moze byc stopniowane - np. 2 stopnie to jeszcze tam gdzie wierzcholki
% sasiada
% filtracja - ustawiamy wartosc pixela na podstawie sasiedztwa
% filtry opisujemy w macierzy dajac wagi dla kazdego pixela

k = 3; % wielkosc filtra (dolnoprzepustowy - usredniajacy)
f = ones(k)/(k^2); % macierz 3x3 z 1
fim = imfilter(im, f);
subplot(2,2,2);
imshow(fim); % im wiekszy filtr tym wieksze rozmycie
title('Filtr dolnoprzepustowy k=3');

% filtr gaussowski - rozklad gaussowski w macierzy filtru
% filtry do np. antyaliasingu, pozbycia sie szumu (pojedyncze pixele itd.)

f = -ones(k);
f((k+1)/2,(k+1)/2) = k^2;
fim = imfilter(im, f);
subplot(2,2,3);
imshow(fim); % wyostrzenie pixeli (filtr gornoprzepustowy)
title('Filtr gornoprzepustowy k=3');

f = -ones(k);
f((k+1)/2,(k+1)/2) = k^2 - 1;
fim = imfilter(im, f);
subplot(2,2,4);
imshow(fim); % filtr krawedziowy (suma wag 0)
title('Filtr krawedziowy k=3');

saveas(gcf, 'zdj8.jpg');

k = 5;
fim = medfilt2(im, [k,k]); % filtr medianowy (mediane wstawiamy na srodek)
% zachowuje bardziej ksztalt - i nie tworzy nowych wartosci

figure;
subplot(2,2,1);
imshow(im);
title('Filtr medianowy k=5');

t = .53; % wartosc progowa
bim = fim;
bim(bim >t)=1; % progowanie
bim(bim<=t)=0;

subplot(2,2,2);
imshow(bim); % obraz czarno-bialy
title('Binaryzacja t=.53');
% imhist(fim);

t = graythresh(fim); % wariancje z lewo i prawo - minimalizujemy, a miedzy nimi
% maksymalizujemy, metoda otzu, liczymy automatycznie

bim = imbinarize(fim, t); % binaryzacja, nie trzeba podawac progu, sam sobie wyliczy
subplot(2,2,3);
imshow(bim);
title('Binaryzacja graythresh');

% obiekt powinien byc bialy, tlo czarne (dla jakis algorytmow...)

%bim=1-bim;
bim=~bim; % odwracamy kolory
subplot(2,2,4);
imshow(bim);
title('graythresh (odwrocone kolory)');

saveas(gcf, 'zdj9.jpg');

%bim = imbinarize(fim, 'adaptive'); % adaptacyjna binaryzacja - wedlug otoczenia nie globalnie (tu nie ma sensu)
%figure;
%subplot(2,2,1);
%imshow(bim);

% binarnie moda i mediana to samo

fbim = medfilt2(bim, [3,3]); % filtr medianowy
figure;
subplot(2,2,1);
imshow(fbim);
title('Binaryzacja i Filtr medianowy k=3');

% minimum z pixeli - erozja (zmniejszamy) - zabieramy bialego
% maksimum z pixeli - dylatacja (rozciagamy) - dokladamy do bialego

ebim = imerode(bim, ones(5)); % ones(3) - podajemy sasiadow w macierzy (tutaj 3x3)
subplot(2,2,2);
imshow(ebim);
title('erode - ones(5)');

dbim = imdilate(bim, ones(5));
subplot(2,2,3);
imshow(dbim);
title('dilate - ones(5)');

saveas(gcf, 'zdj10.jpg');

% obiekt -> erozja -> dylatacja  - otwarcie morfologiczne - jak chcemy
% pozbyc sie malego obiektu
% obiekt -> dylatacja -> erozja - zamkniecie morfologiczne - jak chcemy
% pozbyc sie np. kropek

obim = imopen(bim, ones(3));
cbim = imclose(bim, ones(3));
figure;
subplot(2,1,1);
imshow(obim);
title('open - ones(3)');
subplot(2,1,2);
imshow(cbim);
title('close - ones(3)');

saveas(gcf, 'zdj11.jpg');
